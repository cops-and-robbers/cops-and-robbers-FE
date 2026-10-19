import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/band_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 장면 자리(폰 393×852)에 띄운다. 보이는 영역 = 눌리는 영역이라 탭으로 확인한다.
Future<void> pumpScene(
  WidgetTester tester, {
  required VoidCallback onTap,
  bool revealFromBand = false,
  bool fold = false,
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
      home: BandTransition(
        revealFromBand: revealFromBand,
        fold: fold,
        child: GestureDetector(
          onTap: onTap,
          child: const ColoredBox(color: AppColors.white),
        ),
      ),
    ),
  );
}

const topCorner = Offset(20, 120); // 띠 바깥 — 남은 시간 숫자가 있는 자리
const center = Offset(196, 426);

void main() {
  // 역할 띠가 빠지는 동안엔 띠 자리로만 장면이 비치고, 다 빠진 뒤 화면 전체로 펼쳐진다
  testWidgets(
    'scene_shows_only_band_strip_then_fills_screen_when_role_banner_leaves',
    (tester) async {
      var taps = 0;
      await pumpScene(tester, onTap: () => taps++, revealFromBand: true);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tapAt(topCorner);
      expect(taps, 0);
      await tester.tapAt(center);
      expect(taps, 1);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tapAt(topCorner);
      expect(taps, 2);
    },
  );

  // 다시 켠 앱처럼 역할 배너 없이 뜨는 장면은 처음부터 화면 전체다
  testWidgets('scene_fills_screen_at_once_when_shown_without_role_banner', (
    tester,
  ) async {
    var taps = 0;
    await pumpScene(tester, onTap: () => taps++);
    await tester.tapAt(topCorner);
    expect(taps, 1);
  });

  testWidgets('scene_fills_screen_at_once_when_reduce_motion_is_on', (
    tester,
  ) async {
    var taps = 0;
    await pumpScene(
      tester,
      onTap: () => taps++,
      revealFromBand: true,
      reduceMotion: true,
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tapAt(topCorner);
    expect(taps, 1);
  });

  // 출동: 장면이 출동 띠 모양으로 접혀 그 자리에서 출동 배너로 이어진다
  testWidgets('scene_folds_into_band_strip_when_dispatch_comes', (
    tester,
  ) async {
    var taps = 0;
    await pumpScene(tester, onTap: () => taps++);
    await pumpScene(tester, onTap: () => taps++, fold: true);
    await tester.pump(BandTransition.foldDuration);
    await tester.tapAt(topCorner);
    expect(taps, 0);
    await tester.tapAt(center);
    expect(taps, 1);
  });
}
