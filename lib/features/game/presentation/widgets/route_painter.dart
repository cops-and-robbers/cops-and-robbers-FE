import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/game_area_model.dart';
import 'route_geometry.dart';

/// 경로 위에 찍을 마커 그룹 (같은 의미·색의 위치 모음).
///
/// 예: 경찰=체포 지점(빨강) / 도둑=잡힌 지점(빨강) + 탈옥 지점(노랑).
class RouteMarker {
  const RouteMarker(this.points, this.color);

  final List<LatLngModel> points;
  final Color color;
}

/// 내 이동 경로를 스타일라이즈드 곡선으로 그리는 페인터(구글 타일 미사용).
///
/// [markers]가 있으면 경로와 동일한 변환으로 투영해, 의미별 색 마커로 강조한다.
class RoutePainter extends CustomPainter {
  RoutePainter({
    required this.route,
    required this.lineColor,
    required this.startColor,
    required this.endColor,
    this.markers = const [],
  });

  final List<LatLngModel> route;
  final Color lineColor;
  final Color startColor;
  final Color endColor;

  /// 경로 위에 강조 표시할 마커 그룹들.
  final List<RouteMarker> markers;

  @override
  void paint(Canvas canvas, Size size) {
    final proj = projectRoute(route, size);
    final pts = proj.points;
    if (pts.isEmpty) return;

    if (pts.length >= 2) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      final stroke = Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, stroke);
    }

    // 시작/끝 점
    canvas.drawCircle(pts.first, 6, Paint()..color = startColor);
    canvas.drawCircle(pts.last, 6, Paint()..color = endColor);

    // 체포/탈옥/잡힘 마커 — 흰 헤일로 + 색 링 + 색 중심으로 도드라지게.
    for (final group in markers) {
      for (final m in group.points) {
        final c = proj.project(m);
        canvas.drawCircle(c, 8, Paint()..color = AppColors.white);
        canvas.drawCircle(
          c,
          8,
          Paint()
            ..color = group.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
        canvas.drawCircle(c, 3.5, Paint()..color = group.color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoutePainter old) =>
      old.route != route ||
      old.lineColor != lineColor ||
      old.startColor != startColor ||
      old.endColor != endColor ||
      old.markers != markers;
}
