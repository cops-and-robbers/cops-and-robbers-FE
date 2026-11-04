import 'package:cops_and_robbers/core/widgets/tutorial/tutorial_player.dart';
import 'package:cops_and_robbers/core/widgets/tutorial/tutorial_script.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

TutorialCopy _copy(AppLocalizations l10n, TutorialScene scene) =>
    TutorialCopy('장면 ${scene.index}', '설명 ${scene.index}');

Future<void> _pump(
  WidgetTester tester, {
  required List<TutorialScene> scenes,
  VoidCallback? onFinished,
  Stream<Offset> Function()? tilt,
  Size size = const Size(393, 852),
  Locale locale = const Locale('ko'),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, _) => TutorialPlayer(
          scenes: scenes,
          copyOf: _copy,
          finishLabel: (l10n) => l10n.onboardingStartButton,
          onFinished: onFinished ?? () {},
          tiltStream: tilt ?? () => const Stream.empty(),
        ),
      ),
    ),
  );
  await _advance(tester, 100);
}

Future<void> _advance(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 32) {
    await tester.pump(const Duration(milliseconds: 32));
  }
}

void main() {
  testWidgets('next_button_ignores_tap_when_scene_animation_is_playing', (
    tester,
  ) async {
    await _pump(
      tester,
      scenes: const [TutorialScene.zoneIn, TutorialScene.pick],
    );

    await tester.tap(find.text('다음'), warnIfMissed: false);
    await _advance(tester, 100);

    expect(find.text('장면 ${TutorialScene.zoneIn.index}'), findsOneWidget);
  });

  testWidgets('next_button_moves_to_next_scene_when_animation_has_finished', (
    tester,
  ) async {
    await _pump(
      tester,
      scenes: const [TutorialScene.zoneIn, TutorialScene.pick],
    );
    await _advance(tester, 1600);

    await tester.tap(find.text('다음'));
    await _advance(tester, 300);

    expect(find.text('장면 ${TutorialScene.pick.index}'), findsOneWidget);
  });

  testWidgets('skip_button_finishes_tutorial_when_scene_animation_is_playing', (
    tester,
  ) async {
    var finished = false;
    await _pump(
      tester,
      scenes: const [TutorialScene.zoneIn, TutorialScene.pick],
      onFinished: () => finished = true,
    );

    await tester.tap(find.text('건너뛰기'));
    await tester.pump();

    expect(finished, isTrue);
  });

  testWidgets('last_scene_shows_start_button_and_finishes_when_tapped', (
    tester,
  ) async {
    var finished = false;
    await _pump(
      tester,
      scenes: const [TutorialScene.zoneIn],
      onFinished: () => finished = true,
    );
    await _advance(tester, 1600);

    await tester.tap(find.text('시작하기'));
    await tester.pump();

    expect(finished, isTrue);
  });

  testWidgets('tutorial_does_not_overflow_when_small_phone_shows_japanese', (
    tester,
  ) async {
    await _pump(
      tester,
      scenes: tutorialScenes(TutorialMode.classic),
      size: const Size(320, 568),
      locale: const Locale('ja'),
    );
    await _advance(tester, 1600);

    expect(tester.takeException(), isNull);
  });

  testWidgets('scan_scene_moves_qr_by_drag_when_motion_sensor_reports_error', (
    tester,
  ) async {
    await _pump(
      tester,
      scenes: const [TutorialScene.scan, TutorialScene.zoneIn],
      tilt: () => Stream<Offset>.error(StateError('센서 없음')),
    );
    await _advance(tester, 2000);
    expect(find.text('체포!'), findsNothing);

    await tester.drag(find.byKey(tutorialStageKey), const Offset(0, 100));
    await _advance(tester, 1000);

    expect(tester.takeException(), isNull);
    expect(find.text('체포!'), findsOneWidget);
  });

  testWidgets('stage_keeps_whole_zone_visible_when_phone_is_tall', (
    tester,
  ) async {
    await _pump(
      tester,
      scenes: const [TutorialScene.zoneIn],
      size: const Size(393, 932),
    );

    final stage = tester.getSize(find.byKey(tutorialStageKey));

    // 무대가 폭보다 높아지면 화면을 채우려 커지면서 구역 원 양옆이 잘린다
    expect(stage.height, lessThanOrEqualTo(stage.width * 486 / 393 + 1));
  });
}
