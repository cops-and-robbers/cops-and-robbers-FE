import '../entities/auth_result_entity.dart';

/// Auth Repository 인터페이스
///
/// Domain Layer에서 정의하며, Data Layer에서 구현합니다.
/// Presentation Layer는 이 인터페이스에만 의존합니다.
///
/// **의존성 흐름**: Presentation → Domain ← Data
abstract class AuthRepository {
  /// 소셜 로그인 (Google)
  ///
  /// 1. Firebase Google 로그인
  /// 2. Firebase ID Token 획득
  /// 3. 백엔드 `/api/auth/login` 호출
  /// 4. JWT 토큰 저장
  ///
  /// Returns: [AuthResultEntity] (userId, nickname, isNewUser)
  Future<AuthResultEntity> signInWithGoogle();

  /// 소셜 로그인 (Apple)
  ///
  /// 1. Firebase Apple 로그인
  /// 2. Firebase ID Token 획득
  /// 3. 백엔드 `/api/auth/login` 호출
  /// 4. JWT 토큰 저장
  ///
  /// Returns: [AuthResultEntity] (userId, nickname, isNewUser)
  Future<AuthResultEntity> signInWithApple();

  /// 로그아웃
  ///
  /// 1. 백엔드 `/api/auth/logout` 호출
  /// 2. Firebase 로그아웃
  /// 3. JWT 토큰 삭제
  Future<void> signOut();
}
