import 'package:freezed_annotation/freezed_annotation.dart';

import 'login_response_model.dart';

part 'token_reissue_response_model.freezed.dart';
part 'token_reissue_response_model.g.dart';

/// 토큰 재발급 응답 DTO
///
/// `POST /api/auth/reissue` 응답 (200)
///
/// **응답 예시**:
/// ```json
/// {
///   "tokens": {
///     "accessToken": "eyJhbG...",
///     "refreshToken": "eyJhbG..."
///   }
/// }
/// ```
@freezed
class TokenReissueResponseModel with _$TokenReissueResponseModel {
  const factory TokenReissueResponseModel({
    /// JWT 토큰 (Access + Refresh)
    required TokensModel tokens,
  }) = _TokenReissueResponseModel;

  factory TokenReissueResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TokenReissueResponseModelFromJson(json);
}
