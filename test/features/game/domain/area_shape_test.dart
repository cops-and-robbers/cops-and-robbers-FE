import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
