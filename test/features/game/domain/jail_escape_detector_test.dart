import 'dart:math' as math;

import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/game/domain/jail_escape_detector.dart';
import 'package:flutter_test/flutter_test.dart';

const _metersPerDegreeLatitude = 111320.0;
const _center = GeoPoint(latitude: 37.5665, longitude: 126.9780);
const _circle = AreaShape.circle(center: _center, radiusInMeters: 20);
// 약 44m(남북) × 35m(동서) 사각형 감옥. 중심은 _center.
const _square = AreaShape.polygon(
  points: [
    GeoPoint(latitude: 37.5663, longitude: 126.9778),
    GeoPoint(latitude: 37.5663, longitude: 126.9782),
    GeoPoint(latitude: 37.5667, longitude: 126.9782),
    GeoPoint(latitude: 37.5667, longitude: 126.9778),
  ],
);
const _shapes = {'circle': _circle, 'polygon': _square};

/// 북쪽 경계에서 [meters]만큼 떨어진 점. 양수면 밖, 음수면 안.
GeoPoint _fromNorthEdge(AreaShape shape, double meters) {
  final edgeLatitude = shape.when(
    circle: (center, radius) =>
        center.latitude + radius / _metersPerDegreeLatitude,
    polygon: (_) => 37.5667,
  );
  return GeoPoint(
    latitude: edgeLatitude + meters / _metersPerDegreeLatitude,
    longitude: _center.longitude,
  );
}

typedef _Step = (int second, GeoPoint point, double accuracy);

/// [steps]를 차례로 넣고 요청(true)이 나온 초를 돌려준다.
List<int> _requestSeconds(AreaShape jail, List<_Step> steps) {
  final detector = JailEscapeDetector();
  final start = DateTime.utc(2026, 9, 25, 9);
  return [
    for (final (second, point, accuracy) in steps)
      if (detector.update(
        jail: jail,
        point: point,
        accuracyInMeters: accuracy,
        receivedAt: start.add(Duration(seconds: second)),
      ))
        second,
  ];
}

void main() {
  for (final MapEntry(key: name, value: jail) in _shapes.entries) {
    const inside = _center;
    final outside = _fromNorthEdge(jail, 12);
    final nearInside = _fromNorthEdge(jail, -2);
    final nearOutside = _fromNorthEdge(jail, 2);

    group(name, () {
      test(
        'detector_requests_once_when_robber_enters_then_stays_outside_3s',
        () {
          for (final arrestedOutside in [true, false]) {
            expect(
              _requestSeconds(jail, [
                if (arrestedOutside) (0, outside, 3),
                (1, inside, 3),
                (2, outside, 3),
                (4, outside, 3),
                (5, outside, 3),
              ]),
              [5],
              reason: 'arrestedOutside=$arrestedOutside',
            );
          }
        },
      );

      test('detector_never_requests_when_robber_never_enters_jail', () {
        expect(
          _requestSeconds(jail, [
            for (var second = 0; second <= 60; second += 2)
              (second, outside, 3),
          ]),
          isEmpty,
        );
      });

      test(
        'detector_counts_entry_when_two_inside_samples_span_1s_near_boundary',
        () {
          expect(
            _requestSeconds(jail, [
              (0, nearInside, 5),
              (1, nearInside, 5),
              (2, outside, 3),
              (5, outside, 3),
            ]),
            [5],
          );
        },
      );

      test(
        'detector_ignores_single_inside_sample_when_it_is_near_boundary',
        () {
          expect(
            _requestSeconds(jail, [
              (0, nearInside, 5),
              (1, outside, 3),
              (4, outside, 3),
              (8, outside, 3),
            ]),
            isEmpty,
          );
        },
      );

      test('detector_never_requests_when_positions_flip_across_the_edge', () {
        expect(
          _requestSeconds(jail, [
            (0, inside, 3),
            for (var second = 1; second <= 30; second++)
              (second, second.isEven ? nearInside : nearOutside, 3),
          ]),
          isEmpty,
        );
      });

      test(
        'detector_never_requests_when_accuracy_covers_the_outside_distance',
        () {
          expect(
            _requestSeconds(jail, [
              (0, inside, 3),
              (1, outside, 20),
              (4, outside, 20),
              (8, outside, 20),
            ]),
            isEmpty,
          );
        },
      );

      test('detector_uses_inaccurate_sample_when_it_is_far_outside', () {
        final far = _fromNorthEdge(jail, 80);
        expect(
          _requestSeconds(jail, [(0, inside, 3), (1, far, 30), (4, far, 30)]),
          [4],
        );
      });

      test('detector_skips_sample_when_accuracy_is_not_positive_or_finite', () {
        expect(
          _requestSeconds(jail, [
            (0, inside, 3),
            (1, outside, 3),
            (2, outside, 0),
            (3, outside, -1),
            (3, outside, double.nan),
            (4, outside, 3),
          ]),
          [4],
        );
      });

      test(
        'detector_requests_on_second_outside_sample_when_samples_are_sparse',
        () {
          expect(
            _requestSeconds(jail, [
              (0, inside, 3),
              (1, outside, 3),
              (11, outside, 3),
            ]),
            [11],
          );
        },
      );

      test(
        'detector_restarts_outside_timer_when_accuracy_spikes_into_buffer',
        () {
          expect(
            _requestSeconds(jail, [
              (0, inside, 3),
              (1, outside, 3),
              (3, outside, 20),
              (4, outside, 3),
              (6, outside, 3),
              (7, outside, 3),
            ]),
            [7],
          );
        },
      );

      test('detector_retries_every_5s_when_robber_stays_outside', () {
        expect(
          _requestSeconds(jail, [
            (0, inside, 3),
            (1, outside, 3),
            (4, outside, 3),
            (6, outside, 3),
            (9, outside, 3),
          ]),
          [4, 9],
        );
      });
    });
  }

  group('불변식 (시드 599)', () {
    final random = math.Random(599);
    double between(double min, double max) =>
        min + random.nextDouble() * (max - min);
    final metersPerDegreeLongitude =
        _metersPerDegreeLatitude * math.cos(_center.latitude * math.pi / 180);
    GeoPoint offset({required double north, required double east}) => GeoPoint(
      latitude: _center.latitude + north / _metersPerDegreeLatitude,
      longitude: _center.longitude + east / metersPerDegreeLongitude,
    );

    bool anyRequest(
      AreaShape jail,
      GeoPoint Function() nextPoint, {
      required double minAccuracy,
    }) {
      final detector = JailEscapeDetector();
      var at = DateTime.utc(2026, 9, 25, 9);
      for (var i = 0; i < 30; i++) {
        at = at.add(Duration(milliseconds: (between(0.2, 6) * 1000).round()));
        final requested = detector.update(
          jail: jail,
          point: nextPoint(),
          accuracyInMeters: between(minAccuracy, 15),
          receivedAt: at,
        );
        if (requested) return true;
      }
      return false;
    }

    test('detector_never_requests_when_random_positions_never_enter_jail', () {
      for (final MapEntry(key: name, value: jail) in _shapes.entries) {
        for (var run = 0; run < 200; run++) {
          GeoPoint far() {
            final bearing = between(0, 2 * math.pi);
            final distance = between(60, 250);
            return offset(
              north: distance * math.cos(bearing),
              east: distance * math.sin(bearing),
            );
          }

          expect(
            anyRequest(jail, far, minAccuracy: 1),
            isFalse,
            reason: '$name run=$run',
          );
        }
      }
    });

    test(
      'detector_never_requests_when_random_positions_stay_inside_or_in_buffer',
      () {
        // 원: 중심에서 22.5m 이내 → 밖이어도 경계에서 2.5m 이내.
        // 사각형: 각 변에서 2m 이내 → 모서리 바깥도 2.83m 이내.
        // 정확도는 3m 이상이라 두 경우 모두 완충 구간이다.
        final generators = <String, (AreaShape, GeoPoint Function())>{
          'circle': (
            _circle,
            () {
              final bearing = between(0, 2 * math.pi);
              final distance = between(0, 22.5);
              return offset(
                north: distance * math.cos(bearing),
                east: distance * math.sin(bearing),
              );
            },
          ),
          'polygon': (
            _square,
            () => offset(
              north: between(-24.26, 24.26),
              east: between(-19.65, 19.65),
            ),
          ),
        };
        for (final MapEntry(key: name, value: (jail, point))
            in generators.entries) {
          for (var run = 0; run < 200; run++) {
            expect(
              anyRequest(jail, point, minAccuracy: 3),
              isFalse,
              reason: '$name run=$run',
            );
          }
        }
      },
    );
  });
}
