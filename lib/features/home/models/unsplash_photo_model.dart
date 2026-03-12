import 'package:shutter_nest/app/app_strings.dart';
import 'package:shutter_nest/app/models/base_response_model.dart';

/// Single Unsplash photo (subset of API fields used in the app).
class UnsplashPhoto {
  const UnsplashPhoto({
    required this.id,
    required this.width,
    required this.height,
    this.description,
    required this.urls,
    this.blurHash,
    this.userName,
  });

  final String id;
  final int width;
  final int height;
  final String? description;
  final UnsplashPhotoUrls urls;
  final String? blurHash;
  final String? userName;

  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) {
    final urlsJson = json['urls'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>?;
    return UnsplashPhoto(
      id: json['id'] as String? ?? '',
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      urls: urlsJson != null
          ? UnsplashPhotoUrls.fromJson(urlsJson)
          : const UnsplashPhotoUrls(regular: '', small: '', thumb: ''),
      blurHash: json['blur_hash'] as String?,
      userName: userJson?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'width': width,
      'height': height,
      'description': description,
      'urls': urls.toJson(),
      'blur_hash': blurHash,
      'user': userName != null ? {'name': userName} : null,
    };
  }

  /// Height for masonry tile based on aspect ratio (e.g. 300 logical px width).
  double computeTileHeight(double logicalWidth) {
    if (height <= 0) return 200;
    return logicalWidth * (height / width);
  }
}

class UnsplashPhotoUrls {
  const UnsplashPhotoUrls({
    required this.regular,
    required this.small,
    required this.thumb,
    this.full,
    this.raw,
  });

  final String regular;
  final String small;
  final String thumb;
  /// Highest quality (max dimensions). Prefer for download without compression.
  final String? full;
  /// Base URL for custom params. Use for download if full is null.
  final String? raw;

  /// Best URL for full-quality download (no compression): full ?? raw ?? regular.
  String get downloadUrl => full ?? raw ?? regular;

  factory UnsplashPhotoUrls.fromJson(Map<String, dynamic> json) {
    return UnsplashPhotoUrls(
      regular: json['regular'] as String? ?? '',
      small: json['small'] as String? ?? '',
      thumb: json['thumb'] as String? ?? '',
      full: json['full'] as String?,
      raw: json['raw'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'regular': regular,
        'small': small,
        'thumb': thumb,
        if (full != null) 'full': full,
        if (raw != null) 'raw': raw,
      };
}

/// Unsplash list photos API response. Extends [BaseResponseModel] with [List<UnsplashPhoto>].
class UnsplashPhotosResponse extends BaseResponseModel<List<UnsplashPhoto>> {
  const UnsplashPhotosResponse({
    required super.success,
    super.message,
    super.data,
    super.errors,
  });

  /// Parse from API response. Unsplash list photos returns a JSON array directly.
  factory UnsplashPhotosResponse.fromJson(dynamic json) {
    if (json is List) {
      final list = json
          .map((e) => UnsplashPhoto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return UnsplashPhotosResponse(success: true, data: list);
    }
    if (json is Map<String, dynamic>) {
      final errors = json['errors'] as List<dynamic>?;
      return UnsplashPhotosResponse(
        success: false,
        message: json['message'] as String?,
        errors: errors?.map((e) => e.toString()).toList(),
      );
    }
    return UnsplashPhotosResponse(success: false, message: AppStrings.errorInvalidResponse);
  }

  List<UnsplashPhoto> get photos => data ?? [];
}
