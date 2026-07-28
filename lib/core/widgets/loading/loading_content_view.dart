import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import 'loading_visuals.dart';

/// 풀스크린 로딩 콘텐츠
///
/// 오버레이(`AppLoading`)와 전체 페이지(`LoadingPage`)가 공유하는 단일 뷰다.
/// 모달 스피너 대신 "제목 + 안심 서브카피 + 비주얼"로 진행 상황을 설명해
/// 차단당한 느낌 대신 진행 중인 단계라는 인상을 준다.
///
/// 팀 테마는 진입점에서 읽어 prop으로 내린다(하위 위젯 직접 watch 금지).
class LoadingContentView extends StatelessWidget {
  const LoadingContentView({
    super.key,
    required this.message,
    required this.isDarkMode,
    this.subtitle,
    this.bottom,
  });

  /// 제목 — 카테고리별 랜덤 세계관 문구
  final String message;

  /// 안심 서브카피 (없으면 숨김)
  final String? subtitle;

  /// true = 도둑(다크), false = 경찰(라이트)
  final bool isDarkMode;

  /// 하단 슬롯 — `LoadingPage`의 진행률 바 등. 없으면 숨김
  final Widget? bottom;

  Color get _backgroundColor => isDarkMode ? AppColors.black : AppColors.white;

  TextStyle get _titleStyle =>
      (isDarkMode ? AppTextStyles.robberHeading24 : AppTextStyles.heading_24)
          .copyWith(color: isDarkMode ? AppColors.white : AppColors.black);

  TextStyle get _subtitleStyle => AppTextStyles.paragraph_14.copyWith(
    color: isDarkMode ? AppColors.black400 : AppColors.black600,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: AppPadding.horizontal20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.vertical64),
              Text(
                message,
                style: _titleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                SizedBox(height: AppSpacing.vertical12),
                Text(
                  subtitle!,
                  style: _subtitleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              Expanded(
                child: Center(child: LoadingVisual(isDarkMode: isDarkMode)),
              ),
              if (bottom != null) bottom!,
              SizedBox(height: AppSpacing.vertical64),
            ],
          ),
        ),
      ),
    );
  }
}
