import 'package:cops_and_robbers/features/game/presentation/widgets/event_result_board.dart';
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
  testWidgets('collected_slots_unlocked_and_remaining_slots_locked', (tester) async {
    await _pump(tester, EventResultBoard(arrestCount: 2, onGoHome: () {}));

    // 3개 슬롯 모두 존재
    expect(find.byKey(const ValueKey('event_result_slot_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('event_result_slot_2')), findsOneWidget);
    expect(find.byKey(const ValueKey('event_result_slot_3')), findsOneWidget);
    // 미수집(3번)만 자물쇠
    expect(find.byKey(const ValueKey('event_result_lock_1')), findsNothing);
    expect(find.byKey(const ValueKey('event_result_lock_2')), findsNothing);
    expect(find.byKey(const ValueKey('event_result_lock_3')), findsOneWidget);
  });

  testWidgets('shows_arrest_count_text_and_only_home_button', (tester) async {
    await _pump(tester, EventResultBoard(arrestCount: 2, onGoHome: () {}));
    final l10n =
        AppLocalizations.of(tester.element(find.byType(EventResultBoard)));

    expect(find.text(l10n.gameEventResultArrestCount(2)), findsOneWidget);
    expect(find.text(l10n.buttonGoHome), findsOneWidget);
    expect(find.text(l10n.buttonPlayAgain), findsNothing); // 한 번 더 숨김
  });

  testWidgets('renders_overridden_title_and_button_when_provided', (tester) async {
    await _pump(
      tester,
      EventResultBoard(
        arrestCount: 1,
        onGoHome: () {},
        title: 'PROGRESS_TITLE',
        buttonText: 'CLOSE_BTN',
      ),
    );
    final l10n =
        AppLocalizations.of(tester.element(find.byType(EventResultBoard)));

    // 오버라이드 문구 렌더
    expect(find.text('PROGRESS_TITLE'), findsOneWidget);
    expect(find.text('CLOSE_BTN'), findsOneWidget);
    // 기본 게임종료 문구는 노출 안 됨
    expect(find.text(l10n.gameEventResultTitle), findsNothing); // "수사 종료"
    expect(find.text(l10n.buttonGoHome), findsNothing); // "홈으로"
  });
}
