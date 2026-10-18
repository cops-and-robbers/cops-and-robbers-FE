import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'start_banners.dart';

/// 대기·설명 장면이 배너 띠와 이어지게 하는 전환.
///
/// 역할 띠가 오른쪽으로 빠지는 동안 장면은 그 띠 자리로만 비치고, 줄이 다 빠진 뒤 화면 전체로
/// 펼쳐진다. 출동 때는 반대로 출동 띠 모양으로 접혀 그 자리에서 출동 배너로 이어진다.
/// 띠 모양은 [StripeBanner]와 같다(300 폭 기준 390 폭, -4.6°, 화면 가운데).
class BandTransition extends StatefulWidget {
  const BandTransition({
    super.key,
    required this.child,
    this.revealFromBand = false,
    this.fold = false,
  });

  final Widget child;

  /// 처음 뜰 때 역할 띠 모양에서 펼친다. 다시 켠 앱처럼 역할 배너 없이 뜨는 장면은 false.
  final bool revealFromBand;

  /// true가 되면 출동 띠 모양으로 접는다.
  final bool fold;

  /// 마지막 줄이 빠질 무렵(0.38초)까지 띠 모양을 유지한 뒤 0.6초 동안 펼친다
  static const revealDuration = Duration(milliseconds: 980);
  static const foldDuration = Duration(milliseconds: 450);

  @override
  State<BandTransition> createState() => _BandTransitionState();
}

class _BandTransitionState extends State<BandTransition>
    with TickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: BandTransition.revealDuration,
    value: 1,
  );
  late final AnimationController _fold = AnimationController(
    vsync: this,
    duration: BandTransition.foldDuration,
  );
  bool _started = false;

  bool get _reduce => MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.revealFromBand && !_reduce) _reveal.forward(from: 0);
  }

  @override
  void didUpdateWidget(BandTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fold && !oldWidget.fold && !_reduce) _fold.forward();
  }

  @override
  void dispose() {
    _reveal.dispose();
    _fold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_reveal, _fold]),
      builder: (context, child) {
        final open = const Interval(
          380 / 980,
          1,
          curve: Cubic(.7, 0, .25, 1),
        ).transform(_reveal.value);
        final fold = const Cubic(.6, 0, .8, .3).transform(_fold.value);
        if (open == 1 && fold == 0) return child!;
        return ClipPath(
          clipper: fold > 0
              ? _BandClipper(
                  bandHeight: DispatchBanner.bandHeight,
                  open: 1 - fold,
                )
              : _BandClipper(bandHeight: 154, open: open),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// [open] 0 = 기울어진 띠, 1 = 화면 전체. 네 꼭짓점을 짝지어 잇는다.
class _BandClipper extends CustomClipper<Path> {
  const _BandClipper({required this.bandHeight, required this.open});

  final double bandHeight;
  final double open;

  @override
  Path getClip(Size size) {
    final s = size.width / 300;
    final c = size.center(Offset.zero);
    const angle = -4.6 * math.pi / 180;
    Offset band(double x, double y) =>
        c +
        Offset(
              x * math.cos(angle) - y * math.sin(angle),
              x * math.sin(angle) + y * math.cos(angle),
            ) *
            s;
    final h = bandHeight / 2;
    final from = [band(-195, -h), band(195, -h), band(195, h), band(-195, h)];
    final to = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ];
    return Path()..addPolygon([
      for (var i = 0; i < 4; i++) Offset.lerp(from[i], to[i], open)!,
    ], true);
  }

  @override
  bool shouldReclip(_BandClipper old) =>
      old.open != open || old.bandHeight != bandHeight;
}
