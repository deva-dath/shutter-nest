import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shutter_nest/core/widgets/like_heart_icon.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';

/// Tile for a liked photo: image, heart (red), tap heart to unlike.
class LikedPhotoTile extends StatelessWidget {
  const LikedPhotoTile({
    super.key,
    required this.photo,
    required this.height,
    required this.onUnlike,
  });

  final UnsplashPhoto photo;
  final double height;
  final VoidCallback onUnlike;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: photo.urls.small,
              fit: BoxFit.cover,
              placeholder: (_, __) => _Placeholder(height: height),
              errorWidget: (_, __, ___) => _ErrorPlaceholder(height: height),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: LikeHeartIcon(
                isLiked: true,
                onTap: onUnlike,
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
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
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

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.height});

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
