import 'package:freezed_annotation/freezed_annotation.dart';

part 'nickname_update_request_model.freezed.dart';
part 'nickname_update_request_model.g.dart';

/// 닉네임 변경 요청 DTO
///
/// `PATCH /api/user/me/nickname` 요청 본문
///
/// **요청 예시**:
/// ```json
/// {
///   "nickname": "새닉네임"
/// }
/// ```
@freezed
class NicknameUpdateRequestModel with _$NicknameUpdateRequestModel {
  const factory NicknameUpdateRequestModel({
    /// 변경할 닉네임 (최대 10자)
    required String nickname,
  }) = _NicknameUpdateRequestModel;

  factory NicknameUpdateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$NicknameUpdateRequestModelFromJson(json);
}
