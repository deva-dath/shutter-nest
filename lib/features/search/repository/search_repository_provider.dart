import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/core/providers/api_service_provider.dart';
import 'package:shutter_nest/features/search/repository/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(ref.watch(apiServiceProvider));
});
