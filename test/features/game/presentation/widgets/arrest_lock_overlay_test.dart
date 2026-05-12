import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/features/game/presentation/widgets/arrest_lock_overlay.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        home: Scaffold(body: Stack(children: [child])),
      ),
    ),
  );
}

void main() {
  group('ArrestLockOverlay', () {
    testWidgets('hides_manual_escape_button_when_showManualFallback_is_false', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(const ArrestLockOverlay(gameId: 1, myParticipantId: 100)),
      );

      expect(find.text('탈옥 완료'), findsNothing);
    });

    testWidgets(
      'shows_auto_escape_guidance_text_when_showManualFallback_is_false',
      (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _wrap(const ArrestLockOverlay(gameId: 1, myParticipantId: 100)),
        );

        expect(find.textContaining('감옥 영역에 들어갔다가 다시 벗어나면'), findsOneWidget);
      },
    );

    testWidgets('shows_manual_escape_button_when_showManualFallback_is_true', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          const ArrestLockOverlay(
            gameId: 1,
            myParticipantId: 100,
            showManualFallback: true,
          ),
        ),
      );

      expect(find.text('탈옥 완료'), findsOneWidget);
    });

    testWidgets('shows_failure_guidance_text_when_showManualFallback_is_true', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          const ArrestLockOverlay(
            gameId: 1,
            myParticipantId: 100,
            showManualFallback: true,
          ),
        ),
      );

      expect(find.textContaining('자동 탈옥 처리에 실패'), findsOneWidget);
    });
  });
}
