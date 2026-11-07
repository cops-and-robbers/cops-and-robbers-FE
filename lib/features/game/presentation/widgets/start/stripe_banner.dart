import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/widgets/dialogs/dialog_animation.dart';

/// 띠 안 내용. [enter]·[exit]는 0→1 진행 — 캐릭터를 내용과 따로 움직일 때 쓴다.
typedef StripeBannerContent =
    Widget Function(
      BuildContext context,
      double scale,
      Animation<double> enter,
      Animation<double> exit,
    );

/// 역할 배너(①)의 사선 줄무늬 띠. 뒤를 어둡게 덮고, 탭해도 넘어가지 않고 끝까지 보여 준다.
///
/// 사선으로 잘린 줄 7개가 왼쪽에서 빨려 나와 펼쳐지고, 내용이 밀려 들어온다.
/// 머문 뒤 내용이 먼저 빠지고 줄들이 오른쪽 끝으로 빨려 나간다(들어올 땐 감속,
/// 나갈 땐 가속, 퇴장이 진입보다 짧게). 좌표는 300 폭 목업 기준.
class StripeBanner extends StatefulWidget {
  const StripeBanner({
    super.key,
    required this.color,
    required this.bandHeight,
    required this.hold,
    required this.onDone,
    required this.content,
    required this.angleDegrees,
    required this.bandOffsetY,
    this.onRevealNext,
    this.backdropColor,
    this.edgeColor,
    this.overlay,
    this.decor,
  });

  final Color color;

  /// 목업 기준 띠 높이. 폭은 390(화면보다 넓게).
  final double bandHeight;

  /// 다 들어온 뒤 머무는 시간
  final Duration hold;
  final VoidCallback onDone;
  final StripeBannerContent content;

  /// 나가기 시작 [revealNextAfter] 뒤 한 번 — 첫 줄이 빠지기 시작할 때 다음 장면을 띠 자리로
  /// 비추기 시작한다([BandTransition]이 이어서 펼친다)
  final VoidCallback? onRevealNext;

  /// 띠 기울기(도)
  final double angleDegrees;

  /// 화면 가운데에서 띠를 옮기는 거리(300 폭 목업 기준, 위가 음수)
  final double bandOffsetY;

  /// 뒤를 덮는 색. 없으면 지도가 비치는 다이얼로그 배리어.
  final Color? backdropColor;

  /// 띠 아래로 살짝 비치는 두께 색. 띠와 같은 줄무늬로 함께 움직인다. 없으면 그리지 않는다.
  final Color? edgeColor;

  /// 띠와 함께 나타나고 사라지지만 기울지 않는 층 — 화면 전체 좌표로 그린다
  final StripeBannerContent? overlay;

  /// 띠 바깥에 스스로 움직이는 장식 층(화면 전체 좌표). 내용과 달리 페이드·밀림을 입히지 않는다.
  final StripeBannerContent? decor;

  /// 마지막 줄(0.30초 시작 + 0.38초)과 내용(0.56초 시작 + 0.32초)이 끝나는 시간
  static const enterDuration = Duration(milliseconds: 900);

  /// 내용 0.2초, 줄은 0.12초 뒤부터 0.04초 시차로 0.34초씩
  static const exitDuration = Duration(milliseconds: 700);
  static const revealNextAfter = Duration(milliseconds: 120);
  static const _reducedEnter = Duration(milliseconds: 220);
  static const _reducedExit = Duration(milliseconds: 200);

  @override
  State<StripeBanner> createState() => _StripeBannerState();
}

typedef _Pose = ({double x, double sx, double sy});

class _StripeBannerState extends State<StripeBanner>
    with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(vsync: this);
  late final AnimationController _exit = AnimationController(vsync: this);
  Timer? _holdTimer;
  Timer? _revealTimer;
  bool _revealed = false;
  bool _started = false;
  bool _leaving = false;
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduce = MediaQuery.disableAnimationsOf(context);
    _enter.duration = _reduce
        ? StripeBanner._reducedEnter
        : StripeBanner.enterDuration;
    _exit.duration = _reduce
        ? StripeBanner._reducedExit
        : StripeBanner.exitDuration;
    _enter.forward().whenComplete(() {
      if (!mounted) return;
      _holdTimer = Timer(widget.hold, _leave);
    });
  }

  void _leave() {
    if (_leaving || !mounted) return;
    _leaving = true;
    _holdTimer?.cancel();
    _revealTimer = Timer(StripeBanner.revealNextAfter, _revealNext);
    _exit.forward().whenComplete(() {
      if (!mounted) return;
      _revealNext();
      widget.onDone();
    });
  }

  void _revealNext() {
    if (_revealed) return;
    _revealed = true;
    _revealTimer?.cancel();
    widget.onRevealNext?.call();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _revealTimer?.cancel();
    _enter.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final s = constraints.maxWidth / 300;
        final bandWidth = 390 * s;
        final both = Listenable.merge([_enter, _exit]);
        Widget banner = Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: both,
                builder: (context, child) {
                  final inT = const Interval(
                    0,
                    500 / 900,
                  ).transform(_enter.value);
                  final outT = const Interval(
                    200 / 700,
                    620 / 700,
                  ).transform(_exit.value);
                  return Opacity(
                    opacity: _reduce ? 1 : inT * (1 - outT),
                    child: child,
                  );
                },
                child: ColoredBox(
                  color: widget.backdropColor ?? DialogAnimation.barrierColor,
                ),
              ),
            ),
            Center(
              child: Transform.translate(
                offset: Offset(0, widget.bandOffsetY * s),
                child: OverflowBox(
                  maxWidth: bandWidth,
                  child: Transform.rotate(
                    angle: widget.angleDegrees * math.pi / 180,
                    child: SizedBox(
                      width: bandWidth,
                      height: widget.bandHeight * s,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (widget.edgeColor case final edge?)
                            Transform.translate(
                              offset: Offset(0, 6 * s),
                              child: _stripes(bandWidth, edge),
                            ),
                          _stripes(bandWidth, widget.color),
                          _contentLayer(s, widget.content),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.decor case final decor?)
              Positioned.fill(
                child: decor(
                  context,
                  s,
                  _reduce ? kAlwaysCompleteAnimation : _enter,
                  _reduce ? kAlwaysDismissedAnimation : _exit,
                ),
              ),
            if (widget.overlay case final overlay?)
              Positioned.fill(child: _contentLayer(s, overlay)),
          ],
        );
        if (_reduce) {
          banner = AnimatedBuilder(
            animation: both,
            builder: (context, child) => Opacity(
              opacity: (_enter.value * (1 - _exit.value)).clamp(0.0, 1.0),
              child: child,
            ),
            child: banner,
          );
        }
        // 탭으로 넘기지 않는다. 뒤 지도·장면도 누르지 못하게 막는다
        return AbsorbPointer(child: banner);
      },
    );
  }

  Widget _stripes(double bandWidth, Color color) {
    // stretch가 없으면 자식 없는 ColoredBox가 폭 0으로 잡혀 줄이 안 칠해진다
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([_enter, _exit]),
              builder: (context, child) {
                if (_reduce) return child!;
                final pose = _leaving || _exit.value > 0
                    ? _exitPose(
                        Interval(
                          (120 + i * 40) / 700,
                          (460 + i * 40) / 700,
                        ).transform(_exit.value),
                      )
                    : _enterPose(
                        Interval(
                          i * 50 / 900,
                          (380 + i * 50) / 900,
                        ).transform(_enter.value),
                      );
                return Transform.translate(
                  offset: Offset(pose.x * bandWidth, 0),
                  child: Transform.scale(
                    scaleX: pose.sx,
                    scaleY: pose.sy,
                    child: child,
                  ),
                );
              },
              // 기울어진 줄끼리 맞닿으면 안티앨리어싱 틈이 비친다. 살짝 겹쳐 틈을 없앤다.
              child: Transform.scale(
                scaleY: 1.04,
                child: ClipPath(
                  clipper: const _SlantClipper(),
                  child: ColoredBox(color: color),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _contentLayer(double s, StripeBannerContent content) {
    final enter = _reduce ? kAlwaysCompleteAnimation : _enter;
    final exit = _reduce ? kAlwaysDismissedAnimation : _exit;
    return AnimatedBuilder(
      animation: Listenable.merge([enter, exit]),
      builder: (context, child) {
        final inT = Interval(
          560 / 900,
          1,
          curve: const Cubic(.22, 1, .36, 1),
        ).transform(enter.value);
        final outT = const Interval(
          0,
          200 / 700,
          curve: Cubic(.64, 0, .78, 0),
        ).transform(exit.value);
        return Opacity(
          opacity: (inT * (1 - outT)).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset((-16 * (1 - inT) + 16 * outT) * s, 0),
            child: child,
          ),
        );
      },
      child: content(context, s, enter, exit),
    );
  }

  static _Pose _lerp(_Pose a, _Pose b, double t) => (
    x: a.x + (b.x - a.x) * t,
    sx: a.sx + (b.sx - a.sx) * t,
    sy: a.sy + (b.sy - a.sy) * t,
  );

  /// 시안 STRIPE_IN: 가늘고 길게 빨려 나와 살짝 지나쳤다 제자리
  static _Pose _enterPose(double t) {
    const p0 = (x: -2.05, sx: 1.9, sy: 0.12);
    const p1 = (x: 0.03, sx: 0.94, sy: 1.12);
    const p2 = (x: -0.01, sx: 1.02, sy: 0.97);
    const p3 = (x: 0.0, sx: 1.0, sy: 1.0);
    if (t < 0.7) {
      return _lerp(p0, p1, const Cubic(.12, .9, .3, 1).transform(t / 0.7));
    }
    if (t < 0.86) {
      return _lerp(p1, p2, Curves.easeOut.transform((t - 0.7) / 0.16));
    }
    return _lerp(p2, p3, (t - 0.86) / 0.14);
  }

  /// 시안 STRIPE_OUT: 살짝 물러섰다가 오른쪽 끝으로 가늘게 빨려 나감
  static _Pose _exitPose(double t) {
    const p0 = (x: 0.0, sx: 1.0, sy: 1.0);
    const p1 = (x: -0.03, sx: 1.03, sy: 1.05);
    const p2 = (x: 2.4, sx: 2.2, sy: 0.06);
    const curve = Cubic(.5, 0, .8, .3);
    if (t < 0.15) return _lerp(p0, p1, curve.transform(t / 0.15));
    return _lerp(p1, p2, curve.transform((t - 0.15) / 0.85));
  }
}

/// 양 끝이 사선으로 잘린 줄 (시안 clip-path: 3% 0, 100% 0, 97% 100%, 0 100%)
class _SlantClipper extends CustomClipper<Path> {
  const _SlantClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width * 0.03, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width * 0.97, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
