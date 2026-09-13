import 'package:clock/clock.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/game_timer_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('서버 남은 시간은 수신 시각 기준으로 흐르고 재수신 즉시 보정된다', (tester) async {
    var now = DateTime(2026, 9, 9, 12);
    final receivedAt = now;
    Widget timer(Duration remaining, DateTime received) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        home: GameTimerText.remaining(
          remainingTime: remaining,
          receivedAt: received,
        ),
      ),
    );
    await withClock(Clock(() => now), () async {
      await tester.pumpWidget(timer(const Duration(minutes: 120), receivedAt));
      expect(find.text('120:00'), findsOneWidget);
      now = now.add(const Duration(seconds: 61));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('118:59'), findsOneWidget);
      await tester.pumpWidget(timer(const Duration(seconds: 30), now));
      expect(find.text('00:30'), findsOneWidget);
      now = now.add(const Duration(seconds: 40));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:00'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('남은 시간이 한 시간을 넘어도 분이 0으로 돌아가지 않는다', (tester) async {
    final now = DateTime(2026, 9, 9, 12);
    await withClock(Clock.fixed(now), () async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => MaterialApp(
            home: GameTimerText(
              startTime: now,
              totalDuration: const Duration(minutes: 90),
            ),
          ),
        ),
      );
      expect(find.text('90:00'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
