import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/core/providers/api_service_provider.dart';
import 'package:shutter_nest/features/home/repository/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return HomeRepository(api);
});
