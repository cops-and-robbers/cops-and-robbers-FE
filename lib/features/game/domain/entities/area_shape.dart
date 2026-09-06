import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';

part 'area_shape.freezed.dart';

/// 도메인 좌표 (google_maps LatLng 비의존 — 순수 도메인 타입)
@freezed
class GeoPoint with _$GeoPoint {
  const factory GeoPoint({
    required double latitude,
    required double longitude,
  }) = _GeoPoint;
}

/// 게임 구역 도형 — 원형/다각형 공통 추상화
///
/// 이탈판정·감옥판정·카메라 계산이 도형 종류와 무관하게 동작하도록
/// 분기를 union 내부에 숨긴다. 렌더링처럼 출력이 실제로 다른 곳만
/// `when()`으로 명시 분기한다.
@freezed
class AreaShape with _$AreaShape {
  const AreaShape._();

  const factory AreaShape.circle({
    required GeoPoint center,
    required double radiusInMeters,
  }) = CircleShape;

  const factory AreaShape.polygon({required List<GeoPoint> points}) =
      PolygonShape;

  /// 점이 구역 내부(경계 포함)에 있는지 판정
  ///
  /// 폴리곤은 ray casting 평면 근사 — 게임 스케일(수 km 이하)에서 오차 무시
  /// 가능. 날짜변경선·극지방은 미지원 (한국 서비스 전제).
  bool contains(GeoPoint point) => when(
    circle: (center, radiusInMeters) =>
        Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          point.latitude,
          point.longitude,
        ) <=
        radiusInMeters,
    polygon: (points) => _rayCastContains(points, point),
  );

  /// 점에서 실제 도형 경계까지의 최단 거리(m).
  ///
  /// 폴리곤을 외접 원으로 근사하지 않아 오목한 영역과 꼭짓점에서도 실제 경계를
  /// 기준으로 GPS 이탈 여유를 적용할 수 있다.
  double distanceToBoundaryInMeters(GeoPoint point) => when(
    circle: (center, radiusInMeters) =>
        (Geolocator.distanceBetween(
                  center.latitude,
                  center.longitude,
                  point.latitude,
                  point.longitude,
                ) -
                radiusInMeters)
            .abs(),
    polygon: (points) => _distanceToPolygonBoundary(points, point),
  );

  /// 구역 대표 중심점 (카메라 초기 위치용)
  GeoPoint get centroid => when(
    circle: (center, _) => center,
    polygon: (points) {
      final lat =
          points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
      final lng =
          points.map((p) => p.longitude).reduce((a, b) => a + b) /
          points.length;
      return GeoPoint(latitude: lat, longitude: lng);
    },
  );

  /// 구역을 덮는 대략적 반경(m) — 기존 반경 기반 줌 계산 파이프라인 재사용용
  double get boundingRadiusInMeters => when(
    circle: (_, radiusInMeters) => radiusInMeters,
    polygon: (points) {
      final c = centroid;
      return points
          .map(
            (p) => Geolocator.distanceBetween(
              c.latitude,
              c.longitude,
              p.latitude,
              p.longitude,
            ),
          )
          .reduce((a, b) => a > b ? a : b);
    },
  );

  /// 구역을 덮는 위경도 박스 (남서/북동 꼭짓점) — 인게임 카메라 이동 제한용
  ///
  /// centroid ± boundingRadius × (1 + [marginRatio])를 평면 근사로 환산한다.
  /// 길쭉한 폴리곤은 짧은 축이 실제보다 후해지지만, "구역에서 크게 못 벗어나게"
  /// 하는 목적에는 충분하다 (도형별 정밀 박스는 필요해질 때).
  ({GeoPoint southWest, GeoPoint northEast}) boundingBox({
    double marginRatio = 0,
  }) {
    const earthRadius = 6371000.0;
    final c = centroid;
    final halfInMeters = boundingRadiusInMeters * (1 + marginRatio);
    final latOffset = (halfInMeters / earthRadius) * (180 / math.pi);
    final lngOffset = latOffset / math.cos(c.latitude * math.pi / 180);
    return (
      southWest: GeoPoint(
        latitude: c.latitude - latOffset,
        longitude: c.longitude - lngOffset,
      ),
      northEast: GeoPoint(
        latitude: c.latitude + latOffset,
        longitude: c.longitude + lngOffset,
      ),
    );
  }
}

/// 게임 구역 엔티티 — 서버 제약상 두 구역은 항상 같은 도형 타입이지만,
/// 소비처는 타입 혼합 여부와 무관하게 각 shape만 다루면 된다.
@freezed
class GameAreaEntity with _$GameAreaEntity {
  const factory GameAreaEntity({
    required AreaShape playground,
    required AreaShape jail,
  }) = _GameAreaEntity;
}

/// ray casting 내부 판정 — 점에서 수평 반직선을 쏘아 변과의 교차 횟수가
/// 홀수면 내부. 위경도 축 스케일 차이는 교차 '횟수'에 영향 없음(위상 판정).
bool _rayCastContains(List<GeoPoint> pts, GeoPoint p) {
  if (pts.length < 3) return false;

  var inside = false;
  for (var i = 0, j = pts.length - 1; i < pts.length; j = i++) {
    final a = pts[i];
    final b = pts[j];
    if (_isPointOnSegment(a, b, p)) return true;

    final intersects =
        ((a.latitude > p.latitude) != (b.latitude > p.latitude)) &&
        (p.longitude <
            (b.longitude - a.longitude) *
                    (p.latitude - a.latitude) /
                    (b.latitude - a.latitude) +
                a.longitude);
    if (intersects) inside = !inside;
  }
  return inside;
}

/// 부동소수점 좌표에서 점이 선분 위에 있는지 판정한다.
bool _isPointOnSegment(GeoPoint a, GeoPoint b, GeoPoint p) {
  const epsilon = 1e-12;
  final cross =
      (p.longitude - a.longitude) * (b.latitude - a.latitude) -
      (p.latitude - a.latitude) * (b.longitude - a.longitude);
  if (cross.abs() > epsilon) return false;

  final minLatitude = a.latitude < b.latitude ? a.latitude : b.latitude;
  final maxLatitude = a.latitude > b.latitude ? a.latitude : b.latitude;
  final minLongitude = a.longitude < b.longitude ? a.longitude : b.longitude;
  final maxLongitude = a.longitude > b.longitude ? a.longitude : b.longitude;

  return p.latitude >= minLatitude - epsilon &&
      p.latitude <= maxLatitude + epsilon &&
      p.longitude >= minLongitude - epsilon &&
      p.longitude <= maxLongitude + epsilon;
}

double _distanceToPolygonBoundary(List<GeoPoint> points, GeoPoint point) {
  if (points.isEmpty) return 0;

  const metersPerDegreeLatitude = 111320.0;
  final metersPerDegreeLongitude =
      metersPerDegreeLatitude * math.cos(point.latitude * math.pi / 180);
  var nearest = double.infinity;

  for (var i = 0; i < points.length; i++) {
    final a = points[i];
    final b = points[(i + 1) % points.length];
    final ax = (a.longitude - point.longitude) * metersPerDegreeLongitude;
    final ay = (a.latitude - point.latitude) * metersPerDegreeLatitude;
    final bx = (b.longitude - point.longitude) * metersPerDegreeLongitude;
    final by = (b.latitude - point.latitude) * metersPerDegreeLatitude;
    final dx = bx - ax;
    final dy = by - ay;
    final lengthSquared = dx * dx + dy * dy;
    final t = lengthSquared == 0
        ? 0.0
        : (-(ax * dx + ay * dy) / lengthSquared).clamp(0.0, 1.0);
    nearest = math.min(
      nearest,
      math.sqrt(math.pow(ax + t * dx, 2) + math.pow(ay + t * dy, 2)),
    );
  }

  return nearest.isFinite ? nearest : 0;
}
