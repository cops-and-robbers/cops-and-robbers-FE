import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_model.freezed.dart';
part 'login_request_model.g.dart';

/// 소셜 로그인 요청 DTO
///
/// `POST /api/auth/login` 요청 바디
///
/// **필수 필드**:
/// - [socialPlatform]: 소셜 플랫폼 (`GOOGLE`, `APPLE`)
/// - [idToken]: Firebase ID Token
/// - [fcmToken]: FCM 디바이스 토큰
/// - [deviceType]: 디바이스 타입 (`IOS`, `ANDROID`)
/// - [deviceId]: 고유 디바이스 ID
@freezed
class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({
    /// 소셜 플랫폼 (`GOOGLE`, `APPLE`)
    required String socialPlatform,

    /// Firebase ID Token
    required String idToken,

    /// FCM 디바이스 토큰
    required String fcmToken,

    /// 디바이스 타입 (`IOS`, `ANDROID`)
    required String deviceType,

    /// 고유 디바이스 ID
    required String deviceId,
  }) = _LoginRequestModel;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);
}
