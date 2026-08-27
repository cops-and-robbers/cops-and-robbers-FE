import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/i18n/error_message_mapper.dart';
import '../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/route_paths.dart';
import '../domain/report_target.dart';
import 'pages/report_category_page.dart';

/// 신고 한 건의 전체 흐름
///
/// 유형 선택 화면을 띄우고, 접수까지 끝난 결과를 스낵바로 알린다. 무엇을
/// 신고하는지는 [target]에 담겨 있어 이 함수는 대상 종류를 알 필요가 없다.
///
/// 확인 다이얼로그는 없다 — 선택 화면의 "신고하기" 버튼이 확인을 겸하고, 기타는
/// 사유 작성 화면이 그 역할을 한다.
Future<void> runReportFlow({
  required BuildContext context,
  required ReportTarget target,
  bool isDarkMode = false,
}) async {
  final outcome = await context.push<ReportOutcome>(
    RoutePaths.report,
    extra: ReportArgs(target: target, isDarkMode: isDarkMode),
  );

  // 유형을 고르지 않고 그냥 나갔다 — 알릴 것이 없다.
  if (outcome == null || !context.mounted) return;

  final l10n = AppLocalizations.of(context);
  final error = outcome.error;

  AppSnackbar.show(
    context,
    // 서버가 준 사유(중복 신고·본인 글 신고 등)를 그대로 보여줘야 사용자가 왜
    // 안 됐는지 안다. `AppException`이 아닌 예외만 일반 문구로 떨어진다.
    message: error == null
        ? l10n.messageReportSubmitted
        : error is AppException
        ? l10n.errorByException(error)
        : l10n.errorReportFailed,
    backgroundColor: error == null ? null : AppColors.red,
    isDarkMode: isDarkMode,
  );
}
