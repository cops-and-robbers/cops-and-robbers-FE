import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/features/game/domain/ar_capture_state.dart';

void main() {
  // 왼쪽 약 17도, 위쪽 약 6도에 놓인 그림을 찾는 상황
  const start = ArCaptureState(targetYaw: 0.3, targetPitch: 0.1);

  /// 폰을 [seconds] 동안 일정한 속도로 움직이는 상황을 60Hz 이벤트로 흘려 보낸다.
  ArCaptureState move(
    ArCaptureState state, {
    required double seconds,
    double yawRate = 0,
    double pitchRate = 0,
  }) {
    var next = state;
    const dt = 1 / 60;
    for (var i = 0; i < (seconds / dt).round(); i++) {
      next = next.advance(yawRate: yawRate, pitchRate: pitchRate, dt: dt);
    }
    return next;
  }

  test('picture_stays_out_of_frame_when_player_has_not_moved_phone', () {
    final state = move(start, seconds: 5);

    expect(state.inFrame, isFalse);
    expect(state.heldSeconds, 0);
    expect(state.isCaptured, isFalse);
  });

  test('capture_succeeds_when_player_turns_to_picture_and_holds_for_3s', () {
    // 왼쪽 위로 0.5초 돌려 그림을 틀에 넣는다
    final aimed = move(start, seconds: 0.5, yawRate: 0.6, pitchRate: 0.2);
    expect(aimed.inFrame, isTrue);

    expect(move(aimed, seconds: 2.5).isCaptured, isFalse);
    expect(move(aimed, seconds: 3.1).isCaptured, isTrue);
  });

  test('hold_shrinks_gradually_when_player_swings_phone_away_mid_hold', () {
    final aimed = move(start, seconds: 0.5, yawRate: 0.6, pitchRate: 0.2);
    final held = move(aimed, seconds: 2);

    final swungAway = move(held, seconds: 0.5, yawRate: -2);

    // 0으로 돌아가지 않고, 0.5초 동안 벗어난 만큼만 조금 줄어든다
    expect(swungAway.heldSeconds, lessThan(held.heldSeconds));
    expect(swungAway.heldSeconds, greaterThan(held.heldSeconds - 0.5));
  });

  test('hold_runs_out_when_player_stays_away_long_enough', () {
    final aimed = move(start, seconds: 0.5, yawRate: 0.6, pitchRate: 0.2);
    final held = move(aimed, seconds: 2);

    final swungAway = move(held, seconds: 0.5, yawRate: -2);

    expect(move(swungAway, seconds: 10).heldSeconds, 0);
  });

  test('phone_counts_as_lowered_when_player_looks_down_at_screen', () {
    const lookingDown = ArCaptureState(
      targetYaw: 0,
      targetPitch: 0,
      pitch: -pi / 4,
    );
    const upright = ArCaptureState(targetYaw: 0, targetPitch: 0);

    expect(lookingDown.isPhoneLowered, isTrue);
    expect(upright.isPhoneLowered, isFalse);
  });

  test('picture_stays_still_until_player_first_brings_it_into_frame', () {
    var state = start;
    const dt = 1 / 60;
    for (var i = 0; i < 120; i++) {
      state = state.advance(
        yawRate: 0,
        pitchRate: 0,
        dt: dt,
        targetYawRate: 0.35,
      );
    }

    expect(state.targetYaw, start.targetYaw);
    expect(state.hasEntered, isFalse);
  });

  test(
    'picture_shows_on_the_near_side_when_player_turned_almost_full_circle',
    () {
      // 왼쪽으로 350도 돌았으면 그림은 왼쪽으로 한 바퀴가 아니라 바로 옆에 있다
      final turned = move(start, seconds: 1, yawRate: 350 * pi / 180);

      expect(turned.yawOffset.abs(), lessThan(pi / 2));
    },
  );

  group('cameraElevation', () {
    test('is_level_when_phone_is_held_upright', () {
      expect(cameraElevation(y: 9.8, z: 0), closeTo(0, 0.01));
    });

    test('points_45_degrees_down_when_player_looks_down_at_screen', () {
      expect(cameraElevation(y: 6.9, z: 6.9), closeTo(-pi / 4, 0.01));
    });

    test('points_straight_down_when_phone_lies_flat_on_table', () {
      expect(cameraElevation(y: 0, z: 9.8), closeTo(-pi / 2, 0.01));
    });
  });

  test('player_must_raise_phone_when_opened_while_looking_down', () {
    // 45도 내려다본 채로 화면을 열어도 그림은 눈높이에 있다
    const opened = ArCaptureState(
      targetYaw: 0,
      targetPitch: 0.1,
      pitch: -pi / 4,
    );
    expect(opened.inFrame, isFalse);

    // 초당 약 50도로 1초 들어 올리면 틀에 들어온다
    final raised = move(opened, seconds: 1, pitchRate: pi / 4 + 0.1);
    expect(raised.inFrame, isTrue);
  });

  test('pitch_returns_to_real_camera_angle_when_gyro_has_drifted', () {
    // 자이로가 57도쯤 밀렸지만 실제로는 폰을 수평으로 들고 있는 상황 (60Hz 5초)
    var state = const ArCaptureState(targetYaw: 0, targetPitch: 0, pitch: 1);
    for (var i = 0; i < 300; i++) {
      state = state.correctPitch(0);
    }

    expect(state.pitch, closeTo(0, 0.01));
  });

  group('moving picture', () {
    /// 그림이 [targetYawRate]로 움직이는 동안 폰을 [yawRate]로 돌리는 상황 (60Hz)
    ArCaptureState chase(
      ArCaptureState state, {
      required double seconds,
      double yawRate = 0,
      double targetYawRate = 0,
      double targetPitchRate = 0,
    }) {
      var next = state;
      const dt = 1 / 60;
      for (var i = 0; i < (seconds / dt).round(); i++) {
        next = next.advance(
          yawRate: yawRate,
          pitchRate: 0,
          dt: dt,
          targetYawRate: targetYawRate,
          targetPitchRate: targetPitchRate,
        );
      }
      return next;
    }

    // 폰을 그림에 정확히 맞춘 채 시작하는 상황
    const aimed = ArCaptureState(targetYaw: 0, targetPitch: 0);

    test('picture_leaves_frame_when_player_stops_following_it', () {
      expect(chase(aimed, seconds: 2, targetYawRate: 0.12).inFrame, isFalse);
    });

    test('capture_succeeds_when_player_follows_moving_picture_for_3s', () {
      final state = chase(
        aimed,
        seconds: 3.1,
        yawRate: 0.12,
        targetYawRate: 0.12,
      );

      expect(state.isCaptured, isTrue);
    });

    test('picture_stays_near_upright_height_when_it_keeps_moving_up', () {
      // 틀 밖에서 찾는 중이어야 포착으로 멈추지 않고 계속 움직인다
      const searching = ArCaptureState(
        targetYaw: 1,
        targetPitch: 0,
        hasEntered: true,
      );
      final state = chase(searching, seconds: 60, targetPitchRate: 0.03);

      expect(state.targetPitch, ArCaptureState.targetPitchLimit);
    });
  });

  test('stays_captured_when_phone_keeps_moving_after_success', () {
    final aimed = move(start, seconds: 0.5, yawRate: 0.6, pitchRate: 0.2);
    final captured = move(aimed, seconds: 3.1);

    expect(move(captured, seconds: 1, yawRate: -2).isCaptured, isTrue);
  });
}
