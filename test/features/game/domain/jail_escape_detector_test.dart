import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/game/domain/jail_escape_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const jail = AreaShape.circle(
    center: GeoPoint(latitude: 37.5665, longitude: 126.9780),
    radiusInMeters: 20,
  );
  final startedAt = DateTime.utc(2026, 9, 6, 9);

  JailLocationSample sample({
    required double latitude,
    required int seconds,
    double accuracy = 3,
  }) => JailLocationSample(
    point: GeoPoint(latitude: latitude, longitude: 126.9780),
    accuracyInMeters: accuracy,
    timestamp: startedAt.add(Duration(seconds: seconds)),
  );

  JailEscapeDetector detector() => JailEscapeDetector();

  test('accepts_delayed_android_samples_but_breaks_long_gaps', () {
    for (final intervalMs in [2000, 5100, 10000, 10001]) {
      final subject = detector();
      final results = <bool>[];
      for (var i = 0; i < 4; i++) {
        final timestamp = startedAt.add(Duration(milliseconds: intervalMs * i));
        results.add(
          subject.update(
            jail: jail,
            sample: JailLocationSample(
              point: GeoPoint(
                latitude: i < 2 ? 37.5665 : 37.5668,
                longitude: 126.9780,
              ),
              accuracyInMeters: 3,
              timestamp: timestamp,
            ),
            now: timestamp,
          ),
        );
      }
      expect(results, [
        false,
        false,
        false,
        intervalMs <= 10000,
      ], reason: 'interval=${intervalMs}ms');
    }
  });

  test('requests_escape_after_confirmed_entry_and_exit', () {
    final subject = detector();

    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5665, seconds: 0),
        now: startedAt,
      ),
      isFalse,
    );
    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5665, seconds: 1),
        now: startedAt.add(const Duration(seconds: 1)),
      ),
      isFalse,
    );
    expect(subject.hasEnteredJail, isTrue);

    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5668, seconds: 3),
        now: startedAt.add(const Duration(seconds: 3)),
      ),
      isFalse,
    );
    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5668, seconds: 5),
        now: startedAt.add(const Duration(seconds: 5)),
      ),
      isTrue,
    );
  });

  test('does_not_request_escape_without_entry_in_current_arrest', () {
    final subject = detector();

    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5668, seconds: 0),
        now: startedAt,
      ),
      isFalse,
    );
    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5668, seconds: 3),
        now: startedAt.add(const Duration(seconds: 3)),
      ),
      isFalse,
    );
  });

  test('ignores_inaccurate_stale_and_duplicate_samples', () {
    final subject = detector();

    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5665, seconds: 0, accuracy: 30),
        now: startedAt,
      ),
      isFalse,
    );
    final stale = sample(latitude: 37.5665, seconds: 1);
    expect(
      subject.update(
        jail: jail,
        sample: stale,
        now: startedAt.add(const Duration(seconds: 10)),
      ),
      isFalse,
    );
    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5665, seconds: 2),
        now: startedAt.add(const Duration(seconds: 2)),
      ),
      isFalse,
    );
    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5665, seconds: 2),
        now: startedAt.add(const Duration(seconds: 2)),
      ),
      isFalse,
    );
    expect(subject.hasEnteredJail, isFalse);
    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5665, seconds: 3),
        now: startedAt.add(const Duration(seconds: 3)),
      ),
      isFalse,
    );
    expect(subject.hasEnteredJail, isFalse);
  });

  test('supports_polygon_jails', () {
    const polygonJail = AreaShape.polygon(
      points: [
        GeoPoint(latitude: 37.5663, longitude: 126.9778),
        GeoPoint(latitude: 37.5663, longitude: 126.9782),
        GeoPoint(latitude: 37.5667, longitude: 126.9782),
        GeoPoint(latitude: 37.5667, longitude: 126.9778),
      ],
    );
    final subject = JailEscapeDetector(
      minConsecutiveSamples: 1,
      minInsideDuration: Duration.zero,
      minOutsideDuration: Duration.zero,
    );

    expect(
      subject.update(
        jail: polygonJail,
        sample: sample(latitude: 37.5665, seconds: 0),
        now: startedAt,
      ),
      isFalse,
    );
    expect(
      subject.update(
        jail: polygonJail,
        sample: sample(latitude: 37.5670, seconds: 1),
        now: startedAt.add(const Duration(seconds: 1)),
      ),
      isTrue,
    );
  });

  test('reset_discards_entry_from_previous_arrest', () {
    final subject = detector();
    subject.update(
      jail: jail,
      sample: sample(latitude: 37.5665, seconds: 0),
      now: startedAt,
    );
    subject.update(
      jail: jail,
      sample: sample(latitude: 37.5665, seconds: 1),
      now: startedAt.add(const Duration(seconds: 1)),
    );
    expect(subject.hasEnteredJail, isTrue);

    subject.reset();
    expect(subject.hasEnteredJail, isFalse);
    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5668, seconds: 3),
        now: startedAt.add(const Duration(seconds: 3)),
      ),
      isFalse,
    );
  });

  test('does_not_retrigger_until_the_robber_reenters', () {
    final subject = JailEscapeDetector(
      minConsecutiveSamples: 1,
      minInsideDuration: Duration.zero,
      minOutsideDuration: Duration.zero,
    );

    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5665, seconds: 0),
        now: startedAt,
      ),
      isFalse,
    );
    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5668, seconds: 1),
        now: startedAt.add(const Duration(seconds: 1)),
      ),
      isTrue,
    );
    expect(
      subject.update(
        jail: jail,
        sample: sample(latitude: 37.5668, seconds: 2),
        now: startedAt.add(const Duration(seconds: 2)),
      ),
      isFalse,
    );
  });
}
