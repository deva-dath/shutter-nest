/// Central place for all user-facing and shared strings used in the project.
/// Import this file to keep copy consistent and to support future localization.
abstract final class AppStrings {
  AppStrings._();

  // --- App ---
  static const String appTitle = 'ShutterNest';

  // --- Splash ---
  static const String splashBrandText = 'SHUTTERNEST';
  static const String splashFontFamily = 'Gavister';

  // --- Navigation (bottom nav labels) ---
  static const String navHome = 'Home';
  static const String navSearch = 'Search';
  static const String navLiked = 'Liked';
  static const String navDownloads = 'Downloads';
  static const String navSettings = 'Settings';

  // --- Screen titles (app bar / page headers) ---
  static const String titleHome = 'Home';
  static const String titleSearch = 'Search';
  static const String titleLiked = 'Liked';
  static const String titlePhotos = 'Photos';
  static const String titleDownloadedPhotos = 'Downloaded Photos';
  static const String titleSettings = 'Settings';

  // --- Search ---
  static const String searchHint = 'Search photos...';
  static const String searchEmptyPrompt = 'Enter a keyword to perform Search';
  static const String searchPeoplePrompt = 'Enter a username and search to see their photos';
  static String noResultsFor(String query) => 'No results for "$query"';

  /// Quick-search buttons below the search field. "People" uses GET /users/:username/photos; others use search.
  static const List<String> searchSuggestions = [
    'Nature',
    'Cities',
    'People',
    'Animals',
    'Food',
    'Travel',
    'Minimal',
    'Ocean',
  ];

  /// When "People" chip is tapped we call GET /users/:username/photos with this username.
  static const String peopleChipUsername = 'deva_007';

  // --- Home ---
  static const String homeNoPhotos = 'No photos yet';

  // --- Liked ---
  static const String likedEmpty = 'No liked photos yet';
  static const String likedEmptyHint = 'Like photos from Home to see them here';

  // --- Downloaded ---
  static const String downloadedEmpty = 'No downloaded photos yet';
  static String photosDownloaded(int count) =>
      count == 1 ? '1 photo downloaded' : '$count photos downloaded';

  // --- Settings (theme) ---
  static const String settingsLight = 'Light';
  static const String settingsDark = 'Dark';
  static const String settingsSystem = 'System';

  // --- Buttons ---
  static const String buttonRetry = 'Retry';

  // --- Errors / fallback messages (user-facing or API fallbacks) ---
  static const String errorRequestFailed = 'Request failed';
  static const String errorInvalidResponseBody = 'Invalid response body';
  static const String errorInvalidResponse = 'Invalid response';
  static const String errorSearchFailed = 'Search failed';
  static const String errorLoadMoreFailed = 'Load more failed';
  static const String errorLoadPhotosFailed = 'Failed to load photos';
}
