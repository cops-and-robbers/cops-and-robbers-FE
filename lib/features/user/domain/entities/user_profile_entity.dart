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
  }) = _UserProfileEntity;
}
