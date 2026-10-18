import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/stripe_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 역할 배너와 같은 설정(띠 154, 머묾 2.35초)
Future<void> pumpBanner(
  WidgetTester tester, {
  required VoidCallback onDone,
  VoidCallback? onRevealNext,
  bool tapToSkip = true,
  bool dimBehind = true,
  bool reduceMotion = false,
  VoidCallback? onMapTap,
  bool filledStart = false,
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
            Positioned.fill(
              child: GestureDetector(
                onTap: onMapTap,
                child: const ColoredBox(color: AppColors.black100),
              ),
            ),
            Positioned.fill(
              child: StripeBanner(
                color: AppColors.blue,
                bandHeight: 154,
                hold: const Duration(milliseconds: 2350),
                dimBehind: dimBehind,
                tapToSkip: tapToSkip,
                onDone: onDone,
                onRevealNext: onRevealNext,
                filledStart: filledStart,
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

  testWidgets('role_banner_leaves_within_a_second_when_player_taps', (
    tester,
  ) async {
    var done = 0;
    await pumpBanner(tester, onDone: () => done++);
    await advance(tester, const Duration(milliseconds: 1500));
    await tester.tapAt(const Offset(196, 426));
    await advance(tester, const Duration(milliseconds: 800));
    expect(done, 1);
  });

  // 들어오는 중 탭: 줄이 튀지 않도록 다 들어온 뒤(0.9초) 바로 나간다
  testWidgets(
    'role_banner_leaves_right_after_entering_when_player_taps_early',
    (tester) async {
      var done = 0, next = 0;
      await pumpBanner(
        tester,
        onDone: () => done++,
        onRevealNext: () => next++,
      );
      await advance(tester, const Duration(milliseconds: 300));
      await tester.tapAt(const Offset(196, 426));
      await advance(tester, const Duration(milliseconds: 550)); // 0.85초
      expect(next, 0); // 수정 전엔 탭 즉시 나가 0.75초에 떴다
      await advance(tester, const Duration(milliseconds: 400)); // 1.25초
      expect(done, 0); // 수정 전엔 1.0초에 끝났다
      await advance(
        tester,
        const Duration(milliseconds: 450),
      ); // 1.7초: 0.9+0.7+여유
      expect(done, 1);
      expect(next, 1);
    },
  );

  testWidgets('dispatch_banner_lets_map_tap_through_when_shown', (
    tester,
  ) async {
    var mapTaps = 0;
    await pumpBanner(
      tester,
      onDone: () {},
      tapToSkip: false,
      dimBehind: false,
      onMapTap: () => mapTaps++,
    );
    await advance(tester, const Duration(milliseconds: 1500));
    await tester.tapAt(const Offset(196, 426)); // 띠 한가운데
    expect(mapTaps, 1);
    await advance(tester, const Duration(milliseconds: 2600));
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

  // 장면이 출동 띠 모양으로 접힌 자리: 줄이 빨려 들지 않고 그 자리에서 보이며 글이 곧바로 들어온다
  testWidgets(
    'words_appear_within_half_second_when_banner_starts_from_folded_scene',
    (tester) async {
      var done = 0;
      await pumpBanner(
        tester,
        onDone: () => done++,
        dimBehind: false,
        tapToSkip: false,
        filledStart: true,
      );
      await advance(tester, const Duration(milliseconds: 500));
      final words = tester.widget<Opacity>(
        find
            .ancestor(of: find.text('내 역할'), matching: find.byType(Opacity))
            .first,
      );
      expect(words.opacity, greaterThan(0.9));
      // 들어오기 0.47 + 머묾 2.35 + 나가기 0.7
      await advance(tester, const Duration(milliseconds: 3100));
      expect(done, 1);
    },
  );
}
