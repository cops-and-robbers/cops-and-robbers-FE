import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 캐릭터 움직임 — 달리기, 기다리며 숨쉬기, 출동 직전 들썩임.
enum RunMotion { run, breathe, ready }

/// 시작 장면 캐릭터를 제자리에서 움직인다. 움직임 줄이기 설정이면 멈춘 그림.
class RunCycle extends StatefulWidget {
  const RunCycle({
    super.key,
    required this.child,
    required this.scale,
    this.motion = RunMotion.run,
    this.period = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  });

  final Widget child;

  /// 목업 1px → 화면 px (화면 폭 / 300). 튀어 오르는 높이를 화면 크기에 맞춘다.
  final double scale;
  final RunMotion motion;

  /// 달리기 한 번(올라갔다 내려오기의 절반) 시간. 둘째 캐릭터는 0.46초로 엇갈린다.
  final Duration period;

  /// 둘째 캐릭터를 반 박자 늦게 시작해 발이 엇갈리게 한다.
  final Duration delay;

  @override
  State<RunCycle> createState() => _RunCycleState();
}

class _RunCycleState extends State<RunCycle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  Timer? _delayTimer;

  /// 움직임이 실제로 돌고 있는지. 지연 중·움직임 줄이기에서는 기본 자세(변형 없음)로 둔다.
  bool _animating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant RunCycle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motion != widget.motion ||
        oldWidget.period != widget.period) {
      _sync();
    }
  }

  void _sync() {
    _delayTimer?.cancel();
    _animating = false;
    _controller.duration = switch (widget.motion) {
      RunMotion.run => widget.period,
      RunMotion.breathe => const Duration(milliseconds: 1400),
      RunMotion.ready => const Duration(milliseconds: 280),
    };
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0;
      return;
    }
    _delayTimer = Timer(widget.delay, () {
      if (!mounted) return;
      setState(() => _animating = true);
      _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 0% 키프레임은 변형이 있으므로, 움직이지 않는 동안에는 자식을 그대로 둔다.
    if (!_animating) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return switch (widget.motion) {
          RunMotion.run => _run(t, child!),
          RunMotion.breathe => Transform.scale(
            alignment: Alignment.bottomCenter,
            scaleX: 1 + 0.02 * t,
            scaleY: 1 + 0.035 * t,
            child: child,
          ),
          RunMotion.ready => Transform.translate(
            offset: Offset(0, -4 * widget.scale * t),
            child: Transform.scale(
              alignment: Alignment.bottomCenter,
              scaleY: 1 - 0.06 * t,
              child: child,
            ),
          ),
        };
      },
    );
  }

  /// 착지(납작·뒤로 기욺) → 떠오름 → 앞으로 기울며 내려옴. 시안 runcycle 키프레임(0·45%·100%).
  Widget _run(double t, Widget child) {
    double key(double a, double b, double c) =>
        t < 0.45 ? a + (b - a) * (t / 0.45) : b + (c - b) * ((t - 0.45) / 0.55);
    return Transform.translate(
      offset: Offset(0, key(0, -9, -2) * widget.scale),
      child: Transform.rotate(
        alignment: Alignment.bottomCenter,
        angle: key(-3, 2, 4) * math.pi / 180,
        child: Transform.scale(
          alignment: Alignment.bottomCenter,
          scaleX: key(1.06, 0.96, 1),
          scaleY: key(0.93, 1.05, 1),
          child: child,
        ),
      ),
    );
  }
}
