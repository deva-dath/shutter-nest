import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/network/api_constants.dart';
import 'package:shutter_nest/network/api_service.dart';

/// Provides [ApiService] configured with Unsplash base URL and Authorization.
/// Set [unsplashAccessKey] in api_constants or via --dart-define=UNSPLASH_ACCESS_KEY=your_key.
final apiServiceProvider = Provider<ApiService>((ref) {
  final api = ApiService();
  api.setHeader('Accept-Version', 'v1');
  if (unsplashAccessKey.isNotEmpty) {
    api.setAuthorization('Client-ID $unsplashAccessKey');
  }
  return api;
});
