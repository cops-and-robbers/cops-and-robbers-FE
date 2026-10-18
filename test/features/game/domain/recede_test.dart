import 'package:cops_and_robbers/features/game/domain/recede.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mouse_starts_full_size_on_near_ground_when_police_wait_just_began', () {
    final pose = recede(0, policeWaitRecede);
    expect(pose.width, 96);
    expect(pose.feetY, closeTo(464.7, 1e-9));
  });

  test(
    'mouse_ends_small_with_feet_below_horizon_when_police_is_dispatched',
    () {
      final pose = recede(1, policeWaitRecede);
      expect(pose.width, closeTo(30, 1e-9));
      expect(pose.feetY, closeTo(420.2, 0.1));
      expect(pose.feetY, greaterThan(startHorizonY)); // 건물·나무 위에 떠 보이지 않게
    },
  );

  test(
    'cat_ends_with_feet_below_horizon_when_robber_screen_reaches_dispatch',
    () {
      expect(recede(1, robberWaitRecede).feetY, closeTo(427.9, 0.1));
    },
  );

  // 거리는 1/크기에 비례한다. 같은 시간 간격마다 거리가 같은 만큼 늘면 같은 속도다.
  test('mouse_moves_away_at_constant_speed_when_wait_progresses_evenly', () {
    double distance(double p) => 1 / recede(p, policeWaitRecede).width;
    final steps = [
      for (var i = 0; i < 4; i++) distance((i + 1) / 4) - distance(i / 4),
    ];
    for (final step in steps) {
      expect(step, closeTo(steps.first, 1e-12));
    }
  });

  test('pose_stays_at_end_when_progress_overshoots_after_dispatch', () {
    expect(recede(1.4, policeWaitRecede).width, closeTo(30, 1e-9));
  });
}
