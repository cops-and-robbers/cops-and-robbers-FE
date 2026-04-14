import '../constants/report_categories.dart';

/// Report Repository 인터페이스
///
/// 도메인 레이어에서 신고 기능의 계약을 정의합니다.
abstract class ReportRepository {
  /// 채팅 메시지 신고
  ///
  /// [gameId] 게임 ID
  /// [reportedParticipantId] 신고 대상 참가자 ID
  /// [messageContent] 신고된 메시지 내용
  /// [category] 신고 카테고리
  /// [etcReason] 기타 사유 (category가 other일 때 필수)
  ///
  /// Throws:
  /// - [AppException]: API 에러 (중복 신고, 본인 신고 불가 등)
  Future<void> reportChat({
    required int gameId,
    required int reportedParticipantId,
    required String messageContent,
    required ReportCategory category,
    String? etcReason,
  });
}
