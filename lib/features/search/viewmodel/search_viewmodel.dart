import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/app/app_strings.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';
import 'package:shutter_nest/features/search/repository/search_repository.dart';
import 'package:shutter_nest/features/search/repository/search_repository_provider.dart';

/// State for search: query or user-photos mode, results, loading, error, pagination.
class SearchState {
  const SearchState({
    this.query = '',
    this.isPeopleMode = false,
    this.userPhotosUsername,
    this.userPhotosHasMore = false,
    this.photos = const [],
    this.total = 0,
    this.totalPages = 0,
    this.currentPage = 0,
    this.isLoading = false,
    this.error,
  });

  final String query;
  /// When true, search box submit is treated as username for GET /users/:username/photos.
  final bool isPeopleMode;
  /// When set, results are from GET /users/:username/photos.
  final String? userPhotosUsername;
  final bool userPhotosHasMore;
  final List<UnsplashPhoto> photos;
  final int total;
  final int totalPages;
  final int currentPage;
  final bool isLoading;
  final String? error;

  bool get hasMore =>
      userPhotosUsername != null
          ? userPhotosHasMore
          : (currentPage < totalPages && totalPages > 0);

  /// Display label for the current source (query, username, or "People").
  String get effectiveQuery =>
      userPhotosUsername != null ? userPhotosUsername! : query;

  SearchState copyWith({
    String? query,
    bool? isPeopleMode,
    String? userPhotosUsername,
    bool? userPhotosHasMore,
    List<UnsplashPhoto>? photos,
    int? total,
    int? totalPages,
    int? currentPage,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      isPeopleMode: isPeopleMode ?? this.isPeopleMode,
      userPhotosUsername: userPhotosUsername ?? this.userPhotosUsername,
      userPhotosHasMore: userPhotosHasMore ?? this.userPhotosHasMore,
      photos: photos ?? this.photos,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// ViewModel for Search tab. Calls search API and holds results.
class SearchViewModel extends Notifier<SearchState> {
  SearchRepository get _repo => ref.read(searchRepositoryProvider);

  static const int _perPage = 24;

  @override
  SearchState build() => const SearchState();

  /// Search with a new query (resets results). Uses GET /search/photos.
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(
        query: '',
        isPeopleMode: false,
        userPhotosUsername: null,
        userPhotosHasMore: false,
        photos: [],
        total: 0,
        totalPages: 0,
        currentPage: 0,
        error: null,
      );
      return;
    }
    state = state.copyWith(
      query: query.trim(),
      isPeopleMode: false,
      userPhotosUsername: null,
      userPhotosHasMore: false,
      photos: [],
      total: 0,
      totalPages: 0,
      currentPage: 0,
      isLoading: true,
      error: null,
    );
    final response = await _repo.searchPhotos(
      query: state.query,
      page: 1,
      perPage: _perPage,
    );
    if (!response.success) {
      state = state.copyWith(
        isLoading: false,
        error: response.message ?? response.errors?.join(', ') ?? AppStrings.errorSearchFailed,
      );
      return;
    }
    state = state.copyWith(
      photos: response.photos,
      total: response.total,
      totalPages: response.totalPages,
      currentPage: 1,
      isLoading: false,
      error: null,
    );
  }

  /// Enter "People" mode: next search box submit will fetch that username's photos.
  void enterPeopleMode() {
    state = state.copyWith(
      query: '',
      isPeopleMode: true,
      userPhotosUsername: null,
      userPhotosHasMore: false,
      photos: [],
      total: 0,
      totalPages: 0,
      currentPage: 0,
      error: null,
    );
  }

  /// Load a user's photos. Uses GET /users/:username/photos. Keeps [isPeopleMode] true.
  Future<void> loadUserPhotos(String username) async {
    if (username.trim().isEmpty) return;
    final uname = username.trim();
    state = state.copyWith(
      query: '',
      isPeopleMode: true,
      userPhotosUsername: uname,
      userPhotosHasMore: false,
      photos: [],
      total: 0,
      totalPages: 0,
      currentPage: 0,
      isLoading: true,
      error: null,
    );
    final result = await _repo.getUserPhotos(
      username: uname,
      page: 1,
      perPage: _perPage,
    );
    if (!result.success) {
      state = state.copyWith(
        isLoading: false,
        error: result.message ?? AppStrings.errorSearchFailed,
      );
      return;
    }
    state = state.copyWith(
      photos: result.photos,
      currentPage: 1,
      userPhotosHasMore: result.hasMore,
      isLoading: false,
      error: null,
    );
  }

  /// Load next page (append to results).
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    final username = state.userPhotosUsername;
    if (username != null) {
      state = state.copyWith(isLoading: true, error: null);
      final nextPage = state.currentPage + 1;
      final result = await _repo.getUserPhotos(
        username: username,
        page: nextPage,
        perPage: _perPage,
      );
      if (!result.success) {
        state = state.copyWith(
          isLoading: false,
          error: result.message ?? AppStrings.errorLoadMoreFailed,
        );
        return;
      }
      state = state.copyWith(
        photos: [...state.photos, ...result.photos],
        currentPage: nextPage,
        userPhotosHasMore: result.hasMore,
        isLoading: false,
        error: null,
      );
      return;
    }
    if (state.query.isEmpty) return;
    state = state.copyWith(isLoading: true, error: null);
    final nextPage = state.currentPage + 1;
    final response = await _repo.searchPhotos(
      query: state.query,
      page: nextPage,
      perPage: _perPage,
    );
    if (!response.success) {
      state = state.copyWith(
        isLoading: false,
        error: response.message ?? AppStrings.errorLoadMoreFailed,
      );
      return;
    }
    state = state.copyWith(
      photos: [...state.photos, ...response.photos],
      currentPage: nextPage,
      isLoading: false,
      error: null,
    );
  }
}

final searchViewModelProvider =
    NotifierProvider<SearchViewModel, SearchState>(SearchViewModel.new);
