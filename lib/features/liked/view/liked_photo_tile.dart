import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shutter_nest/app/appcolors.dart';
import 'package:shutter_nest/core/widgets/like_heart_icon.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';

/// Duration for the fade-out when unliking.
const Duration _unlikeFadeDuration = Duration(milliseconds: 280);

/// Tile for a liked photo: image, heart (red). Tap tile to open detail; tap heart to unlike.
class LikedPhotoTile extends StatefulWidget {
  const LikedPhotoTile({
    super.key,
    required this.photo,
    required this.height,
    required this.onUnlike,
    this.onTap,
  });

  final UnsplashPhoto photo;
  final double height;
  final VoidCallback onUnlike;
  final VoidCallback? onTap;

  @override
  State<LikedPhotoTile> createState() => _LikedPhotoTileState();
}

class _LikedPhotoTileState extends State<LikedPhotoTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: _unlikeFadeDuration,
    );
    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onUnlike();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onUnlike() {
    if (_fadeController.isAnimating) return;
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.photo.urls.small,
                fit: BoxFit.cover,
                placeholder: (_, __) => _Placeholder(height: widget.height),
                errorWidget: (_, __, ___) =>
                    _ErrorPlaceholder(height: widget.height),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: LikeHeartIcon(
                  isLiked: true,
                  onTap: _onUnlike,
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
