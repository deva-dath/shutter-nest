import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shutter_nest/config/routes/app_router.dart';

/// Provides the app [GoRouter] for navigation from anywhere via [ref].
final goRouterProvider = Provider<GoRouter>((ref) => AppRouter.router);
