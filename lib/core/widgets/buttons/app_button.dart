import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../services/vibration_service.dart';

/// 아이콘 위치를 정의하는 Enum
///
/// 버튼 내에서 아이콘이 텍스트의 왼쪽에 위치할지 오른쪽에 위치할지 결정합니다.
enum IconPosition {
  /// 텍스트 왼쪽에 아이콘 배치
  leading,

  /// 텍스트 오른쪽에 아이콘 배치
  trailing,
}

/// 앱 전역에서 사용하는 공용 버튼 컴포넌트
///
/// **기본 스펙**:
/// - 크기: 353x56 (반응형)
/// - 모서리: 16px 라운드
/// - 텍스트: AppTextStyles.label_16
/// - 테두리: 기본 1px (showBorder로 제어 가능)
///
/// **색상**:
/// - 활성화: 배경 black, 텍스트 white, 테두리 black100
/// - 비활성화: 배경 black100, 텍스트 white, 테두리 없음
///
/// **사용 예시**:
/// ```dart
/// // 기본 버튼 (테두리 있음)
/// AppButton(
///   text: '로그인',
///   onPressed: () {},
/// )
///
/// // 테두리 없는 버튼
/// AppButton(
///   text: '건너뛰기',
///   onPressed: () {},
///   showBorder: false,
///   backgroundColor: AppColors.green,
/// )
///
/// // 아이콘 포함 버튼
/// AppButton(
///   text: '설정',
///   onPressed: () {},
///   icon: Icon(Icons.settings, size: 20.w),
///   iconPosition: IconPosition.leading,
/// )
///
/// // 로딩 중 버튼
/// AppButton(
///   text: '로그인 중...',
///   onPressed: () {},
///   isLoading: true,
/// )
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.showBorder = true,
    this.borderWidth = 1.0,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.iconGap,
    this.isLoading = false,
    this.subtitle,
    this.subtitleColor,
    this.contentAlignment,
    this.textStyle,
  });

  /// 버튼 텍스트 (필수)
  final String text;

  /// 버튼 클릭 핸들러 (필수, null이면 비활성화)
  final VoidCallback? onPressed;

  /// 활성화 상태 배경색 (기본: AppColors.black)
  final Color? backgroundColor;

  /// 활성화 상태 텍스트/아이콘 색상 (기본: AppColors.white)
  final Color? foregroundColor;

  /// 비활성화 상태 배경색 (기본: AppColors.black100)
  final Color? disabledBackgroundColor;

  /// 비활성화 상태 텍스트/아이콘 색상 (기본: AppColors.white)
  final Color? disabledForegroundColor;

  /// 테두리 표시 여부 (기본: true)
  final bool showBorder;

  /// 테두리 두께 (기본: 1.0px)
  final double borderWidth;

  /// 활성화 상태 테두리 색상 (기본: AppColors.black100)
  final Color? borderColor;

  /// 버튼 너비 (기본: 353.w)
  final double? width;

  /// 버튼 높이 (기본: 56.h)
  final double? height;

  /// 내용물(아이콘·텍스트) 안쪽 여백 (기본: 없음)
  ///
  /// 기본이 0인 이유: 대부분의 호출부가 [width]를 고정하고 내용을 가운데 두므로
  /// 여백이 필요 없다. 폭 대비 내용이 짧아 가장자리와의 간격을 직접 잡아야 할 때만 준다.
  final EdgeInsetsGeometry? padding;

  /// 모서리 반경 (기본: 16.r)
  final BorderRadius? borderRadius;

  /// 아이콘 위젯 (선택 사항)
  final Widget? icon;

  /// 아이콘 위치 (기본: leading - 텍스트 왼쪽)
  final IconPosition iconPosition;

  /// 아이콘과 텍스트 사이 간격 (기본: 8)
  ///
  /// `contentAlignment: spaceBetween`이면 좌우로 밀어붙이므로 이 값은 무시된다.
  final double? iconGap;

  /// 로딩 상태 (true면 CircularProgressIndicator 표시)
  final bool isLoading;

  /// 서브 텍스트 (선택 사항, 메인 텍스트 아래 작은 글씨)
  final String? subtitle;

  /// 서브 텍스트 색상 (기본: foregroundColor)
  final Color? subtitleColor;

  /// 버튼 내용 정렬 (기본: center, spaceBetween으로 좌우 정렬 가능)
  final MainAxisAlignment? contentAlignment;

  /// 텍스트 스타일 오버라이드 (미지정 시 label_16)
  final TextStyle? textStyle;

  // ============================================
  // 기본값 Getter 메서드
  // ============================================

  /// 활성 상태 배경색
  Color get _effectiveBackgroundColor {
    if (isLoading || onPressed == null) {
      return disabledBackgroundColor ?? AppColors.black100;
    }
    return backgroundColor ?? AppColors.black;
  }

  /// 활성 상태 텍스트/아이콘 색상
  Color get _effectiveForegroundColor {
    if (isLoading || onPressed == null) {
      return disabledForegroundColor ?? AppColors.white;
    }
    return foregroundColor ?? AppColors.white;
  }

  /// 활성 상태 테두리 색상 (비활성화 시 투명)
  Color get _effectiveBorderColor {
    if (isLoading || onPressed == null) {
      return Colors.transparent; // 비활성화 시 테두리 없음
    }
    return borderColor ?? AppColors.black100; // 활성화 시 black100
  }

  /// 기본 너비 (353px)
  double get _effectiveWidth => width ?? 353.w;

  /// 기본 높이 (56px)
  double get _effectiveHeight => height ?? 56.h;

  /// 기본 모서리 반경 (16px)
  BorderRadius get _effectiveBorderRadius {
    return borderRadius ?? AppRadius.xlarge;
  }

  /// 기본 정렬 방식 (center)
  MainAxisAlignment get _effectiveContentAlignment {
    return contentAlignment ?? MainAxisAlignment.center;
  }

  /// 서브텍스트 색상 (기본: 메인 텍스트 색상과 동일)
  Color get _effectiveSubtitleColor {
    return subtitleColor ?? _effectiveForegroundColor;
  }

  // ============================================
  // Widget Build
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _effectiveWidth,
      height: _effectiveHeight,
      decoration: BoxDecoration(
        borderRadius: _effectiveBorderRadius,
        border: showBorder
            ? Border.all(color: _effectiveBorderColor, width: borderWidth)
            : null,
      ),
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null)
            ? null
            : () {
                // 공통 탭 햅틱 — 활성 상태에서만 발동(로딩·비활성 시 미발동)
                VibrationService.instance().buttonTap();
                onPressed!();
              },
        style: ElevatedButton.styleFrom(
          fixedSize: Size(_effectiveWidth, _effectiveHeight),
          backgroundColor: _effectiveBackgroundColor,
          foregroundColor: _effectiveForegroundColor,
          disabledBackgroundColor:
              disabledBackgroundColor ?? AppColors.black100,
          disabledForegroundColor: disabledForegroundColor ?? AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: _effectiveBorderRadius),
          padding: padding ?? EdgeInsets.zero,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
      ),
    );
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  /// 로딩 인디케이터 위젯
  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: AppSpacing.horizontal20,
      height: AppSpacing.vertical20,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(_effectiveForegroundColor),
      ),
    );
  }

  /// 버튼 내용 (텍스트 + 아이콘)
  Widget _buildButtonContent() {
    // 텍스트 위젯 구성 (단일 or 2줄)
    Widget textWidget;
    if (subtitle == null) {
      // 기존: 단일 텍스트
      textWidget = Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: (textStyle ?? AppTextStyles.label_16).copyWith(
          color: _effectiveForegroundColor,
        ),
      );
    } else {
      // 새로운: 2줄 텍스트 (Column)
      textWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
        children: [
          Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: (textStyle ?? AppTextStyles.label_16).copyWith(
              color: _effectiveForegroundColor,
            ),
          ),
          SizedBox(height: AppSpacing.vertical4), // 간격
          Text(
            subtitle!,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.tag_12.copyWith(
              color: _effectiveSubtitleColor,
            ),
          ),
        ],
      );
    }

    if (icon == null) {
      // Row가 없어 Flexible을 못 쓰지만, 부모 제약에 맞춰 Text가 알아서 줄어든다
      return textWidget;
    }

    // 아이콘 + 텍스트
    final iconWidget = icon!;
    final isSpaceBetween =
        _effectiveContentAlignment == MainAxisAlignment.spaceBetween;
    // 버튼 폭이 고정(fixedSize)이라 아이콘+간격+텍스트 합이 넘칠 수 있어
    // Row 안에서만 Flexible로 감싸 텍스트가 줄어들도록 한다
    final flexibleTextWidget = Flexible(child: textWidget);
    final gap = SizedBox(width: iconGap ?? AppSpacing.horizontal8);

    return Row(
      mainAxisAlignment: _effectiveContentAlignment,
      mainAxisSize: MainAxisSize.max, // 전체 너비 사용
      children: iconPosition == IconPosition.trailing
          ? [flexibleTextWidget, if (!isSpaceBetween) gap, iconWidget]
          : [iconWidget, if (!isSpaceBetween) gap, flexibleTextWidget],
    );
  }
}
