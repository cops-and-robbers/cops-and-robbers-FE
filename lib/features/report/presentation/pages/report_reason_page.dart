import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/pages/text_submit_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/constants/report_categories.dart';
import '../../domain/report_target.dart';
import '../report_submitter.dart';
import 'report_category_page.dart';

/// 기타 신고 사유 작성 화면
///
/// 이 화면이 접수까지 한다. 글만 돌려주고 먼저 닫히면 서버 왕복 동안 신고 유형
/// 화면이 도로 보였다가 닫힌다 — 사용자는 신고를 마치고 곧장 원래 화면으로
/// 돌아가야 한다.
///
/// 접수가 끝나면 [ReportOutcome]을 돌려주고, 유형 선택 화면이 그것을 그대로
/// 위로 넘겨 두 장이 한 번에 닫힌다.
class ReportReasonPage extends ConsumerStatefulWidget {
  const ReportReasonPage({
    super.key,
    required this.target,
    this.isDarkMode = false,
  });

  final ReportTarget target;
  final bool isDarkMode;

  /// 기타 사유 길이 상한 — 서버 검증값(`etcReason.maxLength`)과 같아야 한다.
  static const int maxLength = 300;

  @override
  ConsumerState<ReportReasonPage> createState() => _ReportReasonPageState();
}

class _ReportReasonPageState extends ConsumerState<ReportReasonPage> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      // 접수가 도는 중에 닫히면 결과를 알릴 자리가 사라지고, 스택도 예상과
      // 달라진다.
      canPop: !_submitting,
      child: TextSubmitPage(
        title: l10n.buttonReport,
        label: l10n.fieldReportContentLabel,
        hintText: l10n.fieldReportReasonHint,
        submitText: l10n.buttonReport,
        isDestructive: true,
        isDarkMode: widget.isDarkMode,
        maxLength: ReportReasonPage.maxLength,
        onSubmit: _submit,
      ),
    );
  }

  Future<void> _submit(String text) async {
    if (_submitting) return;
    setState(() => _submitting = true);

    Object? failure;
    try {
      await submitReport(
        ref,
        target: widget.target,
        category: ReportCategory.other,
        etcReason: text,
      );
    } catch (e) {
      failure = e;
    }
    if (!mounted) return;

    setState(() => _submitting = false);
    context.pop(ReportOutcome(failure));
  }
}
