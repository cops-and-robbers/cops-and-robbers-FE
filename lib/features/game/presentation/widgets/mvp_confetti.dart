import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// MVP 공개 화면 색종이 — 화면 양옆에서 터진 뒤 화면 폭에 고르게 퍼져 떨어진다 (FE #679).
///
/// 터진 직후엔 어지럽게 엇갈리지만, 조각마다 화면 폭을 나눈 칸을 하나씩 받아 그 칸으로
/// 퍼진 뒤 살랑이며 떨어진다(혼돈 속의 질서). 공기 저항으로 금방 느려지고 종이가 뒤집히듯
/// 납작해졌다 펴진다. 모양·색·크기는 시안(9085:24542)의 색종이 6개 그대로다.
/// 위치·속도는 고정 시드라 매번 같은 모양으로 터진다(테스트 렌더도 같다).
class MvpConfetti extends StatefulWidget {
  const MvpConfetti({super.key});

  static const duration = Duration(milliseconds: 3600);

  /// 한쪽에서 나오는 조각 수.
  static const perSide = 16;

  static const _shapes = [
    'assets/backgrounds/mvp/confetti_1.svg',
    'assets/backgrounds/mvp/confetti_2.svg',
    'assets/backgrounds/mvp/confetti_3.svg',
    'assets/backgrounds/mvp/confetti_4.svg',
    'assets/backgrounds/mvp/confetti_5.svg',
    'assets/backgrounds/mvp/confetti_6.svg',
  ];

  @override
  State<MvpConfetti> createState() => _MvpConfettiState();
}

class _Piece {
  _Piece(
    math.Random r, {
    required this.fromLeft,
    required this.shape,
    required this.lane,
    required this.vy,
  }) : y0 = 0.42 + r.nextDouble() * 0.12,
       drag = 2.0 + r.nextDouble() * 1.2,
       // 떨어지는 끝속도(화면 높이/초). 시안 검토에서 1.5배로 확정.
       vt = (0.07 + r.nextDouble() * 0.06) * 1.5,
       swayA = 6 + r.nextDouble() * 12,
       swayW = 3 + r.nextDouble() * 3,
       phase = r.nextDouble() * math.pi * 2,
       flipW = 5 + r.nextDouble() * 6,
       spin = (r.nextDouble() - 0.5) * 3,
       angle0 = r.nextDouble() * math.pi * 2,
       scale = 0.75 + r.nextDouble() * 0.5,
       delay = r.nextDouble() * 0.18;

  final bool fromLeft;
  final String shape;

  /// 도착할 가로 자리 — 화면 폭 비율.
  final double lane;

  /// 솟는 힘 — 화면 높이/초 (음수가 위).
  final double vy;

  final double y0, drag, vt, swayA, swayW, phase, flipW, spin, angle0;
  final double scale, delay;
}

class _MvpConfettiState extends State<MvpConfetti>
    with SingleTickerProviderStateMixin {
  static const _designW = 393.0;
  static const _margin = 24.0;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: MvpConfetti.duration,
  )..forward();

  late final List<_Piece> _pieces = () {
    final r = math.Random(679);
    final n = MvpConfetti.perSide * 2;
    final laneW = (_designW - _margin * 2) / n;
    // 솟는 높이를 n단계로 나눠 섞는다 — 같은 높이에 몰려 한 줄로 떨어지지 않게.
    final heights = List.generate(n, (i) => i)..shuffle(r);
    return [
      for (var i = 0; i < n; i++)
        _Piece(
          r,
          // 왼쪽 조각은 짝수 칸, 오른쪽 조각은 홀수 칸 — 엇갈려 지나가며 전체를 채운다.
          fromLeft: i.isEven,
          shape: MvpConfetti._shapes[i % MvpConfetti._shapes.length],
          lane:
              (_margin + laneW * (i + 0.5 + (r.nextDouble() - 0.5) * 0.6)) /
              _designW,
          vy: -(0.45 + 0.9 * (heights[i] + r.nextDouble()) / n),
        ),
    ];
  }();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, box) => AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final elapsed =
                _c.value * MvpConfetti.duration.inMilliseconds / 1000;
            return Stack(
              clipBehavior: Clip.none,
              children: [for (final p in _pieces) _buildPiece(p, box, elapsed)],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPiece(_Piece p, BoxConstraints box, double elapsed) {
    final k = elapsed - p.delay;
    if (k <= 0) return const SizedBox.shrink();
    final w = box.maxWidth, h = box.maxHeight, unit = w / _designW;

    // 터지는 힘이 사라지는 정도 — 공기 저항으로 금방 1에 가까워진다.
    final slow = 1 - math.exp(-p.drag * k);
    final reach = 1 - math.exp(-p.drag * 1.4 * k);
    final startX = p.fromLeft ? 0.0 : w;
    final x =
        startX +
        (p.lane * w - startX) * reach +
        p.swayA * unit * math.sin(p.swayW * k + p.phase) * slow;
    final y = (p.y0 + (p.vy - p.vt) / p.drag * slow + p.vt * k) * h;

    final total = MvpConfetti.duration.inMilliseconds / 1000;
    final opacity = ((total - elapsed) / 0.8).clamp(0.0, 1.0);
    // 종이가 뒤집히는 느낌 — 세로가 납작해졌다 펴진다.
    final flip = math.cos(p.flipW * k + p.phase);
    final s = p.scale * unit;

    return Positioned(
      left: x,
      top: y,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: p.angle0 + p.spin * k,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(s, s * flip, 1),
              child: SvgPicture.asset(p.shape),
            ),
          ),
        ),
      ),
    );
  }
}
