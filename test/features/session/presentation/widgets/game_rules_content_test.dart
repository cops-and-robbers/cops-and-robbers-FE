import 'package:cops_and_robbers/features/session/presentation/widgets/game_rules_content.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('waiting_room_rules_list_ping_as_fourth_rule_when_dialog_opens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => const MaterialApp(
          locale: Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GameRulesContent(locationRevealIntervalMinutes: 3),
          ),
        ),
      ),
    );
    expect(find.text('4.'), findsOneWidget);
    // 하이라이트 조각은 WidgetSpan 안의 Text라 따로 찾힌다
    expect(find.text('길게 누르면'), findsOneWidget);
    expect(find.text('3분마다'), findsOneWidget); // 기존 2번은 그대로
  });
}
