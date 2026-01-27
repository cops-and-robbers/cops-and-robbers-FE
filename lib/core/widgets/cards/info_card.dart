import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';

/// 재사용 가능한 정보 카드 컴포넌트
///
/// 둥근 모서리 Container를 제공하며,
/// 선택적 타이틀과 커스터마이징 가능한 스타일을 지원합니다.
///
/// 사용 예시:
/// ```dart
/// InfoCard(
///   title: "구역",
///   titleStyle: AppTextStyles.label_16,
///   backgroundColor: AppColors.white,
///   child: Column(children: [...]),
/// )
/// ```
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    this.title,
    this.titleStyle,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.showBorder = true,
    this.borderWidth = 1.0,
    this.borderColor,
    required this.child,
  });

  /// 카드 제목 (선택적)
  final String? title;

  /// 제목 텍스트 스타일
  final TextStyle? titleStyle;

  /// 카드 내부 패딩
  final EdgeInsets? padding;

  /// 배경색
  final Color? backgroundColor;

  /// 모서리 둥글기
  final BorderRadius? borderRadius;

  /// 테두리 표시 여부
  final bool showBorder;

  /// 테두리 두께
  final double borderWidth;

  /// 테두리 색상
  final Color? borderColor;

  /// 카드 내용
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? AppPadding.all16,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: borderRadius ?? AppRadius.xl20,
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.black100,
                width: borderWidth,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(title!, style: titleStyle),
            SizedBox(height: AppSpacing.vertical16),
          ],
          child,
        ],
      ),
    );
  }
}
