import 'package:shutter_nest/features/search/models/search_photos_response.dart';
import 'package:shutter_nest/network/api_service.dart';

/// Repository for search. Calls Unsplash GET /search/photos.
/// See https://unsplash.com/documentation#search-photos
class SearchRepository {
  const SearchRepository(this._api);

  final ApiService _api;

  /// Search photos by [query]. [page] and [perPage] (max 30) for pagination.
  Future<UnsplashSearchResponse> searchPhotos({
    required String query,
    int page = 1,
    int perPage = 20,
    String orderBy = 'relevant',
  }) async {
    if (query.trim().isEmpty) {
      return const UnsplashSearchResponse(
        success: true,
        data: SearchPhotosData(total: 0, totalPages: 0, photos: []),
      );
    }

    final response = await _api.get(
      '/search/photos',
      queryParams: {
        'query': query.trim(),
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (orderBy.isNotEmpty) 'order_by': orderBy,
      },
    );

    if (!response.success) {
      return UnsplashSearchResponse(
        success: false,
        message: response.body.isNotEmpty ? response.body : 'Request failed',
        errors: response.statusCode > 0 ? ['HTTP ${response.statusCode}'] : null,
      );
    }

    final json = response.json;
    if (json == null) {
      return const UnsplashSearchResponse(
        success: false,
        message: 'Invalid response body',
      );
    }

    return UnsplashSearchResponse.fromJson(json);
  }
}
