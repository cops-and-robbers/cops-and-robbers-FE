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
  }) = _MyPageResponseModel;

  factory MyPageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MyPageResponseModelFromJson(json);
}
