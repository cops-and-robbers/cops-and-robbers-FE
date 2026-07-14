import 'dart:math' as math;
import 'dart:ui';

import '../../data/models/game_area_model.dart';

/// 경도(도) → Web Mercator x. 라디안 변환으로 y축과 단위를 맞춘다.
///
/// y는 라디안 기반 log 스케일인데 x를 도(degree) 그대로 쓰면 x가 약 57배
/// (180/π) 커져 경로가 세로로 납작하게 눌린다(좌우 직선처럼 보임). 동일 라디안
/// 단위로 맞춰야 위·경도 변화가 같은 비율로 반영된다.
double _mercatorX(double lonDeg) => lonDeg * math.pi / 180.0;

/// 위도(도) → Web Mercator y.
double _mercatorY(double latDeg) {
  final rad = latDeg * math.pi / 180.0;
  return math.log(math.tan(math.pi / 4 + rad / 2));
}

/// 경로 투영 결과 — 투영된 경로점들과, 동일 변환으로 임의 좌표를 투영하는 함수.
class RouteProjection {
  const RouteProjection(this.points, this._project);

  /// 경로점들의 캔버스 좌표.
  final List<Offset> points;

  final Offset Function(LatLngModel) _project;

  /// 경로와 동일한 변환으로 임의 좌표(체포/탈옥 위치 등)를 투영한다.
  Offset project(LatLngModel p) => _project(p);
}

/// 경로 좌표를 캔버스 좌표로 투영한다. (경로점 + 동일 변환 투영 함수 반환)
///
/// - Web Mercator 투영 후, 경로의 바운딩 박스를 [padding]을 제외한 영역에
///   비율 유지(uniform scale)로 맞춰 넣고 중앙 정렬한다.
/// - 화면 y축은 위가 0이므로 mercator y를 뒤집는다.
/// - 점이 없거나 한 점/모두 동일 좌표면 캔버스 중앙에 배치한다.
RouteProjection projectRoute(
  List<LatLngModel> route,
  Size size, {
  double padding = 12.0,
}) {
  final centerX = size.width / 2;
  final centerY = size.height / 2;
  final center = Offset(centerX, centerY);

  if (route.isEmpty) {
    return RouteProjection(const [], (_) => center);
  }

  final xs = route.map((p) => _mercatorX(p.longitude)).toList();
  final ys = route.map((p) => _mercatorY(p.latitude)).toList();

  final minX = xs.reduce(math.min);
  final maxX = xs.reduce(math.max);
  final minY = ys.reduce(math.min);
  final maxY = ys.reduce(math.max);

  final spanX = maxX - minX;
  final spanY = maxY - minY;

  // 둘 다 0이면(단일/동일 좌표) 전부 중앙.
  if (spanX == 0 && spanY == 0) {
    return RouteProjection(
      List<Offset>.filled(route.length, center),
      (_) => center,
    );
  }

  final availW = size.width - padding * 2;
  final availH = size.height - padding * 2;
  final scaleX = spanX == 0 ? double.infinity : availW / spanX;
  final scaleY = spanY == 0 ? double.infinity : availH / spanY;
  final scale = math.min(scaleX, scaleY);

  final originX = centerX - spanX * scale / 2;
  final originY = centerY - spanY * scale / 2;

  Offset project(LatLngModel p) => Offset(
    originX + (_mercatorX(p.longitude) - minX) * scale,
    // mercator y가 클수록 위(북쪽) → 화면 위(작은 y)로 뒤집기
    originY + (maxY - _mercatorY(p.latitude)) * scale,
  );

  return RouteProjection([for (final p in route) project(p)], project);
}

/// 경로점들의 캔버스 좌표만 반환하는 편의 함수.
List<Offset> projectRouteToCanvas(
  List<LatLngModel> route,
  Size size, {
  double padding = 12.0,
}) => projectRoute(route, size, padding: padding).points;
