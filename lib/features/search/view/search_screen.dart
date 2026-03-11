import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shutter_nest/app/app_strings.dart';
import 'package:shutter_nest/app/appcolors.dart';
import 'package:shutter_nest/core/providers/liked_photos_provider.dart';
import 'package:shutter_nest/core/utils/shutter_app_bar.dart';
import 'package:shutter_nest/core/widgets/like_heart_icon.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';
import 'package:shutter_nest/features/search/viewmodel/search_viewmodel.dart';

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

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  static double _heightForPhoto(UnsplashPhoto photo, double crossAxisWidth) {
    final h = photo.computeTileHeight(crossAxisWidth);
    if (h > 0) return h.clamp(160.0, 400.0);
    return _fallbackHeights[photo.id.hashCode.abs() % _fallbackHeights.length];
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final vm = ref.read(searchViewModelProvider.notifier);
    final state = ref.read(searchViewModelProvider);
    if (!state.hasMore || state.isLoading) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 400) {
      vm.loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Runs keyword search (GET /search/photos) with the given query.
  void _submitSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    ref.read(searchViewModelProvider.notifier).search(q);
  }

  /// Handles search field submit: in People mode uses value as username (GET /users/:username/photos), else keyword search.
  void _onSearchSubmitted(String value) {
    final q = value.trim();
    if (q.isEmpty) return;
    final vm = ref.read(searchViewModelProvider.notifier);
    final state = ref.read(searchViewModelProvider);
    if (state.isPeopleMode) {
      vm.loadUserPhotos(q);
    } else {
      vm.search(q);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchViewModelProvider);
    final crossAxisWidth = (MediaQuery.sizeOf(context).width - 12 * 3) / 2;

    return Scaffold(
      appBar: const ShutterAppBar(title: AppStrings.titleSearch),
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                fillColor: AppColors.inputFill,
                hintText: AppStrings.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchViewModelProvider.notifier).search('');
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
              ),
              onSubmitted: _onSearchSubmitted,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: AppStrings.searchSuggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final term = AppStrings.searchSuggestions[index];
                final isPeople = term == 'People';
                final isSelected = isPeople
                    ? state.isPeopleMode
                    : (!state.isPeopleMode && state.query == term);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FilterChip(
                    label: Text(term),
                    selected: isSelected,
                    onSelected: (_) {
                      if (isPeople) {
                        _searchController.clear();
                        ref.read(searchViewModelProvider.notifier).enterPeopleMode();
                      } else {
                        _searchController.text = term;
                        _submitSearch(term);
                      }
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.query.isEmpty && state.userPhotosUsername == null && !state.isPeopleMode
                ? Center(
                    child: Text(
                      AppStrings.searchEmptyPrompt,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : state.isPeopleMode && state.userPhotosUsername == null && !state.isLoading && state.photos.isEmpty && state.error == null
                ? Center(
                    child: Text(
                      AppStrings.searchPeoplePrompt,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : state.isLoading && state.photos.isEmpty
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
                            onPressed: () {
                              final vm = ref.read(searchViewModelProvider.notifier);
                              if (state.userPhotosUsername != null) {
                                vm.loadUserPhotos(state.userPhotosUsername!);
                              } else {
                                _submitSearch(state.query);
                              }
                            },
                            child: const Text(AppStrings.buttonRetry),
                          ),
                        ],
                      ),
                    ),
                  )
                : state.photos.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.noResultsFor(state.effectiveQuery),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childCount:
                              state.photos.length +
                              (state.hasMore && state.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.photos.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final photo = state.photos[index];
                            final height = _heightForPhoto(
                              photo,
                              crossAxisWidth,
                            );
                            final likedAsync = ref.watch(likedPhotosProvider);
                            final isLiked =
                                likedAsync.value?.any(
                                  (p) => p.id == photo.id,
                                ) ??
                                false;
                            return _SearchPhotoTile(
                              photo: photo,
                              height: height,
                              isLiked: isLiked,
                              onLikeTap: () => ref
                                  .read(likedPhotosProvider.notifier)
                                  .toggle(photo),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchPhotoTile extends StatefulWidget {
  const _SearchPhotoTile({
    required this.photo,
    required this.height,
    required this.isLiked,
    required this.onLikeTap,
  });

  final UnsplashPhoto photo;
  final double height;
  final bool isLiked;
  final VoidCallback onLikeTap;

  @override
  State<_SearchPhotoTile> createState() => _SearchPhotoTileState();
}

class _SearchPhotoTileState extends State<_SearchPhotoTile>
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
        tween: Tween(
          begin: 0.0,
          end: 1.35,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 48,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.35,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
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
    final showPop =
        _popController.isAnimating ||
        _popController.status == AnimationStatus.forward;
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
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
              placeholder: (_, __) => Container(
                height: widget.height,
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
              ),
              errorWidget: (_, __, ___) => Container(
                height: widget.height,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.photo_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            if (showPop)
              Center(
                child: ScaleTransition(
                  scale: _popScale,
                  child: const Icon(
                    Icons.favorite,
                    size: 56,
                    color: AppColors.likeActive,
                  ),
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
    );
  }
}
