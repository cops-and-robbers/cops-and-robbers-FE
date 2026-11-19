import 'package:cops_and_robbers/core/widgets/tutorial/tutorial_map_painter.dart';
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
    expect(classic.length, 12);
  });

  // 필수 규칙(구역~축소)을 다 본 뒤에 몰라도 게임은 되는 추가 기능을 보여 준다 (#719)
  test('classic_tutorial_shows_radio_then_grid_when_rules_are_done', () {
    expect(classic.skip(classic.indexOf(TutorialScene.shrink)), [
      TutorialScene.shrink,
      TutorialScene.radio,
      TutorialScene.grid,
      TutorialScene.community,
    ]);
  });

  test('extra_feature_scenes_start_right_after_zone_shrink_in_both_modes', () {
    for (final mode in TutorialMode.values) {
      final scenes = tutorialScenes(mode);
      expect(
        tutorialFirstExtraIndex(mode),
        scenes.indexOf(TutorialScene.shrink) + 1,
      );
      expect(scenes[tutorialFirstExtraIndex(mode)], TutorialScene.radio);
    }
  });

  // 경찰이 무전 버튼을 누르고 말한 뒤, 동료가 먼저 말하자 내 버튼이 잠기는 데서 멈춘다
  test('radio_scene_ends_with_teammate_talking_and_my_button_locked', () {
    final stage = _playUpTo(classic, TutorialScene.radio);
    var talked = false;
    for (var i = 0; i < 2000 && stage.timeline.isPlaying; i++) {
      stage.update(16);
      talked |= stage.q['ptt'] > .9;
    }

    expect(talked, isTrue);
    expect(stage.q['radio'], 1);
    expect(stage.q['ptt'], 0);
    expect(stage.q['pill'], 1);
    expect(stage.q['lock'], 1);
    expect(stage.dark, isFalse);
  });

  // QR 체포 장면처럼 + 메뉴에서 좌표를 켜고, 길게 눌러 발견 핑을 찍으면 팀 채팅으로 간다
  test('grid_scene_ends_with_found_ping_in_team_chat_when_grid_is_on', () {
    final stage = _playUpTo(classic, TutorialScene.grid);
    var menuOpened = false;
    var gridPressed = false;
    var cardShown = false;
    for (var i = 0; i < 2000 && stage.timeline.isPlaying; i++) {
      stage.update(16);
      menuOpened |= stage.q['gmenu'] > .9;
      gridPressed |= stage.q['gpress'] > .9;
      cardShown |= stage.q['pcard'] > .9;
    }

    expect(menuOpened && gridPressed && cardShown, isTrue);
    expect(stage.q['gmenu'], 0);
    expect(stage.q['bar'], 0);
    expect(stage.q['pcard'], 0);
    expect(stage.view['grid'], 1);
    expect(stage.q['ping'], 1);
    expect(stage.q['chat'], 1);
  });

  test('grid_scene_hides_radio_button_when_previous_scene_was_radio', () {
    final stage = _playUpTo(classic, TutorialScene.grid);
    _runUntilIdle(stage);

    expect(stage.q['radio'], 0);
    expect(stage.q['pill'], 0);
  });

  test('last_scene_clears_grid_and_chat_when_tutorial_wraps_up', () {
    final stage = _playUpTo(classic, TutorialScene.community);
    _runUntilIdle(stage);

    expect(stage.view['grid'], 0);
    expect(stage.q['ping'], 0);
    expect(stage.q['chat'], 0);
    expect(stage.q['fab'], 0);
  });

  test('tag_tutorial_shows_qr_and_scan_before_out_when_arrest_is_qr', () {
    final tag = tutorialScenes(TutorialMode.tag);

    expect(tag, [
      TutorialScene.zoneIn,
      TutorialScene.flat,
      TutorialScene.chase,
      TutorialScene.showQr,
      TutorialScene.scan,
      TutorialScene.out,
      TutorialScene.shrink,
      TutorialScene.radio,
      TutorialScene.grid,
      TutorialScene.community,
    ]);
    expect(tag, isNot(contains(TutorialScene.jail)));
  });

  test('tag_chase_scene_shows_no_touch_callout_when_seeker_closes_in', () {
    final stage = TutorialStage()..tag = true;
    stage.beginScene();
    playScene(TutorialScene.chase, stage);
    _runUntilIdle(stage);

    expect(stage.callout, isNull);
  });

  test('scan_scene_calls_arrest_callout_when_hider_qr_is_scanned_in_tag', () {
    final tag = tutorialScenes(TutorialMode.tag);
    final stage = TutorialStage()..tag = true;
    for (final scene in tag.takeWhile((s) => s != TutorialScene.scan)) {
      stage.beginScene();
      playScene(scene, stage);
      _runUntilIdle(stage);
    }
    stage.beginScene();
    playScene(TutorialScene.scan, stage);
    _runUntilIdle(stage);
    stage.moveQr(0, 60);
    _run(stage, 1500);

    expect(stage.scanned, isTrue);
    expect(stage.callout, TutorialCallout.arrest);
  });

  test(
    'tag_out_scene_shows_result_without_second_catch_when_hider_was_scanned',
    () {
      final tag = tutorialScenes(TutorialMode.tag);
      final stage = TutorialStage()..tag = true;
      for (final scene in tag.takeWhile((s) => s != TutorialScene.scan)) {
        stage.beginScene();
        playScene(scene, stage);
        _runUntilIdle(stage);
      }
      stage.beginScene();
      playScene(TutorialScene.scan, stage);
      _runUntilIdle(stage);
      stage.moveQr(0, 60);
      _run(stage, 1500);
      _runUntilIdle(stage);

      stage.beginScene();
      playScene(TutorialScene.out, stage);
      var seekerReappeared = false;
      var calloutShown = false;
      for (var i = 0; i < 400 && stage.timeline.isPlaying; i++) {
        stage.update(16);
        seekerReappeared |= stage.cop['op'] > .01;
        calloutShown |= stage.q['fb'] > .01;
      }

      expect(seekerReappeared, isFalse);
      expect(calloutShown, isFalse);
      expect(stage.outed['op'], 1);
      expect(stage.dark, isTrue);
    },
  );

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

  test(
    'community_copy_waits_for_the_art_when_zone_circle_fills_the_screen',
    () {
      final stage = _playUpTo(classic, TutorialScene.community);

      _run(stage, 1400);
      expect(stage.art['op'], closeTo(1, .01));
      expect(stage.view['copy'], 0);

      _runUntilIdle(stage);
      expect(stage.view['copy'], 1);
    },
  );

  // 원이 커지는 동안 지도가 함께 누우면 건물과 나무가 일그러져 보였다.
  // 앞 장면(좌표, #719)이 위에서 내려다보는 시점이라 그 각도를 그대로 이어 간다.
  test('map_keeps_its_angle_when_zone_circle_grows_into_the_last_scene', () {
    final stage = _playUpTo(classic, TutorialScene.community);
    final tiltBefore = stage.cam['tilt'];

    _runUntilIdle(stage);

    expect(stage.cam['tilt'], tiltBefore);
  });

  // 실제 플로팅 메뉴처럼 + 버튼이 눌리면 X로 돌아간다
  test('menu_button_turns_into_close_when_my_qr_item_opens', () {
    final stage = _playUpTo(classic, TutorialScene.showQr);

    _run(stage, 640);
    expect(stage.q['fab'], greaterThan(0));
    expect(stage.q['fabOpen'], 0);

    _run(stage, 500);
    expect(stage.q['fabOpen'], greaterThan(0));
  });

  // 흰 링 대신 내 QR 버튼 자체가 눌린다
  test('my_qr_item_is_pressed_without_ring_when_thief_opens_qr', () {
    final stage = _playUpTo(classic, TutorialScene.showQr);

    _run(stage, 1470);

    expect(stage.q['myQrPress'], greaterThan(0));
    expect(stage.q['rip'], 0);
  });

  // 구역이 줄면 밝은 건물이 새 경계에 걸쳐 원이 잘려 보였다
  test('objects_inside_zone_dim_like_outside_when_zone_has_shrunk', () {
    final stage = _playUpTo(classic, TutorialScene.shrink);
    _runUntilIdle(stage);

    expect(
      tutorialObjectDim(stage.view, stage.view['px'], stage.view['py']),
      tutorialObjectDim(stage.view, 2000, 2000),
    );
  });

  test('objects_inside_zone_stay_bright_when_zone_has_full_size', () {
    final stage = _playUpTo(classic, TutorialScene.zoneIn);
    _runUntilIdle(stage);

    expect(tutorialObjectDim(stage.view, 0, 0), 0);
    expect(tutorialObjectDim(stage.view, 2000, 2000), greaterThan(0));
  });
}
