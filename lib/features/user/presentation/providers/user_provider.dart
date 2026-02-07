import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';

part 'user_provider.g.dart';

// ============================================================================
// Data Layer Providers
// ============================================================================

/// UserRemoteDataSource Provider (Retrofit)
@riverpod
UserRemoteDataSource userRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return UserRemoteDataSource(dio);
}

/// UserRepository Provider
@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepositoryImpl(ref.watch(userRemoteDataSourceProvider));
}
