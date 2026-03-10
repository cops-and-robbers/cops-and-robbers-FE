import 'package:freezed_annotation/freezed_annotation.dart';

part 'arrest_response_model.freezed.dart';
part 'arrest_response_model.g.dart';

/// 체포 응답 바디
@freezed
class ArrestResponseModel with _$ArrestResponseModel {
  const factory ArrestResponseModel({
    required String robberNickname,
    required int remainingThieves,
  }) = _ArrestResponseModel;

  factory ArrestResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ArrestResponseModelFromJson(json);
}
