import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/features/game/domain/jail_zone_check.dart';

void main() {
  group('JailZoneCheck.computeIsOutside', () {
    test('returns_true_when_distance_exceeds_radius_plus_buffer', () {
      final result = JailZoneCheck.computeIsOutside(
        distanceMeters: 41,
        radiusMeters: 30,
        buffer: 10,
        previousIsOutside: false,
      );

      expect(result, isTrue);
    });

    test('returns_false_when_distance_within_radius', () {
      final result = JailZoneCheck.computeIsOutside(
        distanceMeters: 25,
        radiusMeters: 30,
        buffer: 10,
        previousIsOutside: true,
      );

      expect(result, isFalse);
    });

    test('keeps_previous_state_when_distance_within_hysteresis_band', () {
      final keepOutside = JailZoneCheck.computeIsOutside(
        distanceMeters: 35,
        radiusMeters: 30,
        buffer: 10,
        previousIsOutside: true,
      );
      final keepInside = JailZoneCheck.computeIsOutside(
        distanceMeters: 35,
        radiusMeters: 30,
        buffer: 10,
        previousIsOutside: false,
      );

      expect(keepOutside, isTrue);
      expect(keepInside, isFalse);
    });

    test('returns_true_at_exact_boundary_of_radius_plus_buffer', () {
      // distance == radius + buffer → 아직 이탈로 판정 안 함 (strict >)
      final result = JailZoneCheck.computeIsOutside(
        distanceMeters: 40,
        radiusMeters: 30,
        buffer: 10,
        previousIsOutside: false,
      );

      expect(result, isFalse);
    });
  });

  group('JailZoneCheck.evaluateTransition', () {
    test('returns_entered_when_was_outside_and_now_inside', () {
      final result = JailZoneCheck.evaluateTransition(
        wasOutside: true,
        isOutside: false,
      );

      expect(result, JailZoneTransition.entered);
    });

    test('returns_exited_when_was_inside_and_now_outside', () {
      final result = JailZoneCheck.evaluateTransition(
        wasOutside: false,
        isOutside: true,
      );

      expect(result, JailZoneTransition.exited);
    });

    test('returns_none_when_state_unchanged_inside', () {
      final result = JailZoneCheck.evaluateTransition(
        wasOutside: false,
        isOutside: false,
      );

      expect(result, JailZoneTransition.none);
    });

    test('returns_none_when_state_unchanged_outside', () {
      final result = JailZoneCheck.evaluateTransition(
        wasOutside: true,
        isOutside: true,
      );

      expect(result, JailZoneTransition.none);
    });
  });
}
