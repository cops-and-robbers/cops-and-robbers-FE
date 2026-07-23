import 'dart:math' as math;

import 'entities/area_shape.dart';

/// 폴리곤 편집(핀 모드) 전용 순수 기하 함수 모음.
///
/// 사용자가 무순서로 찍은 핀을 다각형으로 만들고 검증하는 데 쓰인다.
/// 전부 평면 근사 — 게임 스케일(수 km 이하)에서 충분하며,
/// 날짜변경선·극지방은 미지원 (한국 서비스 전제).

/// 무순서 핀 목록을 centroid 기준 방위각으로 정렬해 다각형 경계 순서로 만든다.
///
/// 찍은 순서·최근접 연결과 달리 순서 무관·결정적이며, 실사용 배치(≤10핀)에서
/// 자기교차 없는 단순 다각형을 만든다. 예외 배치는 [hasSelfIntersection]이 거른다.
List<GeoPoint> sortByAngleAroundCentroid(List<GeoPoint> points) {
  if (points.length < 2) return List.of(points);
  final cLat =
      points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
  final cLng =
      points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
  return List.of(points)..sort((a, b) {
    final angleA = math.atan2(a.latitude - cLat, a.longitude - cLng);
    final angleB = math.atan2(b.latitude - cLat, b.longitude - cLng);
    return angleA.compareTo(angleB);
  });
}

/// 다각형의 비인접 변끼리 교차하는지 검사 (완료 버튼 활성화 전 안전망)
///
/// n ≤ 10이라 최대 45쌍 — 성능 문제 없음.
bool hasSelfIntersection(List<GeoPoint> polygon) {
  final n = polygon.length;
  if (n < 4) return false; // 삼각형 이하는 자기교차 불가
  for (var i = 0; i < n; i++) {
    for (var j = i + 1; j < n; j++) {
      // 꼭짓점을 공유하는 인접 변은 제외
      if ((i + 1) % n == j || (j + 1) % n == i) continue;
      if (_segmentsIntersect(
        polygon[i],
        polygon[(i + 1) % n],
        polygon[j],
        polygon[(j + 1) % n],
      )) {
        return true;
      }
    }
  }
  return false;
}

/// shoelace 공식으로 다각형 면적(㎡) 계산 (면적 칩 표시용)
double polygonAreaInSquareMeters(List<GeoPoint> polygon) {
  if (polygon.length < 3) return 0;
  // 위도 1도당 거리(m) 근사. 경도는 기준 위도의 cos으로 보정.
  const metersPerDegLat = 111320.0;
  final refLatRad = polygon.first.latitude * math.pi / 180;
  final metersPerDegLng = metersPerDegLat * math.cos(refLatRad);
  var sum = 0.0;
  for (var i = 0; i < polygon.length; i++) {
    final a = polygon[i];
    final b = polygon[(i + 1) % polygon.length];
    final ax = a.longitude * metersPerDegLng;
    final ay = a.latitude * metersPerDegLat;
    final bx = b.longitude * metersPerDegLng;
    final by = b.latitude * metersPerDegLat;
    sum += ax * by - bx * ay;
  }
  return sum.abs() / 2;
}

/// inner 다각형이 outer 다각형 내부에 완전히 포함되는지 검사 (감옥⊂플레이그라운드)
///
/// 꼭짓점 전부 내부 + 변 교차 없음 두 조건 모두 필요 — 오목한 outer에서는
/// 꼭짓점이 모두 안이어도 변이 경계를 가로지를 수 있다.
bool isPolygonInsidePolygon(List<GeoPoint> inner, List<GeoPoint> outer) {
  if (inner.length < 3 || outer.length < 3) return false;
  final outerShape = AreaShape.polygon(points: outer);
  if (!inner.every(outerShape.contains)) return false;
  final ni = inner.length;
  final no = outer.length;
  for (var i = 0; i < ni; i++) {
    for (var j = 0; j < no; j++) {
      if (_segmentsIntersect(
        inner[i],
        inner[(i + 1) % ni],
        outer[j],
        outer[(j + 1) % no],
      )) {
        return false;
      }
    }
  }
  return true;
}

/// 세 점의 방향성(cross product) — 양수면 반시계, 음수면 시계
double _cross(GeoPoint o, GeoPoint a, GeoPoint b) =>
    (a.longitude - o.longitude) * (b.latitude - o.latitude) -
    (a.latitude - o.latitude) * (b.longitude - o.longitude);

/// 선분 (p1,p2)와 (p3,p4)의 진성 교차(끝점 접촉 제외) 판정
bool _segmentsIntersect(GeoPoint p1, GeoPoint p2, GeoPoint p3, GeoPoint p4) {
  final d1 = _cross(p3, p4, p1);
  final d2 = _cross(p3, p4, p2);
  final d3 = _cross(p1, p2, p3);
  final d4 = _cross(p1, p2, p4);
  return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
      ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
}
