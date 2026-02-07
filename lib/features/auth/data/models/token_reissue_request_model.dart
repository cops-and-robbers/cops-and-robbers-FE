import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_reissue_request_model.freezed.dart';
part 'token_reissue_request_model.g.dart';

/// 토큰 재발급 요청 DTO
///
/// `POST /api/auth/reissue` 요청 바디
@freezed
class TokenReissueRequestModel with _$TokenReissueRequestModel {
  const factory TokenReissueRequestModel({
    /// Refresh Token
    required String refreshToken,
  }) = _TokenReissueRequestModel;

  factory TokenReissueRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TokenReissueRequestModelFromJson(json);
}
