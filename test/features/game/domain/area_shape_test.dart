import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  // 서울 시청 부근 기준 좌표. 위도 0.001도 ≈ 111m
  const base = GeoPoint(latitude: 37.5665, longitude: 126.9780);

  group('AreaShape.circle contains', () {
    const circle = AreaShape.circle(center: base, radiusInMeters: 200);

    test('returns_true_when_point_is_inside_radius', () {
      expect(
        circle.contains(
          const GeoPoint(latitude: 37.5670, longitude: 126.9780), // 약 55m
        ),
        isTrue,
      );
    });

    test('returns_false_when_point_is_outside_radius', () {
      expect(
        circle.contains(
          const GeoPoint(latitude: 37.5765, longitude: 126.9780), // 약 1.1km
        ),
        isFalse,
      );
    });
  });

  group('AreaShape.polygon contains', () {
    // base를 중심으로 한 사각형 (±0.002도 ≈ ±222m)
    const square = AreaShape.polygon(
      points: [
        GeoPoint(latitude: 37.5685, longitude: 126.9760),
        GeoPoint(latitude: 37.5685, longitude: 126.9800),
        GeoPoint(latitude: 37.5645, longitude: 126.9800),
        GeoPoint(latitude: 37.5645, longitude: 126.9760),
      ],
    );

    test('returns_true_when_point_is_inside_square', () {
      expect(square.contains(base), isTrue);
    });

    test('returns_false_when_point_is_outside_square', () {
      expect(
        square.contains(const GeoPoint(latitude: 37.5700, longitude: 126.9780)),
        isFalse,
      );
    });

    test('returns_true_when_point_is_on_polygon_boundary', () {
      expect(
        square.contains(const GeoPoint(latitude: 37.5685, longitude: 126.9780)),
        isTrue,
      );
    });

    test('handles_concave_polygon_notch_correctly', () {
      // ㄷ자(오목) 폴리곤 — 바닥에 파인 홈은 외부여야 한다
      const concave = AreaShape.polygon(
        points: [
          GeoPoint(latitude: 37.5700, longitude: 126.9760),
          GeoPoint(latitude: 37.5700, longitude: 126.9800),
          GeoPoint(latitude: 37.5660, longitude: 126.9800),
          GeoPoint(latitude: 37.5660, longitude: 126.9785),
          GeoPoint(latitude: 37.5690, longitude: 126.9785),
          GeoPoint(latitude: 37.5690, longitude: 126.9775),
          GeoPoint(latitude: 37.5660, longitude: 126.9775),
          GeoPoint(latitude: 37.5660, longitude: 126.9760),
        ],
      );
      // 파인 홈 안쪽 점 (폴리곤 외부)
      expect(
        concave.contains(
          const GeoPoint(latitude: 37.5670, longitude: 126.9780),
        ),
        isFalse,
      );
      // 몸통 점 (폴리곤 내부)
      expect(
        concave.contains(
          const GeoPoint(latitude: 37.5695, longitude: 126.9780),
        ),
        isTrue,
      );
    });
  });

  group('centroid / boundingRadiusInMeters', () {
    test('circle_returns_center_and_radius_as_is', () {
      const circle = AreaShape.circle(center: base, radiusInMeters: 300);
      expect(circle.centroid, base);
      expect(circle.boundingRadiusInMeters, 300);
    });

    test(
      'polygon_centroid_is_vertex_average_and_radius_covers_all_vertices',
      () {
        const square = AreaShape.polygon(
          points: [
            GeoPoint(latitude: 37.5685, longitude: 126.9760),
            GeoPoint(latitude: 37.5685, longitude: 126.9800),
            GeoPoint(latitude: 37.5645, longitude: 126.9800),
            GeoPoint(latitude: 37.5645, longitude: 126.9760),
          ],
        );
        expect(square.centroid.latitude, closeTo(37.5665, 1e-9));
        expect(square.centroid.longitude, closeTo(126.9780, 1e-9));
        // 대각 꼭짓점까지 거리(≈ 284m)를 덮어야 한다
        expect(square.boundingRadiusInMeters, greaterThan(250));
        expect(square.boundingRadiusInMeters, lessThan(320));
      },
    );
  });

  group('distanceToBoundaryInMeters', () {
    test('circle_returns_distance_to_circumference_on_both_sides', () {
      const circle = AreaShape.circle(center: base, radiusInMeters: 100);

      expect(circle.distanceToBoundaryInMeters(base), closeTo(100, 0.1));
      expect(
        circle.distanceToBoundaryInMeters(
          const GeoPoint(latitude: 37.5683, longitude: 126.9780),
        ),
        closeTo(100, 3),
      );
    });

    test('polygon_uses_nearest_edge_instead_of_bounding_circle', () {
      const square = AreaShape.polygon(
        points: [
          GeoPoint(latitude: 37.5675, longitude: 126.9770),
          GeoPoint(latitude: 37.5675, longitude: 126.9790),
          GeoPoint(latitude: 37.5655, longitude: 126.9790),
          GeoPoint(latitude: 37.5655, longitude: 126.9770),
        ],
      );

      expect(square.distanceToBoundaryInMeters(base), closeTo(88, 4));
      expect(
        square.distanceToBoundaryInMeters(
          const GeoPoint(latitude: 37.5676, longitude: 126.9780),
        ),
        closeTo(11, 2),
      );
    });
  });

  group('boundingBox', () {
    /// centroid에서 [point]까지의 실거리(m)
    double distanceFromCentroid(AreaShape shape, GeoPoint point) {
      final c = shape.centroid;
      return Geolocator.distanceBetween(
        c.latitude,
        c.longitude,
        point.latitude,
        point.longitude,
      );
    }

    test(
      'box_edges_sit_at_130_percent_of_radius_when_margin_is_30_percent',
      () {
        const circle = AreaShape.circle(center: base, radiusInMeters: 200);
        final box = circle.boundingBox(marginRatio: 0.3);

        // 상하좌우 네 변 중점까지의 거리 = 반경 × 1.3 = 260m
        final north = GeoPoint(
          latitude: box.northEast.latitude,
          longitude: base.longitude,
        );
        final east = GeoPoint(
          latitude: base.latitude,
          longitude: box.northEast.longitude,
        );
        final south = GeoPoint(
          latitude: box.southWest.latitude,
          longitude: base.longitude,
        );
        final west = GeoPoint(
          latitude: base.latitude,
          longitude: box.southWest.longitude,
        );
        for (final edge in [north, east, south, west]) {
          expect(distanceFromCentroid(circle, edge), closeTo(260, 5));
        }
      },
    );

    test('box_edges_sit_at_radius_when_margin_omitted', () {
      const circle = AreaShape.circle(center: base, radiusInMeters: 200);
      final box = circle.boundingBox();

      final north = GeoPoint(
        latitude: box.northEast.latitude,
        longitude: base.longitude,
      );
      expect(distanceFromCentroid(circle, north), closeTo(200, 5));
    });

    test('box_covers_all_vertices_when_polygon_has_margin', () {
      const vertices = [
        GeoPoint(latitude: 37.5685, longitude: 126.9760),
        GeoPoint(latitude: 37.5685, longitude: 126.9800),
        GeoPoint(latitude: 37.5645, longitude: 126.9800),
        GeoPoint(latitude: 37.5645, longitude: 126.9760),
      ];
      const square = AreaShape.polygon(points: vertices);
      final box = square.boundingBox(marginRatio: 0.3);

      // 모든 꼭짓점이 박스 안에 여유 있게 들어와야 한다
      for (final p in vertices) {
        expect(p.latitude, greaterThan(box.southWest.latitude));
        expect(p.latitude, lessThan(box.northEast.latitude));
        expect(p.longitude, greaterThan(box.southWest.longitude));
        expect(p.longitude, lessThan(box.northEast.longitude));
      }
    });
  });
}
