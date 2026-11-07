import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'start_banners.dart';

/// 대기·설명 장면이 배너 띠와 이어지게 하는 전환.
///
/// 역할 띠가 오른쪽으로 빠지는 동안 장면은 그 띠 자리로만 비치고, 줄이 다 빠진 뒤 화면 전체로
/// 펼쳐진다. 띠 모양은 [RoleBanner]의 [StripeBanner]와 같다.
class BandTransition extends StatefulWidget {
  const BandTransition({
    super.key,
    required this.child,
    this.revealFromBand = false,
  });

  final Widget child;

  /// 처음 뜰 때 역할 띠 모양에서 펼친다. 다시 켠 앱처럼 역할 배너 없이 뜨는 장면은 false.
  final bool revealFromBand;

  /// 마지막 줄이 빠질 무렵(0.38초)까지 띠 모양을 유지한 뒤 0.6초 동안 펼친다
  static const revealDuration = Duration(milliseconds: 980);

  @override
  State<BandTransition> createState() => _BandTransitionState();
}

class _BandTransitionState extends State<BandTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: BandTransition.revealDuration,
    value: 1,
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
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _reveal,
      builder: (context, child) {
        final open = const Interval(
          380 / 980,
          1,
          curve: Cubic(.7, 0, .25, 1),
        ).transform(_reveal.value);
        // 다 펼쳐져도 ClipPath 틀은 그대로 두고 자르기만 끈다 — 틀을 빼면 위젯 트리 모양이 바뀌어
        // 장면이 새로 만들어지고 공지·규칙·남은 시간 막대가 처음부터 다시 돈다
        final settled = open == 1;
        return ClipPath(
          clipBehavior: settled ? Clip.none : Clip.antiAlias,
          clipper: settled
              ? null
              : _BandClipper(
                  bandHeight: RoleBanner.bandHeight,
                  angleDegrees: RoleBanner.bandAngleDegrees,
                  offsetY: RoleBanner.bandOffsetY,
                  open: open,
                ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// [open] 0 = 기울어진 띠, 1 = 화면 전체. 네 꼭짓점을 짝지어 잇는다.
class _BandClipper extends CustomClipper<Path> {
  const _BandClipper({
    required this.bandHeight,
    required this.open,
    required this.angleDegrees,
    required this.offsetY,
  });

  final double bandHeight;
  final double angleDegrees;
  final double offsetY;
  final double open;

  @override
  Path getClip(Size size) {
    final s = size.width / 300;
    final c = size.center(Offset.zero) + Offset(0, offsetY * s);
    final angle = angleDegrees * math.pi / 180;
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
      old.open != open ||
      old.bandHeight != bandHeight ||
      old.angleDegrees != angleDegrees ||
      old.offsetY != offsetY;
}
