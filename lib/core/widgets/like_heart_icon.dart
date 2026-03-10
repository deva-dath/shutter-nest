import 'package:flutter/material.dart';
import 'package:shutter_nest/app/appcolors.dart';

/// Heart icon from assets. Red when [isLiked], otherwise white. Tappable [onTap].
class LikeHeartIcon extends StatelessWidget {
  const LikeHeartIcon({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.size = 28,
  });

  final bool isLiked;
  final VoidCallback onTap;
  final double size;

  static const String _assetPath = 'assets/icons/heart.png';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Padding(
          padding: EdgeInsets.all(size * 0.25),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              isLiked ? AppColors.likeActive : AppColors.likeInactive,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              _assetPath,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.favorite,
                size: size,
                color: isLiked ? AppColors.likeActive : AppColors.likeInactive,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
