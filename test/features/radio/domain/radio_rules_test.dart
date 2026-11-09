import 'dart:math';

import 'package:cops_and_robbers/features/radio/domain/radio_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// 갱신 시점의 양 끝을 재현하려고 난수를 고정한다
class _FixedRandom implements Random {
  _FixedRandom(this.value);
  final double value;
  @override
  double nextDouble() => value;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}

void main() {
  group('radioAvailable', () {
    test('radio_shown_for_police_when_room_has_radio', () {
      expect(
        radioAvailable(isPolice: true, isEventGame: false, radioEnabled: true),
        isTrue,
      );
    });

    // 도둑끼리 대화가 되면 추격 정보가 공유된다 (DEC-0114)
    test('radio_hidden_for_robber_when_room_has_radio', () {
      expect(
        radioAvailable(isPolice: false, isEventGame: false, radioEnabled: true),
        isFalse,
      );
    });

    test('radio_hidden_for_police_in_event_game', () {
      expect(
        radioAvailable(isPolice: true, isEventGame: true, radioEnabled: true),
        isFalse,
      );
    });

    test('radio_hidden_for_police_when_host_turned_radio_off', () {
      expect(
        radioAvailable(isPolice: true, isEventGame: false, radioEnabled: false),
        isFalse,
      );
    });
  });

  group('radioRefreshDelay', () {
    // 경찰이 다 같이 출동해 발급 시각이 같다 — 70~90% 사이로 흩어 재발급이 한꺼번에 몰리지 않게 한다
    test('refresh_lands_at_84s_at_earliest_when_token_lives_2_minutes', () {
      expect(
        radioRefreshDelay(const Duration(minutes: 2), _FixedRandom(0)),
        const Duration(seconds: 84),
      );
    });

    test('refresh_lands_at_108s_at_latest_when_token_lives_2_minutes', () {
      expect(
        radioRefreshDelay(const Duration(minutes: 2), _FixedRandom(1)),
        const Duration(seconds: 108),
      );
    });
  });

  group('RadioFloor', () {
    // 상희(101)가 먼저 눌렀고 의민(102)이 거의 동시에 눌렀다
    test('first_unmute_keeps_floor_when_second_police_presses_right_after', () {
      final floor = const RadioFloor().onUnmuted('101').onUnmuted('102');
      expect(floor.holder, '101');
    });

    test('floor_frees_when_holder_releases_button', () {
      final floor = const RadioFloor().onUnmuted('101').onMuted('101');
      expect(floor.holder, isNull);
    });

    test('floor_stays_with_holder_when_someone_else_releases', () {
      final floor = const RadioFloor().onUnmuted('101').onMuted('102');
      expect(floor.holder, '101');
    });

    test('button_locks_for_me_while_another_police_talks', () {
      final floor = const RadioFloor().onUnmuted('101');
      expect(floor.lockedFor('102'), isTrue);
      expect(floor.lockedFor('101'), isFalse);
    });

    // 둘이 거의 동시에 눌러 둘 다 송신 중 — 먼저 사람이 떼면 남은 사람이 보여야 한다
    test('floor_passes_to_cop_still_talking_when_first_releases', () {
      final floor = const RadioFloor()
          .onUnmuted('101')
          .onUnmuted('102')
          .onMuted('101');
      expect(floor.holder, '102');
    });

    test('button_is_free_when_nobody_talks', () {
      expect(const RadioFloor().lockedFor('102'), isFalse);
    });
  });
}
