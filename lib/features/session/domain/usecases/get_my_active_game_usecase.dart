import '../entities/user_game_status_entity.dart';
import '../repositories/session_repository.dart';

/// 참여 중인 게임 정보 조회 유스케이스
///
/// 앱 재접속 시 사용자가 대기실 또는 게임에 참여 중인지 확인하여
/// 적절한 화면으로 자동 복귀하는 데 사용됩니다.
///
/// ```dart
/// final status = await ref.read(getMyActiveGameUsecaseProvider).execute();
/// if (status.isParticipating) {
///   // participationInfo로 화면 분기
/// }
/// ```
class GetMyActiveGameUsecase {
  final SessionRepository _repository;

  GetMyActiveGameUsecase({required SessionRepository repository})
    : _repository = repository;

  /// 참여 중인 게임 상태를 반환합니다.
  ///
  /// Throws:
  /// - [AuthException]: 인증 실패
  /// - [ServerException]: 서버 오류
  Future<UserGameStatusEntity> execute() => _repository.getMyActiveGame();
}
