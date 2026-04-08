import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_request_model.freezed.dart';
part 'report_request_model.g.dart';

/// 채팅 신고 요청 DTO
///
/// `POST /api/report/chat` 요청 본문.
/// [reportType]이 `ETC`일 때 [etcReason] 필수 (최대 300자).
@freezed
class ReportRequestModel with _$ReportRequestModel {
  const factory ReportRequestModel({
    required int gameId,
    required int reportedParticipantId,
    required String messageContent,
    required String reportType,
    String? etcReason,
  }) = _ReportRequestModel;

  factory ReportRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ReportRequestModelFromJson(json);
}
