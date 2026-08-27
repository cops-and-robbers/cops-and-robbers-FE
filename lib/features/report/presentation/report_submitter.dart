import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/constants/report_categories.dart';
import '../domain/report_target.dart';
import 'providers/report_provider.dart';

/// 대상에 맞는 접수 메서드를 고른다.
///
/// 유형 선택 화면과 사유 작성 화면 둘 다 접수를 한다 — 기타는 작성 화면이 떠 있는
/// 채로 보내야 왕복 동안 신고 메뉴가 도로 보이지 않는다.
Future<void> submitReport(
  WidgetRef ref, {
  required ReportTarget target,
  required ReportCategory category,
  String? etcReason,
}) {
  final repository = ref.read(reportRepositoryProvider);

  return switch (target) {
    CommunityPostReportTarget(:final postId) => repository.reportCommunityPost(
      postId: postId,
      category: category,
      etcReason: etcReason,
    ),
    GameChatReportTarget(
      :final gameId,
      :final reportedParticipantId,
      :final messageContent,
    ) =>
      repository.reportChat(
        gameId: gameId,
        reportedParticipantId: reportedParticipantId,
        messageContent: messageContent,
        category: category,
        etcReason: etcReason,
      ),
  };
}
