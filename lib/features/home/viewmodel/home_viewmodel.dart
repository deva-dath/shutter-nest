import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';
import 'package:shutter_nest/features/home/repository/home_repository.dart';
import 'package:shutter_nest/features/home/repository/home_repository_provider.dart';

/// State for home photos: list, loading, error.
class HomePhotosState {
  const HomePhotosState({
    this.photos = const [],
    this.isLoading = false,
    this.error,
  });

  final List<UnsplashPhoto> photos;
  final bool isLoading;
  final String? error;

  HomePhotosState copyWith({
    List<UnsplashPhoto>? photos,
    bool? isLoading,
    String? error,
  }) {
    return HomePhotosState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// ViewModel for home screen. Calls repository and exposes state.
class HomeViewModel extends Notifier<HomePhotosState> {
  @override
  HomePhotosState build() => const HomePhotosState();

  HomeRepository get _repo => ref.read(homeRepositoryProvider);

  /// Fetches photos from Unsplash and updates state. Call from the view (e.g. on load).
  Future<void> loadPhotos({int page = 1, int perPage = 20}) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _repo.getPhotos(page: page, perPage: perPage);
    if (!response.success) {
      state = state.copyWith(
        isLoading: false,
        error: response.message ?? response.errors?.join(', ') ?? 'Failed to load photos',
      );
      return;
    }
    state = state.copyWith(
      photos: response.photos,
      isLoading: false,
      error: null,
    );
  }
}

final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomePhotosState>(HomeViewModel.new);
