import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/dispatch_countdown.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chase_scene_test.dart' show installVibration;

// 14:00에 시작한 5분 대기 방 — 경찰은 14:05:00에 출동한다
final release = DateTime(2026, 10, 16, 14, 5);

/// 테스트가 움직이는 기기 시계. [advance]가 화면 시간과 함께 민다.
late DateTime fakeNow;

Future<void> pumpCountdown(
  WidgetTester tester, {
  required Duration beforeRelease,
  required VoidCallback onDone,
  Locale locale = const Locale('ko'),
  bool reduceMotion = false,
}) async {
  fakeNow = release.subtract(beforeRelease);
  tester.view.physicalSize = const Size(393, 852) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, _) => MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: reduceMotion),
            child: Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: DispatchCountdown(
                      releaseAt: release,
                      onDone: onDone,
                      now: () => fakeNow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> advance(WidgetTester tester, Duration d) async {
  for (var i = 0; i < d.inMilliseconds ~/ 50; i++) {
    fakeNow = fakeNow.add(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets(
    'countdown_shows_three_when_opened_three_seconds_before_dispatch',
    (tester) async {
      await pumpCountdown(
        tester,
        beforeRelease: const Duration(milliseconds: 2500),
        onDone: () {},
      );
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
    },
  );

  testWidgets('countdown_shows_go_word_when_dispatch_time_arrives', (
    tester,
  ) async {
    await pumpCountdown(
      tester,
      beforeRelease: const Duration(milliseconds: 500),
      onDone: () {},
    );
    await advance(tester, const Duration(milliseconds: 600));
    expect(find.text('출동!'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('countdown_shows_lets_go_when_player_uses_english', (
    tester,
  ) async {
    await pumpCountdown(
      tester,
      beforeRelease: const Duration(milliseconds: 100),
      onDone: () {},
      locale: const Locale('en'),
    );
    await advance(tester, const Duration(milliseconds: 200));
    expect(find.text("Let's go!"), findsOneWidget);
  });

  testWidgets('countdown_calls_done_once_when_circle_finishes_opening', (
    tester,
  ) async {
    var done = 0;
    await pumpCountdown(
      tester,
      beforeRelease: const Duration(seconds: 1),
      onDone: () => done++,
    );
    // 1초 + "출동!" 1.2초 + 원형 열기 1초 = 3.2초
    await advance(tester, const Duration(milliseconds: 3100));
    expect(done, 0);
    await advance(tester, const Duration(milliseconds: 300));
    expect(done, 1);
    await advance(tester, const Duration(milliseconds: 500));
    expect(done, 1);
  });

  testWidgets('countdown_still_counts_and_finishes_when_reduce_motion_is_on', (
    tester,
  ) async {
    var done = 0;
    await pumpCountdown(
      tester,
      beforeRelease: const Duration(milliseconds: 1500),
      onDone: () => done++,
      reduceMotion: true,
    );
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    await advance(tester, const Duration(milliseconds: 3800));
    expect(done, 1);
  });

  // 대기 화면은 10~6초만 울리고, 5~1초는 카운팅이 이어받는다 — 5초가 빠지면 박자가 끊긴다
  testWidgets('player_feels_every_second_from_five_when_overlay_opens_at_six', (
    tester,
  ) async {
    final vibration = await installVibration();
    await pumpCountdown(
      tester,
      beforeRelease: const Duration(seconds: 6), // 덮는 1초부터 띄운다
      onDone: () {},
    );
    await advance(tester, const Duration(milliseconds: 5900));
    expect(vibration.vibrateCalls, 5); // 5, 4, 3, 2, 1
    await advance(tester, const Duration(milliseconds: 200));
    expect(vibration.vibrateCalls, 6); // "출동!" 출동 진동
    await advance(tester, const Duration(seconds: 3));
  });

  testWidgets(
    'countdown_hides_number_while_screen_closes_in_when_six_seconds_before',
    (tester) async {
      await pumpCountdown(
        tester,
        beforeRelease: const Duration(milliseconds: 5600),
        onDone: () {},
      );
      await tester.pump();
      expect(find.text('6'), findsNothing);
      expect(find.text('5'), findsNothing);
      await advance(tester, const Duration(milliseconds: 700));
      expect(find.text('5'), findsOneWidget);
      await advance(tester, const Duration(seconds: 8));
    },
  );

  // 1초의 떨림은 사이렌·숫자만 — 검은 바탕이 밀리면 가장자리 틈으로 지도가 비쳐 화면이 깨져 보인다
  testWidgets('screen_edges_stay_covered_when_last_second_shakes', (
    tester,
  ) async {
    await pumpCountdown(
      tester,
      beforeRelease: const Duration(milliseconds: 900),
      onDone: () {},
    );
    final background = find.byWidgetPredicate(
      (w) => w is ColoredBox && w.color == AppColors.pureBlack,
    );
    for (var i = 0; i < 10; i++) {
      await advance(tester, const Duration(milliseconds: 50));
      expect(
        tester.getRect(background),
        const Offset(0, 0) & const Size(393, 852),
      );
    }
    await advance(tester, const Duration(seconds: 3));
  });

  // 카운팅은 탭해도 넘어가지 않는다 — 모두가 같은 순간에 "출동!"을 본다
  testWidgets('countdown_runs_to_the_end_when_player_taps_it', (tester) async {
    var done = 0;
    await pumpCountdown(
      tester,
      beforeRelease: const Duration(seconds: 3),
      onDone: () => done++,
    );
    await tester.pump();
    await tester.tapAt(const Offset(196, 426));
    await advance(tester, const Duration(milliseconds: 500));
    expect(find.text('3'), findsOneWidget);
    expect(done, 0);
    await advance(tester, const Duration(milliseconds: 5000));
    expect(done, 1);
  });
}
