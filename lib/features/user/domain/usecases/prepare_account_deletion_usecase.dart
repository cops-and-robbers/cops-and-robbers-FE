import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../session/domain/repositories/session_repository.dart';

/// 회원 탈퇴 준비 UseCase
///
/// Apple 로그인 계정의 토큰을 탈퇴 API 호출 전에 철회합니다.
/// 그 외 계정은 아무 일도 하지 않습니다.
///
/// **주의**: 철회한 뒤 탈퇴가 409로 막히면 Apple 연결만 끊기고 계정이 남습니다.
/// 그래서 참여 중인 게임을 철회 전에 확인합니다.
class PrepareAccountDeletionUseCase {
  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;

  PrepareAccountDeletionUseCase({
    required AuthRepository authRepository,
    required SessionRepository sessionRepository,
  }) : _authRepository = authRepository,
       _sessionRepository = sessionRepository;

  /// Throws:
  /// - [ServerException]: 참여 중인 게임이 있거나 게임 조회에 실패한 경우
  /// - [AuthCancelledException]: Apple 인증을 취소한 경우
  /// - [AuthException]: Apple 토큰 철회에 실패한 경우
  Future<void> execute() async {
    if (!_authRepository.isAppleAccount) return;

    final status = await _sessionRepository.getMyActiveGame();
    if (status.isParticipating) {
      // 서버가 409로 거절할 때와 같은 문구가 나가도록 같은 코드로 던진다
      throw const ServerException(
        message: 'conflict',
        messageKey: 'errorTemporaryRetry',
        code: 'CANNOT_WITHDRAW',
      );
    }

    await _authRepository.revokeAppleToken();
  }
}
