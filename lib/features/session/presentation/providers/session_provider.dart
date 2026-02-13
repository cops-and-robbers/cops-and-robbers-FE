import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/session_remote_datasource.dart';
import '../../data/models/join_game_request.dart';
import '../../data/models/join_game_response.dart';
import '../../data/models/leave_game_response.dart';
import '../../data/models/ready_request.dart';
import '../../data/models/team_change_request.dart';
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

/// 게임 방 퇴장 기능
///
/// 대기실/게임 화면에서 나갈 때 서버에 퇴장을 알립니다.
@riverpod
Future<LeaveGameResponse?> leaveGame(Ref ref, int gameId) async {
  try {
    final dataSource = ref.read(sessionRemoteDataSourceProvider);
    final response = await dataSource.leaveGame(gameId);
    debugPrint('[Session] ✅ 게임 퇴장 성공: gameId=$gameId, 남은 인원=${response.remainingCount}');
    return response;
  } catch (e) {
    debugPrint('[Session] ❌ 게임 퇴장 실패: $e');
    return null;
  }
}

/// 게임 시작 기능
///
/// 방장이 게임을 시작합니다.
/// 성공 시 true, 실패 시 false를 반환합니다.
@riverpod
Future<bool> startGame(Ref ref, int gameId) async {
  try {
    final dataSource = ref.read(sessionRemoteDataSourceProvider);
    await dataSource.startGame(gameId);
    debugPrint('[Session] ✅ 게임 시작 성공: gameId=$gameId');
    return true;
  } catch (e) {
    debugPrint('[Session] ❌ 게임 시작 실패: $e');
    return false;
  }
}

/// 준비 상태 변경 기능
///
/// 대기실에서 준비 상태를 변경합니다.
/// 성공 시 true, 실패 시 false를 반환합니다.
@riverpod
Future<bool> updateReady(Ref ref, int gameId, {required bool isReady}) async {
  try {
    final dataSource = ref.read(sessionRemoteDataSourceProvider);
    await dataSource.updateReady(gameId, ReadyRequest(isReady: isReady));
    debugPrint('[Session] ✅ 준비 상태 변경 성공: gameId=$gameId, isReady=$isReady');
    return true;
  } catch (e) {
    debugPrint('[Session] ❌ 준비 상태 변경 실패: $e');
    return false;
  }
}

/// 팀 변경 기능
///
/// 대기실에서 팀을 변경합니다.
/// 팀 변경 시 준비 상태가 해제됩니다.
/// 성공 시 true, 실패 시 false를 반환합니다.
@riverpod
Future<bool> changeTeam(Ref ref, int gameId, {required String targetTeam}) async {
  try {
    final dataSource = ref.read(sessionRemoteDataSourceProvider);
    await dataSource.changeTeam(gameId, TeamChangeRequest(targetTeam: targetTeam));
    debugPrint('[Session] ✅ 팀 변경 성공: gameId=$gameId, targetTeam=$targetTeam');
    return true;
  } catch (e) {
    debugPrint('[Session] ❌ 팀 변경 실패: $e');
    return false;
  }
}

/// 게임 방 참여 기능
///
/// 초대 코드를 사용하여 게임 방에 참여합니다.
/// 성공 시 JoinGameResponse, 실패 시 null을 반환합니다.
@riverpod
Future<JoinGameResponse?> joinGame(Ref ref, {required String inviteCode}) async {
  try {
    final dataSource = ref.read(sessionRemoteDataSourceProvider);
    final response = await dataSource.joinGame(JoinGameRequest(inviteCode: inviteCode));
    debugPrint('[Session] ✅ 게임 참여 성공: gameId=${response.gameId}, participantId=${response.participantId}');
    return response;
  } catch (e) {
    debugPrint('[Session] ❌ 게임 참여 실패: $e');
    return null;
  }
}
