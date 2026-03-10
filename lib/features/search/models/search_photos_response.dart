import 'package:shutter_nest/app/app_strings.dart';
import 'package:shutter_nest/app/models/base_response_model.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';

/// Data payload for [UnsplashSearchResponse] (total, totalPages, photos).
class SearchPhotosData {
  const SearchPhotosData({
    required this.total,
    required this.totalPages,
    required this.photos,
  });

  final int total;
  final int totalPages;
  final List<UnsplashPhoto> photos;
}

/// Response for GET /search/photos. Extends [BaseResponseModel] per Unsplash API.
/// See https://unsplash.com/documentation#search-photos
class UnsplashSearchResponse extends BaseResponseModel<SearchPhotosData> {
  const UnsplashSearchResponse({
    required super.success,
    super.message,
    super.data,
    super.errors,
  });

  /// Parse from API response: { "total", "total_pages", "results": [...] }.
  factory UnsplashSearchResponse.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const UnsplashSearchResponse(
        success: false,
        message: AppStrings.errorInvalidResponse,
      );
    }
    final errors = json['errors'] as List<dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      return UnsplashSearchResponse(
        success: false,
        message: json['message'] as String?,
        errors: errors.map((e) => e.toString()).toList(),
      );
    }
    final results = json['results'] as List<dynamic>?;
    final total = (json['total'] as num?)?.toInt() ?? 0;
    final totalPages = (json['total_pages'] as num?)?.toInt() ?? 0;
    final photos = results
            ?.map((e) => UnsplashPhoto.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];
    return UnsplashSearchResponse(
      success: true,
      data: SearchPhotosData(
        total: total,
        totalPages: totalPages,
        photos: photos,
      ),
    );
  }

  int get total => data?.total ?? 0;
  int get totalPages => data?.totalPages ?? 0;
  List<UnsplashPhoto> get photos => data?.photos ?? [];
}
