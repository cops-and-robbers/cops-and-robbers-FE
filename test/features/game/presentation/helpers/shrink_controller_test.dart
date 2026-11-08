import 'package:clock/clock.dart';
import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/game/domain/shrink_schedule.dart';
import 'package:cops_and_robbers/features/game/presentation/helpers/shrink_controller.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const center = GeoPoint(latitude: 37.55, longitude: 127.07);
  final start = DateTime(2026, 11, 8, 12);
  final at = shrinkClockFor(
    area: const GameAreaEntity(
      playground: AreaShape.circle(center: center, radiusInMeters: 1000),
      jail: AreaShape.circle(center: center, radiusInMeters: 10),
    ),
    finalRadius: 200,
    start: start,
    roundDurationMinutes: 30,
    policeWaitMinutes: 5,
  )!;

  /// [entered]에 게임 화면에 들어와 [minutes]분 동안 둔다. 알림을 (차수, 연출 여부)로 모은다.
  List<(int, bool)> run(
    DateTime entered, {
    Duration wait = Duration.zero,
    void Function(ShrinkController c, FakeAsync async)? during,
  }) {
    final calls = <(int, bool)>[];
    fakeAsync((async) {
      withClock(async.getClock(entered), () {
        final c = ShrinkController(
          stateAt: at,
          onChange: (s, {required animate}) => calls.add((s.stage, animate)),
        )..start();
        during?.call(c, async);
        async.elapse(wait);
        c.dispose();
      });
    });
    return calls;
  }

  test('entering_mid_game_reports_current_stage_without_animation', () {
    expect(run(DateTime(2026, 11, 8, 12, 3)), [(0, false)]);
  });

  test('at_ten_minutes_zone_shrinks_with_animation', () {
    final calls = run(
      DateTime(2026, 11, 8, 12, 9, 50),
      wait: const Duration(seconds: 11),
    );
    expect(calls, [(0, false), (1, true)]);
  });

  test('all_four_shrinks_fire_once_each', () {
    final calls = run(
      DateTime(2026, 11, 8, 12, 3),
      wait: const Duration(minutes: 27),
    );
    expect(calls, [(0, false), (1, true), (2, true), (3, true), (4, true)]);
  });

  test('reopening_app_at_15m07s_draws_stage_two_without_animation', () {
    // 꺼져 있던 사이 지나간 축소는 연출·알림을 다시 띄우지 않는다 (DEC-0149)
    expect(run(DateTime(2026, 11, 8, 12, 15, 7)), [(2, false)]);
  });

  test('no_timer_after_final_shrink', () {
    expect(
      run(DateTime(2026, 11, 8, 12, 26), wait: const Duration(minutes: 10)),
      [(4, false)],
    );
  });

  test('disposed_controller_stays_silent_at_shrink_time', () {
    final calls = <(int, bool)>[];
    fakeAsync((async) {
      withClock(async.getClock(DateTime(2026, 11, 8, 12, 9)), () {
        final c = ShrinkController(
          stateAt: at,
          onChange: (s, {required animate}) => calls.add((s.stage, animate)),
        )..start();
        c.dispose();
        async.elapse(const Duration(minutes: 5));
      });
    });
    expect(calls, [(0, false)]);
  });

  test('resume_recompute_does_not_repeat_the_same_stage', () {
    // 앱 복귀(resumed) 때 다시 계산해도 차수가 그대로면 알리지 않는다
    final calls = run(
      DateTime(2026, 11, 8, 12, 11),
      during: (c, async) => c.recompute(animate: false),
    );
    expect(calls, [(1, false)]);
  });

  test(
    'timer_firing_late_after_ios_suspend_redraws_without_replaying_notice',
    () {
      // iOS가 앱을 멈췄다 깨우면 지난 타이머가 resumed보다 먼저 돈다 — 지나간 축소는 되살리지 않는다 (DEC-0149)
      final calls = <(int, bool)>[];
      var lag = Duration.zero;
      fakeAsync((async) {
        final fake = async.getClock(DateTime(2026, 11, 8, 12, 9));
        withClock(Clock(() => fake.now().add(lag)), () {
          final c = ShrinkController(
            stateAt: at,
            onChange: (s, {required animate}) => calls.add((s.stage, animate)),
          )..start();
          lag = const Duration(minutes: 3); // 멈춰 있던 동안 시계만 흘렀다
          async.elapse(const Duration(minutes: 1));
          c.dispose();
        });
      });
      expect(calls, [(0, false), (1, false)]);
    },
  );
}
