/// Represents a single route item with a name and a path.
class RouteItem {
  /// The logical name of the route (used internally or for identification).
  final String name;

  /// The URL path associated with the route.
  final String path;

  /// Constructor requiring both name and path for the route.
  const RouteItem({required this.name, required this.path});
}

/// Holds all the named routes used in the app as static constants.
/// This helps maintain a single source of truth for route names and paths.
class RouterName {
  /// Splash screen shown on app launch.
  static const splash = RouteItem(name: 'splash', path: '/splash');

  /// Home screen of the app.
  static const home = RouteItem(name: 'home', path: '/home');

  /// Photos screen.
  static const photos = RouteItem(name: 'photos', path: '/photos');

  /// Search screen.
  static const search = RouteItem(name: 'search', path: '/search');

  /// Photos liked by the user.
  static const liked = RouteItem(name: 'liked', path: '/liked');

  /// Photos downloaded by the user.
  static const downloaded = RouteItem(name: 'downloaded', path: '/downloaded');

  /// Settings screen.
  static const settings = RouteItem(name: 'settings', path: '/settings');
}
