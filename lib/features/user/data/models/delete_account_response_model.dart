import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_account_response_model.freezed.dart';
part 'delete_account_response_model.g.dart';

/// 회원 탈퇴 응답 DTO
///
/// `DELETE /api/user/me` 응답 (200)
///
/// **응답 예시**:
/// ```json
/// {
///   "message": "회원탈퇴가 완료되었습니다."
/// }
/// ```
@freezed
class DeleteAccountResponseModel with _$DeleteAccountResponseModel {
  const factory DeleteAccountResponseModel({
    /// 결과 메시지
    required String message,
  }) = _DeleteAccountResponseModel;

  factory DeleteAccountResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DeleteAccountResponseModelFromJson(json);
}
