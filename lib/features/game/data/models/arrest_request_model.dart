import 'package:freezed_annotation/freezed_annotation.dart';

part 'arrest_request_model.freezed.dart';
part 'arrest_request_model.g.dart';

/// 체포 요청 바디
@freezed
class ArrestRequestModel with _$ArrestRequestModel {
  const factory ArrestRequestModel({
    /// 서버 키는 `runnerParticipantId` (BE #254)
    @JsonKey(name: 'runnerParticipantId') required int robberParticipantId,
  }) = _ArrestRequestModel;

  factory ArrestRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ArrestRequestModelFromJson(json);
}
