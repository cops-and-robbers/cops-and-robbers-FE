import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

/// 가로 점선 구분선
///
/// Flutter의 [Divider]는 실선만 그리고, `DecoratedBox`로 점선을 흉내내려면
/// 이미지를 반복해야 한다. 폭이 화면마다 달라 대시 개수가 바뀌므로 그릴 때
/// 실제 폭을 받아 계산하는 [CustomPaint]가 가장 단순하다.
class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    this.color = AppColors.black200,
    this.thickness,
    this.dashWidth,
    this.dashGap,
  });

  final Color color;

  /// 선 두께 (기본 1)
  final double? thickness;

  /// 대시 하나의 길이 (기본 2)
  final double? dashWidth;

  /// 대시 사이 간격 (기본 2)
  final double? dashGap;

  @override
  Widget build(BuildContext context) {
    final stroke = thickness ?? 1.h;
    return SizedBox(
      height: stroke,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color,
          thickness: stroke,
          dashWidth: dashWidth ?? 6.w,
          dashGap: dashGap ?? 2.w,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({
    required this.color,
    required this.thickness,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double thickness;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final step = dashWidth + dashGap;
    // step이 0이면 무한 루프가 된다 — 호출부가 0을 넘길 수 있으므로 방어한다.
    if (step <= 0) return;

    final y = size.height / 2;
    for (double x = 0; x < size.width; x += step) {
      // 마지막 대시가 폭을 넘지 않도록 자른다.
      final end = (x + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) =>
      old.color != color ||
      old.thickness != thickness ||
      old.dashWidth != dashWidth ||
      old.dashGap != dashGap;
}
