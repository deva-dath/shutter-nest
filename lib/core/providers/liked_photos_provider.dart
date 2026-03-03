import 'package:flutter_riverpod/flutter_riverpod.dart';

/// IDs of photos the user has liked. Extend with a proper model when you have one.
class LikedPhotosNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void add(String id) {
    if (state.contains(id)) return;
    state = [...state, id];
  }

  void remove(String id) {
    state = state.where((e) => e != id).toList();
  }

  void toggle(String id) {
    if (state.contains(id)) {
      remove(id);
    } else {
      add(id);
    }
  }

  bool isLiked(String id) => state.contains(id);
}

final likedPhotosProvider =
    NotifierProvider<LikedPhotosNotifier, List<String>>(LikedPhotosNotifier.new);
