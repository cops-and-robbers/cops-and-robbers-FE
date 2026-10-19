import 'package:cops_and_robbers/features/game/presentation/widgets/start/run_cycle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpRunner(WidgetTester tester, {required bool reduceMotion}) =>
    tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: RunCycle(scale: 1.31, child: SizedBox(width: 96, height: 110)),
        ),
      ),
    );

void main() {
  testWidgets('run_cycle_keeps_running_when_motion_is_allowed', (tester) async {
    await pumpRunner(tester, reduceMotion: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('run_cycle_stands_still_when_reduce_motion_is_on', (
    tester,
  ) async {
    await pumpRunner(tester, reduceMotion: true);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('run_cycle_shows_neutral_pose_when_reduce_motion_is_on', (
    tester,
  ) async {
    await pumpRunner(tester, reduceMotion: true);
    expect(
      find.descendant(
        of: find.byType(RunCycle),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
  });

  testWidgets('run_cycle_shows_neutral_pose_until_start_delay_elapses', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: RunCycle(
            scale: 1.31,
            delay: Duration(milliseconds: 230),
            child: SizedBox(width: 96, height: 110),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.descendant(
        of: find.byType(RunCycle),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
}
