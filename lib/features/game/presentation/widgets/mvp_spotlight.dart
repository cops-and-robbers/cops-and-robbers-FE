import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// MVP 공개 화면의 천장 조명 (FE #679).
///
/// 화면 위 바깥의 조명이 고개를 돌리듯 바닥을 훑다가 가운데에 멈춘다. 가운데에서 멀수록
/// 바닥의 빛 웅덩이가 넓고 조금 높게(멀리) 보여 원근이 생긴다. 조명 밖은 어둡게 덮는다.
/// 좌표는 시안 393x852 기준이고 그릴 때 화면 크기에 맞춰 늘린다.
class MvpSpotlightPainter extends CustomPainter {
  const MvpSpotlightPainter({
    required this.darkness,
    required this.sweep,
    required this.beamOn,
    required this.beamStrength,
  });

  /// 조명 밖 어둠 0~1.
  final double darkness;

  /// 훑는 진행 0~1 — 1이면 가운데에 멈춘 상태.
  final double sweep;

  /// 조명이 켜진 정도 0~1.
  final double beamOn;

  /// 빛줄기 밝기 — 흰 무대(경찰)는 빛이 하얗게 날아가지 않게 낮춘다.
  final double beamStrength;

  static const _designW = 393.0;
  static const _designH = 852.0;
  static const _centerX = 196.0;
  static const _sourceY = -90.0;
  static const _floorY = 600.0;
  static const _sourceHalf = 24.0;

  /// 바닥 x 경로 — 왼쪽 → 오른쪽 → 왼쪽 조금 → 가운데를 살짝 지나쳤다 돌아온다.
  static const _path = [
    (0.0, 30.0),
    (0.35, 350.0),
    (0.68, 110.0),
    (0.88, 212.0),
    (1.0, _centerX),
  ];

  static double floorX(double p) {
    for (var i = 1; i < _path.length; i++) {
      final (p0, x0) = _path[i - 1];
      final (p1, x1) = _path[i];
      if (p <= p1) {
        final t = ((p - p0) / (p1 - p0)).clamp(0.0, 1.0);
        return x0 + (x1 - x0) * (t * t * (3 - 2 * t));
      }
    }
    return _centerX;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (darkness <= 0) return;
    final sx = size.width / _designW;
    final sy = size.height / _designH;

    final px = floorX(sweep);
    final d = (px - _centerX).abs();
    final pool = Rect.fromCenter(
      center: Offset(px * sx, (_floorY - d * 0.12) * sy),
      width: (135 + d * 0.28) * 2 * sx,
      height: (30 + d * 0.06) * 2 * sy,
    );
    // 조명 머리도 웅덩이 쪽으로 조금 기운다.
    final srcX = (_centerX + (px - _centerX) * 0.18) * sx;
    final srcY = _sourceY * sy;
    final cone = Path()
      ..moveTo(srcX - _sourceHalf * sx, srcY)
      ..lineTo(srcX + _sourceHalf * sx, srcY)
      ..lineTo(pool.right, pool.center.dy)
      ..arcTo(pool, 0, math.pi, false)
      ..close();

    // 어둠을 깔고 조명 자리만 흐리게 뚫는다.
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.black.withValues(alpha: 0.95 * darkness),
    );
    canvas.drawPath(
      cone,
      Paint()
        ..blendMode = BlendMode.dstOut
        ..color = AppColors.black.withValues(alpha: 0.92 * beamOn)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 * sx),
    );
    canvas.restore();

    // 빛줄기(위가 밝고 아래로 옅어짐)와 바닥 웅덩이.
    final beam = beamOn * darkness * beamStrength;
    if (beam <= 0) return;
    canvas.drawPath(
      cone,
      Paint()
        ..blendMode = BlendMode.plus
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * sx)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white.withValues(alpha: 0.5 * beam),
            AppColors.white.withValues(alpha: 0.08 * beam),
            AppColors.white.withValues(alpha: 0.16 * beam),
          ],
          stops: const [0, 0.75, 1],
        ).createShader(Rect.fromLTRB(0, srcY, size.width, pool.center.dy)),
    );
    canvas.drawOval(
      pool,
      Paint()
        ..blendMode = BlendMode.plus
        ..color = AppColors.white.withValues(alpha: 0.22 * beam)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * sx),
    );
  }

  @override
  bool shouldRepaint(MvpSpotlightPainter old) =>
      old.darkness != darkness ||
      old.sweep != sweep ||
      old.beamOn != beamOn ||
      old.beamStrength != beamStrength;
}
