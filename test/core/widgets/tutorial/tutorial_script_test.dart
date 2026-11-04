import 'package:cops_and_robbers/core/widgets/tutorial/tutorial_script.dart';
import 'package:cops_and_robbers/core/widgets/tutorial/tutorial_stage.dart';
import 'package:flutter_test/flutter_test.dart';

/// 장면 하나를 재생한다. 앞 장면이 끝난 상태에서 이어지는 실제 흐름과 같게 처음부터 돌린다.
TutorialStage _playUpTo(List<TutorialScene> scenes, TutorialScene last) {
  final stage = TutorialStage();
  for (final scene in scenes) {
    stage.beginScene();
    playScene(scene, stage);
    if (scene == last) return stage;
    _runUntilIdle(stage);
  }
  throw StateError('$last 장면이 목록에 없다');
}

void _runUntilIdle(TutorialStage stage) {
  for (var i = 0; i < 2000 && stage.timeline.isPlaying; i++) {
    stage.update(16);
  }
}

void _run(TutorialStage stage, int ms) {
  for (var t = 0; t < ms; t += 16) {
    stage.update(16);
  }
}

void main() {
  final classic = tutorialScenes(TutorialMode.classic);

  test('classic_tutorial_shows_map_before_chase_when_following_game_order', () {
    expect(classic.take(3), [
      TutorialScene.zoneIn,
      TutorialScene.flat,
      TutorialScene.chase,
    ]);
    expect(classic.length, 10);
  });

  test('tag_tutorial_ends_game_without_jail_when_caught', () {
    final tag = tutorialScenes(TutorialMode.tag);

    expect(tag.length, 6);
    expect(tag, contains(TutorialScene.out));
    expect(tag, isNot(contains(TutorialScene.jail)));
    expect(tag, isNot(contains(TutorialScene.scan)));
  });

  test('onboarding_mentions_no_role_scene_when_app_is_opened_first_time', () {
    expect(onboardingScenes, isNot(contains(TutorialScene.chase)));
    expect(onboardingScenes, isNot(contains(TutorialScene.jail)));
    expect(onboardingScenes.length, 6);
  });

  test('theme_is_dark_only_when_robber_turn', () {
    final stage = TutorialStage();
    final darkScenes = <TutorialScene>[];
    for (final scene in classic) {
      stage.beginScene();
      playScene(scene, stage);
      _runUntilIdle(stage);
      if (stage.dark) darkScenes.add(scene);
    }

    expect(darkScenes, [
      TutorialScene.showQr,
      TutorialScene.jail,
      TutorialScene.rescue,
      TutorialScene.escape,
    ]);
  });

  test('scan_scene_arrests_when_qr_is_held_inside_frame', () {
    final stage = _playUpTo(classic, TutorialScene.scan);
    _runUntilIdle(stage);

    stage.moveQr(0, 60);
    _run(stage, 1500);

    expect(stage.scanned, isTrue);
  });

  test('scan_scene_keeps_tilt_hint_when_qr_is_not_scanned', () {
    final stage = _playUpTo(classic, TutorialScene.scan);
    _runUntilIdle(stage);
    _run(stage, 10000);

    expect(stage.scanned, isFalse);
    expect(stage.q['tilt'], 1);
    expect(stage.timeline.isPlaying, isFalse);
  });

  test('scene_after_scan_clears_qr_when_user_skipped_the_scan', () {
    final stage = _playUpTo(classic, TutorialScene.scan);
    _runUntilIdle(stage);

    stage.beginScene();
    playScene(TutorialScene.jail, stage);
    _runUntilIdle(stage);

    expect(stage.q['tg'], 0);
    expect(stage.q['tilt'], 0);
    expect(stage.q['fr'], 0);
  });

  test('onboarding_hides_invite_card_when_next_scene_starts_timer', () {
    final stage = _playUpTo(onboardingScenes, TutorialScene.guide);
    _runUntilIdle(stage);

    expect(stage.q['inv'], 0);
    expect(stage.q['a1'], 0);
    expect(stage.q['bar'], 0);
  });

  test('onboarding_shows_zone_exit_banner_when_dot_is_outside_area', () {
    final stage = _playUpTo(onboardingScenes, TutorialScene.guide);

    _run(stage, 1800);
    expect(stage.q['zb'], greaterThan(.9));

    _runUntilIdle(stage);
    expect(stage.q['zb'], 0);
  });

  test('show_qr_scene_keeps_next_locked_when_qr_is_still_rising', () {
    final stage = _playUpTo(classic, TutorialScene.showQr);

    _run(stage, 2300);

    expect(stage.timeline.isPlaying, isTrue);
    expect(stage.qrY, greaterThan(230));
  });

  test('stage_needs_no_frames_when_scene_has_finished_animating', () {
    final stage = _playUpTo(classic, TutorialScene.chase);
    expect(stage.needsFrame, isTrue);

    _runUntilIdle(stage);
    expect(stage.needsFrame, isFalse);
  });

  test('stage_keeps_animating_when_scan_is_waiting_for_the_qr', () {
    final stage = _playUpTo(classic, TutorialScene.scan);
    _runUntilIdle(stage);

    expect(stage.needsFrame, isTrue);
  });

  test('stage_keeps_animating_when_footprints_are_still_blinking', () {
    final stage = _playUpTo(classic, TutorialScene.flat);
    _runUntilIdle(stage);

    expect(stage.needsFrame, isTrue);
  });
}
