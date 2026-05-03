import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/bug_remote_datasource.dart';
import '../../data/repositories/bug_repository_impl.dart';
import '../../domain/repositories/bug_repository.dart';

part 'bug_provider.g.dart';

// ============================================================================
// Data Layer Providers
// ============================================================================

/// BugRemoteDataSource Provider (Retrofit)
@riverpod
BugRemoteDataSource bugRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return BugRemoteDataSource(dio);
}

// ============================================================================
// Domain Layer Providers
// ============================================================================

/// BugRepository Provider
@riverpod
BugRepository bugRepository(Ref ref) {
  return BugRepositoryImpl(ref.watch(bugRemoteDataSourceProvider));
}
