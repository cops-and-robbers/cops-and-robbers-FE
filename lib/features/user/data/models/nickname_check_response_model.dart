import 'package:freezed_annotation/freezed_annotation.dart';

part 'nickname_check_response_model.freezed.dart';
part 'nickname_check_response_model.g.dart';

/// 닉네임 중복 확인 응답 DTO
///
/// `GET /api/user/check-nickname` 응답 (200)
///
/// **응답 예시**:
/// ```json
/// {
///   "isAvailable": true,
///   "message": "사용 가능한 닉네임입니다."
/// }
/// ```
@freezed
class NicknameCheckResponseModel with _$NicknameCheckResponseModel {
  const factory NicknameCheckResponseModel({
    /// 사용 가능 여부
    required bool isAvailable,

    /// 결과 메시지
    required String message,
  }) = _NicknameCheckResponseModel;

  factory NicknameCheckResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NicknameCheckResponseModelFromJson(json);
}
