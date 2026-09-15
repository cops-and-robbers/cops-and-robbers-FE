import 'package:cops_and_robbers/core/widgets/dialogs/app_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BuildContext pageContext;

  Future<void> mountPage(WidgetTester tester) => tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        home: Builder(
          builder: (context) {
            pageContext = context;
            return const Scaffold(body: Text('게임 화면'));
          },
        ),
      ),
    ),
  );

  testWidgets('단독 팝업은 만료되면 닫히고 완료 결과를 전달한다', (tester) async {
    await mountPage(tester);
    var completed = false;
    AppPopup.show<void>(
      context: pageContext,
      autoCloseDuration: const Duration(seconds: 1),
      content: const Text('경찰 대기'),
    ).then((_) => completed = true);
    await tester.pump();
    expect(find.text('경찰 대기'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(AppPopup), findsNothing);
    expect(completed, isTrue);
    expect(find.text('게임 화면'), findsOneWidget);
  });

  for (final autoCloseTop in [false, true]) {
    testWidgets('가려진 팝업만 만료 시 제거하고 위 팝업은 유지한다 (자동 닫힘: $autoCloseTop)', (
      tester,
    ) async {
      await mountPage(tester);
      var completed = false;
      AppPopup.show<void>(
        context: pageContext,
        autoCloseDuration: const Duration(seconds: 1),
        content: const Text('경찰 대기'),
      ).then((_) => completed = true);
      await tester.pump();
      AppPopup.show<void>(
        context: pageContext,
        autoCloseDuration: autoCloseTop ? const Duration(seconds: 5) : null,
        content: const Text('위 팝업'),
      );
      await tester.pump();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('경찰 대기', skipOffstage: false), findsNothing);
      expect(find.text('위 팝업'), findsOneWidget);
      expect(completed, isTrue);

      if (autoCloseTop) {
        await tester.pump(const Duration(seconds: 4));
      } else {
        Navigator.of(pageContext).pop();
      }
      await tester.pumpAndSettle();
      expect(find.byType(AppPopup), findsNothing);
      expect(find.text('게임 화면'), findsOneWidget);
    });
  }
}
