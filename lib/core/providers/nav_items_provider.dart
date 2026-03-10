import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/app/app_strings.dart';
import 'package:shutter_nest/core/utils/shutter_bottom_nav.dart';

/// Bottom navigation items for [ShutterBottomNav]. Single source of truth.
final shutterNavItemsProvider = Provider<List<ShutterNavItem>>((ref) {
  return const [
    ShutterNavItem(
      label: AppStrings.navHome,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    ShutterNavItem(
      label: AppStrings.navSearch,
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
    ),
    ShutterNavItem(
      label: AppStrings.navLiked,
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
    ),
    ShutterNavItem(
      label: AppStrings.navDownloads,
      icon: Icons.download_outlined,
      activeIcon: Icons.download,
    ),
    ShutterNavItem(
      label: AppStrings.navSettings,
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
  ];
});
