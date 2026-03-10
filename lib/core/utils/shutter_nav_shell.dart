import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shutter_nest/core/providers/nav_items_provider.dart';
import 'package:shutter_nest/core/utils/shutter_bottom_nav.dart';
import 'package:shutter_nest/features/home/viewmodel/home_viewmodel.dart';

/// Index of the Home tab in the bottom nav.
const int _homeTabIndex = 0;

/// Duration for tab switch animation.
const Duration _tabTransitionDuration = Duration(milliseconds: 220);

/// Shell that shows [ShutterBottomNav] and the selected tab's content with animated transitions.
class ShutterNavShell extends ConsumerStatefulWidget {
  const ShutterNavShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ShutterNavShell> createState() => _ShutterNavShellState();
}

class _ShutterNavShellState extends ConsumerState<ShutterNavShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _tabTransitionDuration,
    );
    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.02),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    final currentIndex = widget.navigationShell.currentIndex;

    if (index == _homeTabIndex) {
      ref.read(homeViewModelProvider.notifier).loadPhotos(perPage: 24);
    }

    if (index == currentIndex) return;

    _controller.forward().then((_) {
      if (!mounted) return;
      widget.navigationShell.goBranch(index);
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navItems = ref.watch(shutterNavItemsProvider);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: child,
            ),
          );
        },
        child: widget.navigationShell,
      ),
      bottomNavigationBar: ShutterBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTap,
        items: navItems,
      ),
    );
  }
}
