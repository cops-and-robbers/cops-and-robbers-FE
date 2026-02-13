/// User Repository 인터페이스
///
/// 사용자 프로필 관련 비즈니스 로직의 데이터 접근 추상화입니다.
abstract class UserRepository {
  /// 닉네임 중복 확인
  ///
  /// [nickname]이 사용 가능하면 `true`, 중복이면 `false`를 반환합니다.
  Future<bool> checkNickname(String nickname);

  /// 닉네임 변경
  ///
  /// 현재 로그인한 사용자의 닉네임을 [nickname]으로 변경합니다.
  /// 성공 시 아무것도 반환하지 않습니다 (204 No Content).
  Future<void> updateNickname(String nickname);
}
