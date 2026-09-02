import 'dart:async';

import 'package:cops_and_robbers/core/widgets/loading/app_refresh_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// 당겨서 새로고침이 붙은 목록 하나.
///
/// [gate]를 넘기면 그걸 complete할 때까지 새로고침이 끝나지 않는다 — "새로고침
/// 중" 화면을 붙잡아 두고 확인하기 위한 손잡이다.
Widget _wrap({required List<String> log, Completer<void>? gate}) =>
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, _) => MaterialApp(
        home: Scaffold(
          body: AppRefreshControl(
            onRefresh: () async {
              log.add('refresh');
              if (gate != null) await gate.future;
            },
            child: ListView(
              children: [
                for (var i = 0; i < 20; i++)
                  SizedBox(height: 60, child: Text('항목 $i')),
              ],
            ),
          ),
        ),
      ),
    );

void main() {
  group('AppRefreshControl', () {
    testWidgets('runs_onRefresh_when_pulled_past_the_trigger', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(_wrap(log: log));
      await tester.pumpAndSettle();

      await tester.fling(find.text('항목 0'), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(log, ['refresh']);
    });

    testWidgets('ignores_a_pull_that_stops_short_of_the_trigger', (
      tester,
    ) async {
      // 살짝 당겼다 놓은 것까지 새로고침으로 치면 스크롤 한 번에 목록이 계속
      // 다시 그려진다.
      final log = <String>[];
      await tester.pumpWidget(_wrap(log: log));
      await tester.pumpAndSettle();

      await tester.drag(find.text('항목 0'), const Offset(0, 30));
      await tester.pumpAndSettle();

      expect(log, isEmpty);
    });

    testWidgets('spins_the_indicator_while_refreshing', (tester) async {
      final log = <String>[];
      final gate = Completer<void>();
      await tester.pumpWidget(_wrap(log: log, gate: gate));
      await tester.pumpAndSettle();

      await tester.fling(find.text('항목 0'), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Material 퍽 안에서 스피너가 돈다.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // 응답 대기 중에는 끝을 모르므로 무한 회전(value == null)이어야 한다.
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .value,
        isNull,
      );

      gate.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('keeps_spinning_a_beat_even_when_the_refresh_is_instant', (
      tester,
    ) async {
      // 캐시처럼 즉시 끝나면 스피너가 번쩍이고 사라져 아무 일도 안 일어난 것처럼
      // 보인다. 최소 시간만큼은 붙잡아 둔다 (AppLoading과 같은 판단).
      await tester.pumpWidget(_wrap(log: []));
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('항목 0')),
      );
      await gesture.moveBy(const Offset(0, 200));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // 최소 유지가 없으면 320ms 언저리에 사라진다(실측). 여유를 두고 그
      // 이후를 본다 — 한 번에 크게 pump하면 상태 전이가 다 흐르지 않으므로
      // 실제 프레임처럼 잘게 흘린다.
      for (var elapsed = 0; elapsed < 420; elapsed += 50) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('fills_the_ring_as_the_finger_pulls_down', (tester) async {
      // 아직 새로고침 전에는 얼마나 더 당겨야 하는지가 링으로 보여야 한다.
      await tester.pumpWidget(_wrap(log: []));
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('항목 0')),
      );
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump();
      final near = _ringValue(tester);

      await gesture.moveBy(const Offset(0, 40));
      await tester.pump();
      expect(_ringValue(tester), greaterThan(near!));

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}

/// 퍽 안 진행도 링의 값. null이면 무한 회전.
double? _ringValue(WidgetTester tester) => tester
    .widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator))
    .value;
