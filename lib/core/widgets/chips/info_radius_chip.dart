import 'package:cops_and_robbers/core/constants/spacing_and_radius.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

/// 정보 표시용 칩 컴포넌트
///
/// 복합 텍스트 스타일을 지원하여 "반경 400m" 형태의 정보를 표시합니다.
/// prefix는 paragraph_14_100, value는 label_16 스타일을 사용합니다.
///
/// 사용 예시:
/// ```dart
/// // 기본 (파란색)
/// InfoRadiusChip(
///   prefix: '반경',
///   value: '400m',
/// )
///
/// // 커스텀 색상
/// InfoRadiusChip(
///   prefix: '거리',
///   value: '1.2km',
///   backgroundColor: AppColors.green,
///   prefixColor: AppColors.white,
///   valueColor: AppColors.white,
/// )
/// ```
class InfoRadiusChip extends StatelessWidget {
  const InfoRadiusChip({
    super.key,
    required this.prefix,
    required this.value,
    this.backgroundColor,
    this.prefixColor,
    this.valueColor,
    this.width,
    this.height,
    this.borderRadius,
  });

  /// prefix 텍스트 (예: "반경")
  final String prefix;

  /// value 텍스트 (예: "400m")
  final String value;

  /// 배경색 (기본: AppColors.blue)
  final Color? backgroundColor;

  /// prefix 텍스트 색상 (기본: AppColors.white)
  final Color? prefixColor;

  /// value 텍스트 색상 (기본: AppColors.white)
  final Color? valueColor;

  /// 너비 (기본: 110.w)
  final double? width;

  /// 높이 (기본: 40.h)
  final double? height;

  /// 모서리 둥글기 (기본: 12.r)
  final double? borderRadius;

  // ============================================
  // 기본값 Getter 메서드
  // ============================================

  /// 배경색 (기본: AppColors.blue)
  Color get _effectiveBackgroundColor => backgroundColor ?? AppColors.blue;

  /// prefix 색상 (기본: AppColors.white)
  Color get _effectivePrefixColor => prefixColor ?? AppColors.white;

  /// value 색상 (기본: AppColors.white)
  Color get _effectiveValueColor => valueColor ?? AppColors.white;

  /// 너비 (기본: 110.w)
  double get _effectiveWidth => width ?? 110.w;

  /// 높이 (기본: 40.h)
  double get _effectiveHeight => height ?? 40.h;

  /// 모서리 둥글기 (기본: 12.r)
  double get _effectiveBorderRadius => borderRadius ?? 12.r;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _effectiveWidth,
      height: _effectiveHeight,
      decoration: BoxDecoration(
        color: _effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(_effectiveBorderRadius),
      ),
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          children: [
            // prefix: paragraph_14_100
            TextSpan(
              text: prefix,
              style: AppTextStyles.paragraph_14_100.copyWith(
                color: _effectivePrefixColor,
              ),
            ),
            // 공백
            WidgetSpan(child: SizedBox(width: AppSpacing.horizontal8)),
            // value: label_16
            TextSpan(
              text: value,
              style: AppTextStyles.label_16.copyWith(
                color: _effectiveValueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
