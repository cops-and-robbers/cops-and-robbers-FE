import 'package:cops_and_robbers/features/game/domain/reveal_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 9, 30, 10);

  DateTime? next(DateTime now, {int? wait = 5, int? interval = 3}) =>
      nextRevealAt(
        start: start,
        policeWaitMinutes: wait,
        intervalMinutes: interval,
        now: now,
      );

  test('next_reveal_is_first_reveal_when_police_still_waiting', () {
    expect(next(DateTime(2026, 9, 30, 10, 2)), DateTime(2026, 9, 30, 10, 8));
  });

  test('next_reveal_skips_past_reveals_when_game_is_midway', () {
    expect(next(DateTime(2026, 9, 30, 10, 12)), DateTime(2026, 9, 30, 10, 14));
  });

  test('next_reveal_stays_on_reveal_time_when_now_equals_it', () {
    // 게임 화면은 이 순간 00:00을 보인다 — 같은 시각을 돌려줘야 두 화면이 일치한다.
    expect(next(DateTime(2026, 9, 30, 10, 8)), DateTime(2026, 9, 30, 10, 8));
  });

  test('next_reveal_is_null_when_interval_is_zero_or_missing', () {
    final now = DateTime(2026, 9, 30, 10, 2);
    expect(next(now, interval: 0), isNull);
    expect(next(now, interval: null), isNull);
  });

  test('next_reveal_is_null_when_police_wait_is_unknown', () {
    expect(next(DateTime(2026, 9, 30, 10, 2), wait: null), isNull);
  });
}
