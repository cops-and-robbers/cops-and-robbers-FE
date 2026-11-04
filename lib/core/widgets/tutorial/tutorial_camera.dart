import 'dart:math' as math;

import 'tutorial_timeline.dart';

/// 지도 무대의 기준 크기. 좌표는 모두 이 크기로 잡고 화면에 맞춰 늘린다.
const double tutorialStageWidth = 393;
const double tutorialStageHeight = 486;

/// 모든 시점이 같은 방향을 본다. 장면이 바뀔 때 화면이 돌면 어지럽다.
const double tutorialHeading = -24;

class ProjectedPoint {
  const ProjectedPoint(this.x, this.y, this.depth, this.k);

  final double x;
  final double y;
  final double depth;

  /// 원근 배율. 가까울수록 크다.
  final double k;
}

class TutorialCamera extends TutorialProps {
  TutorialCamera(super.values);

  static const Map<String, double> wide3dValues = {
    'tilt': 58,
    'az': tutorialHeading,
    'scale': .72,
    'cx': 0,
    'cy': 0,
    'persp': 1100,
    'oy': .5,
  };
  static const Map<String, double> flatValues = {
    'tilt': 0,
    'az': tutorialHeading,
    'scale': .72,
    'cx': 0,
    'cy': 0,
    'persp': 1100,
    'oy': .5,
  };

  factory TutorialCamera.wide3d() => TutorialCamera(wide3dValues);
  factory TutorialCamera.flat() => TutorialCamera(flatValues);
}

/// 한 프레임 동안 쓰는 카메라 값. 점마다 삼각함수를 다시 계산하지 않게 한다.
class CameraFrame {
  CameraFrame(TutorialCamera camera, {double azOffset = 0, double oyOffset = 0})
    : scale = camera['scale'],
      cx = camera['cx'],
      cy = camera['cy'],
      persp = camera['persp'],
      tilt = camera['tilt'],
      oy = camera['oy'] + oyOffset,
      _sinTilt = math.sin(camera['tilt'] * math.pi / 180),
      _cosTilt = math.cos(camera['tilt'] * math.pi / 180),
      _sinAz = math.sin((camera['az'] + azOffset) * math.pi / 180),
      _cosAz = math.cos((camera['az'] + azOffset) * math.pi / 180);

  final double scale;
  final double cx;
  final double cy;
  final double persp;
  final double tilt;
  final double oy;
  final double _sinTilt;
  final double _cosTilt;
  final double _sinAz;
  final double _cosAz;

  ProjectedPoint project(double x, double y, [double z = 0]) {
    final dx = x - cx;
    final dy = y - cy;
    final rx = dx * _cosAz - dy * _sinAz;
    final ry = dx * _sinAz + dy * _cosAz;
    final depth = ry * _sinTilt + persp;
    final k = persp / math.max(depth, 60);
    return ProjectedPoint(
      tutorialStageWidth / 2 + rx * scale * k,
      tutorialStageHeight * oy - (ry * _cosTilt + z * _sinTilt) * scale * k,
      depth,
      k,
    );
  }

  /// 지평선 높이. 기울어진 시점에서 하늘을 칠할 때 쓴다.
  double get horizonY =>
      tutorialStageHeight * oy - scale * persp / math.tan(tilt * math.pi / 180);
}

ProjectedPoint projectPoint(
  TutorialCamera camera,
  double x,
  double y, [
  double z = 0,
]) => CameraFrame(camera).project(x, y, z);
