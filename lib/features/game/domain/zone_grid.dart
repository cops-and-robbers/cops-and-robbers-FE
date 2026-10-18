import 'dart:math' as math;

import 'entities/area_shape.dart';

/// 인게임 지도 좌표 격자 한 칸 — "C3"처럼 열 글자 + 행 번호로 부른다.
class ZoneGridCell {
  const ZoneGridCell({
    required this.label,
    required this.southWest,
    required this.northEast,
  });

  final String label;
  final GeoPoint southWest;
  final GeoPoint northEast;

  GeoPoint get center => GeoPoint(
    latitude: (southWest.latitude + northEast.latitude) / 2,
    longitude: (southWest.longitude + northEast.longitude) / 2,
  );
}

/// 게임 구역을 덮는 좌표 격자 (#636)
///
/// 모든 기기가 같은 구역 정보로 같은 계산을 하므로 서버 없이도 모두에게 같은 라벨이 뜬다.
/// 라벨은 구역을 덮는 정사각형 기준으로 매겨 고정하고(열 서→동 A…, 행 북→남 1…),
/// 구역에 걸친 칸만 [cells]·[lines]에 담는다 — 구역 밖 칸은 빈자리로 남는다.
class ZoneGrid {
  const ZoneGrid._({
    required this.cellMeters,
    required this.size,
    required this.cells,
    required this.lines,
    required this.centerLatitude,
  });

  factory ZoneGrid.forArea(AreaShape area) {
    final radius = area.boundingRadiusInMeters;
    // 한 변이 12칸 이하가 되는 가장 작은 칸 — 칸이 너무 촘촘하면 라벨이 겹치고 읽기 어렵다
    // (반경 300m까지 50m, 기본 500m는 100m, 원형 상한 1km는 200m)
    // 1000m 칸이면 반경 6km까지 12칸 — 그보다 큰 구역은 마지막 단계를 쓴다
    final cellMeters = _cellSteps.firstWhere(
      (step) => (2 * radius / step).ceil() <= _maxColumns,
      orElse: () => _cellSteps.last,
    );
    final size = math.max(1, (2 * radius / cellMeters).ceil());

    final c = area.centroid;
    final latPerMeter = 180 / (math.pi * _earthRadius);
    final lngPerMeter = latPerMeter / math.cos(c.latitude * math.pi / 180);
    final half = size * cellMeters / 2;
    final north = c.latitude + half * latPerMeter;
    final west = c.longitude - half * lngPerMeter;
    final cellLat = cellMeters * latPerMeter;
    final cellLng = cellMeters * lngPerMeter;

    double latOfRow(int row) => north - row * cellLat;
    double lngOfCol(int col) => west + col * cellLng;

    final included = List.generate(
      size,
      (row) => List.generate(
        size,
        (col) => _overlaps(
          area,
          south: latOfRow(row + 1),
          north: latOfRow(row),
          west: lngOfCol(col),
          east: lngOfCol(col + 1),
        ),
      ),
    );

    final cells = <ZoneGridCell>[
      for (var row = 0; row < size; row++)
        for (var col = 0; col < size; col++)
          if (included[row][col])
            ZoneGridCell(
              label: '${String.fromCharCode(0x41 + col)}${row + 1}',
              southWest: GeoPoint(
                latitude: latOfRow(row + 1),
                longitude: lngOfCol(col),
              ),
              northEast: GeoPoint(
                latitude: latOfRow(row),
                longitude: lngOfCol(col + 1),
              ),
            ),
    ];

    bool at(int row, int col) =>
        row >= 0 && row < size && col >= 0 && col < size && included[row][col];

    // 칸 테두리를 이어지는 구간끼리 한 선으로 묶는다 — 칸마다 사각형을 그리면 선 개체가 수백 개가 된다
    final lines = <List<GeoPoint>>[];
    for (var k = 0; k <= size; k++) {
      lines
        ..addAll(
          _runs(size, (row) => at(row, k - 1) || at(row, k)).map(
            (r) => [
              GeoPoint(latitude: latOfRow(r.start), longitude: lngOfCol(k)),
              GeoPoint(latitude: latOfRow(r.end), longitude: lngOfCol(k)),
            ],
          ),
        )
        ..addAll(
          _runs(size, (col) => at(k - 1, col) || at(k, col)).map(
            (r) => [
              GeoPoint(latitude: latOfRow(k), longitude: lngOfCol(r.start)),
              GeoPoint(latitude: latOfRow(k), longitude: lngOfCol(r.end)),
            ],
          ),
        );
    }

    return ZoneGrid._(
      cellMeters: cellMeters,
      size: size,
      cells: cells,
      lines: lines,
      centerLatitude: c.latitude,
    );
  }

  static const _earthRadius = 6371000.0;
  static const _maxColumns = 12;

  /// 칸 크기 후보 — "한 칸 = 100m"처럼 바로 읽히는 딱 떨어지는 값만
  static const _cellSteps = [50.0, 100.0, 200.0, 500.0, 1000.0];

  /// 라벨을 읽을 수 있는 칸의 최소 화면 크기 (logical px)
  static const _minLabelCellPx = 24.0;

  final double cellMeters;

  /// 한 변의 칸 수
  final int size;

  /// 구역에 걸친 칸만
  final List<ZoneGridCell> cells;

  /// 구역에 걸친 칸의 테두리 (각 선은 시작·끝 두 점)
  final List<List<GeoPoint>> lines;

  final double centerLatitude;

  /// 점이 들어 있는 칸 이름 — 구역에 걸친 칸이 아니면 null.
  /// 칸 경계 위의 점은 북서쪽 칸으로 본다 (칸 수가 12×12 이하라 순회로 충분하다).
  String? cellAt(GeoPoint point) {
    for (final cell in cells) {
      if (point.latitude >= cell.southWest.latitude &&
          point.latitude <= cell.northEast.latitude &&
          point.longitude >= cell.southWest.longitude &&
          point.longitude <= cell.northEast.longitude) {
        return cell.label;
      }
    }
    return null;
  }

  /// 이 줌에서 한 칸이 라벨을 읽을 만큼 큰지 — 작으면 라벨끼리 겹친다
  bool labelsVisibleAt(double zoom) {
    final metersPerPx =
        156543.03392 *
        math.cos(centerLatitude * math.pi / 180) /
        math.pow(2, zoom);
    return cellMeters / metersPerPx >= _minLabelCellPx;
  }

  /// 칸이 구역에 조금이라도 걸치는지
  static bool _overlaps(
    AreaShape area, {
    required double south,
    required double north,
    required double west,
    required double east,
  }) {
    bool inCell(GeoPoint p) =>
        p.latitude >= south &&
        p.latitude <= north &&
        p.longitude >= west &&
        p.longitude <= east;

    // 원: 중심에서 가장 가까운 칸 안의 점 하나로 정확히 판정된다
    final exact = area.when(
      circle: (center, _) => area.contains(
        GeoPoint(
          latitude: center.latitude.clamp(south, north),
          longitude: center.longitude.clamp(west, east),
        ),
      ),
      polygon: (points) => points.any(inCell),
    );
    if (exact) return true;

    // ponytail: 칸 안 5×5 점 표본 — 점 간격(칸의 1/4)보다 가늘게 걸친 폴리곤 조각은 놓친다.
    // 실제로 문제가 되면 사각형·다각형 변 교차 판정으로 바꾼다.
    const steps = 4;
    for (var i = 0; i <= steps; i++) {
      for (var j = 0; j <= steps; j++) {
        final p = GeoPoint(
          latitude: south + (north - south) * i / steps,
          longitude: west + (east - west) * j / steps,
        );
        if (area.contains(p)) return true;
      }
    }
    return false;
  }

  /// [test]가 참인 인덱스의 연속 구간 (끝은 배타)
  static Iterable<({int start, int end})> _runs(
    int length,
    bool Function(int index) test,
  ) sync* {
    int? start;
    for (var i = 0; i <= length; i++) {
      final on = i < length && test(i);
      if (on && start == null) start = i;
      if (!on && start != null) {
        yield (start: start, end: i);
        start = null;
      }
    }
  }
}
