import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_icon_update_request_model.freezed.dart';
part 'profile_icon_update_request_model.g.dart';

/// 프로필 아이콘 변경 요청 DTO
///
/// `PATCH /api/user/me/profile-icon` 요청 본문.
/// 서버는 번호만 보관한다 — 이미지 URL이 아니라 앱 에셋 번호와 1:1 대응하는 정수다.
@freezed
class ProfileIconUpdateRequestModel with _$ProfileIconUpdateRequestModel {
  const factory ProfileIconUpdateRequestModel({required int profileIcon}) =
      _ProfileIconUpdateRequestModel;

  factory ProfileIconUpdateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileIconUpdateRequestModelFromJson(json);
}
