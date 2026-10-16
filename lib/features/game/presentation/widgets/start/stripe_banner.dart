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

/// 역할 배너(①)·출동 배너(④)가 함께 쓰는 사선 줄무늬 띠.
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
    this.onRevealNext,
    this.dimBehind = false,
    this.tapToSkip = false,
    this.filledStart = false,
  });

  final Color color;

  /// 목업 기준 띠 높이(역할 154, 출동 168). 폭은 390(화면보다 넓게), -4.6° 기울기.
  final double bandHeight;

  /// 다 들어온 뒤 머무는 시간
  final Duration hold;
  final VoidCallback onDone;
  final StripeBannerContent content;

  /// 나가기 시작 [revealNextAfter] 뒤 한 번 — 첫 줄이 빠지기 시작할 때 다음 장면을 띠 자리로
  /// 비추기 시작한다([BandTransition]이 이어서 펼친다)
  final VoidCallback? onRevealNext;

  /// 뒤 지도를 어둡게 덮는다(역할 배너)
  final bool dimBehind;

  /// 탭하면 바로 나간다. false면 터치를 아래로 통과시킨다(출동 배너 — 지도를 바로 써야 한다).
  final bool tapToSkip;

  /// 장면이 띠 모양으로 접힌 자리에서 시작한다 — 줄은 빨려 들지 않고 그 자리에서 나타나고
  /// 내용이 곧바로 들어온다(출동 배너)
  final bool filledStart;

  /// 마지막 줄(0.30초 시작 + 0.38초)과 내용(0.56초 시작 + 0.32초)이 끝나는 시간
  static const enterDuration = Duration(milliseconds: 900);

  /// 내용 0.2초, 줄은 0.12초 뒤부터 0.04초 시차로 0.34초씩
  static const exitDuration = Duration(milliseconds: 700);
  static const revealNextAfter = Duration(milliseconds: 120);
  static const _filledEnter = Duration(milliseconds: 470);
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
  bool _skipRequested = false;
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduce = MediaQuery.disableAnimationsOf(context);
    _enter.duration = _reduce
        ? StripeBanner._reducedEnter
        : widget.filledStart
        ? StripeBanner._filledEnter
        : StripeBanner.enterDuration;
    _exit.duration = _reduce
        ? StripeBanner._reducedExit
        : StripeBanner.exitDuration;
    _enter.forward().whenComplete(() {
      if (!mounted) return;
      if (_skipRequested) {
        _leave();
      } else {
        _holdTimer = Timer(widget.hold, _leave);
      }
    });
  }

  void _leave() {
    if (_leaving || !mounted) return;
    // 들어오는 중 탭은 기억만 해 둔다 — 도중에 끊으면 줄이 한 프레임 튄다. 다 들어온 뒤 머묾 없이 나간다.
    if (_enter.isAnimating) {
      _skipRequested = true;
      return;
    }
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
            if (widget.dimBehind)
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
                  child: ColoredBox(color: DialogAnimation.barrierColor),
                ),
              ),
            Center(
              child: OverflowBox(
                maxWidth: bandWidth,
                child: Transform.rotate(
                  angle: -4.6 * math.pi / 180,
                  child: SizedBox(
                    width: bandWidth,
                    height: widget.bandHeight * s,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [_stripes(bandWidth), _contentLayer(s)],
                    ),
                  ),
                ),
              ),
            ),
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
        return widget.tapToSkip
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _leave,
                child: banner,
              )
            : IgnorePointer(child: banner);
      },
    );
  }

  Widget _stripes(double bandWidth) {
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
                if (widget.filledStart && !_leaving && _exit.value == 0) {
                  // 접힌 장면 위로 0.15초 동안 줄이 비쳐 오른다
                  return Opacity(
                    opacity: const Interval(
                      0,
                      150 / 470,
                    ).transform(_enter.value),
                    child: child,
                  );
                }
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
              child: ClipPath(
                clipper: const _SlantClipper(),
                child: ColoredBox(color: widget.color),
              ),
            ),
          ),
      ],
    );
  }

  Widget _contentLayer(double s) {
    final enter = _reduce ? kAlwaysCompleteAnimation : _enter;
    final exit = _reduce ? kAlwaysDismissedAnimation : _exit;
    return AnimatedBuilder(
      animation: Listenable.merge([enter, exit]),
      builder: (context, child) {
        final inT = Interval(
          widget.filledStart ? 150 / 470 : 560 / 900,
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
      child: widget.content(context, s, enter, exit),
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
