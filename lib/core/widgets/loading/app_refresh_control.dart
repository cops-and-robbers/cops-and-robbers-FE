import 'dart:math' as math;

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../services/vibration_service.dart';

/// 사이렌 한 사이클: 빗살이 하나씩 생기고, 잠시 유지한 뒤 접힌다.
const Duration _sirenCycle = Duration(milliseconds: 1000);

/// 파동 하나가 화면 끝까지 퍼지는 시간.
const Duration _waveDuration = Duration(milliseconds: 800);

/// 당겨서 새로고침 (pull-to-refresh)
///
/// 당긴 만큼 사이렌 윗부분 빗살이 하나씩 생기고 색이 회색에서 파랑으로 넘어간다.
/// 임계점을 넘기면 진동과 함께 1초 주기로 반복한다. 손을 떼면 사이렌 자리에서
/// 파랑 파동이 화면 끝까지 한 번 퍼지고, 불러오는 동안에는 사이렌만 반복한다.
/// 진동은 임계점에 닿을 때와 파동이 절반 퍼졌을 때 울린다.
/// 동작 줄이기 설정이면 멈춘 사이렌만 보인다.
///
/// 패키지의 상태 전이가 곧 사용자 동작이라(`armed → settling`이 손 뗌) 부수
/// 효과는 전부 [CustomRefreshIndicator.onStateChanged]에 묶는다.
///
/// 사용:
/// ```dart
/// AppRefreshControl(
///   onRefresh: _refresh,
///   child: ListView.separated(...),
/// )
/// ```
class AppRefreshControl extends StatefulWidget {
  const AppRefreshControl({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  /// 새로고침 동작. 이 Future가 끝날 때까지 사이렌이 반복한다.
  final Future<void> Function() onRefresh;

  /// 감쌀 스크롤 위젯.
  final Widget child;

  @visibleForTesting
  static const Key sirenKey = ValueKey('app_refresh_control_siren');

  @visibleForTesting
  static const Key waveKey = ValueKey('app_refresh_control_wave');

  @override
  State<AppRefreshControl> createState() => _AppRefreshControlState();
}

class _AppRefreshControlState extends State<AppRefreshControl>
    with SingleTickerProviderStateMixin {
  /// 표시 최소 유지 시간
  ///
  /// 캐시가 물려 응답이 즉시 오면 표시가 번쩍이고 사라져, 오히려 아무 일도
  /// 안 일어난 것처럼 보인다. 전체 화면 로딩이 같은 이유로 최소 시간을 두고
  /// 있다 (`AppLoading.minVisibleDuration`). 여긴 훨씬 가벼운 표시라 그보다
  /// 짧게 잡는다.
  static const Duration _minimumSpin = Duration(milliseconds: 200);

  late final AnimationController _cycle;

  /// 바운스로 내려가 있는 거리. 클램핑 목록에서는 항상 0이다.
  final ValueNotifier<double> _bounce = ValueNotifier(0);

  double get _bandHeight => 60.h;
  double get _sirenWidth => 32.r;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    _cycle = AnimationController(vsync: this, duration: _sirenCycle);
  }

  /// 새로고침이 아무리 빨리 끝나도 [_minimumSpin]만큼은 표시가 남게 한다.
  ///
  /// 지연을 먼저 걸어 두고 `finally`에서 기다리므로, 실제 조회가 그보다 오래
  /// 걸리면 아무것도 늘어나지 않는다 — 느린 요청에 200ms를 더 얹지 않는다.
  /// 실패해도 같은 시간을 유지한다(에러 스낵바가 뜰 자리를 만들어 준다).
  Future<void> _refreshAtLeastBriefly() async {
    final minimum = Future<void>.delayed(_minimumSpin);
    try {
      await widget.onRefresh();
    } finally {
      await minimum;
    }
  }

  void _handleStateChanged(IndicatorStateChange change) {
    if (change.didChange(to: IndicatorState.armed)) {
      VibrationService.instance().buttonTap();
      _startCycle();
    } else if (change.didChange(
          from: IndicatorState.armed,
          to: IndicatorState.dragging,
        ) ||
        change.didChange(
          from: IndicatorState.armed,
          to: IndicatorState.canceling,
        )) {
      // 되돌린 경로가 플랫폼마다 다르다: 바운스는 dragging으로 내려오고,
      // 클램핑은 목록이 바로 스크롤돼 canceling으로 간다.
      _cycle.value = 0;
    } else if (change.didChange(
      from: IndicatorState.armed,
      to: IndicatorState.settling,
    )) {
      // 다 켜진 지점으로 맞춰야 파란 사이렌에서 파동이 나가는 것처럼 보인다.
      _startCycle();
      _spawnWave();
    } else if (change.didChange(to: IndicatorState.idle)) {
      _cycle.value = 0;
    }
  }

  /// 다 켜진 지점부터 돌린다. 당기기가 끝난 모습과 이어져 첫 사이클이 튀지 않는다.
  void _startCycle() {
    if (_reduceMotion) return;
    _cycle
      ..value = RefreshSirenPainter.raysDoneAt
      ..repeat();
  }

  /// 파동 하나를 앱 맨 위 층에 띄운다.
  ///
  /// 표시가 먼저 접히거나 위젯이 사라져도 끊기지 않도록 이 위젯 수명과 분리한다.
  void _spawnWave() {
    if (_reduceMotion) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final overlay = Overlay.of(context, rootOverlay: true);
      final layer = overlay.context.findRenderObject()! as RenderBox;
      final box = context.findRenderObject()! as RenderBox;
      final center = box.localToGlobal(
        Offset(box.size.width / 2, _bandHeight / 2),
        ancestor: layer,
      );
      late final OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => _WaveBurst(
          key: AppRefreshControl.waveKey,
          center: center,
          startRadius: _sirenWidth / 2,
          onHalfway: VibrationService.instance().buttonTap,
          onDone: () {
            entry.remove();
            entry.dispose();
          },
        ),
      );
      overlay.insert(entry);
    });
  }

  @override
  void dispose() {
    // 오버레이의 파동은 건드리지 않는다 — 여기서 지우면 퍼지다가 중간에 끊긴다.
    _cycle.dispose();
    _bounce.dispose();
    super.dispose();
  }

  bool _trackBounce(ScrollNotification notification) {
    if (notification.depth == 0) {
      final metrics = notification.metrics;
      _bounce.value = math.max(0, metrics.minScrollExtent - metrics.pixels);
    }
    return false;
  }

  /// 목록을 내릴 거리.
  ///
  /// 클램핑은 목록이 제자리라 당긴 만큼 직접 내린다. 바운스는 이미 내려가 있어
  /// 드래그 중에는 밀지 않는다. 손을 뗀 뒤에는 되감기는 바운스가 띠 높이 밑으로
  /// 내려간 만큼만 채운다 — 바로 띠 높이를 더하면 손 뗀 프레임에 목록이 튄다.
  double _contentPush(IndicatorController controller) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return _bandHeight * controller.value.clamp(0.0, 1.0);
    }
    final released =
        controller.isSettling ||
        controller.isLoading ||
        controller.isFinalizing;
    if (!released) return 0;
    return math.max(0, _bandHeight * controller.value - _bounce.value);
  }

  Widget _buildSiren(IndicatorController controller) {
    final pull = controller.value.clamp(0.0, 1.0);
    return IgnorePointer(
      child: Center(
        child: Opacity(
          opacity: (controller.value * _bandHeight / 32.h).clamp(0.0, 1.0),
          child: AnimatedBuilder(
            animation: _cycle,
            builder: (context, _) => CustomPaint(
              key: AppRefreshControl.sirenKey,
              size: Size(
                _sirenWidth,
                _sirenWidth * RefreshSirenPainter.heightPerWidth,
              ),
              painter: RefreshSirenPainter(
                phase: _cycle.isAnimating
                    ? _cycle.value
                    : pull * RefreshSirenPainter.raysDoneAt,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: _refreshAtLeastBriefly,
      offsetToArmed: 100.h,
      onStateChanged: _handleStateChanged,
      builder: (context, child, controller) => Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _trackBounce,
            child: ValueListenableBuilder<double>(
              valueListenable: _bounce,
              builder: (_, _, list) => Transform.translate(
                offset: Offset(0, _contentPush(controller)),
                child: list,
              ),
              child: child,
            ),
          ),
          if (!controller.isIdle)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _bandHeight,
              child: Semantics(
                label: controller.isLoading
                    ? AppLocalizations.of(context).refreshLoadingLabel
                    : null,
                child: _buildSiren(controller),
              ),
            ),
        ],
      ),
      child: widget.child,
    );
  }
}

/// 파동 앞머리의 반지름. 끝에서는 가장 먼 귀퉁이에 닿아 화면 끝까지 퍼진다.
@visibleForTesting
double waveFrontRadius(
  double progress, {
  required Offset center,
  required Size size,
  required double startRadius,
}) {
  final reach = [
    Offset.zero,
    Offset(size.width, 0),
    Offset(0, size.height),
    Offset(size.width, size.height),
  ].map((corner) => (corner - center).distance).reduce(math.max);
  return startRadius +
      (reach - startRadius) * Curves.easeOutCubic.transform(progress);
}

/// 파동 하나: 사이렌 자리에서 화면 끝까지 퍼진 뒤 [onDone]으로 스스로 층을 걷는다.
class _WaveBurst extends StatefulWidget {
  const _WaveBurst({
    super.key,
    required this.center,
    required this.startRadius,
    required this.onHalfway,
    required this.onDone,
  });

  final Offset center;
  final double startRadius;
  final VoidCallback onDone;

  /// 파동이 절반(400ms) 퍼졌을 때 한 번. 앞머리가 화면 아래쪽에 닿는 때와 맞는다.
  final VoidCallback onHalfway;

  @override
  State<_WaveBurst> createState() => _WaveBurstState();
}

class _WaveBurstState extends State<_WaveBurst>
    with SingleTickerProviderStateMixin {
  // 가장 진해지는 시점(진행률), 가장 진할 때의 불투명도
  static const double _peakAt = 0.12;
  static const double _peakOpacity = 0.3;

  bool _passedHalfway = false;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _waveDuration)
        ..addListener(() {
          if (_passedHalfway || _controller.value < 0.5) return;
          _passedHalfway = true;
          widget.onHalfway();
        })
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onDone();
        })
        ..forward();

  /// 금방 진해진 뒤 앞머리가 끝에 닿을 때까지 버티다 마지막에 빠르게 옅어진다.
  /// 내내 고르게 옅어지면 화면 끝에서는 보이지 않는다.
  double get _strength {
    final progress = _controller.value;
    return progress < _peakAt
        ? progress / _peakAt
        : 1 - math.pow((progress - _peakAt) / (1 - _peakAt), 3).toDouble();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          // 색에 알파를 섞지 않고 Opacity로 옅게 한다 (LoadingVisual과 같은 방식).
          builder: (context, _) => Opacity(
            opacity: _strength * _peakOpacity,
            child: CustomPaint(
              painter: _WavePainter(
                progress: _controller.value,
                center: widget.center,
                startRadius: widget.startRadius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 원에서 바깥으로 번지는 파동. 앞머리만 밝고 안쪽은 비워 내용을 덜 가린다.
class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.progress,
    required this.center,
    required this.startRadius,
  });

  final double progress;
  final Offset center;
  final double startRadius;

  // 가장 밝은 앞머리 고리의 위치(그라데이션 비율)
  static const double _frontStop = 0.88;

  @override
  void paint(Canvas canvas, Size size) {
    final front = waveFrontRadius(
      progress,
      center: center,
      size: size,
      startRadius: startRadius,
    );
    // 끝점은 같은 색의 알파 0이다. AppColors.transparent(검정)로 가면 중간에 회색
    // 띠가 생긴다 (ZoneExitVignette와 같은 이유).
    final fade = AppColors.blueVer2Basic.withAlpha(0);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader =
            RadialGradient(
              colors: [fade, fade, AppColors.blueVer2Basic, fade],
              stops: const [0, 0.55, _frontStop, 1],
            ).createShader(
              // 앞머리 고리가 끝에 닿도록 바깥 반지름을 그만큼 더 키운다.
              Rect.fromCircle(center: center, radius: front / _frontStop),
            ),
    );
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.center != center ||
      oldDelegate.startRadius != startRadius;
}

/// 사이렌 빗살 하나. 값은 [AppIcons.siren] SVG의 rect와 transform 그대로다.
class _SirenRay {
  const _SirenRay(this.matrix, this.width, this.height, this.radius);

  final List<double> matrix;
  final double width;
  final double height;
  final double radius;
}

/// 사이렌: [AppIcons.siren] SVG를 조각별로 그린다.
///
/// 빗살을 하나씩 움직여야 해서 SVG를 통째로 쓸 수 없다. 패스를 직접 그리면 새
/// 에셋이나 의존성이 없고, 비동기 로딩이 없어 당기는 첫 프레임부터 바로 보인다.
@visibleForTesting
class RefreshSirenPainter extends CustomPainter {
  const RefreshSirenPainter({required this.phase});

  /// 사이클 진행 (0~1). 0~[raysDoneAt]은 빗살이 생기고, [_holdUntil]까지 유지한 뒤 접힌다.
  final double phase;

  /// 빗살이 다 생기고 색이 완전히 파랑이 되는 지점.
  static const double raysDoneAt = 0.6;

  /// 세로 ÷ 가로 (SVG viewBox 14×17).
  static const double heightPerWidth = 17 / 14;

  static const double _holdUntil = 0.85;
  static const double _viewBoxWidth = 14;
  static const int _rayCount = 3;

  /// 빗살이 하나씩 다 생길 때마다 한 칸씩 파랑으로 넘어간다.
  static const List<Color> _colors = [
    AppColors.black300,
    AppColors.blue500,
    AppColors.blueVer2Rich,
    AppColors.blueVer2Basic,
  ];

  /// 왼쪽, 가운데, 오른쪽 순서로 생긴다.
  static const List<_SirenRay> _rays = [
    _SirenRay(
      [-0.836065, 0.548631, 0.54355, 0.839377, 1.42627, 1.45703],
      1.70619,
      2.56615,
      0.853097,
    ),
    _SirenRay([1, 0, 0, 1, 6, 0], 1.70281, 2.5712, 0.851404),
    _SirenRay(
      [0.836065, 0.548631, -0.54355, 0.839377, 12.5735, 1.45703],
      1.70619,
      2.56615,
      0.853097,
    ),
  ];

  static final List<Path> _body = [
    // 돔
    Path()
      ..moveTo(7, 4.54492)
      ..cubicTo(10.2183, 4.54517, 12.832, 7.12497, 12.832, 10.3008)
      ..lineTo(12.832, 13.5439)
      ..lineTo(9.78516, 13.5439)
      ..lineTo(9.78516, 10.7148)
      ..cubicTo(9.78516, 9.19768, 8.53589, 7.9668, 7, 7.9668)
      ..cubicTo(5.46268, 7.96699, 4.21582, 9.19937, 4.21582, 10.7148)
      ..lineTo(4.21582, 13.5439)
      ..lineTo(1.16699, 13.5439)
      ..lineTo(1.16699, 10.3008)
      ..cubicTo(1.16699, 7.12481, 3.7799, 4.54492, 7, 4.54492)
      ..close(),
    // 돔 안 작은 원
    Path()..addOval(const Rect.fromLTRB(5.40503, 9.2168, 6.82768, 10.6206)),
    // 받침 아랫단
    Path()
      ..moveTo(0, 16.352)
      ..cubicTo(0, 16.7093, 0.293461, 16.9989, 0.655502, 16.9989)
      ..lineTo(13.3445, 16.9989)
      ..cubicTo(13.7065, 16.9989, 14, 16.7093, 14, 16.352)
      ..lineTo(14, 15.6895)
      ..lineTo(0, 15.6895)
      ..close(),
    // 받침 윗단
    Path()
      ..moveTo(14, 13.7184)
      ..cubicTo(14, 13.3853, 13.7065, 13.1152, 13.3445, 13.1152)
      ..lineTo(0.655502, 13.1152)
      ..cubicTo(0.293461, 13.1152, 0, 13.3853, 0, 13.7184)
      ..lineTo(0, 14.4008)
      ..lineTo(14, 14.4008)
      ..close(),
  ];

  Color get _color => phase >= raysDoneAt
      ? _colors.last
      : _colors[(phase / (raysDoneAt / _rayCount)).floor()];

  /// [index]번째 빗살의 크기 (0~1). 빗살 하나에 사이클의 0.2씩 쓴다.
  double _rayScale(int index) {
    if (phase >= _holdUntil) {
      return 1 - (phase - _holdUntil) / (1 - _holdUntil);
    }
    final span = raysDoneAt / _rayCount;
    final grown = ((phase - index * span) / span).clamp(0.0, 1.0);
    return Curves.easeOut.transform(grown);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _color;
    canvas.save();
    canvas.scale(size.width / _viewBoxWidth);
    for (final part in _body) {
      canvas.drawPath(part, paint);
    }
    for (var i = 0; i < _rays.length; i++) {
      final scale = _rayScale(i);
      if (scale <= 0) continue;
      final ray = _rays[i];
      final m = ray.matrix;
      canvas.save();
      canvas.transform(
        Float64List.fromList([
          m[0], m[1], 0, 0, //
          m[2], m[3], 0, 0, //
          0, 0, 1, 0, //
          m[4], m[5], 0, 1, //
        ]),
      );
      // 돔 쪽 끝을 축으로 자라나게 한다.
      canvas.translate(ray.width / 2, ray.height);
      canvas.scale(scale);
      canvas.translate(-ray.width / 2, -ray.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, ray.width, ray.height),
          Radius.circular(ray.radius),
        ),
        paint,
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(RefreshSirenPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
