import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';
import '../buttons/previous_button.dart';

/// 앱 공용 상단 앱바
///
/// 화면마다 반복되던 크롬(`surfaceTintColor`·`elevation: 0`·`PreviousButton`·
/// 타이틀 스타일)을 한 곳에 모은다. [AppBar]를 상속하므로 여기서 안 채운
/// 파라미터(`bottom`·`toolbarHeight` 등)는 그대로 쓸 수 있다.
///
/// 팀 테마는 [DEC-0005] 원칙대로 상위 페이지가 [isDarkMode]로 내려준다
/// (하위 위젯이 `roleThemeProvider`를 직접 구독하지 않는다).
///
/// 도둑 모드 타이틀은 기본이 Moneygraphy(`robberHeading`)다. 게임 설정·구역
/// 미리보기처럼 도둑 모드에서도 Pretendard를 유지하는 화면은 `useRobberFont:
/// false`를 넘긴다 — 라이트 모드에서는 어느 쪽이든 차이가 없다.
///
/// **사용 예시**:
/// ```dart
/// appBar: AppTopBar(title: l10n.pageNoticesTitle, onBack: context.pop),
/// ```
class AppTopBar extends AppBar {
  AppTopBar({
    super.key,
    String? title,
    Widget? titleWidget,
    bool isDarkMode = false,
    bool useRobberFont = true,
    VoidCallback? onBack,
    Widget? leading,
    Color? backgroundColor,
    super.actions,
    super.centerTitle = true,
    super.titleSpacing,
  }) : super(
         // surfaceTint를 배경과 같게 둬야 M3 스크롤 오버레이 색이 안 낀다.
         backgroundColor: backgroundColor ?? _background(isDarkMode),
         surfaceTintColor: backgroundColor ?? _background(isDarkMode),
         elevation: 0,
         // leading을 항상 명시적으로 관리한다 — 뒤로가기 유무는 [onBack]이 정한다.
         automaticallyImplyLeading: false,
         leading:
             leading ??
             (onBack == null
                 ? null
                 : PreviousButton(
                     onPressed: onBack,
                     color: isDarkMode
                         ? AppColors.black200
                         : AppColors.black800,
                   )),
         title:
             titleWidget ??
             (title == null
                 ? null
                 : Text(
                     title,
                     style:
                         (isDarkMode && useRobberFont
                                 ? AppTextStyles.robberHeading
                                 : AppTextStyles.heading_20)
                             .copyWith(
                               color: isDarkMode
                                   ? AppColors.white
                                   : AppColors.black,
                             ),
                   )),
       );

  static Color _background(bool isDarkMode) =>
      isDarkMode ? AppColors.black900 : AppColors.white;
}
