import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/session_remote_datasource.dart';
import '../../data/repositories/session_repository_impl.dart';
import '../../domain/entities/create_session_result.dart';
import '../../domain/repositories/session_repository.dart';

part 'session_provider.g.dart';

// ============================================================================
// Data Layer Providers
// ============================================================================

/// SessionRemoteDataSource Provider (Retrofit)
@riverpod
SessionRemoteDataSource sessionRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return SessionRemoteDataSource(dio);
}

// ============================================================================
// Domain Layer Providers
// ============================================================================

/// SessionRepository Provider
@riverpod
SessionRepository sessionRepository(Ref ref) {
  return SessionRepositoryImpl(ref.watch(sessionRemoteDataSourceProvider));
}

// ============================================================================
// Presentation Layer Providers
// ============================================================================

/// 세션 생성 상태 관리 Notifier
///
/// 게임 방 생성 API 호출 및 결과 상태를 관리합니다.
/// `AsyncValue<CreateSessionResult?>` 상태를 통해 로딩/성공/에러를 표현합니다.
@riverpod
class SessionCreationNotifier extends _$SessionCreationNotifier {
  @override
  FutureOr<CreateSessionResult?> build() => null;

  /// 게임 방 생성 API 호출
  ///
  /// 성공 시 state에 [CreateSessionResult]가 저장됩니다.
  /// 실패 시 state에 에러가 저장되며, Presentation에서 처리합니다.
  Future<void> createGame({
    required double playgroundLatitude,
    required double playgroundLongitude,
    required int playgroundRadiusInMeters,
    required double jailLatitude,
    required double jailLongitude,
    required int jailRadiusInMeters,
    required int roundDurationMinutes,
    required int locationRevealIntervalMinutes,
    required int policeWaitMinutes,
    required int maxParticipants,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref
          .read(sessionRepositoryProvider)
          .createGame(
            playgroundLatitude: playgroundLatitude,
            playgroundLongitude: playgroundLongitude,
            playgroundRadiusInMeters: playgroundRadiusInMeters,
            jailLatitude: jailLatitude,
            jailLongitude: jailLongitude,
            jailRadiusInMeters: jailRadiusInMeters,
            roundDurationMinutes: roundDurationMinutes,
            locationRevealIntervalMinutes: locationRevealIntervalMinutes,
            policeWaitMinutes: policeWaitMinutes,
            maxParticipants: maxParticipants,
          );
    });
  }
}
