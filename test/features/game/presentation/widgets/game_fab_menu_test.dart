import 'package:cops_and_robbers/core/constants/app_icons.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/game_fab_menu.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpMenu(WidgetTester tester, VoidCallback onArrest) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: GameFabMenu(
              isDarkMode: false,
              items: [
                const GameFabMenuItem(label: '좌표', icon: AppIcons.grid),
                const GameFabMenuItem(label: '참가자', icon: AppIcons.person),
                GameFabMenuItem(
                  label: '체포',
                  icon: AppIcons.qrScan,
                  onTap: onArrest,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('items_are_hidden_until_police_opens_the_menu', (tester) async {
    await pumpMenu(tester, () {});

    expect(find.text('체포'), findsNothing);
  });

  testWidgets('arrest_runs_and_menu_closes_when_police_taps_arrest', (
    tester,
  ) async {
    var arrests = 0;
    await pumpMenu(tester, () => arrests++);

    await tester.tap(find.byType(GameFabMenu));
    await tester.pumpAndSettle();
    expect(find.text('참가자'), findsOneWidget);

    await tester.tap(find.text('체포'));
    await tester.pumpAndSettle();

    expect(arrests, 1);
    expect(find.text('체포'), findsNothing);
  });

  testWidgets('menu_closes_without_action_when_police_taps_close_button', (
    tester,
  ) async {
    var arrests = 0;
    await pumpMenu(tester, () => arrests++);

    await tester.tap(find.byType(GameFabMenu));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();

    expect(arrests, 0);
    expect(find.text('체포'), findsNothing);
  });

  testWidgets('screen_reader_hears_open_and_close_labels_on_menu_button', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpMenu(tester, () {});

    expect(find.bySemanticsLabel('메뉴 열기'), findsOneWidget);

    await tester.tap(find.byType(GameFabMenu));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('메뉴 닫기'), findsOneWidget);
    semantics.dispose();
  });
}
