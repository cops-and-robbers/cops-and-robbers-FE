import '../entities/agreement_status_entity.dart';
import '../entities/user_profile_entity.dart';

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

  /// 내 프로필 조회
  ///
  /// 현재 로그인한 사용자의 프로필 정보를 반환합니다.
  Future<UserProfileEntity> getMyProfile();

  /// 회원 탈퇴
  ///
  /// 백엔드에서 사용자 계정을 삭제합니다.
  /// 성공 시 로컬 정리(Firebase signOut, 토큰 삭제)는 호출자가 별도로 수행합니다.
  Future<void> deleteAccount();

  /// 약관 동의 상태를 조회합니다.
  ///
  /// Returns: 현재 사용자의 4종 약관 동의 여부
  /// Throws: [NetworkException], [ServerException], [AuthException]
  Future<AgreementStatusEntity> getAgreements();

  /// 약관 동의 정보를 저장합니다.
  ///
  /// 필수 3종(이용약관·개인정보처리방침·위치정보 이용약관)은 내부적으로 true로
  /// 고정되며, 마케팅만 사용자 선택값을 전달합니다.
  ///
  /// [marketing]: 마케팅 수신 동의 여부 (true/false)
  /// Throws: [NetworkException], [ServerException], [ValidationException]
  Future<void> updateAgreements({required bool marketing});
}
