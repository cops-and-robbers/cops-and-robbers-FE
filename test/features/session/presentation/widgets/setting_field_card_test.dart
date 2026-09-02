import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/features/session/presentation/widgets/setting_field_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (_, _) => MaterialApp(home: Scaffold(body: child)),
  );
}

Color _textColor(WidgetTester tester, String text) {
  return tester.widget<Text>(find.text(text)).style!.color!;
}

void main() {
  testWidgets('renders_label_value_and_hint', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SettingFieldCard(
          label: '참여 인원',
          value: '50명',
          hint: '최소 인원은 2명입니다',
        ),
      ),
    );

    expect(find.text('참여 인원'), findsOneWidget);
    expect(find.text('50명'), findsOneWidget);
    expect(find.text('최소 인원은 2명입니다'), findsOneWidget);
  });

  testWidgets('renders_prefix_and_suffix_around_value', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SettingFieldCard(
          label: '경찰 시작 시간',
          value: '5분',
          valuePrefix: '도둑 시작 후',
          valueSuffix: '뒤',
        ),
      ),
    );

    expect(find.text('도둑 시작 후'), findsOneWidget);
    expect(find.text('5분'), findsOneWidget);
    expect(find.text('뒤'), findsOneWidget);
  });

  testWidgets('dims_text_by_state', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            SettingFieldCard(label: '입력중', value: '30분'),
            SettingFieldCard(label: '제안값', value: '10명', isValueDimmed: true),
            SettingFieldCard(label: '완료됨', value: '5분', isActive: false),
          ],
        ),
      ),
    );

    expect(_textColor(tester, '30분'), AppColors.black);
    expect(_textColor(tester, '10명'), AppColors.black300);
    expect(_textColor(tester, '완료됨'), AppColors.black400);
    expect(_textColor(tester, '5분'), AppColors.black400);
  });

  testWidgets('marks_hint_as_warning', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SettingFieldCard(
          label: '게임 시간',
          value: '5분',
          hint: '게임 시간은 최소 10분입니다',
          isHintWarning: true,
        ),
      ),
    );

    expect(_textColor(tester, '게임 시간은 최소 10분입니다'), AppColors.red);
  });

  testWidgets('fires_onTap', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      _wrap(
        SettingFieldCard(
          label: '참여 인원',
          value: '50명',
          isActive: false,
          onTap: () => tapped++,
        ),
      ),
    );

    await tester.tap(find.text('참여 인원'));
    expect(tapped, 1);
  });
}
