import 'package:cops_and_robbers/features/game/domain/location_send_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2024, 1, 1, 12, 0, 0);

  // 위도 0.0001° ≈ 11m, 0.000005° ≈ 0.55m
  const lat0 = 37.5;
  const lng0 = 127.0;
  const latFar = 37.5001; // 기준점에서 약 11m
  const latNear = 37.500005; // 기준점에서 약 0.55m

  group('shouldSendLocation', () {
    test('returns_false_when_arrested', () {
      expect(
        shouldSendLocation(
          lastSentTime: now.subtract(const Duration(seconds: 10)),
          now: now,
          lastLat: lat0,
          lastLng: lng0,
          newLat: latFar,
          newLng: lng0,
          isArrested: true,
        ),
        isFalse,
      );
    });

    test('returns_false_when_within_5s_throttle', () {
      expect(
        shouldSendLocation(
          lastSentTime: now.subtract(const Duration(seconds: 4)),
          now: now,
          lastLat: lat0,
          lastLng: lng0,
          newLat: latFar,
          newLng: lng0,
          isArrested: false,
        ),
        isFalse,
      );
    });

    test('returns_false_when_moved_less_than_10m', () {
      expect(
        shouldSendLocation(
          lastSentTime: now.subtract(const Duration(seconds: 10)),
          now: now,
          lastLat: lat0,
          lastLng: lng0,
          newLat: latNear,
          newLng: lng0,
          isArrested: false,
        ),
        isFalse,
      );
    });

    test('returns_true_when_all_conditions_met', () {
      expect(
        shouldSendLocation(
          lastSentTime: now.subtract(const Duration(seconds: 10)),
          now: now,
          lastLat: lat0,
          lastLng: lng0,
          newLat: latFar,
          newLng: lng0,
          isArrested: false,
        ),
        isTrue,
      );
    });

    test('returns_true_when_no_previous_position', () {
      expect(
        shouldSendLocation(
          lastSentTime: null,
          now: now,
          lastLat: null,
          lastLng: null,
          newLat: latFar,
          newLng: lng0,
          isArrested: false,
        ),
        isTrue,
      );
    });
  });
}
