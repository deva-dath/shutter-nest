import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/core/providers/nav_items_provider.dart';
import 'package:shutter_nest/core/utils/shutter_bottom_nav.dart';

/// Shell that shows [ShutterBottomNav] and the selected tab's content.
class ShutterNavShell extends ConsumerWidget {
  const ShutterNavShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    if (index != navigationShell.currentIndex) {
      navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navItems = ref.watch(shutterNavItemsProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ShutterBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        items: navItems,
      ),
    );
  }
}
