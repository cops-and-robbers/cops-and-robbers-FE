import 'package:cops_and_robbers/features/game/domain/distance_send_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 14, 12, 0, 0);

  group('shouldSendDistance', () {
    // 앱이 강제 종료됐다가 같은 게임에 재진입하면(#629) 기기 파일에서 거리가 복원되고
    // 전송 기록은 비어 있다. 30초를 기다리지 않고 바로 서버 값을 따라잡아야 한다.
    test('sends_immediately_when_distance_restored_after_app_restart', () {
      expect(
        shouldSendDistance(
          lastSentTime: null,
          now: now,
          lastSentMeters: null,
          currentMeters: 812.4,
        ),
        isTrue,
      );
    });

    // 시작하자마자 제자리에 숨은 도둑 — 보낼 값이 없다.
    test('skips_when_robber_hides_in_place_from_game_start', () {
      expect(
        shouldSendDistance(
          lastSentTime: null,
          now: now,
          lastSentMeters: null,
          currentMeters: 0,
        ),
        isFalse,
      );
    });

    test('waits_when_running_player_sent_29s_ago', () {
      expect(
        shouldSendDistance(
          lastSentTime: now.subtract(const Duration(seconds: 29)),
          now: now,
          lastSentMeters: 420,
          currentMeters: 505,
        ),
        isFalse,
      );
    });

    test('sends_again_when_running_player_reaches_30s', () {
      expect(
        shouldSendDistance(
          lastSentTime: now.subtract(const Duration(seconds: 30)),
          now: now,
          lastSentMeters: 420,
          currentMeters: 505,
        ),
        isTrue,
      );
    });

    // 감옥에 갇혀 있거나 숨어서 1분째 안 움직인 도둑 — 같은 값을 반복해 보내지 않는다.
    test('skips_when_jailed_robber_has_not_moved_for_a_minute', () {
      expect(
        shouldSendDistance(
          lastSentTime: now.subtract(const Duration(minutes: 1)),
          now: now,
          lastSentMeters: 1350,
          currentMeters: 1350,
        ),
        isFalse,
      );
    });
  });
}
