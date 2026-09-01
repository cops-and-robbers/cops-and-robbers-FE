import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_page_response_model.freezed.dart';
part 'my_page_response_model.g.dart';

/// 마이페이지 사용자 정보 응답 DTO
///
/// `GET /api/user/me` 응답 (200)
///
/// **응답 예시**:
/// ```json
/// {
///   "userId": 1,
///   "nickname": "홍길동",
///   "socialPlatform": "GOOGLE",
///   "allowGamePush": true,
///   "allowMarketingPush": false
/// }
/// ```
@freezed
class MyPageResponseModel with _$MyPageResponseModel {
  const factory MyPageResponseModel({
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

    /// 커뮤니티 푸시 알림 허용 여부 (BE #182, v2.26.0)
    ///
    /// [profileIcon]과 같은 이유로 `required`를 피한다 — 계약상 필수가 아니다.
    /// 가입 기본값과 같은 true로 채운다.
    @Default(true) bool allowCommunityPush,

    /// 프로필 아이콘 번호 (앱 에셋 번호와 1:1)
    ///
    /// OpenAPI 계약상 필수가 아니다. `required`로 두면 서버가 이 필드를 빼는
    /// 순간 응답 파싱이 통째로 실패해 닉네임 조회까지 같이 죽는다 — 서버 기본값과
    /// 같은 1로 채우고 넘어간다.
    @Default(1) int profileIcon,
  }) = _MyPageResponseModel;

  factory MyPageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MyPageResponseModelFromJson(json);
}
