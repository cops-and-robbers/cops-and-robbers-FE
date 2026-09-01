import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/constants/text_styles.dart';
import 'package:cops_and_robbers/core/widgets/buttons/previous_button.dart';
import 'package:cops_and_robbers/core/widgets/navigation/app_top_bar.dart';

/// [AppTextStyles]가 ScreenUtil `.sp`를 쓰므로 앱바는 반드시
/// `ScreenUtilInit` 하위에서 생성해야 한다 (실제 앱의 `build()`와 동일 조건).
Future<void> _pump(WidgetTester tester, AppTopBar Function() build) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => Scaffold(appBar: build()),
      ),
    ),
  );
}

void main() {
  testWidgets('renders_light_palette_when_isDarkMode_is_false', (tester) async {
    await _pump(tester, () => AppTopBar(title: '공지사항', onBack: () {}));

    final bar = tester.widget<AppTopBar>(find.byType(AppTopBar));
    expect(bar.backgroundColor, AppColors.white);
    expect(bar.surfaceTintColor, AppColors.white);
    expect(bar.elevation, 0);

    final title = tester.widget<Text>(find.text('공지사항'));
    expect(title.style?.color, AppColors.black);
    expect(title.style?.fontSize, AppTextStyles.heading_20.fontSize);
  });

  testWidgets('renders_dark_palette_when_isDarkMode_is_true', (tester) async {
    await _pump(
      tester,
      () => AppTopBar(title: '감옥', isDarkMode: true, onBack: () {}),
    );

    final bar = tester.widget<AppTopBar>(find.byType(AppTopBar));
    expect(bar.backgroundColor, AppColors.black900);

    final title = tester.widget<Text>(find.text('감옥'));
    expect(title.style?.color, AppColors.white);
    expect(title.style?.fontSize, AppTextStyles.robberHeading.fontSize);

    final back = tester.widget<PreviousButton>(find.byType(PreviousButton));
    expect(back.color, AppColors.black200);
  });

  testWidgets('keeps_pretendard_title_when_useRobberFont_is_false', (
    tester,
  ) async {
    await _pump(
      tester,
      () => AppTopBar(
        title: '게임 설정',
        isDarkMode: true,
        useRobberFont: false,
        onBack: () {},
      ),
    );

    // 도둑 모드지만 폰트는 라이트와 같은 Pretendard, 색만 다크를 따른다.
    final title = tester.widget<Text>(find.text('게임 설정'));
    expect(title.style?.fontFamily, AppTextStyles.heading_20.fontFamily);
    expect(title.style?.color, AppColors.white);
  });

  testWidgets('omits_leading_when_onBack_is_null', (tester) async {
    await _pump(tester, () => AppTopBar(title: '커뮤니티'));

    expect(find.byType(PreviousButton), findsNothing);
    expect(find.text('커뮤니티'), findsOneWidget);
  });

  testWidgets('prefers_titleWidget_over_title_when_both_are_given', (
    tester,
  ) async {
    await _pump(
      tester,
      () => AppTopBar(title: '무시됨', titleWidget: const Text('슬롯')),
    );

    expect(find.text('슬롯'), findsOneWidget);
    expect(find.text('무시됨'), findsNothing);
  });
}
