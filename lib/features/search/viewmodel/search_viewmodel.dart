import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/features/home/models/unsplash_photo_model.dart';
import 'package:shutter_nest/features/search/repository/search_repository.dart';
import 'package:shutter_nest/features/search/repository/search_repository_provider.dart';

/// State for search: query, results, loading, error, pagination.
class SearchState {
  const SearchState({
    this.query = '',
    this.photos = const [],
    this.total = 0,
    this.totalPages = 0,
    this.currentPage = 0,
    this.isLoading = false,
    this.error,
  });

  final String query;
  final List<UnsplashPhoto> photos;
  final int total;
  final int totalPages;
  final int currentPage;
  final bool isLoading;
  final String? error;

  bool get hasMore => currentPage < totalPages && totalPages > 0;

  SearchState copyWith({
    String? query,
    List<UnsplashPhoto>? photos,
    int? total,
    int? totalPages,
    int? currentPage,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
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

  /// Search with a new query (resets results).
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(
        query: '',
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
        error: response.message ?? response.errors?.join(', ') ?? 'Search failed',
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

  /// Load next page (append to results).
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.query.isEmpty) return;
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
        error: response.message ?? 'Load more failed',
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
