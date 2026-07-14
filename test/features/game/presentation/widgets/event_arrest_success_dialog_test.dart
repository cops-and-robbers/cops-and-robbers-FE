import 'package:cops_and_robbers/features/game/presentation/widgets/event_arrest_success_dialog.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows_evidence_slot_for_given_index_and_nickname', (
    tester,
  ) async {
    await _pump(
      tester,
      const EventArrestSuccessDialog(evidenceIndex: 2, robberNickname: '도둑1'),
    );

    expect(find.byKey(const ValueKey('event_evidence_2')), findsOneWidget);
    final l10n = AppLocalizations.of(
      tester.element(find.byType(EventArrestSuccessDialog)),
    );
    expect(
      find.text(l10n.gameEventArrestSuccessMessage('도둑1')),
      findsOneWidget,
    );
  });

  testWidgets('caps_evidence_index_at_three', (tester) async {
    await _pump(
      tester,
      const EventArrestSuccessDialog(evidenceIndex: 5, robberNickname: 'x'),
    );
    expect(find.byKey(const ValueKey('event_evidence_3')), findsOneWidget);
  });
}
