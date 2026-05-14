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

// ============================================================================
// Game Push Agreement
// ============================================================================

/// 게임 푸시 알림 동의 상태 Provider
///
/// build: GET /api/user/agreements/game-push
/// toggle: PUT /api/user/agreements/game-push (낙관적 업데이트, 실패 시 원복)
@riverpod
class GamePushNotifier extends _$GamePushNotifier {
  @override
  FutureOr<bool> build() {
    return ref.watch(userRepositoryProvider).getGamePushAgreement();
  }

  Future<void> toggle() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final next = !current;
    state = AsyncValue.data(next);
    try {
      await ref
          .read(userRepositoryProvider)
          .updateGamePushAgreement(allowGamePush: next);
    } catch (_) {
      state = AsyncValue.data(current);
      rethrow;
    }
  }
}
