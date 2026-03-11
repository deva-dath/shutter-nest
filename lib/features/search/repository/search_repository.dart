import 'package:shutter_nest/app/app_strings.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';
import 'package:shutter_nest/features/search/models/search_photos_response.dart';
import 'package:shutter_nest/features/search/models/user_photos_result.dart';
import 'package:shutter_nest/network/api_service.dart';

/// Repository for search. Uses Unsplash Search and Users APIs.
/// See https://unsplash.com/documentation#search-photos and #list-a-users-photos
class SearchRepository {
  const SearchRepository(this._api);

  final ApiService _api;

  /// List a user's photos: GET /users/:username/photos.
  /// See https://unsplash.com/documentation#list-a-users-photos
  Future<UserPhotosResult> getUserPhotos({
    required String username,
    int page = 1,
    int perPage = 20,
    String orderBy = 'latest',
  }) async {
    final path = '/users/${Uri.encodeComponent(username)}/photos';
    final response = await _api.get(
      path,
      queryParams: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (orderBy.isNotEmpty) 'order_by': orderBy,
      },
    );

    if (!response.success) {
      return UserPhotosResult(
        success: false,
        message: response.body.isNotEmpty ? response.body : AppStrings.errorRequestFailed,
        photos: [],
        hasMore: false,
      );
    }

    final json = response.json;
    if (json == null) {
      return const UserPhotosResult(
        success: false,
        message: AppStrings.errorInvalidResponseBody,
        photos: [],
        hasMore: false,
      );
    }

    final parsed = UnsplashPhotosResponse.fromJson(json);
    if (!parsed.success) {
      return UserPhotosResult(
        success: false,
        message: parsed.message ?? AppStrings.errorRequestFailed,
        photos: [],
        hasMore: false,
      );
    }

    final photos = parsed.photos;
    return UserPhotosResult(
      success: true,
      photos: photos,
      hasMore: photos.length >= perPage,
    );
  }

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
        message: response.body.isNotEmpty ? response.body : AppStrings.errorRequestFailed,
        errors: response.statusCode > 0 ? ['HTTP ${response.statusCode}'] : null,
      );
    }

    final json = response.json;
    if (json == null) {
      return const UnsplashSearchResponse(
        success: false,
        message: AppStrings.errorInvalidResponseBody,
      );
    }

    return UnsplashSearchResponse.fromJson(json);
  }
}
