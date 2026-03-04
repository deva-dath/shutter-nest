import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/features/liked/repository/liked_photos_repository.dart';
import 'package:shutter_nest/network/database/liked_photos_database.dart';

final likedPhotosRepositoryProvider = Provider<LikedPhotosRepository>((ref) {
  return LikedPhotosRepository(LikedPhotosDatabase.instance);
});
