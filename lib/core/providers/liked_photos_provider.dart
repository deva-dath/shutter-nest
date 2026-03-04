import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';
import 'package:shutter_nest/features/liked/repository/liked_photos_repository.dart';
import 'package:shutter_nest/features/liked/repository/liked_photos_repository_provider.dart';

/// Loads liked photos from DB and exposes add/remove/toggle. State is [AsyncValue]<[List]<[UnsplashPhoto]>>.
class LikedPhotosNotifier extends AsyncNotifier<List<UnsplashPhoto>> {
  LikedPhotosRepository get _repo => ref.read(likedPhotosRepositoryProvider);

  @override
  Future<List<UnsplashPhoto>> build() async {
    return _repo.getAll();
  }

  Future<void> add(UnsplashPhoto photo) async {
    await _repo.add(photo);
    state = AsyncValue.data([...(state.value ?? []), photo]);
  }

  Future<void> remove(String id) async {
    await _repo.remove(id);
    state = AsyncValue.data((state.value ?? []).where((p) => p.id != id).toList());
  }

  Future<void> toggle(UnsplashPhoto photo) async {
    if (isLiked(photo.id)) {
      await remove(photo.id);
    } else {
      await add(photo);
    }
  }

  bool isLiked(String id) => (state.value ?? []).any((p) => p.id == id);
}

final likedPhotosProvider =
    AsyncNotifierProvider<LikedPhotosNotifier, List<UnsplashPhoto>>(
  LikedPhotosNotifier.new,
);
