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
///   "isAvailable": false,
///   "code": "BANNED_WORD_NICKNAME",
///   "message": "닉네임에 부적절한 표현이 포함되어 있습니다."
/// }
/// ```
@freezed
class NicknameCheckResponseModel with _$NicknameCheckResponseModel {
  const factory NicknameCheckResponseModel({
    /// 사용 가능 여부
    required bool isAvailable,

    /// 결과 코드 (`AVAILABLE` | `DUPLICATED_NICKNAME` | `BANNED_WORD_NICKNAME`)
    ///
    /// BE #248 배포 전 서버는 보내지 않으므로 nullable이다.
    String? code,

    /// 결과 메시지
    required String message,
  }) = _NicknameCheckResponseModel;

  factory NicknameCheckResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NicknameCheckResponseModelFromJson(json);
}
