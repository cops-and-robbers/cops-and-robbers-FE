import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';

/// 사용자 프로필 엔티티
///
/// `/api/user/me` 에서 가져온 사용자 정보를 나타냅니다.
@freezed
class UserProfileEntity with _$UserProfileEntity {
  const factory UserProfileEntity({
    /// 사용자 ID
    required int userId,

    /// 닉네임
    required String nickname,

    /// 소셜 로그인 플랫폼 (GOOGLE, KAKAO, APPLE 등)
    required String socialPlatform,

    /// 게임 푸시 알림 허용 여부
    required bool allowGamePush,

    /// 마케팅 푸시 알림 허용 여부
    required bool allowMarketingPush,

    /// 커뮤니티 푸시 알림 허용 여부. 마이페이지 스위치는 전용 GET을 보므로
    /// 화면이 이 값을 직접 읽지는 않는다 — 서버가 주는 값을 버리지 않으려고 둔다.
    @Default(true) bool allowCommunityPush,

    /// 프로필 아이콘 번호 (`assets/profiles/<번호>.svg` 와 1:1)
    required int profileIcon,
  }) = _UserProfileEntity;
}
