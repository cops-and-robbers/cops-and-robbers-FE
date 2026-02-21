import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/spacing_and_radius.dart';
import '../constants/text_styles.dart';

/// 말풍선 위젯
///
/// 텍스트 길이에 따라 자동으로 크기가 조절되는 말풍선.
/// 하단 중앙에 삼각형 꼬리가 있으며, shadow가 적용됩니다.
///
/// **사용 예시**:
/// ```dart
/// SpeechBubble(text: '너무 기대 돼\n이번에는 어떤 역할을 할까?')
/// ```
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({
    super.key,
    required this.text,
    this.textStyle,
    this.padding,
  });

  /// 말풍선 안 텍스트
  final String text;

  /// 텍스트 스타일 (기본: paragraph_14, black)
  final TextStyle? textStyle;

  /// 내부 패딩 (기본: 가로 16, 세로 12)
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal16,
          vertical: AppSpacing.vertical12,
        );
    final effectiveStyle =
        textStyle ??
        AppTextStyles.paragraph_14.copyWith(color: AppColors.black);

    return CustomPaint(
      painter: _SpeechBubblePainter(),
      child: Padding(
        padding: effectivePadding.copyWith(
          bottom: effectivePadding.bottom + AppSpacing.vertical12,
        ),
        child: Text(text, textAlign: TextAlign.center, style: effectiveStyle),
      ),
    );
  }
}

/// 말풍선 형태를 그리는 CustomPainter
///
/// 둥근 사각형 + 하단 삼각형 꼬리 + shadow
/// Shadow: X1, Y1, Blur 8 (sigma 4), Spread 0, #000000 10%
class _SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = AppRadius.large.topLeft.x;
    final triangleHeight = 10.h;
    final triangleWidth = 14.w;
    final bodyHeight = size.height - triangleHeight;

    // 말풍선 body path
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, bodyHeight),
          Radius.circular(radius),
        ),
      );

    // 삼각형 꼬리 (하단 중앙)
    final centerX = size.width / 2;
    path.moveTo(centerX - triangleWidth / 2, bodyHeight);
    path.lineTo(centerX, size.height);
    path.lineTo(centerX + triangleWidth / 2, bodyHeight);
    path.close();

    // Shadow (X:1, Y:1, Blur:8 → sigma:4, Spread:0, #000000 10%)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.save();
    canvas.translate(1, 1);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Fill
    final paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
