import 'package:cops_and_robbers/core/widgets/pages/server_error_page.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget harness({required VoidCallback onRetry}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, child) => MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ServerErrorPage(onRetry: onRetry),
      ),
    );
  }

  group('ServerErrorPage', () {
    // 기본 테스트 화면(800x600, dpr 3)은 로고 302.w가 넘쳐 레이아웃 assertion이 난다
    setUp(() {
      final view =
          TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
      view.physicalSize = const Size(1080, 2340);
      view.devicePixelRatio = 3.0;
      addTearDown(view.resetPhysicalSize);
      addTearDown(view.resetDevicePixelRatio);
    });

    testWidgets('shows_server_error_title_and_retry_button', (tester) async {
      await tester.pumpWidget(harness(onRetry: () {}));
      await tester.pumpAndSettle();

      expect(find.text('서버에 문제가 생겼어요'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('invokes_onRetry_when_retry_button_is_tapped', (tester) async {
      var retried = 0;
      await tester.pumpWidget(harness(onRetry: () => retried++));
      await tester.pumpAndSettle();

      await tester.tap(find.text('다시 시도'));
      await tester.pump();

      expect(retried, 1);
    });
  });
}
