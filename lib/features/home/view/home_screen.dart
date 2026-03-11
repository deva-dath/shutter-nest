import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:shutter_nest/app/app_strings.dart';
import 'package:shutter_nest/app/appcolors.dart';
import 'package:shutter_nest/app/constants/route_constants.dart';
import 'package:shutter_nest/core/providers/liked_photos_provider.dart';
import 'package:shutter_nest/core/utils/shutter_app_bar.dart';
import 'package:shutter_nest/core/widgets/like_heart_icon.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';
import 'package:shutter_nest/features/home/viewmodel/home_viewmodel.dart';

/// Varying tile heights for staggered masonry when photo aspect is square or missing.
const List<double> _fallbackHeights = [
  200,
  280,
  240,
  320,
  260,
  300,
  220,
  290,
  270,
  310,
];

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).loadPhotos(perPage: 24);
    });
  }

  void _onScroll() {
    final vm = ref.read(homeViewModelProvider.notifier);
    final state = ref.read(homeViewModelProvider);
    if (!state.hasMore || state.isLoading) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 400) {
      vm.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static double _heightForPhoto(UnsplashPhoto photo, double crossAxisWidth) {
    final h = photo.computeTileHeight(crossAxisWidth);
    if (h > 0) return h.clamp(160.0, 400.0);
    return _fallbackHeights[photo.id.hashCode.abs() % _fallbackHeights.length];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final crossAxisWidth = (MediaQuery.sizeOf(context).width - 12 * 3) / 2;

    return Scaffold(
      appBar: const ShutterAppBar(title: AppStrings.titleHome),
      body: state.isLoading && state.photos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.photos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => ref
                              .read(homeViewModelProvider.notifier)
                              .loadPhotos(perPage: 24),
                          child: const Text(AppStrings.buttonRetry),
                        ),
                      ],
                    ),
                  ),
                )
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      sliver: state.photos.isEmpty
                          ? const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 200,
                                child: Center(child: Text(AppStrings.homeNoPhotos)),
                              ),
                            )
                          : SliverMasonryGrid.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childCount: state.photos.length,
                              itemBuilder: (context, index) {
                                final photo = state.photos[index];
                                final height =
                                    _heightForPhoto(photo, crossAxisWidth);
                                final likedAsync = ref.watch(likedPhotosProvider);
                                final isLiked = likedAsync.value
                                        ?.any((p) => p.id == photo.id) ??
                                    false;
                                return _PhotoTile(
                                  photo: photo,
                                  height: height,
                                  isLiked: isLiked,
                                  onLikeTap: () => ref
                                      .read(likedPhotosProvider.notifier)
                                      .toggle(photo),
                                  onTap: () {
                                    context.push(
                                      RouterName.photoDetail.path.replaceAll(':id', photo.id),
                                      extra: photo,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                    if (state.isLoading && state.photos.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
    );
  }
}

class _PhotoTile extends StatefulWidget {
  const _PhotoTile({
    required this.photo,
    required this.height,
    required this.isLiked,
    required this.onLikeTap,
    this.onTap,
  });

  final UnsplashPhoto photo;
  final double height;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback? onTap;

  @override
  State<_PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<_PhotoTile>
    with SingleTickerProviderStateMixin {
  static const Duration _popDuration = Duration(milliseconds: 550);

  late final AnimationController _popController;
  late final Animation<double> _popScale;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(vsync: this, duration: _popDuration);
    _popScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.35)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 48,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 52,
      ),
    ]).animate(_popController);
    _popController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _popController.reset();
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  void _onLikeTap() {
    widget.onLikeTap();
    if (!widget.isLiked) {
      setState(() {});
      _popController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showPop = _popController.isAnimating || _popController.status == AnimationStatus.forward;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
            CachedNetworkImage(
              imageUrl: widget.photo.urls.small,
              fit: BoxFit.cover,
              placeholder: (_, __) => _PlaceholderTile(height: widget.height),
              errorWidget: (_, __, ___) => _ErrorPlaceholder(height: widget.height),
            ),
            if (showPop)
              Center(
                child: ScaleTransition(
                  scale: _popScale,
                  child: _CenterHeart(size: 56),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: LikeHeartIcon(
                isLiked: widget.isLiked,
                onTap: _onLikeTap,
                size: 28,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.transparent,
                      AppColors.blackOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Red heart used for the center pop animation.
class _CenterHeart extends StatelessWidget {
  const _CenterHeart({this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.favorite, size: size, color: AppColors.likeActive);
  }
}

class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.photo_outlined,
          size: 48,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
