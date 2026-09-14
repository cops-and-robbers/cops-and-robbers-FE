import 'package:clock/clock.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/location_reveal_countdown.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget countdown(DateTime? target, DateTime? end, {int interval = 3}) =>
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LocationRevealCountdown(
            nextRevealTime: target,
            gameEndTime: end,
            intervalMinutes: interval,
          ),
        ),
      ),
    );

void main() {
  final start = DateTime(2026, 9, 15, 12);
  final finished = find.text('추가 도둑 위치 공개는 없어요');
  final label = find.textContaining('다음 도둑 위치 공개까지');

  testWidgets('공개가 종료 시각 이상이면 종료 안내로 바꾸고 종료 시각 보정을 즉시 반영한다', (tester) async {
    await withClock(Clock.fixed(start), () async {
      final target = start.add(const Duration(minutes: 3));
      for (final minutes in [2, 3, 4]) {
        await tester.pumpWidget(
          countdown(target, start.add(Duration(minutes: minutes))),
        );
        expect(label, minutes <= 3 ? findsNothing : findsOneWidget);
        expect(finished, minutes <= 3 ? findsOneWidget : findsNothing);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('마지막 공개 후 다음 주기가 종료를 넘으면 공개 종료를 안내한다', (tester) async {
    var now = start;
    await withClock(Clock(() => now), () async {
      await tester.pumpWidget(
        countdown(
          start.add(const Duration(minutes: 1)),
          start.add(const Duration(minutes: 3)),
        ),
      );
      expect(find.text('다음 도둑 위치 공개까지 01:00'), findsOneWidget);
      now = start.add(const Duration(minutes: 1, seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(label, findsNothing);
      expect(finished, findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('백그라운드 복귀와 공개 주기 변경 시 표시 여부를 즉시 재계산한다', (tester) async {
    var now = start;
    final target = start.add(const Duration(minutes: 1));
    final end = start.add(const Duration(minutes: 3));
    await withClock(Clock(() => now), () async {
      await tester.pumpWidget(countdown(target, end));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      now = start.add(const Duration(minutes: 2));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(label, findsNothing);
      expect(finished, findsOneWidget);
      await tester.pumpWidget(countdown(target, end, interval: 1));
      expect(label, findsOneWidget);
      now = end;
      await tester.pump(const Duration(seconds: 1));
      expect(label, findsNothing);
      expect(finished, findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('종료 시각을 모르면 기존 공개 예정 및 주기 안내를 유지한다', (tester) async {
    await withClock(Clock.fixed(start), () async {
      for (final target in [start.add(const Duration(minutes: 3)), null]) {
        await tester.pumpWidget(countdown(target, null));
        expect(find.text('다음 도둑 위치 공개까지 03:00'), findsOneWidget);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
