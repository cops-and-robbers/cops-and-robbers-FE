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
    required this.treeShadow,
    required this.treeTrunk,
    required this.treeTones,
    required this.road,
    required this.wallA,
    required this.wallB,
    required this.roofs,
    required this.line,
  });

  final Color sky;
  final Color base;
  final Color park;
  final Color treeShadow;
  final Color treeTrunk;
  final List<_TreeTone> treeTones;
  final Color road;
  final Color wallA;
  final Color wallB;
  final List<Color> roofs;
  final Color line;
}

class _TreeTone {
  const _TreeTone({required this.shade, required this.mid, required this.top});

  final Color shade;
  final Color mid;
  final Color top;
}

/// 나무 윗부분의 잎 덩어리 세 개. 값은 나무 반지름 기준이다.
const _treeLobes = [
  (dx: -.5, dy: .12, radius: .66),
  (dx: .5, dy: .18, radius: .62),
  (dx: 0.0, dy: -.34, radius: .74),
];

/// 구역 밖을 어둡게 하는 세기.
const double _outsideDim = .4;

/// 건물과 나무 한 채를 얼마나 어둡게 할지. 한 채씩 통째로 판단해 구역 선에 잘리지 않는다.
///
/// 구역이 줄어들면 밝은 건물이 새 경계에 걸쳐 원이 잘려 보이므로 안쪽도 함께 어둡게 한다.
double tutorialObjectDim(TutorialProps view, double x, double y) {
  final outside = _outsideDim * view['dim'];
  // 흰 원이 덮는 장면에서는 원이 지나가도 밝아지지 않게 한다
  if (view['white'] > 0) return outside;
  final dx = x - view['px'];
  final dy = y - view['py'];
  final radius = view['play'];
  if (dx * dx + dy * dy > radius * radius) return outside;
  final shrunk = (TutorialStage.playRadius - radius) / 40;
  return outside * shrunk.clamp(0.0, 1.0);
}

const _lightPalette = _MapPalette(
  sky: AppColors.background,
  base: AppColors.black100,
  park: AppColors.green100,
  treeShadow: AppColors.black200,
  treeTrunk: AppColors.black500,
  treeTones: [
    _TreeTone(
      shade: AppColors.deepGreen,
      mid: AppColors.deepGreen900,
      top: AppColors.green800,
    ),
    _TreeTone(
      shade: AppColors.deepGreen900,
      mid: AppColors.green800,
      top: AppColors.green500,
    ),
  ],
  road: AppColors.white,
  wallA: AppColors.black200,
  wallB: AppColors.black300,
  roofs: [
    AppColors.white,
    AppColors.black100,
    AppColors.blueVer2_50,
    AppColors.red100,
  ],
  line: AppColors.black200,
);

/// 도둑 게임 화면과 같은 지도색(MapStyles.dark). 건물 옆면만 3D용으로 같은 표에서 골랐다.
const _darkPalette = _MapPalette(
  sky: AppColors.black,
  base: Color(0xFF1A1A2E),
  park: Color(0xFF1A3320),
  treeShadow: AppColors.black,
  treeTrunk: AppColors.black700,
  treeTones: [
    _TreeTone(
      shade: Color(0xFF1F4A2C),
      mid: Color(0xFF2F6B42),
      top: Color(0xFF4B9160),
    ),
    _TreeTone(
      shade: Color(0xFF2A5C38),
      mid: Color(0xFF3D7A4F),
      top: Color(0xFF5FA874),
    ),
  ],
  road: Color(0xFF3A3A5C),
  wallA: Color(0xFF252540),
  wallB: Color(0xFF1A1A2E),
  roofs: [
    Color(0xFF2D2D44),
    Color(0xFF252540),
    Color(0xFF3A3A5C),
    Color(0xFF44445E),
  ],
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

    // 구역 밖을 어둡게 해서 구역이 먼저 보이게 한다.
    // 어둡게 칠하기와 구역 선은 땅에 그린다. 건물과 나무 위에 그리면 잘린 면이 공중에 뜬 판처럼 보인다.
    final zone = _ring(frame, view['px'], view['py'], view['play']);
    if (view['dim'] > 0) {
      final outside = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(_paintBounds)
        ..addPath(zone, Offset.zero);
      canvas.drawPath(
        outside,
        fill
          ..color = AppColors.black.withValues(
            alpha: _outsideDim * view['dim'],
          ),
      );
    }

    void paintZoneLine() => canvas.drawPath(
      zone,
      stroke
        ..color = AppColors.blue800
        ..strokeWidth = 3,
    );
    paintZoneLine();

    _paintTrees(canvas, frame, palette, fill, stroke, view);
    _paintBuildings(canvas, frame, palette, fill, stroke, view);

    // 마지막 장면은 원 안을 모두 덮어야 하므로 건물과 나무 위에 그린다
    if (view['white'] > 0) {
      canvas.drawPath(
        zone,
        fill..color = AppColors.white.withValues(alpha: view['white']),
      );
      paintZoneLine();
    }
    // 구역이 줄어드는 장면은 줄어드는 선이 나무에 가리면 안 된다
    if (view['play'] < TutorialStage.playRadius) paintZoneLine();
    if (view['na'] > 0) _paintDashedRing(canvas, frame, stroke, view);

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

  Color _dimmed(Color color, double amount) =>
      Color.lerp(color, AppColors.black, amount)!;

  void _paintTrees(
    Canvas canvas,
    CameraFrame frame,
    _MapPalette palette,
    Paint fill,
    Paint stroke,
    TutorialProps view,
  ) {
    final tiltCos = math.cos(frame.tilt * math.pi / 180);
    for (final tree in map.trees) {
      final base = frame.project(tree.x, tree.y);
      if (base.depth < 70 || !_paintBounds.contains(Offset(base.x, base.y))) {
        continue;
      }
      // 낮은 시점에서는 건물처럼 카메라 앞을 막는 나무를 그리지 않는다
      if (frame.persp < 600 &&
          base.depth < frame.persp * .9 &&
          (base.x - _w / 2).abs() < 150) {
        continue;
      }
      final r = tree.radius * frame.scale * math.min(6, base.k);
      final top = frame.project(tree.x, tree.y, tree.height);
      // 좌표로 나눠 나무마다 색과 모양이 조금씩 다르게 한다
      final seed = (tree.x + tree.y * 3).round();
      final tone = palette.treeTones[seed.abs() % palette.treeTones.length];
      final dim = tutorialObjectDim(view, tree.x, tree.y);
      final shade = _dimmed(tone.shade, dim);
      final mid = _dimmed(tone.mid, dim);
      final highlight = _dimmed(tone.top, dim);
      final mirror = seed.isEven ? 1.0 : -1.0;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(base.x + r * .2, base.y + r * .1),
          width: r * 2.2,
          height: r * (.5 + 1.7 * tiltCos),
        ),
        fill..color = _dimmed(palette.treeShadow, dim),
      );
      if (frame.tilt > .5) {
        canvas.drawLine(
          Offset(base.x, base.y),
          Offset(top.x, top.y),
          stroke
            ..color = _dimmed(palette.treeTrunk, dim)
            ..strokeWidth = r * .3,
        );
      }
      // 멀리 있어 작게 보이는 나무는 잎 덩어리를 나누지 않는다
      if (r < 5) {
        canvas.drawCircle(Offset(top.x, top.y), r, fill..color = mid);
        continue;
      }
      fill.color = shade;
      for (final lobe in _treeLobes) {
        canvas.drawCircle(
          Offset(top.x + lobe.dx * r * mirror, top.y + (lobe.dy + .16) * r),
          lobe.radius * r,
          fill,
        );
      }
      fill.color = mid;
      for (final lobe in _treeLobes) {
        canvas.drawCircle(
          Offset(top.x + lobe.dx * r * mirror, top.y + lobe.dy * r),
          lobe.radius * r * .92,
          fill,
        );
      }
      // 잎을 한 층 더 올려 3D에서 키 큰 나무로 보이게 한다. 위에서 보면 겹쳐서 하나로 보인다.
      final cap = frame.project(tree.x, tree.y, tree.height * 1.34);
      canvas.drawCircle(
        Offset(cap.x, cap.y + .12 * r),
        r * .68,
        fill..color = shade,
      );
      canvas.drawCircle(Offset(cap.x, cap.y), r * .64, fill..color = mid);
      canvas.drawCircle(
        Offset(cap.x - .2 * r * mirror, cap.y - .22 * r),
        r * .3,
        fill..color = highlight,
      );
    }
  }

  void _paintBuildings(
    Canvas canvas,
    CameraFrame frame,
    _MapPalette palette,
    Paint fill,
    Paint stroke,
    TutorialProps view,
  ) {
    // 먼 건물부터 그린다
    final ordered =
        <
          ({
            TutorialBuilding building,
            double depth,
            double screenX,
            double dim,
          })
        >[];
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
      ordered.add((
        building: building,
        // 같은 자리의 위층이 아래층 뒤에 그려지도록 조금 앞으로 당긴다
        depth: center.depth - building.base * .01,
        screenX: center.x,
        dim: tutorialObjectDim(view, sumX / count, sumY / count),
      ));
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
          final a = frame.project(points[i], points[i + 1], item.building.base);
          final b = frame.project(
            points[i + 2],
            points[i + 3],
            item.building.base,
          );
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
            fill
              ..color = _dimmed(
                isWide ? palette.wallA : palette.wallB,
                item.dim,
              ),
          );
          // 층 줄은 앞쪽 두 벽에만 그린다. 뒤쪽 벽은 어차피 가려진다
          if (item.building.hasFloors && i >= 4) {
            stroke
              ..color = _dimmed(palette.line, item.dim)
              ..strokeWidth = .7;
            final top = item.building.height;
            for (var z = item.building.base + 8; z < top - 3; z += 8) {
              final from = frame.project(points[i], points[i + 1], z);
              final to = frame.project(points[i + 2], points[i + 3], z);
              canvas.drawLine(
                Offset(from.x, from.y),
                Offset(to.x, to.y),
                stroke,
              );
            }
          }
        }
      }
      final roof = _polygon(frame, points, item.building.height);
      canvas.drawPath(
        roof,
        fill..color = _dimmed(palette.roofs[item.building.roofTone], item.dim),
      );
      canvas.drawPath(
        roof,
        stroke
          ..color = _dimmed(palette.line, item.dim)
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
