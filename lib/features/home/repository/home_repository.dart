import 'package:shutter_nest/app/app_strings.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';
import 'package:shutter_nest/network/api_service.dart';

/// Repository for home feature. Fetches photos from Unsplash via [ApiService].
class HomeRepository {
  const HomeRepository(this._api);

  final ApiService _api;

  /// Fetches a list of photos from Unsplash. [page] and [perPage] (max 30) for pagination.
  Future<UnsplashPhotosResponse> getPhotos({int page = 1, int perPage = 20}) async {
    final response = await _api.get(
      '/photos',
      queryParams: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );

    if (!response.success) {
      return UnsplashPhotosResponse(
        success: false,
        message: response.body.isNotEmpty ? response.body : AppStrings.errorRequestFailed,
        errors: response.statusCode > 0 ? ['HTTP ${response.statusCode}'] : null,
      );
    }

    final json = response.json;
    if (json == null) {
      return const UnsplashPhotosResponse(
        success: false,
        message: AppStrings.errorInvalidResponseBody,
      );
    }

    return UnsplashPhotosResponse.fromJson(json);
  }
}
