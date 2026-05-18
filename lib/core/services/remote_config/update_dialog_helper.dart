import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../router/route_paths.dart';
import '../../constants/app_urls.dart';
import '../../utils/url_launcher_util.dart';
import '../../widgets/dialogs/app_dialog.dart';
import 'app_version_checker.dart';

/// 앱 업데이트 및 점검 처리 헬퍼
///
/// [VersionCheckResult]에 따라 적절한 조치를 수행한다.
/// - [VersionCheckResult.maintenance]: 점검 페이지로 이동 (앱 차단)
/// - [VersionCheckResult.forceUpdate]: 강제 업데이트 페이지로 이동 (앱 차단)
/// - [VersionCheckResult.optionalUpdate]: 선택 업데이트 다이얼로그 표시
/// - [VersionCheckResult.recommendUpdate]: 권고 업데이트 다이얼로그 표시
class UpdateDialogHelper {
  UpdateDialogHelper._();

  /// 버전 체크 결과에 따라 페이지 이동 또는 다이얼로그 표시
  ///
  /// 반환값: true면 앱 진행 가능, false면 앱 차단 (페이지 이동 완료)
  static Future<bool> handleResult(
    BuildContext context,
    VersionCheckResult result,
  ) async {
    switch (result) {
      case VersionCheckResult.upToDate:
        return true;

      case VersionCheckResult.maintenance:
        context.go(RoutePaths.maintenance);
        return false;

      case VersionCheckResult.forceUpdate:
        context.go(RoutePaths.forceUpdate);
        return false;

      case VersionCheckResult.optionalUpdate:
        await _showOptionalUpdateDialog(context);
        return true;

      case VersionCheckResult.recommendUpdate:
        await _showRecommendUpdateDialog(context);
        return true;
    }
  }

  /// 권고 업데이트 다이얼로그 (최신 버전 안내, "나중에" 가능)
  static Future<void> _showRecommendUpdateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDialog.show(
      context: context,
      title: l10n.dialogUpdateOptionalTitle,
      message: l10n.dialogUpdateOptionalMessage,
      confirmText: l10n.dialogUpdateOptionalConfirm,
      cancelText: l10n.dialogUpdateOptionalCancel,
      barrierDismissible: true,
      onConfirm: () {
        launchExternalUrl(AppUrls.storeUrl);
      },
    );
  }

  /// 선택 업데이트 다이얼로그 (minimum_version 미만, "나중에" 가능)
  static Future<void> _showOptionalUpdateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDialog.show(
      context: context,
      title: l10n.dialogUpdateMandatoryTitle,
      message: l10n.dialogUpdateMandatoryMessage,
      confirmText: l10n.dialogUpdateMandatoryConfirm,
      cancelText: l10n.dialogUpdateMandatoryCancel,
      barrierDismissible: true,
      onConfirm: () {
        launchExternalUrl(AppUrls.storeUrl);
      },
    );
  }
}
