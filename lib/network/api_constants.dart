/// API keys and base config.
/// Get your Unsplash Access Key from https://unsplash.com/oauth/applications
/// Then either:
/// - Run with: flutter run --dart-define=UNSPLASH_ACCESS_KEY=your_key
/// - Or set [unsplashAccessKey] below for local dev (do not commit real keys).
const String unsplashAccessKey = String.fromEnvironment(
  'UNSPLASH_ACCESS_KEY',
  defaultValue:
      'm-5NSuyrS5JbUkS95dAxSxSc1zVgg7SVmEqJwvrX64c', // Replace with your key for local testing if needed
);
