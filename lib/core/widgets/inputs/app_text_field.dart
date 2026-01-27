import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 앱 전역에서 사용하는 공용 TextField 컴포넌트
///
/// **기본 스펙**:
/// - 크기: 353x48 (반응형)
/// - 모서리: 12px 라운드
/// - 텍스트: AppTextStyles.label_16_medium
/// - Hint: AppColors.black600
/// - 입력 텍스트: AppColors.black
/// - 패딩: 좌우 20px, 상하 16px
/// - 테두리: 기본 1px (showBorder로 제어 가능)
///
/// **색상**:
/// - 배경: white
/// - 텍스트: black
/// - Hint: black600
/// - 기본 테두리: black100
/// - 포커스 테두리: black
/// - 에러 테두리: red
///
/// **사용 예시**:
/// ```dart
/// // 기본 TextField (테두리 있음)
/// AppTextField(
///   hintText: '이메일을 입력하세요',
///   controller: emailController,
/// )
///
/// // 테두리 없는 TextField
/// AppTextField(
///   hintText: '검색어를 입력하세요',
///   showBorder: false,
///   backgroundColor: AppColors.black100,
/// )
///
/// // 에러 상태 TextField
/// AppTextField(
///   hintText: '비밀번호를 입력하세요',
///   controller: passwordController,
///   hasError: true, // 에러 테두리 표시
/// )
///
/// // 여러 줄 입력
/// AppTextField(
///   hintText: '메모를 입력하세요',
///   maxLines: 5,
///   height: 120.h,
/// )
///
/// // 커스텀 색상 TextField
/// AppTextField(
///   hintText: '닉네임을 입력하세요',
///   backgroundColor: AppColors.green100,
///   borderColor: AppColors.green,
///   focusedBorderColor: AppColors.green800,
/// )
/// ```
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.backgroundColor,
    this.textColor,
    this.hintColor,
    this.showBorder = true,
    this.borderWidth = 1.0,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.width,
    this.height,
    this.borderRadius,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.hasError = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
  });

  /// Hint 텍스트 (Placeholder)
  final String? hintText;

  /// TextField 제어를 위한 컨트롤러
  final TextEditingController? controller;

  /// 입력 값 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 키보드 제출 버튼 클릭 콜백
  final ValueChanged<String>? onSubmitted;

  /// 배경색 (기본: AppColors.white)
  final Color? backgroundColor;

  /// 입력 텍스트 색상 (기본: AppColors.black)
  final Color? textColor;

  /// Hint 텍스트 색상 (기본: AppColors.black600)
  final Color? hintColor;

  /// 테두리 표시 여부 (기본: true)
  final bool showBorder;

  /// 테두리 두께 (기본: 1.0px)
  final double borderWidth;

  /// 기본 테두리 색상 (기본: AppColors.black100)
  final Color? borderColor;

  /// 포커스 시 테두리 색상 (기본: AppColors.black)
  final Color? focusedBorderColor;

  /// 에러 시 테두리 색상 (기본: AppColors.red)
  final Color? errorBorderColor;

  /// TextField 너비 (기본: 353.w)
  final double? width;

  /// TextField 높이 (기본: 48.h)
  final double? height;

  /// 모서리 반경 (기본: 12.r)
  final BorderRadius? borderRadius;

  /// 최대 줄 수 (기본: 1)
  final int maxLines;

  /// 최소 줄 수 (기본: null, maxLines와 동일)
  final int? minLines;

  /// 활성화 여부 (기본: true)
  final bool enabled;

  /// 읽기 전용 여부 (기본: false)
  final bool readOnly;

  /// 에러 상태 여부 (true면 에러 테두리 표시)
  final bool hasError;

  /// 비밀번호 입력 시 텍스트 숨김 여부 (기본: false)
  final bool obscureText;

  /// 키보드 타입 (이메일, 숫자 등)
  final TextInputType? keyboardType;

  /// 키보드 액션 버튼 (다음, 완료 등)
  final TextInputAction? textInputAction;

  /// 최대 입력 글자 수
  final int? maxLength;

  /// 앞쪽 아이콘 위젯
  final Widget? prefixIcon;

  /// 뒤쪽 아이콘 위젯
  final Widget? suffixIcon;

  // ============================================
  // 기본값 Getter 메서드
  // ============================================

  /// 기본 너비 (353px)
  double get _effectiveWidth => width ?? 353.w;

  /// 기본 높이 (48px)
  double get _effectiveHeight => height ?? 48.h;

  /// 기본 모서리 반경 (12px)
  BorderRadius get _effectiveBorderRadius {
    return borderRadius ?? BorderRadius.circular(12.r);
  }

  /// 배경색
  Color get _effectiveBackgroundColor {
    return backgroundColor ?? AppColors.white;
  }

  /// 텍스트 색상
  Color get _effectiveTextColor {
    return textColor ?? AppColors.black;
  }

  /// Hint 텍스트 색상
  Color get _effectiveHintColor {
    return hintColor ?? AppColors.black600;
  }

  /// 기본 테두리 색상
  Color get _effectiveBorderColor {
    if (!enabled) return Colors.transparent; // 비활성화 시 테두리 없음
    return borderColor ?? AppColors.black100;
  }

  /// 포커스 테두리 색상
  Color get _effectiveFocusedBorderColor {
    return focusedBorderColor ?? AppColors.black;
  }

  /// 에러 테두리 색상
  Color get _effectiveErrorBorderColor {
    return errorBorderColor ?? AppColors.red;
  }

  // ============================================
  // Widget Build
  // ============================================

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _effectiveWidth,
      height: maxLines > 1 ? null : _effectiveHeight, // 여러 줄일 때는 자동 높이
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        enabled: enabled,
        readOnly: readOnly,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        style: AppTextStyles.label_16_medium.copyWith(
          color: _effectiveTextColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.label_16_medium.copyWith(
            color: _effectiveHintColor,
          ),
          filled: true,
          fillColor: _effectiveBackgroundColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontal20, // 20px
            vertical: AppSpacing.vertical16, // 16px
          ),
          border: _buildBorder(
            hasError ? _effectiveErrorBorderColor : _effectiveBorderColor,
          ),
          enabledBorder: _buildBorder(
            hasError ? _effectiveErrorBorderColor : _effectiveBorderColor,
          ),
          focusedBorder: _buildBorder(
            hasError
                ? _effectiveErrorBorderColor
                : _effectiveFocusedBorderColor,
          ),
          disabledBorder: _buildBorder(Colors.transparent),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          // maxLength 표시 제거 (필요 시 하단에 커스텀 위젯으로 추가 가능)
          counterText: maxLength != null ? '' : null,
        ),
      ),
    );
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  /// 테두리 생성 헬퍼 메서드
  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: _effectiveBorderRadius,
      borderSide: showBorder
          ? BorderSide(color: color, width: borderWidth)
          : BorderSide.none,
    );
  }
}
