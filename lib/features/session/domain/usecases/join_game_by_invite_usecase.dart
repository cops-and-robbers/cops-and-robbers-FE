import '../entities/game_join_result.dart';
import '../repositories/session_repository.dart';

/// 초대 코드로 게임 방 참여 유스케이스
///
/// 딥링크 또는 수동 입력으로 받은 초대 코드를 백엔드에 전달하여
/// 해당 게임에 참여하고 [GameJoinResult]를 반환합니다.
///
/// ```dart
/// final result = await ref.read(joinGameByInviteUsecaseProvider).execute('ABC123');
/// // result.gameId, result.participantId 로 로비 진입
/// ```
class JoinGameByInviteUseCase {
  final SessionRepository _repository;

  JoinGameByInviteUseCase({required SessionRepository repository})
    : _repository = repository;

  /// 초대 코드로 게임 방에 참여합니다.
  ///
  /// Throws:
  /// - [ValidationException]: 초대 코드 누락 또는 유효하지 않음 (400)
  /// - [AuthException]: 인증 실패 (401)
  /// - [ServerException]: 이미 다른 활성 게임 참여 중 (409) 또는 서버 오류
  Future<GameJoinResult> execute(String inviteCode) {
    return _repository.joinGameByInvite(inviteCode: inviteCode);
  }
}
