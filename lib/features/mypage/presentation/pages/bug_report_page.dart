import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/loading/app_loading.dart';
import '../../../../core/widgets/pages/text_submit_page.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../bug/presentation/providers/bug_provider.dart';

/// 버그 제보 화면
///
/// 입력 UI 는 범용 위젯인 [TextSubmitPage] 가 그리고, 이 위젯은 버그 제보에 필요한
/// 문구와 전송 동작만 채운다.
///
/// 라우트가 이 화면을 직접 가리키므로 문구와 onSubmit 을 밖에서 받지 않는다. 콜백은
/// URL 로 복원할 수 없고, 앱이 죽었다 살아나면 라우트만 되살아나 인자가 빈다. 화면이
/// 자기 동작을 갖고 있어야 어디서 들어오든 같게 동작한다.
class BugReportPage extends ConsumerStatefulWidget {
  const BugReportPage({super.key});

  @override
  ConsumerState<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends ConsumerState<BugReportPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextSubmitPage(
      title: l10n.titleBugReport,
      label: l10n.fieldBugReportLabel,
      hintText: l10n.fieldBugReportHint,
      submitText: l10n.buttonSubmitReport,
      maxLength: 1000,
      onSubmit: _submit,
    );
  }

  /// 버그 제보 API 호출 + 결과 처리
  ///
  /// 성공: 로딩과 이 화면을 모두 닫고 성공 스낵바를 띄운다.
  /// 실패: 로딩만 닫고 화면은 유지해 다시 시도할 수 있게 한다.
  /// AuthException 은 AuthInterceptor 가 강제 로그아웃을 처리하므로 여기서는 넘긴다.
  Future<void> _submit(String content) async {
    final navigator = Navigator.of(context);
    final loading = AppLoading.show(context, LoadingCategory.bugReport);

    try {
      await ref.read(bugRepositoryProvider).reportBug(content: content);
      await loading.close();
      if (!mounted) return;
      if (navigator.canPop()) navigator.pop();
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).messageBugReportSubmitted,
      );
    } on AuthException {
      await loading.close();
      return;
    } on AppException catch (e) {
      await loading.close();
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
        backgroundColor: AppColors.red,
      );
    } finally {
      // 안전망: 위에서 처리하지 못한 예외 타입으로 close() 가 호출되지 않는 경로를
      // 막는다. close() 는 멱등이라 정상 경로에는 영향이 없다.
      await loading.close();
    }
  }
}
