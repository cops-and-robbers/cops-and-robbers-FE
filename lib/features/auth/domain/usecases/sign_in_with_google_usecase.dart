import '../entities/auth_result_entity.dart';
import '../repositories/auth_repository.dart';

/// Google 소셜 로그인 UseCase
///
/// Firebase Google 로그인 → 백엔드 로그인 → 토큰 저장을
/// 단일 호출로 수행합니다.
///
/// **사용 예시**:
/// ```dart
/// final result = await signInWithGoogleUseCase.execute();
/// if (result.isNewUser) {
///   // 닉네임 설정 페이지로 이동
/// }
/// ```
class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  SignInWithGoogleUseCase({required AuthRepository repository})
    : _repository = repository;

  /// Google 로그인 실행
  ///
  /// Returns: [AuthResultEntity] (userId, nickname, isNewUser)
  /// Throws: [AuthException], [NetworkException]
  Future<AuthResultEntity> execute() async {
    return await _repository.signInWithGoogle();
  }
}
