import 'dart:math' as math;

import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/game/domain/zone_grid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 어린이대공원 정문 근처를 중심으로 잡은 구역
  const park = GeoPoint(latitude: 37.5482, longitude: 127.0747);

  AreaShape circle(double radius) =>
      AreaShape.circle(center: park, radiusInMeters: radius);

  /// 중심에서 [north]·[east] 미터만큼 떨어진 점 (평면 근사)
  GeoPoint offset(GeoPoint from, {double north = 0, double east = 0}) {
    const earthRadius = 6371000.0;
    final dLat = north / earthRadius * 180 / math.pi;
    final dLng =
        east /
        earthRadius *
        180 /
        math.pi /
        math.cos(from.latitude * math.pi / 180);
    return GeoPoint(
      latitude: from.latitude + dLat,
      longitude: from.longitude + dLng,
    );
  }

  bool cellContains(ZoneGridCell cell, GeoPoint p) =>
      p.latitude >= cell.southWest.latitude &&
      p.latitude <= cell.northEast.latitude &&
      p.longitude >= cell.southWest.longitude &&
      p.longitude <= cell.northEast.longitude;

  Set<String> labels(ZoneGrid grid) => grid.cells.map((c) => c.label).toSet();

  group('칸 크기', () {
    // 한 변 12칸 이하가 되는 가장 작은 칸 (50 → 100 → 200 → 500m …)
    test('uses_50m_cells_when_playground_is_a_small_300m_park', () {
      final grid = ZoneGrid.forArea(circle(300));

      expect(grid.cellMeters, 50);
      expect(grid.size, 12); // A–L
    });

    test('switches_to_100m_cells_when_50m_would_need_more_than_12_columns', () {
      final grid = ZoneGrid.forArea(circle(310));

      expect(grid.cellMeters, 100);
      expect(grid.size, 7);
    });

    test('uses_100m_cells_when_room_uses_default_500m_playground', () {
      final grid = ZoneGrid.forArea(circle(500));

      expect(grid.cellMeters, 100);
      expect(grid.size, 10); // A–J
    });

    test('uses_200m_cells_when_playground_is_the_1km_maximum', () {
      final grid = ZoneGrid.forArea(circle(1000));

      expect(grid.cellMeters, 200);
      expect(grid.size, 10);
    });

    test(
      'keeps_at_most_12_columns_when_a_drawn_polygon_is_wider_than_any_circle',
      () {
        // 원형 상한(1km)보다 넓게 그린 폴리곤도 한 변 12칸을 넘지 않는다
        final wide = AreaShape.polygon(
          points: [
            offset(park, north: 1800, east: -1800),
            offset(park, north: 1800, east: 1800),
            offset(park, north: -1800, east: 1800),
            offset(park, north: -1800, east: -1800),
          ],
        );

        final grid = ZoneGrid.forArea(wide);

        expect(grid.cellMeters, 500);
        expect(grid.size, lessThanOrEqualTo(12));
      },
    );
  });

  group('구역 안 칸만', () {
    test('leaves_out_corner_cells_when_playground_is_a_circle', () {
      final grid = ZoneGrid.forArea(circle(500));

      // 정사각형 네 모서리는 원 밖이라 빈자리
      expect(labels(grid), isNot(contains('A1')));
      expect(labels(grid), isNot(contains('J1')));
      expect(labels(grid), isNot(contains('A10')));
      expect(labels(grid), isNot(contains('J10')));
      // 중심 칸은 있다
      expect(labels(grid), containsAll(['E5', 'F6']));
    });

    test('gives_a_cell_to_players_standing_near_the_circle_edge', () {
      final grid = ZoneGrid.forArea(circle(500));

      // 경계 바로 안쪽(490m)에 선 플레이어 8방향
      for (var deg = 0; deg < 360; deg += 45) {
        final rad = deg * math.pi / 180;
        final player = offset(
          park,
          north: 490 * math.cos(rad),
          east: 490 * math.sin(rad),
        );
        expect(
          grid.cells.any((c) => cellContains(c, player)),
          isTrue,
          reason: '$deg° 방향 경계 근처 플레이어가 라벨 없는 칸에 있다',
        );
      }
    });

    test('leaves_out_cells_in_the_notch_when_playground_is_l_shaped', () {
      // 북동쪽 사분면이 빠진 ㄱ자 공원 (한 변 400m)
      final lShape = AreaShape.polygon(
        points: [
          offset(park, north: 200, east: -200),
          offset(park, north: 200, east: 0),
          offset(park, north: 0, east: 0),
          offset(park, north: 0, east: 200),
          offset(park, north: -200, east: 200),
          offset(park, north: -200, east: -200),
        ],
      );

      final grid = ZoneGrid.forArea(lShape);
      final notch = offset(park, north: 120, east: 120);
      final westWing = offset(park, north: 120, east: -120);

      expect(grid.cells.any((c) => cellContains(c, notch)), isFalse);
      expect(grid.cells.any((c) => cellContains(c, westWing)), isTrue);
    });

    test('names_cells_from_the_north_west_corner_when_reading_the_grid', () {
      final grid = ZoneGrid.forArea(circle(500));
      final e5 = grid.cells.firstWhere((c) => c.label == 'E5');
      final f5 = grid.cells.firstWhere((c) => c.label == 'F5');
      final e6 = grid.cells.firstWhere((c) => c.label == 'E6');

      // 열은 서→동, 행은 북→남
      expect(f5.center.longitude, greaterThan(e5.center.longitude));
      expect(e6.center.latitude, lessThan(e5.center.latitude));
    });
  });

  group('좌표 → 칸 이름', () {
    // 기본 500m 구역 = 100m 칸 10×10, 서쪽 끝 -500m·북쪽 끝 +500m
    test('names_the_cell_where_a_player_pinged_inside_the_park', () {
      final grid = ZoneGrid.forArea(circle(500));

      expect(grid.cellAt(offset(park, north: 150, east: -150)), 'D4');
      expect(grid.cellAt(offset(park, north: -250, east: 350)), 'I8');
    });

    test(
      'returns_null_when_the_point_is_in_a_corner_cell_outside_the_circle',
      () {
        final grid = ZoneGrid.forArea(circle(500));

        expect(grid.cellAt(offset(park, north: 470, east: 470)), isNull);
      },
    );

    test('returns_null_when_the_point_is_beyond_the_grid', () {
      final grid = ZoneGrid.forArea(circle(500));

      expect(grid.cellAt(offset(park, north: 900)), isNull);
    });
  });

  group('격자선', () {
    test('draws_every_edge_of_every_labeled_cell', () {
      final grid = ZoneGrid.forArea(circle(300));

      bool onSomeLine(GeoPoint p) => grid.lines.any((line) {
        final a = line.first;
        final b = line.last;
        const eps = 1e-9;
        final minLat = math.min(a.latitude, b.latitude) - eps;
        final maxLat = math.max(a.latitude, b.latitude) + eps;
        final minLng = math.min(a.longitude, b.longitude) - eps;
        final maxLng = math.max(a.longitude, b.longitude) + eps;
        return p.latitude >= minLat &&
            p.latitude <= maxLat &&
            p.longitude >= minLng &&
            p.longitude <= maxLng;
      });

      for (final cell in grid.cells) {
        final midLat = (cell.southWest.latitude + cell.northEast.latitude) / 2;
        final midLng =
            (cell.southWest.longitude + cell.northEast.longitude) / 2;
        final edges = [
          GeoPoint(latitude: cell.northEast.latitude, longitude: midLng),
          GeoPoint(latitude: cell.southWest.latitude, longitude: midLng),
          GeoPoint(latitude: midLat, longitude: cell.southWest.longitude),
          GeoPoint(latitude: midLat, longitude: cell.northEast.longitude),
        ];
        for (final e in edges) {
          expect(onSomeLine(e), isTrue, reason: '${cell.label} 테두리 누락');
        }
      }
    });
  });

  group('라벨 표시 줌', () {
    test('shows_labels_at_start_zoom_when_cells_are_50m', () {
      final grid = ZoneGrid.forArea(circle(300));

      expect(grid.labelsVisibleAt(16), isTrue);
      expect(grid.labelsVisibleAt(15), isFalse);
    });

    test('shows_labels_one_zoom_further_out_when_cells_are_100m', () {
      final grid = ZoneGrid.forArea(circle(500));

      expect(grid.labelsVisibleAt(15), isTrue);
      expect(grid.labelsVisibleAt(14), isFalse);
    });

    test('shows_labels_two_zooms_further_out_when_cells_are_200m', () {
      final grid = ZoneGrid.forArea(circle(1000));

      expect(grid.labelsVisibleAt(14), isTrue);
      expect(grid.labelsVisibleAt(13), isFalse);
    });
  });
}
