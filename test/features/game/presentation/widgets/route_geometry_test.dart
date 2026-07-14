import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/route_geometry.dart';

void main() {
  const size = Size(200, 200);
  const padding = 12.0;

  group('projectRouteToCanvas', () {
    test('returns_empty_for_empty_route', () {
      expect(projectRouteToCanvas(const [], size, padding: padding), isEmpty);
    });

    test('places_single_point_at_center', () {
      const route = [LatLngModel(latitude: 37.5, longitude: 127.0)];
      final pts = projectRouteToCanvas(route, size, padding: padding);
      expect(pts.length, 1);
      expect(pts.first.dx, closeTo(100, 0.001));
      expect(pts.first.dy, closeTo(100, 0.001));
    });

    test('fits_horizontal_route_within_padding_and_centers_vertically', () {
      const route = [
        LatLngModel(latitude: 37.5, longitude: 127.0),
        LatLngModel(latitude: 37.5, longitude: 127.1),
      ];
      final pts = projectRouteToCanvas(route, size, padding: padding);
      expect(pts.length, 2);
      // 위도 동일 → 수직 중앙 정렬
      expect(pts[0].dy, closeTo(100, 0.001));
      expect(pts[1].dy, closeTo(100, 0.001));
      // 경도 증가 → 좌(=padding)에서 우(=size-padding)로
      expect(pts[0].dx, closeTo(padding, 0.001));
      expect(pts[1].dx, closeTo(size.width - padding, 0.001));
    });

    test('keeps_all_points_inside_canvas_bounds', () {
      const route = [
        LatLngModel(latitude: 37.50, longitude: 127.00),
        LatLngModel(latitude: 37.52, longitude: 127.03),
        LatLngModel(latitude: 37.49, longitude: 127.05),
      ];
      final pts = projectRouteToCanvas(route, size, padding: padding);
      for (final p in pts) {
        expect(p.dx, inInclusiveRange(0, size.width));
        expect(p.dy, inInclusiveRange(0, size.height));
      }
    });

    test('does_not_flatten_square_route_into_a_line', () {
      // 위·경도 변화량이 같은(도 기준) 정사각형 경로. 경도를 라디안으로 변환하지
      // 않으면 x축이 ~57배 커져 캔버스에서 좌우 직선처럼 납작해진다(회귀 방지).
      const route = [
        LatLngModel(latitude: 37.560, longitude: 126.970),
        LatLngModel(latitude: 37.560, longitude: 126.974),
        LatLngModel(latitude: 37.564, longitude: 126.974),
        LatLngModel(latitude: 37.564, longitude: 126.970),
      ];
      final pts = projectRouteToCanvas(route, size, padding: padding);
      final w =
          pts.map((p) => p.dx).reduce(math.max) -
          pts.map((p) => p.dx).reduce(math.min);
      final h =
          pts.map((p) => p.dy).reduce(math.max) -
          pts.map((p) => p.dy).reduce(math.min);
      // 정상이면 종횡비가 1에 가깝다(경도 cos 보정으로 약 0.79). 버그 시 ~45.
      expect(w / h, inInclusiveRange(0.3, 3.0));
    });

    test('projector_projects_route_point_to_same_offset_as_points', () {
      // 마커(체포/탈옥 위치)가 경로와 동일 변환으로 정확히 경로 위에 올라가야 한다.
      const route = [
        LatLngModel(latitude: 37.50, longitude: 127.00),
        LatLngModel(latitude: 37.52, longitude: 127.03),
        LatLngModel(latitude: 37.49, longitude: 127.05),
      ];
      final proj = projectRoute(route, size, padding: padding);
      for (var i = 0; i < route.length; i++) {
        final p = proj.project(route[i]);
        expect(p.dx, closeTo(proj.points[i].dx, 0.001));
        expect(p.dy, closeTo(proj.points[i].dy, 0.001));
      }
    });
  });
}
