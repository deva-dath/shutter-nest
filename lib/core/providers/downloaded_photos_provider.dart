import 'package:flutter_riverpod/flutter_riverpod.dart';

/// IDs of photos the user has downloaded. Extend with a proper model when you have one.
class DownloadedPhotosNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void add(String id) {
    if (state.contains(id)) return;
    state = [...state, id];
  }

  void remove(String id) {
    state = state.where((e) => e != id).toList();
  }

  bool isDownloaded(String id) => state.contains(id);
}

final downloadedPhotosProvider = NotifierProvider<DownloadedPhotosNotifier, List<String>>(
    DownloadedPhotosNotifier.new);
