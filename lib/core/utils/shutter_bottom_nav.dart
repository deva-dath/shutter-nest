import 'package:flutter/material.dart';
import 'package:shutter_nest/app/appcolors.dart';
import 'package:shutter_nest/core/utils/adaptive_glass.dart';

/// Tab definition for [ShutterBottomNav].
class ShutterNavItem {
  const ShutterNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;
}

/// Theme-aligned bottom navigation bar for ShutterNest.
/// Uses app brand green for selection and follows light/dark theme.
class ShutterBottomNav extends StatelessWidget {
  const ShutterBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ShutterNavItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor = isDark ? AppColors.brandGreenLight : AppColors.brandGreen;
    final unselectedColor = theme.colorScheme.onSurface.withValues(alpha: 0.7);

    return AdaptiveGlass.navBar(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) {
                final item = items[index];
                final isSelected = index == currentIndex;
                final icon = isSelected && item.activeIcon != null
                    ? item.activeIcon!
                    : item.icon;
                return Expanded(
                  child: Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      onTap: () => onTap(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              size: 24,
                              color: isSelected
                                  ? selectedColor
                                  : unselectedColor,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isSelected
                                    ? selectedColor
                                    : unselectedColor,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
