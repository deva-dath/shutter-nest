import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';
import 'package:shutter_nest/network/database/liked_photos_database.dart';

/// Repository for liked photos. Persists to SQLite via [LikedPhotosDatabase].
class LikedPhotosRepository {
  LikedPhotosRepository(this._db);

  final LikedPhotosDatabase _db;

  Future<List<UnsplashPhoto>> getAll() => _db.getAllPhotos();

  Future<void> add(UnsplashPhoto photo) => _db.insertPhoto(photo);

  Future<void> remove(String id) => _db.removePhoto(id);

  Future<bool> isLiked(String id) => _db.isLiked(id);
}
