import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';
import '../../services/vibration_service.dart';

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
    this.icon,
  });

  /// 버튼 텍스트
  final String text;

  /// 텍스트 왼쪽에 표시할 아이콘 (없으면 미표시)
  final IconData? icon;

  /// 탭 콜백 (null이면 비활성화)
  final VoidCallback? onTap;

  /// 배경색 (기본: AppColors.black800)
  final Color? backgroundColor;

  /// 텍스트 색상 (기본: AppColors.white)
  final Color? textColor;

  /// 너비 (기본: 내용에 맞춰 조절, 최소 100.w)
  ///
  /// 값을 주면 그 너비로 고정됩니다. 주지 않으면 최소 100.w를 지키되
  /// 영어 등 긴 텍스트는 잘리지 않게 칩이 넓어집니다.
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

  /// 높이 (기본: 40.h)
  double get _effectiveHeight => height ?? 40.h;

  /// 모서리 둥글기 (기본: 8.r)
  double get _effectiveBorderRadius => borderRadius ?? 8.r;

  /// 비활성화 여부 (onTap이 null이면 비활성화)
  bool get _isDisabled => onTap == null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 다른 공용 버튼(AppButton·FlatIconButton 등)처럼 햅틱을 내장한다 —
      // 호출부는 진동을 신경 쓰지 않는다.
      onTap: onTap == null
          ? null
          : () {
              VibrationService.instance().buttonTap();
              onTap!();
            },
      borderRadius: BorderRadius.circular(_effectiveBorderRadius),
      child: Container(
        width: width,
        // 너비 미지정 시 내용에 맞추되 최소 100.w 유지. 텍스트가 그보다 길면
        // 칩이 넓어져 넘침(overflow)이 생기지 않는다.
        constraints: width == null ? BoxConstraints(minWidth: 100.w) : null,
        padding: width == null ? EdgeInsets.symmetric(horizontal: 12.w) : null,
        height: _effectiveHeight,
        decoration: BoxDecoration(
          color: _effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(_effectiveBorderRadius),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16.sp, color: _effectiveTextColor),
              SizedBox(width: 4.w),
            ],
            Text(
              text,
              style: AppTextStyles.label_16.copyWith(
                color: _effectiveTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
