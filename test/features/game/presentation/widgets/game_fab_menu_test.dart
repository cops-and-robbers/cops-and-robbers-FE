import 'package:cops_and_robbers/core/constants/app_icons.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/game_fab_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpMenu(WidgetTester tester, VoidCallback onCapture) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: GameFabMenu(
              items: [
                const GameFabMenuItem(label: '참가자', icon: AppIcons.person),
                const GameFabMenuItem(label: '채팅', icon: AppIcons.comment),
                const GameFabMenuItem(label: '격자', icon: AppIcons.grid),
                GameFabMenuItem(
                  label: '포착',
                  icon: AppIcons.camera,
                  highlighted: true,
                  onTap: onCapture,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('items_are_hidden_until_player_opens_the_menu', (tester) async {
    await pumpMenu(tester, () {});

    expect(find.text('포착'), findsNothing);
  });

  testWidgets('capture_runs_and_menu_closes_when_player_taps_capture', (
    tester,
  ) async {
    var captured = 0;
    await pumpMenu(tester, () => captured++);

    await tester.tap(find.byType(GameFabMenu));
    await tester.pumpAndSettle();
    expect(find.text('참가자'), findsOneWidget);

    await tester.tap(find.text('포착'));
    await tester.pumpAndSettle();

    expect(captured, 1);
    expect(find.text('포착'), findsNothing);
  });

  testWidgets('menu_closes_without_action_when_player_taps_close_button', (
    tester,
  ) async {
    var captured = 0;
    await pumpMenu(tester, () => captured++);

    await tester.tap(find.byType(GameFabMenu));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();

    expect(captured, 0);
    expect(find.text('포착'), findsNothing);
  });
}
