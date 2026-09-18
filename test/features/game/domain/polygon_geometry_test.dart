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

  group('moveVertex', () {
    test('returns_ring_with_the_vertex_replaced_when_result_is_simple', () {
      // NW 꼭짓점을 조금 더 바깥(북서)으로
      const to = GeoPoint(latitude: 37.5690, longitude: 126.9755);

      expect(moveVertex(square, 0, to), [to, square[1], square[2], square[3]]);
    });

    test('returns_null_when_the_move_makes_edges_cross', () {
      // NW 꼭짓점을 동쪽 변(NE→SE) 너머로 넘기면 SW→(새 점) 변이 동쪽 변을 가로지른다
      const to = GeoPoint(latitude: 37.5665, longitude: 126.9850);

      expect(moveVertex(square, 0, to), isNull);
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
