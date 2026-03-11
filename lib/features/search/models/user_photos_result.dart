import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';

/// Result of GET /users/:username/photos (list of photos + hasMore for pagination).
class UserPhotosResult {
  const UserPhotosResult({
    required this.success,
    this.message,
    this.photos = const [],
    this.hasMore = false,
  });

  final bool success;
  final String? message;
  final List<UnsplashPhoto> photos;
  final bool hasMore;
}
