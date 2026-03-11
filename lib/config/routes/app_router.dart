import 'package:go_router/go_router.dart';
import 'package:shutter_nest/app/constants/route_constants.dart';
import 'package:shutter_nest/core/utils/shutter_nav_shell.dart';
import 'package:shutter_nest/features/downloaded/view/downloaded_screen.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';
import 'package:shutter_nest/features/home/view/home_screen.dart';
import 'package:shutter_nest/features/liked/view/liked_screen.dart';
import 'package:shutter_nest/features/photo_detail/view/photo_detail_screen.dart';
import 'package:shutter_nest/features/search/view/search_screen.dart';
import 'package:shutter_nest/features/settings/view/settings_screen.dart';
import 'package:shutter_nest/features/splash/view/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouterName.splash.path,
    routes: [
      GoRoute(
        path: RouterName.splash.path,
        name: RouterName.splash.name,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouterName.photoDetail.path,
        name: RouterName.photoDetail.name,
        builder: (context, state) {
          final photo = state.extra! as UnsplashPhoto;
          return PhotoDetailScreen(photo: photo);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShutterNavShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterName.home.path,
                name: RouterName.home.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomePage()),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterName.search.path,
                name: RouterName.search.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SearchPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterName.liked.path,
                name: RouterName.liked.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: LikedPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterName.downloaded.path,
                name: RouterName.downloaded.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DownloadedPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterName.settings.path,
                name: RouterName.settings.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsPage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
