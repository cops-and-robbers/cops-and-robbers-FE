import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/delete_account_usecase.dart';

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

// ============================================================================
// Domain Layer Providers (UseCases)
// ============================================================================

/// 회원 탈퇴 UseCase Provider
@riverpod
DeleteAccountUseCase deleteAccountUseCase(Ref ref) {
  return DeleteAccountUseCase(repository: ref.watch(userRepositoryProvider));
}
