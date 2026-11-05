import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'tutorial_camera.dart';
import 'tutorial_map_data.dart';
import 'tutorial_stage.dart';
import 'tutorial_timeline.dart';

class _MapPalette {
  const _MapPalette({
    required this.sky,
    required this.base,
    required this.park,
    required this.road,
    required this.wallA,
    required this.wallB,
    required this.roof,
    required this.line,
  });

  final Color sky;
  final Color base;
  final Color park;
  final Color road;
  final Color wallA;
  final Color wallB;
  final Color roof;
  final Color line;
}

const _lightPalette = _MapPalette(
  sky: AppColors.background,
  base: AppColors.black100,
  park: AppColors.green100,
  road: AppColors.white,
  wallA: AppColors.black200,
  wallB: AppColors.black300,
  roof: AppColors.white,
  line: AppColors.black200,
);

/// 도둑 게임 화면과 같은 지도색(MapStyles.dark). 건물 옆면만 3D용으로 같은 표에서 골랐다.
const _darkPalette = _MapPalette(
  sky: AppColors.black,
  base: Color(0xFF1A1A2E),
  park: Color(0xFF1A3320),
  road: Color(0xFF3A3A5C),
  wallA: Color(0xFF252540),
  wallB: Color(0xFF1A1A2E),
  roof: Color(0xFF2D2D44),
  line: Color(0xFF44445E),
);

const double _w = tutorialStageWidth;
const double _h = tutorialStageHeight;

/// 태블릿처럼 옆자리가 남는 화면에서도 지도가 이어지도록 무대 밖까지 칠하는 범위.
const Rect _paintBounds = Rect.fromLTWH(-800, -800, _w + 1600, _h + 1600);

/// 지도 한 장을 카메라에 맞춰 그린다. 라이트·다크 레이어가 각각 하나씩 쓴다.
class TutorialMapPainter extends CustomPainter {
  TutorialMapPainter({
    required this.stage,
    required this.map,
    required this.isDark,
  }) : super(repaint: stage);

  final TutorialStage stage;
  final TutorialMapData map;
  final bool isDark;

  static const _ringSteps = 72;

  @override
  void paint(Canvas canvas, Size size) {
    final palette = isDark ? _darkPalette : _lightPalette;
    final frame = stage.cameraFrame();
    final view = stage.view;
    final fill = Paint()..isAntiAlias = true;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRect(_paintBounds, fill..color = palette.base);

    if (frame.tilt > 40) {
      final horizon = frame.horizonY;
      if (horizon > 0) {
        canvas.drawRect(
          Rect.fromLTRB(
            _paintBounds.left,
            _paintBounds.top,
            _paintBounds.right,
            horizon,
          ),
          fill..color = palette.sky,
        );
      }
    }

    fill.color = palette.park;
    for (final park in map.parks) {
      canvas.drawPath(_polygon(frame, park, 0), fill);
    }

    stroke.color = palette.road;
    for (final road in map.roads) {
      final points = road.points;
      for (var i = 0; i + 3 < points.length; i += 2) {
        final a = frame.project(points[i], points[i + 1]);
        final b = frame.project(points[i + 2], points[i + 3]);
        if (a.depth < 40 && b.depth < 40) continue;
        stroke.strokeWidth =
            road.width * frame.scale * math.min(6, (a.k + b.k) / 2);
        canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y), stroke);
      }
    }

    _paintBuildings(canvas, frame, palette, fill, stroke);

    // 구역 밖을 어둡게 해서 구역이 먼저 보이게 한다
    final zone = _ring(frame, view['px'], view['py'], view['play']);
    if (view['dim'] > 0) {
      final outside = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(_paintBounds)
        ..addPath(zone, Offset.zero);
      canvas.drawPath(
        outside,
        fill..color = AppColors.black.withValues(alpha: .4 * view['dim']),
      );
    }

    if (view['na'] > 0) {
      _paintDashedRing(canvas, frame, stroke, view);
    }

    if (view['white'] > 0) {
      canvas.drawPath(
        zone,
        fill..color = AppColors.white.withValues(alpha: view['white']),
      );
    }
    canvas.drawPath(
      zone,
      stroke
        ..color = AppColors.blue800
        ..strokeWidth = 3,
    );

    if (view['ra'] > 0 && view['rt'] > 0) {
      _paintRoute(canvas, frame, stroke, view);
    }
    if (view['jail'] > 0) {
      final jail = _ring(
        frame,
        TutorialStage.jailX,
        TutorialStage.jailY,
        TutorialStage.jailRadius * (1 + .16 * view['pul']),
      );
      canvas.drawPath(
        jail,
        fill
          ..color = AppColors.red500Alpha20.withValues(
            alpha: AppColors.red500Alpha20.a * view['jail'],
          ),
      );
      canvas.drawPath(
        jail,
        stroke
          ..color = AppColors.red500.withValues(alpha: view['jail'])
          ..strokeWidth = 3,
      );
    }
    if (view['wa'] > 0) {
      canvas.drawPath(
        _ring(
          frame,
          stage.rob['x'],
          stage.rob['y'],
          24 + 30 * (1 - view['wa']),
        ),
        stroke
          ..color = AppColors.red.withValues(alpha: view['wa'])
          ..strokeWidth = 3,
      );
    }
    if (view['trA'] > 0 && view['tr'] > 0) {
      _paintWalkedPath(canvas, frame, stroke, view);
    }
    _paintHaste(canvas, frame, stroke, fill);
  }

  void _paintBuildings(
    Canvas canvas,
    CameraFrame frame,
    _MapPalette palette,
    Paint fill,
    Paint stroke,
  ) {
    // 먼 건물부터 그린다
    final ordered =
        <({TutorialBuilding building, double depth, double screenX})>[];
    for (final building in map.buildings) {
      final points = building.points;
      final count = points.length / 2;
      var sumX = 0.0;
      var sumY = 0.0;
      for (var i = 0; i < points.length; i += 2) {
        sumX += points[i];
        sumY += points[i + 1];
      }
      final center = frame.project(sumX / count, sumY / count);
      ordered.add((building: building, depth: center.depth, screenX: center.x));
    }
    ordered.sort((a, b) => b.depth.compareTo(a.depth));

    for (final item in ordered) {
      // 낮은 시점에서는 카메라와 대상 사이 건물이 화면을 막으므로 그리지 않는다
      if (frame.persp < 600 &&
          item.depth < frame.persp * .9 &&
          (item.screenX - _w / 2).abs() < 150) {
        continue;
      }
      final points = item.building.points;
      var allBehind = true;
      for (var i = 0; i < points.length; i += 2) {
        if (frame.project(points[i], points[i + 1]).depth >= 70) {
          allBehind = false;
          break;
        }
      }
      if (allBehind) continue;

      if (frame.tilt > .5) {
        for (var i = 0; i + 3 < points.length; i += 2) {
          final isWide =
              (points[i + 2] - points[i]).abs() >
              (points[i + 3] - points[i + 1]).abs();
          final a = frame.project(points[i], points[i + 1]);
          final b = frame.project(points[i + 2], points[i + 3]);
          final c = frame.project(
            points[i + 2],
            points[i + 3],
            item.building.height,
          );
          final d = frame.project(
            points[i],
            points[i + 1],
            item.building.height,
          );
          canvas.drawPath(
            Path()
              ..moveTo(a.x, a.y)
              ..lineTo(b.x, b.y)
              ..lineTo(c.x, c.y)
              ..lineTo(d.x, d.y)
              ..close(),
            fill..color = isWide ? palette.wallA : palette.wallB,
          );
        }
      }
      final roof = _polygon(frame, points, item.building.height);
      canvas.drawPath(roof, fill..color = palette.roof);
      canvas.drawPath(
        roof,
        stroke
          ..color = palette.line
          ..strokeWidth = .6,
      );
    }
  }

  void _paintDashedRing(
    Canvas canvas,
    CameraFrame frame,
    Paint stroke,
    TutorialProps view,
  ) {
    final ring = _ring(frame, view['nx'], view['ny'], view['nr']);
    stroke
      ..color = AppColors.blue500.withValues(alpha: view['na'])
      ..strokeWidth = 2;
    for (final metric in ring.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 6), stroke);
      }
    }
  }

  void _paintRoute(
    Canvas canvas,
    CameraFrame frame,
    Paint stroke,
    TutorialProps view,
  ) {
    final end = TutorialStage.routeAt(view['rt']);
    final path = Path();
    for (var i = 0; i <= end.index; i++) {
      final p = frame.project(
        TutorialStage.route[i][0],
        TutorialStage.route[i][1],
      );
      i == 0 ? path.moveTo(p.x, p.y) : path.lineTo(p.x, p.y);
    }
    final tip = frame.project(end.x, end.y);
    path.lineTo(tip.x, tip.y);
    canvas.drawPath(
      path,
      stroke
        ..color = AppColors.blue.withValues(alpha: view['ra'])
        ..strokeWidth = 4,
    );
  }

  // 잡힌 도둑이 걸어 들어간 길을 점선으로 남긴다
  void _paintWalkedPath(
    Canvas canvas,
    CameraFrame frame,
    Paint stroke,
    TutorialProps view,
  ) {
    const jx = TutorialStage.jailX;
    const jy = TutorialStage.jailY;
    final a = frame.project(jx + 62, jy - 62);
    final b = frame.project(
      jx + 62 * (1 - view['tr']),
      jy - 62 * (1 - view['tr']),
    );
    final path = Path()
      ..moveTo(a.x, a.y)
      ..lineTo(b.x, b.y);
    stroke
      ..color = AppColors.red500.withValues(alpha: view['trA'])
      ..strokeWidth = 3;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 2), stroke);
      }
    }
  }

  void _paintHaste(Canvas canvas, CameraFrame frame, Paint stroke, Paint fill) {
    final speed = stage.run['v'];
    if (speed < .02) return;
    final vx = _w / 2;
    final vy = frame.horizonY;
    stroke
      ..color = AppColors.black300.withValues(alpha: .75 * speed)
      ..strokeWidth = 2;
    const lines = 30;
    for (var i = 0; i < lines; i++) {
      final angle = i / lines * 6.283 + (i * 7 % 5) * .04;
      final offset = (i * 13 % lines) / lines;
      final f = (offset + stage.run['t'] * 1.7) % 1;
      final from = 70 + f * f * 340;
      final to = from + 30 + f * 90;
      canvas.drawLine(
        Offset(vx + math.cos(angle) * from, vy + math.sin(angle) * from),
        Offset(vx + math.cos(angle) * to, vy + math.sin(angle) * to),
        stroke,
      );
    }
    canvas.drawRect(
      _paintBounds,
      fill
        ..shader = ui.Gradient.radial(
          Offset(vx, vy + 40),
          360,
          [
            AppColors.white.withValues(alpha: 0),
            AppColors.white.withValues(alpha: .7 * speed),
          ],
          const [110 / 360, 1],
        ),
    );
    fill.shader = null;
  }

  Path _polygon(CameraFrame frame, List<double> points, double z) {
    final path = Path();
    for (var i = 0; i < points.length; i += 2) {
      final p = frame.project(points[i], points[i + 1], z);
      i == 0 ? path.moveTo(p.x, p.y) : path.lineTo(p.x, p.y);
    }
    return path;
  }

  Path _ring(CameraFrame frame, double x, double y, double radius) {
    final path = Path();
    for (var i = 0; i < _ringSteps; i++) {
      final angle = i / _ringSteps * 2 * math.pi;
      final p = frame.project(
        x + radius * math.cos(angle),
        y + radius * math.sin(angle),
      );
      i == 0 ? path.moveTo(p.x, p.y) : path.lineTo(p.x, p.y);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(TutorialMapPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.map != map;
}
