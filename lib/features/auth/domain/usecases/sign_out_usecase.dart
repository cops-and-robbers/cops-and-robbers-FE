import '../repositories/auth_repository.dart';

/// 로그아웃 UseCase
///
/// 백엔드 로그아웃 + Firebase 로그아웃 + 토큰 삭제를
/// 단일 호출로 수행합니다.
///
/// **로그아웃 흐름**:
/// 1. 백엔드 `/api/auth/logout` 호출 (refreshToken 전달)
/// 2. Firebase 로그아웃 (Google/Apple 세션 정리)
/// 3. SecureStorage에서 JWT 토큰 삭제
class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase({required AuthRepository repository})
    : _repository = repository;

  /// 로그아웃 실행
  ///
  /// Throws: [AuthException]
  Future<void> execute() async {
    await _repository.signOut();
  }
}
