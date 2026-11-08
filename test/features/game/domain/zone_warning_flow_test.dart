import 'package:cops_and_robbers/features/game/domain/zone_warning_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 11, 8, 12, 10);
  DateTime sec(int s) => t0.add(Duration(seconds: s));

  /// 줄어든 구역 밖에서 1초마다 위치가 들어온다. 강제 체포를 부른 시각(초)을 모은다.
  List<int> walkOutside(
    ZoneWarningFlow flow, {
    required int seconds,
    bool eligible = true,
  }) {
    final calls = <int>[];
    for (var s = 0; s <= seconds; s++) {
      if (flow.onPosition(
        eligible: eligible,
        countsAsOutside: true,
        at: sec(s),
      )) {
        calls.add(s);
      }
    }
    return calls;
  }

  test(
    'robber_outside_shrunk_zone_for_three_minutes_calls_force_arrest_once',
    () {
      final flow = ZoneWarningFlow();
      expect(walkOutside(flow, seconds: 200), [180]);
    },
  );

  test('failed_force_arrest_is_retried_after_five_seconds', () {
    final flow = ZoneWarningFlow();
    expect(walkOutside(flow, seconds: 180), [180]);
    flow.onForceArrestResult(ForceArrestResult.retry);
    final again = <int>[];
    for (var s = 181; s <= 190; s++) {
      if (flow.onPosition(eligible: true, countsAsOutside: true, at: sec(s))) {
        again.add(s);
      }
    }
    expect(again, [185]);
  });

  test('already_jailed_rejection_resets_without_calling_again', () {
    // 응답만 잃고 서버에서는 이미 잡힌 경우 — 계속 부르지 않고 0으로 돌린다
    final flow = ZoneWarningFlow();
    walkOutside(flow, seconds: 180);
    flow.onForceArrestResult(ForceArrestResult.terminal);
    expect(flow.warnings, 0);
  });

  test('event_game_robber_never_calls_force_arrest', () {
    final flow = ZoneWarningFlow();
    expect(walkOutside(flow, seconds: 300, eligible: false), isEmpty);
    expect(flow.warnings, 0);
  });

  test('time_spent_jailed_after_being_caught_outside_is_not_counted', () {
    // 구역 밖 30초 → 경찰에게 잡혀 10분 수감(판정 대상 아님) → 탈옥 직후 다시 밖
    final flow = ZoneWarningFlow();
    walkOutside(flow, seconds: 30);
    flow.onPosition(eligible: false, countsAsOutside: true, at: sec(300));
    flow.onPosition(eligible: true, countsAsOutside: true, at: sec(630));
    expect(flow.outsideSeconds, 30);
  });

  test('restored_75_seconds_after_app_restart_show_first_warning', () {
    final flow = ZoneWarningFlow(restoredSeconds: 75);
    expect(flow.warnings, 1);
  });

  test('countdown_ticks_between_location_updates_while_outside', () {
    final flow = ZoneWarningFlow()
      ..onPosition(eligible: true, countsAsOutside: true, at: sec(0))
      ..onPosition(eligible: true, countsAsOutside: true, at: sec(10));
    // 마지막 위치 뒤 5초가 더 흘렀다
    expect(flow.untilNextWarningAt(sec(15)), const Duration(seconds: 45));
  });

  test('saves_when_warning_changes_or_every_ten_seconds', () {
    final flow = ZoneWarningFlow();
    flow.onPosition(eligible: true, countsAsOutside: true, at: sec(0));
    expect(flow.shouldSave(sec(0)), isTrue);
    flow.markSaved(sec(0));
    flow.onPosition(eligible: true, countsAsOutside: true, at: sec(5));
    expect(flow.shouldSave(sec(5)), isFalse);
    flow.onPosition(eligible: true, countsAsOutside: true, at: sec(10));
    expect(flow.shouldSave(sec(10)), isTrue);
  });
}
