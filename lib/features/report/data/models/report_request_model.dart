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

/// 커뮤니티 모집글 신고 요청 DTO
///
/// `POST /api/report/community-post` 요청 본문.
/// 신고 대상 id는 경로가 아니라 본문으로 보낸다 (DEC-0032).
/// [reportType]은 인게임 신고와 같은 enum을 그대로 쓰며, `ETC`일 때
/// [etcReason]이 필수다 (최대 300자).
@freezed
class CommunityPostReportRequestModel with _$CommunityPostReportRequestModel {
  const factory CommunityPostReportRequestModel({
    required int postId,
    required String reportType,
    String? etcReason,
  }) = _CommunityPostReportRequestModel;

  factory CommunityPostReportRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostReportRequestModelFromJson(json);
}
