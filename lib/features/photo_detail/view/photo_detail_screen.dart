import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/app/app_strings.dart';
import 'package:shutter_nest/core/providers/downloaded_photos_provider.dart';
import 'package:shutter_nest/core/providers/liked_photos_provider.dart';
import 'package:shutter_nest/core/services/photo_download_service.dart';
import 'package:shutter_nest/core/utils/shutter_app_bar.dart';
import 'package:shutter_nest/core/widgets/like_heart_icon.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';

class PhotoDetailScreen extends ConsumerStatefulWidget {
  const PhotoDetailScreen({super.key, required this.photo});

  final UnsplashPhoto photo;

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isDownloading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onDownload() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    final url = widget.photo.urls.downloadUrl;
    final error = await downloadPhotoToGallery(url);
    if (!mounted) return;
    setState(() => _isDownloading = false);
    if (error == null) {
      ref.read(downloadedPhotosProvider.notifier).add(widget.photo.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.downloadSuccess)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.downloadFailed}: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - appBarHeight - statusBarHeight;

    // Photo starts at center of screen - use half the available height
    final imageHeight = availableHeight / 2;

    final likedAsync = ref.watch(likedPhotosProvider);
    final isLiked =
        likedAsync.value?.any((p) => p.id == widget.photo.id) ?? false;

    return Scaffold(
      appBar: const ShutterAppBar(title: AppStrings.titlePhotos),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // // Spacer to push photo to center initially
          // SliverToBoxAdapter(
          //   child: SizedBox(height: imageHeight),
          // ),
          // Photo section - starts at center, moves up on scroll
          SliverToBoxAdapter(
            child: SizedBox(
              height: imageHeight + 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'photo_${widget.photo.id}',
                    child: CachedNetworkImage(
                      imageUrl: widget.photo.urls.regular,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.photo_outlined,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: LikeHeartIcon(
                      isLiked: isLiked,
                      onTap: () => ref
                          .read(likedPhotosProvider.notifier)
                          .toggle(widget.photo),
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content below photo
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: TextButton(
                      onPressed: _isDownloading ? null : _onDownload,
                      child: _isDownloading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppStrings.buttonDownload),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.photo.description != null &&
                      widget.photo.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        widget.photo.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  if (widget.photo.userName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.photo.userName!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.aspect_ratio,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.photo.width} × ${widget.photo.height}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Extra space for scrolling
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
