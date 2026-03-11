import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/app/app_strings.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';
import 'package:shutter_nest/features/home/repository/home_repository.dart';
import 'package:shutter_nest/features/home/repository/home_repository_provider.dart';

/// State for home photos: list, loading, error, pagination.
class HomePhotosState {
  const HomePhotosState({
    this.photos = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  final List<UnsplashPhoto> photos;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final String? error;

  HomePhotosState copyWith({
    List<UnsplashPhoto>? photos,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return HomePhotosState(
      photos: photos ?? this.photos,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// ViewModel for home screen. Calls repository and exposes state.
class HomeViewModel extends Notifier<HomePhotosState> {
  static const int _perPage = 24;

  @override
  HomePhotosState build() => const HomePhotosState();

  HomeRepository get _repo => ref.read(homeRepositoryProvider);

  /// Fetches the first page of photos (or resets and loads page 1).
  Future<void> loadPhotos({int page = 1, int perPage = _perPage}) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _repo.getPhotos(page: page, perPage: perPage);
    if (!response.success) {
      state = state.copyWith(
        isLoading: false,
        error: response.message ?? response.errors?.join(', ') ?? AppStrings.errorLoadPhotosFailed,
      );
      return;
    }
    final photos = response.photos;
    state = state.copyWith(
      photos: photos,
      currentPage: page,
      hasMore: photos.length >= perPage,
      isLoading: false,
      error: null,
    );
  }

  /// Loads the next page and appends to the list.
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);
    final nextPage = state.currentPage + 1;
    final response = await _repo.getPhotos(page: nextPage, perPage: _perPage);
    if (!response.success) {
      state = state.copyWith(
        isLoading: false,
        error: response.message ?? response.errors?.join(', ') ?? AppStrings.errorLoadMoreFailed,
      );
      return;
    }
    final newPhotos = response.photos;
    state = state.copyWith(
      photos: [...state.photos, ...newPhotos],
      currentPage: nextPage,
      hasMore: newPhotos.length >= _perPage,
      isLoading: false,
      error: null,
    );
  }
}

final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomePhotosState>(HomeViewModel.new);
