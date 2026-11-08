import 'package:cops_and_robbers/features/game/domain/zone_warning_accumulator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 11, 8, 12, 10);
  DateTime sec(num s) => t0.add(Duration(milliseconds: (s * 1000).round()));

  test('robber_outside_for_60_seconds_gets_first_warning', () {
    final acc = ZoneWarningAccumulator()
      ..update(countsAsOutside: true, at: sec(0))
      ..update(countsAsOutside: true, at: sec(60));
    expect(acc.warnings, 1);
    expect(acc.untilNextWarning, const Duration(seconds: 60));
  });

  test('stepping_in_and_out_keeps_adding_outside_time', () {
    // 밖 40초 → 안 10초 → 밖 20초 = 누적 60초
    final acc = ZoneWarningAccumulator()
      ..update(countsAsOutside: true, at: sec(0))
      ..update(countsAsOutside: false, at: sec(40))
      ..update(countsAsOutside: true, at: sec(50))
      ..update(countsAsOutside: true, at: sec(70));
    expect(acc.outsideSeconds, 60);
    expect(acc.warnings, 1);
  });

  test('coming_back_inside_does_not_reset_outside_time', () {
    final acc = ZoneWarningAccumulator()
      ..update(countsAsOutside: true, at: sec(0))
      ..update(countsAsOutside: false, at: sec(30))
      ..update(countsAsOutside: false, at: sec(300));
    expect(acc.outsideSeconds, 30);
  });

  test('three_minutes_outside_requires_force_arrest', () {
    final acc = ZoneWarningAccumulator()
      ..update(countsAsOutside: true, at: sec(0))
      ..update(countsAsOutside: true, at: sec(179));
    expect(acc.shouldForceArrest, isFalse);
    acc.update(countsAsOutside: true, at: sec(180));
    expect(acc.shouldForceArrest, isTrue);
    expect(acc.warnings, 3);
  });

  test('reset_after_force_arrest_counts_from_zero', () {
    final acc = ZoneWarningAccumulator()
      ..update(countsAsOutside: true, at: sec(0))
      ..update(countsAsOutside: true, at: sec(180))
      ..reset()
      ..update(countsAsOutside: true, at: sec(200))
      ..update(countsAsOutside: true, at: sec(210));
    expect(acc.outsideSeconds, 10);
    expect(acc.warnings, 0);
  });

  test('time_spent_jailed_after_pause_is_not_counted', () {
    // 구역 밖에서 30초 있다 경찰에게 잡혀 10분 수감 → 탈옥 직후 밖
    final acc = ZoneWarningAccumulator()
      ..update(countsAsOutside: true, at: sec(0))
      ..update(countsAsOutside: true, at: sec(30))
      ..pause()
      ..update(countsAsOutside: true, at: sec(630));
    expect(acc.outsideSeconds, 30);
  });

  test('restored_seconds_continue_after_app_restart', () {
    final acc = ZoneWarningAccumulator(outsideSeconds: 75);
    expect(acc.warnings, 1);
    expect(acc.untilNextWarning, const Duration(seconds: 45));
  });

  test('gps_wobble_within_accuracy_does_not_count', () {
    // 정확도 15m인데 경계 밖 10m — 실제로는 안일 수 있다
    expect(
      zoneWarningCounts(distanceOutsideMeters: 10, accuracyMeters: 15),
      isFalse,
    );
    expect(
      zoneWarningCounts(distanceOutsideMeters: 20, accuracyMeters: 15),
      isTrue,
    );
  });
}
