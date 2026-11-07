import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/stripe_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 역할 배너와 같은 설정(띠 154, 머묾 2.35초)
Future<void> pumpBanner(
  WidgetTester tester, {
  required VoidCallback onDone,
  VoidCallback? onRevealNext,
  bool reduceMotion = false,
}) async {
  tester.view.physicalSize = const Size(393 * 3, 852 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: AppColors.black100)),
            Positioned.fill(
              child: StripeBanner(
                color: AppColors.blue,
                bandHeight: 154,
                hold: const Duration(milliseconds: 2350),
                angleDegrees: -4.6,
                bandOffsetY: 0,
                onDone: onDone,
                onRevealNext: onRevealNext,
                content: (_, _, _, _) => const Text('내 역할'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 애니메이션은 프레임마다 진행하므로 50ms씩 나눠 흘린다.
Future<void> advance(WidgetTester tester, Duration d) async {
  for (var i = 0; i < d.inMilliseconds ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  // 들어오기 0.9 + 머묾 2.35 + 나가기 0.7 = 3.95초
  testWidgets(
    'role_banner_finishes_after_about_four_seconds_when_player_waits',
    (tester) async {
      var done = 0;
      await pumpBanner(tester, onDone: () => done++);
      await advance(tester, const Duration(milliseconds: 3900));
      expect(done, 0);
      await advance(
        tester,
        const Duration(milliseconds: 300),
      ); // 프레임 간격(50ms) 여유
      expect(done, 1);
    },
  );

  // 시안 v40: 나가기 시작(3.25초) 0.45초 뒤인 3.7초에 다음 장면이 띠 아래에서 뜬다
  testWidgets('next_scene_appears_while_stripes_leave_when_role_banner_ends', (
    tester,
  ) async {
    var next = 0, done = 0;
    await pumpBanner(tester, onDone: () => done++, onRevealNext: () => next++);
    // 첫 줄이 빠지기 시작하는 3.37초(나가기 3.25 + 0.12)에 띠 자리로 다음 장면이 비친다
    await advance(tester, const Duration(milliseconds: 3300));
    expect(next, 0);
    await advance(tester, const Duration(milliseconds: 150));
    expect(next, 1);
    expect(done, 0); // 띠는 아직 빠지는 중
    await advance(tester, const Duration(milliseconds: 700));
    expect(next, 1);
    expect(done, 1);
  });

  // 역할 배너는 탭해도 넘어가지 않는다 — 내 역할을 끝까지 보여 준다(0.9 + 2.35 + 0.7 = 3.95초)
  testWidgets('role_banner_stays_full_time_when_player_taps_while_it_holds', (
    tester,
  ) async {
    var done = 0;
    await pumpBanner(tester, onDone: () => done++);
    await advance(tester, const Duration(milliseconds: 1500));
    await tester.tapAt(const Offset(196, 426));
    await advance(tester, const Duration(milliseconds: 2000)); // 3.5초
    expect(done, 0);
    await advance(tester, const Duration(milliseconds: 700)); // 4.2초
    expect(done, 1);
  });

  testWidgets('role_banner_stays_full_time_when_player_taps_while_it_enters', (
    tester,
  ) async {
    var done = 0, next = 0;
    await pumpBanner(tester, onDone: () => done++, onRevealNext: () => next++);
    await advance(tester, const Duration(milliseconds: 300));
    await tester.tapAt(const Offset(196, 426));
    await advance(tester, const Duration(milliseconds: 2900)); // 3.2초
    expect(next, 0); // 다음 장면은 3.37초에 비친다
    expect(done, 0);
    await advance(tester, const Duration(milliseconds: 1000)); // 4.2초
    expect(next, 1);
    expect(done, 1);
  });

  // 움직임 줄이기: 0.22초 페이드 인 + 머묾 2.35 + 0.2초 페이드 아웃 = 2.77초
  testWidgets(
    'banner_finishes_sooner_without_stripes_when_reduce_motion_is_on',
    (tester) async {
      var done = 0;
      var next = 0;
      await pumpBanner(
        tester,
        onDone: () => done++,
        onRevealNext: () => next++,
        reduceMotion: true,
      );
      await advance(tester, const Duration(milliseconds: 2900));
      expect(done, 1);
      expect(next, 1); // 페이드가 0.45초보다 짧아도 다음 장면은 한 번 뜬다
    },
  );

  // 줄 7개가 띠 폭만큼 팀색으로 칠해져야 배너가 보인다 — 폭 0이면 글만 떠 있다
  testWidgets(
    'stripes_fill_band_width_in_team_color_when_role_banner_settles',
    (tester) async {
      await pumpBanner(tester, onDone: () {});
      await advance(tester, const Duration(milliseconds: 1000));
      final stripes = find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == AppColors.blue,
      );
      expect(stripes, findsNWidgets(7));
      for (final e in stripes.evaluate()) {
        expect(
          tester.getSize(find.byWidget(e.widget)).width,
          closeTo(390 * 393 / 300, 0.01),
        );
      }
    },
  );
}
