import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/game/domain/polygon_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 사각형 꼭짓점 4개 (경계 순서)
  const square = [
    GeoPoint(latitude: 37.5685, longitude: 126.9760),
    GeoPoint(latitude: 37.5685, longitude: 126.9800),
    GeoPoint(latitude: 37.5645, longitude: 126.9800),
    GeoPoint(latitude: 37.5645, longitude: 126.9760),
  ];

  group('sortByAngleAroundCentroid', () {
    test('produces_simple_polygon_regardless_of_input_order', () {
      // 일부러 교차가 생기는 순서(나비넥타이)로 입력
      final shuffled = [square[0], square[2], square[1], square[3]];
      final sorted = sortByAngleAroundCentroid(shuffled);
      expect(hasSelfIntersection(sorted), isFalse);
    });

    test('returns_same_ring_for_any_input_permutation', () {
      final a = sortByAngleAroundCentroid([
        square[0],
        square[2],
        square[1],
        square[3],
      ]);
      final b = sortByAngleAroundCentroid([
        square[3],
        square[1],
        square[0],
        square[2],
      ]);
      // 같은 꼭짓점 집합 → 같은 각도 순서 (시작점만 다를 수 있으므로 순환 비교)
      expect(a.toSet(), b.toSet());
      final startInB = b.indexOf(a.first);
      expect(startInB, isNot(-1));
      for (var i = 0; i < a.length; i++) {
        expect(a[i], b[(startInB + i) % b.length]);
      }
    });
  });

  group('hasSelfIntersection', () {
    test('returns_true_for_bowtie_polygon', () {
      final bowtie = [square[0], square[2], square[1], square[3]];
      expect(hasSelfIntersection(bowtie), isTrue);
    });

    test('returns_false_for_simple_square', () {
      expect(hasSelfIntersection(square), isFalse);
    });

    test('returns_false_for_triangle', () {
      expect(hasSelfIntersection(square.sublist(0, 3)), isFalse);
    });
  });

  group('polygonAreaInSquareMeters', () {
    test('computes_known_square_area_within_tolerance', () {
      // 위도 0.004도 ≈ 445m, 경도 0.004도 ≈ 353m (위도 37.57 기준)
      // 기대 면적 ≈ 445 × 353 ≈ 157,000㎡ (±5%)
      final area = polygonAreaInSquareMeters(square);
      expect(area, greaterThan(157000 * 0.95));
      expect(area, lessThan(157000 * 1.05));
    });

    test('returns_zero_when_less_than_three_points', () {
      expect(polygonAreaInSquareMeters(square.sublist(0, 2)), 0);
    });
  });

  group('isValidPolygon', () {
    test('returns_false_when_three_vertices_are_collinear', () {
      const collinear = [
        GeoPoint(latitude: 37.5660, longitude: 126.9780),
        GeoPoint(latitude: 37.5670, longitude: 126.9780),
        GeoPoint(latitude: 37.5680, longitude: 126.9780),
      ];

      expect(isValidPolygon(collinear), isFalse);
    });

    test('returns_true_when_polygon_has_area_and_no_intersection', () {
      expect(isValidPolygon(square), isTrue);
    });
  });

  group('isPolygonInsidePolygon', () {
    // square 안쪽의 작은 삼각형
    const innerTriangle = [
      GeoPoint(latitude: 37.5670, longitude: 126.9775),
      GeoPoint(latitude: 37.5670, longitude: 126.9785),
      GeoPoint(latitude: 37.5660, longitude: 126.9780),
    ];

    test('returns_true_when_inner_is_fully_contained', () {
      expect(isPolygonInsidePolygon(innerTriangle, square), isTrue);
    });

    test('returns_false_when_inner_vertex_is_outside', () {
      const escaping = [
        GeoPoint(latitude: 37.5670, longitude: 126.9775),
        GeoPoint(latitude: 37.5670, longitude: 126.9900), // square 밖
        GeoPoint(latitude: 37.5660, longitude: 126.9780),
      ];
      expect(isPolygonInsidePolygon(escaping, square), isFalse);
    });
  });
}
