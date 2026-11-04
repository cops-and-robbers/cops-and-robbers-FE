import 'package:cops_and_robbers/core/widgets/pages/maintenance_page.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required Widget home,
  GlobalKey<NavigatorState>? navigatorKey,
  Locale locale = const Locale('ko'),
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) => MaterialApp(
      navigatorKey: navigatorKey,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  testWidgets('shows_the_maintenance_notice', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(home: const MaintenancePage()));
    await tester.pump();

    expect(find.text('서버 점검 중'), findsOneWidget);
    expect(find.textContaining('잠시 후 다시 접속해 주세요'), findsOneWidget);
  });

  for (final locale in const [Locale('ko'), Locale('en'), Locale('ja')]) {
    testWidgets('fits_a_small_phone_in_${locale.languageCode}', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _app(home: const MaintenancePage(), locale: locale),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('fits_a_small_phone_with_large_text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      _app(home: const MaintenancePage(), locale: const Locale('ja')),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('writing_dialog_opens_from_the_root_navigator_context', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      _app(home: const Scaffold(), navigatorKey: navigatorKey),
    );

    showMaintenanceWritingDialog(navigatorKey.currentContext!);
    await tester.pumpAndSettle();

    expect(find.text('점검이 시작됐어요'), findsOneWidget);
    expect(find.text('점검이 끝나면 다시 시도해 주세요'), findsOneWidget);

    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(find.text('점검이 시작됐어요'), findsNothing);
  });
}
