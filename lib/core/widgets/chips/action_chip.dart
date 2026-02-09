import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

/// 액션 버튼용 칩 컴포넌트
///
/// 탭 가능한 버튼 형태의 칩입니다.
/// 단일 텍스트와 onTap 콜백을 지원합니다.
/// `onTap`이 null이면 비활성화(disabled) 상태로 표시됩니다.
///
/// 사용 예시:
/// ```dart
/// // 기본 (검정)
/// ActionChip(
///   text: '중복 확인',
///   onTap: () => check(),
/// )
///
/// // 비활성화
/// ActionChip(
///   text: '중복 확인',
///   onTap: null,
/// )
///
/// // 커스텀 색상
/// ActionChip(
///   text: '확인',
///   onTap: () => check(),
///   backgroundColor: AppColors.blue,
///   textColor: AppColors.white,
/// )
/// ```
class ActionChip extends StatelessWidget {
  const ActionChip({
    super.key,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
  });

  /// 버튼 텍스트
  final String text;

  /// 탭 콜백 (null이면 비활성화)
  final VoidCallback? onTap;

  /// 배경색 (기본: AppColors.black800)
  final Color? backgroundColor;

  /// 텍스트 색상 (기본: AppColors.white)
  final Color? textColor;

  /// 너비 (기본: 100.w)
  final double? width;

  /// 높이 (기본: 40.h)
  final double? height;

  /// 모서리 둥글기 (기본: 8.r)
  final double? borderRadius;

  // ============================================
  // 기본값 Getter 메서드
  // ============================================

  /// 배경색 (기본: AppColors.black800, 비활성화 시: AppColors.black200)
  Color get _effectiveBackgroundColor => _isDisabled
      ? AppColors.black200
      : (backgroundColor ?? AppColors.black800);

  /// 텍스트 색상 (기본: AppColors.white)
  Color get _effectiveTextColor => textColor ?? AppColors.white;

  /// 너비 (기본: 100.w)
  double get _effectiveWidth => width ?? 100.w;

  /// 높이 (기본: 40.h)
  double get _effectiveHeight => height ?? 40.h;

  /// 모서리 둥글기 (기본: 8.r)
  double get _effectiveBorderRadius => borderRadius ?? 8.r;

  /// 비활성화 여부 (onTap이 null이면 비활성화)
  bool get _isDisabled => onTap == null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_effectiveBorderRadius),
      child: Container(
        width: _effectiveWidth,
        height: _effectiveHeight,
        decoration: BoxDecoration(
          color: _effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(_effectiveBorderRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTextStyles.label_16.copyWith(color: _effectiveTextColor),
        ),
      ),
    );
  }
}
