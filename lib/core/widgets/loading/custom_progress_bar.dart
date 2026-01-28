import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 로딩 진행률을 표시하는 커스텀 ProgressBar
///
/// 0.0~1.0 범위의 진행률을 시각적으로 표시합니다.
/// 파일 업로드, 서버 응답 대기, 게임 로딩 등 다양한 상황에서 사용 가능합니다.
///
/// **기본 스펙**:
/// - 크기: 353x8 (반응형)
/// - 채워진 부분: AppColors.black (기본)
/// - 빈 부분: AppColors.black100 (기본)
/// - 애니메이션: 300ms (부드러운 전환)
/// - 모서리: 4px 라운드
///
/// **사용 예시**:
/// ```dart
/// // 기본 사용 (60% 진행)
/// CustomProgressBar(progress: 0.6)
///
/// // 진행률 텍스트 표시
/// CustomProgressBar(
///   progress: 0.45,
///   showPercentage: true,
/// )
///
/// // 색상 및 크기 커스터마이징
/// CustomProgressBar(
///   progress: 0.8,
///   width: 300.w,
///   height: 12.h,
///   fillColor: AppColors.green,
///   backgroundColor: AppColors.black200,
/// )
///
/// // 애니메이션 속도 조절
/// CustomProgressBar(
///   progress: uploadProgress,
///   animationDuration: Duration(milliseconds: 500),
/// )
/// ```
class CustomProgressBar extends StatelessWidget {
  const CustomProgressBar({
    super.key,
    required this.progress,
    this.width,
    this.height,
    this.fillColor,
    this.backgroundColor,
    this.borderRadius,
    this.showPercentage = false,
    this.percentageStyle,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// 진행률 (0.0~1.0 범위, 필수)
  ///
  /// 0.0 = 0%, 1.0 = 100%
  /// 범위 외 값은 자동으로 clamp됨
  final double progress;

  /// 너비 (기본: 353.w)
  final double? width;

  /// 높이 (기본: 8.h)
  final double? height;

  /// 채워진 부분 색상 (기본: AppColors.black)
  final Color? fillColor;

  /// 배경 색상 (기본: AppColors.black100)
  final Color? backgroundColor;

  /// 모서리 반경 (기본: 4.r)
  final BorderRadius? borderRadius;

  /// 진행률 텍스트 표시 여부 (기본: false)
  final bool showPercentage;

  /// 진행률 텍스트 스타일 (기본: AppTextStyles.tag_12)
  final TextStyle? percentageStyle;

  /// 애니메이션 지속 시간 (기본: 300ms)
  final Duration animationDuration;

  // ============================================
  // 기본값 Getter 메서드
  // ============================================

  /// 기본 너비 (353px)
  double get _effectiveWidth => width ?? 353.w;

  /// 기본 높이 (8px)
  double get _effectiveHeight => height ?? 8.h;

  /// 기본 채움 색상 (black)
  Color get _effectiveFillColor => fillColor ?? AppColors.black;

  /// 기본 배경 색상 (black100)
  Color get _effectiveBackgroundColor => backgroundColor ?? AppColors.black100;

  /// 기본 모서리 반경 (4px)
  BorderRadius get _effectiveBorderRadius {
    return borderRadius ?? BorderRadius.circular(4.r);
  }

  /// 기본 텍스트 스타일
  TextStyle get _effectivePercentageStyle {
    return percentageStyle ?? AppTextStyles.tag_12;
  }

  /// 검증된 진행률 (0.0~1.0 범위로 제한)
  double get _clampedProgress => progress.clamp(0.0, 1.0);

  /// 진행률 퍼센트 값 (0~100)
  int get _percentageValue => (_clampedProgress * 100).toInt();

  // ============================================
  // Widget Build
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 진행률 텍스트 (선택 사항)
        if (showPercentage) ...[
          Text('$_percentageValue%', style: _effectivePercentageStyle),
          SizedBox(height: AppSpacing.vertical4),
        ],

        // ProgressBar
        Container(
          width: _effectiveWidth,
          height: _effectiveHeight,
          decoration: BoxDecoration(
            color: _effectiveBackgroundColor,
            borderRadius: _effectiveBorderRadius,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: animationDuration,
              curve: Curves.easeInOut,
              width: _effectiveWidth * _clampedProgress,
              height: _effectiveHeight,
              decoration: BoxDecoration(
                color: _effectiveFillColor,
                borderRadius: _effectiveBorderRadius,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
