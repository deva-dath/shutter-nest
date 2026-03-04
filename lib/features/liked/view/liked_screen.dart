import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shutter_nest/core/utils/shutter_app_bar.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';
import 'package:shutter_nest/features/liked/view/liked_photo_tile.dart';
import 'package:shutter_nest/core/providers/liked_photos_provider.dart';

const List<double> _fallbackHeights = [200, 280, 240, 320, 260, 300];

class LikedPage extends ConsumerWidget {
  const LikedPage({super.key});

  static double _heightForPhoto(UnsplashPhoto photo, double crossAxisWidth) {
    final h = photo.computeTileHeight(crossAxisWidth);
    if (h > 0) return h.clamp(160.0, 400.0);
    return _fallbackHeights[photo.id.hashCode.abs() % _fallbackHeights.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedAsync = ref.watch(likedPhotosProvider);
    final crossAxisWidth = (MediaQuery.sizeOf(context).width - 12 * 3) / 2;

    return Scaffold(
      appBar: const ShutterAppBar(title: 'Liked'),
      body: likedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(likedPhotosProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (List<UnsplashPhoto> photos) {
          if (photos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No liked photos yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Like photos from Home to see them here',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    final height = _heightForPhoto(photo, crossAxisWidth);
                    return LikedPhotoTile(
                      photo: photo,
                      height: height,
                      onUnlike: () => ref.read(likedPhotosProvider.notifier).remove(photo.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
