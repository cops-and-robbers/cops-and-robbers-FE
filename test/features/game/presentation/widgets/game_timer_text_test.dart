import 'package:clock/clock.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/game_timer_text.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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

  testWidgets('게임과 위치 공개는 재빌드·주기 경계·앱 복귀에도 같은 초로 표시된다', (tester) async {
    final start = DateTime(2026, 9, 15, 12, 0, 0, 123);
    var now = start.add(const Duration(seconds: 64, milliseconds: 500));
    Widget screen() => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameTimerText(
          startTime: start,
          totalDuration: const Duration(minutes: 10),
          policeWaitMinutes: 1,
          locationRevealIntervalMinutes: 3,
        ),
      ),
    );
    void expectTimes(String game, String reveal) {
      expect(find.text(game), findsOneWidget);
      expect(find.text('다음 도둑 위치 공개까지 $reveal'), findsOneWidget);
    }

    await withClock(Clock(() => now), () async {
      await tester.pumpWidget(screen());
      expectTimes('08:55', '02:55');

      // 독립 타이머 틱 사이에 부모가 다시 그려지던 재현 조건.
      now = now.add(const Duration(milliseconds: 750));
      await tester.pumpWidget(screen());
      expectTimes('08:54', '02:54');

      now = now.add(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expectTimes('08:53', '02:53');

      for (final elapsed in [
        const Duration(minutes: 4),
        const Duration(minutes: 4, microseconds: 1),
        const Duration(minutes: 7, milliseconds: 500),
      ]) {
        now = start.add(elapsed);
        await tester.pumpWidget(screen());
        final texts = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data!)
            .toList();
        expect(texts.first.split(':').last, texts.last.split(':').last);
      }
      expectTimes('02:59', '02:59');

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      now = start.add(
        const Duration(minutes: 8, seconds: 20, milliseconds: 750),
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expectTimes('01:39', '01:39');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(screen());
      expectTimes('01:39', '01:39');
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('설정이 늦게 도착해도 게임과 위치 공개가 함께 시작된다', (tester) async {
    final start = DateTime(2026, 9, 15, 12);
    Widget screen(DateTime? startTime, int? wait) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameTimerText(
          startTime: startTime,
          totalDuration: startTime == null ? null : const Duration(minutes: 10),
          policeWaitMinutes: wait,
          locationRevealIntervalMinutes: 3,
        ),
      ),
    );
    await withClock(
      Clock.fixed(start.add(const Duration(seconds: 5))),
      () async {
        await tester.pumpWidget(screen(null, null));
        expect(find.text('--:--'), findsOneWidget);
        expect(find.text('다음 도둑 위치 공개까지 03:00'), findsOneWidget);
        await tester.pumpWidget(screen(start, 0));
        expect(find.text('09:55'), findsOneWidget);
        expect(find.text('다음 도둑 위치 공개까지 02:55'), findsOneWidget);
        await tester.pumpWidget(screen(start, 1));
        expect(find.text('09:55'), findsOneWidget);
        expect(find.text('다음 도둑 위치 공개까지 03:55'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  });

  // 30분·경찰 5분 게임 12:07 — 1차 축소(12:10)까지 3분 (#668)
  Future<void> pumpShrinkTimer(WidgetTester tester, DateTime? nextShrinkAt) =>
      tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => MaterialApp(
            locale: const Locale('ko'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: GameTimerText(
              startTime: DateTime(2026, 11, 8, 12),
              totalDuration: const Duration(minutes: 30),
              policeWaitMinutes: 5,
              locationRevealIntervalMinutes: 5,
              nextShrinkAt: (_) => nextShrinkAt,
            ),
          ),
        ),
      );

  testWidgets('구역 축소를 켠 게임은 앱바에 다음 축소까지 남은 시간을 함께 보여 준다', (tester) async {
    await withClock(Clock.fixed(DateTime(2026, 11, 8, 12, 7)), () async {
      await pumpShrinkTimer(tester, DateTime(2026, 11, 8, 12, 10));
      // 앱바가 두 줄이 되지 않게 위치 공개와 한 줄로 (#668 실기기 피드백)
      expect(find.text('위치 공개 03:00 | 구역 축소 03:00'), findsOneWidget);
      expect(find.textContaining('다음 도둑 위치 공개까지'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('마지막 축소가 끝나면 축소 줄을 숨긴다', (tester) async {
    await withClock(Clock.fixed(DateTime(2026, 11, 8, 12, 27)), () async {
      await pumpShrinkTimer(tester, null);
      expect(find.textContaining('구역 축소'), findsNothing);
      expect(find.text('다음 도둑 위치 공개까지 03:00'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('구역 밖에 있는 동안은 작은 줄 자리에 경고만 빨갛게 보여 준다', (tester) async {
    await withClock(Clock.fixed(DateTime(2026, 11, 8, 12, 12)), () async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => MaterialApp(
            locale: const Locale('ko'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: GameTimerText(
              startTime: DateTime(2026, 11, 8, 12),
              totalDuration: const Duration(minutes: 30),
              policeWaitMinutes: 5,
              locationRevealIntervalMinutes: 5,
              nextShrinkAt: (_) => DateTime(2026, 11, 8, 12, 15),
              zoneWarningAt: (_) =>
                  (count: 1, untilNext: const Duration(seconds: 42)),
            ),
          ),
        ),
      );
      expect(find.text('경고 1/3 · 다음 경고까지 00:42'), findsOneWidget);
      expect(find.textContaining('위치 공개까지'), findsNothing);
      expect(find.textContaining('구역 축소'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
