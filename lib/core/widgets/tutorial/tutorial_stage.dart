import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'tutorial_camera.dart';
import 'tutorial_timeline.dart';

/// 무대 위 인물·표시 하나.
class TutorialActor extends TutorialProps {
  TutorialActor({
    required double x,
    required double y,
    required this.width,
    required this.height,
    this.centered = false,
  }) : super({'x': x, 'y': y, 'op': 0, 'sc': 1});

  final double width;
  final double height;

  /// true면 좌표가 그림 가운데, false면 발밑이다.
  final bool centered;
}

enum TutorialCallout { touch, arrest }

/// 튜토리얼 한 판의 상태 전부. 장면 스크립트가 값을 옮기고, 화면은 그리기만 한다.
///
/// 매 프레임 수십 개 값이 바뀌므로 복사 대신 가변 객체로 둔다.
class TutorialStage extends ChangeNotifier {
  static const double jailX = 60;
  static const double jailY = -40;
  static const double jailRadius = 46;
  static const double playRadius = 250;

  static const double _frameX = 196;
  static const double _frameY = 243;
  static const double _frameReach = 125;
  static const double _holdSeconds = .35;
  static const List<double> _blinkCycle = [.6, .2, 0, 0, 0, .4, .8, 1, 1, 1];
  static const int _blinkStepMs = 140;
  static const int _blinkSteps = 30;

  /// 온보딩 "달린 기록" 장면의 경로.
  static const List<List<double>> route = [
    [85, 30],
    [125, -60],
    [35, -135],
    [-70, -105],
    [-135, 10],
    [-45, 95],
    [60, 120],
  ];

  final TutorialTimeline timeline = TutorialTimeline();

  final TutorialCamera cam = TutorialCamera(const {
    'tilt': 28,
    'az': -60,
    'scale': .42,
    'cx': 0,
    'cy': 0,
    'persp': 1100,
    'oy': .5,
  });

  final TutorialProps view = TutorialProps(const {
    'jail': 0,
    'play': playRadius,
    'px': 0,
    'py': 0,
    'white': 0,
    'dim': 1,
    'tr': 0,
    'trA': 0,
    'pul': 0,
    'nr': 0,
    'nx': 0,
    'ny': 0,
    'na': 0,
    'wa': 0,
    'ra': 0,
    'rt': 0,
    'copy': 1,
  });

  final TutorialProps run = TutorialProps(const {'v': 0, 't': 0, 'sh': 0});
  final TutorialProps escape = TutorialProps(const {'p': 0});
  final TutorialProps art = TutorialProps(const {'op': 0, 'sc': 1});

  /// 다크 전환 원. r은 다크가 커질 때, h는 라이트가 다크를 뚫고 커질 때 쓴다.
  final TutorialProps theme = TutorialProps(const {
    'r': 0,
    'x': 196,
    'y': 350,
    'h': 0,
  });

  final TutorialProps q = TutorialProps(const {
    'inv': 0,
    'a1': 0,
    'a2': 0,
    'a3': 0,
    'tm': 0,
    'zb': 0,
    'sec': 1500,
    'qy': 395,
    'fab': 0,
    'bar': 0,
    'item': 0,
    'flash': 0,
    'rip': 0,
    'rx': 0,
    'ry': 0,
    'tg': 0,
    'fr': 0,
    'tilt': 0,
    'hand': 0,
    'hs': 1,
    'hy': 0,
    'fb': 0,
  });

  final TutorialActor cop = TutorialActor(
    x: -130,
    y: -80,
    width: 92,
    height: 76,
  );
  final TutorialActor rob = TutorialActor(x: 30, y: 10, width: 92, height: 76);
  final TutorialActor jailed = TutorialActor(
    x: jailX,
    y: jailY,
    width: 130,
    height: 108,
  );
  final TutorialActor outed = TutorialActor(x: 0, y: 0, width: 110, height: 91);
  final TutorialActor caught = TutorialActor(
    x: 0,
    y: 0,
    width: 104,
    height: 60,
  );
  final TutorialActor ally = TutorialActor(x: 0, y: 0, width: 92, height: 76);
  final TutorialActor dot = TutorialActor(
    x: -60,
    y: -30,
    width: 18,
    height: 18,
    centered: true,
  );
  final TutorialActor paw = TutorialActor(
    x: 115,
    y: 60,
    width: 54,
    height: 38,
    centered: true,
  );

  bool dark = false;
  bool escaping = false;
  bool scanned = false;
  TutorialCallout? callout;

  /// 스캔 장면의 QR 위치. 들고 있는 폰을 움직이면 반대로 움직인다.
  double qrX = 305;
  double qrY = 395;
  double qrGoalX = 305;
  double get qrGoalY => q['qy'];
  set qrGoalY(double value) => q['qy'] = value;
  double holdSeconds = 0;
  bool scanning = false;
  bool targetCaught = false;
  double _qrDragX = 0;
  double _qrDragY = 0;
  double _wobble = 0;

  int clockMs = 0;
  int? _blinkStartMs;

  double get holdProgress => holdSeconds / _holdSeconds;

  /// 움직일 것이 남았는지. 연출이 끝난 뒤에는 지도를 다시 그리지 않아 발열을 줄인다.
  bool get needsFrame =>
      timeline.isPlaying || scanning || _blinkStartMs != null;

  /// 달리는 동안의 카메라 흔들림을 포함한 이번 프레임의 카메라.
  CameraFrame cameraFrame() => CameraFrame(
    cam,
    azOffset: math.sin(run['t'] * 9) * 1.2 * run['v'],
    oyOffset:
        math.sin(run['t'] * 18) * .012 * run['v'] +
        math.sin(run['t'] * 60) * .02 * run['sh'],
  );

  /// 경로 위 t(0~1) 지점과, 그 앞 꺾임점 번호.
  static ({double x, double y, int index}) routeAt(double t) {
    final f = math.min(t, .9999) * (route.length - 1);
    final i = f.floor();
    final r = f - i;
    final a = route[i];
    final b = route[i + 1];
    return (x: a[0] + (b[0] - a[0]) * r, y: a[1] + (b[1] - a[1]) * r, index: i);
  }

  void update(int elapsedMs) {
    final step = math.min(elapsedMs, TutorialTimeline.maxStepMs);
    clockMs += step;
    run['t'] = run['t'] + step / 1000 * math.max(run['v'], 0);
    timeline.tick(elapsedMs);
    if (escaping) _placeEscapingRobber();
    if (view['ra'] > 0 && view['rt'] > 0) {
      final at = routeAt(view['rt']);
      dot['x'] = at.x;
      dot['y'] = at.y;
    }
    _advanceBlink();
    _advanceScan(step / 1000);
    notifyListeners();
  }

  /// 장면이 바뀔 때 앞 장면의 표시를 정리한다.
  ///
  /// 스캔을 건너뛰어도 QR과 힌트가 다음 장면에 남지 않아야 한다.
  void beginScene({bool keepQr = false}) {
    if (escaping) {
      escape['p'] = 1;
      _placeEscapingRobber();
      escaping = false;
    }
    scanning = false;
    final cleared = <String, double>{
      'inv': 0,
      'a1': 0,
      'a2': 0,
      'a3': 0,
      'fab': 0,
      'item': 0,
      'flash': 0,
      'fr': 0,
      'tilt': 0,
    };
    if (!keepQr) {
      cleared['tg'] = 0;
      cleared['bar'] = 0;
    }
    timeline.to(q, cleared, 150);
  }

  void startBlink() => _blinkStartMs = clockMs;

  void stopBlink() => _blinkStartMs = null;

  void _advanceBlink() {
    final start = _blinkStartMs;
    if (start == null) return;
    final index = (clockMs - start) ~/ _blinkStepMs;
    if (index >= _blinkSteps) {
      paw['op'] = 1;
      _blinkStartMs = null;
      return;
    }
    paw['op'] = _blinkCycle[index % _blinkCycle.length];
  }

  void _placeEscapingRobber() {
    // 지도가 tutorialHeading만큼 돌아 있어, 화면에서 완만한 곡선이 되도록 잡은 값이다
    final t = escape['p'];
    final u = 1 - t;
    rob['x'] = jailX + 2 * u * t * 52 + t * t * 53;
    rob['y'] = jailY + 2 * u * t * 36 + t * t * 87;
  }

  /// 폰을 (dx, dy)만큼 움직였다. 끌기와 자이로 입력이 모두 여기로 온다.
  void moveQr(double dx, double dy) {
    if (!scanning) return;
    _qrDragX += dx;
    _qrDragY += dy;
    qrGoalX = (305 - _qrDragX * 1.2).clamp(70.0, 313.0);
    qrGoalY = (395 - _qrDragY * 1.2).clamp(70.0, 400.0);
  }

  void startScanning() {
    _qrDragX = 0;
    _qrDragY = 0;
    scanning = true;
  }

  void _advanceScan(double seconds) {
    _wobble += seconds;
    final wobbleX = scanning ? math.sin(_wobble * 1.3) * 7 : 0.0;
    final wobbleY = scanning ? math.cos(_wobble * 1.7) * 5 : 0.0;
    final follow = 1 - math.pow(.8, seconds * 60).toDouble();
    qrX += (qrGoalX + wobbleX - qrX) * follow;
    qrY += (qrGoalY + wobbleY - qrY) * follow;
    if (!scanning) return;

    cam['az'] = tutorialHeading + (qrX - 305) * .05;
    cam['tilt'] = 76 + (qrY - 395) * .015;

    final inFrame =
        (qrX - _frameX).abs() <= _frameReach &&
        (qrY - _frameY).abs() <= _frameReach;
    if (inFrame) {
      final pull = 1 - math.pow(.92, seconds * 60).toDouble();
      qrX += (_frameX - qrX) * pull;
      qrY += (_frameY - qrY) * pull;
    }
    holdSeconds = inFrame
        ? holdSeconds + seconds
        : math.max(0, holdSeconds - seconds * .5);
    if (holdSeconds >= _holdSeconds) {
      holdSeconds = _holdSeconds;
      _arrest();
    }
  }

  void _arrest() {
    scanning = false;
    scanned = true;
    qrGoalX = _frameX;
    qrGoalY = _frameY;
    q['tilt'] = 0;
    timeline.to(cam, {'az': tutorialHeading, 'tilt': 76}, 250);
    timeline.after(130, () => timeline.to(q, {'flash': 1}, 100));
    timeline.after(240, () {
      timeline.to(q, {'flash': 0}, 200);
      targetCaught = true;
      say(TutorialCallout.arrest, 800);
    });
    timeline.after(1100, () {
      timeline.to(q, {'tg': 0, 'fr': 0}, 300);
      caught['x'] = rob['x'];
      caught['y'] = rob['y'];
      caught['sc'] = 1;
      timeline.to(caught, {'op': 1}, 250);
    });
  }

  void say(TutorialCallout text, int ms) {
    callout = text;
    timeline.to(q, {'fb': 1}, 140);
    timeline.after(ms, () => timeline.to(q, {'fb': 0}, 200));
  }

  /// 역할에 맞춰 화면을 라이트·다크로 바꾼다. (x, y)는 전환 원의 중심이다.
  void setTheme(bool toDark, double x, double y) {
    final wasDark = dark;
    dark = toDark;
    if (wasDark == toDark) return;
    theme['x'] = x;
    theme['y'] = y;
    if (toDark) {
      theme['h'] = 0;
      timeline.to(theme, {'r': 950}, 800);
    } else {
      timeline.to(theme, {'h': 950}, 800);
      timeline.after(800, () {
        theme['r'] = 0;
        theme['h'] = 0;
      });
    }
  }
}
