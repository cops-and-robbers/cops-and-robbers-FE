import 'package:flutter/material.dart';

import '../../report/domain/report_target.dart';
import '../../report/presentation/report_flow.dart';

/// 모집글 신고 — 유형 선택 화면을 띄우고 고른 유형으로 접수한다.
///
/// 상세 화면과 목록 카드가 같은 동선을 쓰므로 한 곳에 둔다.
Future<void> reportCommunityPost(BuildContext context, int postId) =>
    runReportFlow(context: context, target: CommunityPostReportTarget(postId));
