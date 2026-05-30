import '../entities/create_session_result.dart';
import '../entities/game_join_result.dart';
import '../entities/user_game_status_entity.dart';

/// Session Repository 인터페이스
///
/// 게임 방 생성 및 관리 관련 도메인 계약을 정의합니다.
abstract class SessionRepository {
  /// 게임 방 생성
  ///
  /// 서버에 게임 방 생성을 요청하고, 결과를 반환합니다.
  /// 성공 시 gameId, inviteCode, status가 포함된 [CreateSessionResult]를 반환합니다.
  ///
  /// Throws:
  /// - [ValidationException]: 유효성 검증 실패 (400)
  /// - [AuthException]: 인증 실패 (401)
  /// - [ServerException]: 이미 활성 게임 참여 중 (409) 또는 서버 오류
  Future<CreateSessionResult> createGame({
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
  });

  /// 초대 코드로 게임 방 참여
  ///
  /// 성공 시 [GameJoinResult]를 반환합니다.
  ///
  /// Throws:
  /// - [ValidationException]: 초대 코드 누락 또는 유효하지 않음 (400)
  /// - [AuthException]: 인증 실패 (401)
  /// - [ServerException]: 이미 다른 활성 게임 참여 중 (409) 또는 서버 오류
  Future<GameJoinResult> joinGameByInvite({required String inviteCode});

  /// 참여 중인 게임 정보 조회
  ///
  /// Throws:
  /// - [AuthException]: 인증 실패 (401)
  /// - [ServerException]: 서버 오류
  Future<UserGameStatusEntity> getMyActiveGame();
}
