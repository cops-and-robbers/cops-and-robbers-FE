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

/// 커뮤니티 채팅 메시지 신고 요청 DTO
///
/// `POST /api/report/community-chat` 요청 본문.
/// 모집글 신고와 같은 모양이고 대상만 다르다 — 신고 대상 id는 경로가 아니라
/// 본문으로 보낸다 (DEC-0032).
///
/// [chatMessageId]는 **서버가 발급한 메시지 id**다. 앱이 만든 `messageKey`를
/// 보내면 서버가 못 찾는다(404 `CHAT_MESSAGE_NOT_FOUND`) — 대화 내역과 실시간
/// 브로드캐스트 둘 다 이 id를 실어 주므로 따로 조회할 필요는 없다.
@freezed
class CommunityChatReportRequestModel with _$CommunityChatReportRequestModel {
  const factory CommunityChatReportRequestModel({
    required int chatMessageId,
    required String reportType,
    String? etcReason,
  }) = _CommunityChatReportRequestModel;

  factory CommunityChatReportRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityChatReportRequestModelFromJson(json);
}
