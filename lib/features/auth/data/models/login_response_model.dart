import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response_model.freezed.dart';
part 'login_response_model.g.dart';

/// 소셜 로그인 응답 DTO
///
/// `POST /api/auth/login` 응답 (200, 201)
///
/// **응답 예시**:
/// ```json
/// {
///   "userId": 1,
///   "nickname": "민첩한괴도5308",
///   "tokens": {
///     "accessToken": "eyJhbG...",
///     "refreshToken": "eyJhbG..."
///   },
///   "isNewUser": false
/// }
/// ```
@freezed
class LoginResponseModel with _$LoginResponseModel {
  const factory LoginResponseModel({
    /// 사용자 ID
    required int userId,

    /// 닉네임 (서버에서 자동 생성)
    required String nickname,

    /// JWT 토큰 (Access + Refresh)
    required TokensModel tokens,

    /// 신규 회원 여부
    required bool isNewUser,
  }) = _LoginResponseModel;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);
}

/// JWT 토큰 페어 DTO
///
/// Access Token과 Refresh Token을 포함합니다.
@freezed
class TokensModel with _$TokensModel {
  const factory TokensModel({
    /// JWT Access Token
    required String accessToken,

    /// JWT Refresh Token
    required String refreshToken,
  }) = _TokensModel;

  factory TokensModel.fromJson(Map<String, dynamic> json) =>
      _$TokensModelFromJson(json);
}
