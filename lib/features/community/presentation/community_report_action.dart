import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../report/presentation/providers/report_provider.dart';
import '../../report/presentation/report_flow.dart';

/// 모집글 신고 — 유형 선택 화면을 띄우고 고른 유형으로 접수한다.
///
/// 상세 화면과 목록 카드가 같은 동선을 쓰므로 한 곳에 둔다. 고른 뒤의
/// 흐름(기타 사유 입력·결과 안내)은 인게임 신고와 공유한다.
Future<void> reportCommunityPost(
  BuildContext context,
  WidgetRef ref,
  int postId,
) async {
  await runReportFlow(
    context: context,
    submit: (selected, etcReason) => ref
        .read(reportRepositoryProvider)
        .reportCommunityPost(
          postId: postId,
          category: selected,
          etcReason: etcReason,
        ),
  );
}
