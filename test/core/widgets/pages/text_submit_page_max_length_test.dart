import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/widgets/pages/text_submit_page.dart';

/// `TextSubmitPage`의 `maxLength` 옵션 동작 검증.
///
/// 검증 대상 행동:
/// - maxLength 설정 시 글자 수가 한도를 초과하지 않는다 (TextField가 입력을 차단)
/// - maxLength 설정 시 카운터(현재/최대)가 화면에 표시된다
/// - maxLength 미설정 시 카운터가 표시되지 않는다
void main() {
  Widget buildHarness({int? maxLength}) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => ProviderScope(
        child: MaterialApp(
          home: TextSubmitPage(
            title: '버그 제보',
            label: '버그 내용',
            hintText: 'hint',
            submitText: '제보하기',
            maxLength: maxLength,
            onSubmit: (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets(
    'limits_input_to_maxLength_when_maxLength_is_set',
    (tester) async {
      await tester.pumpWidget(buildHarness(maxLength: 10));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      // 11자 입력 시도
      await tester.enterText(textField, '12345678901');
      await tester.pump();

      final controller = (tester.widget<TextField>(textField)).controller!;
      expect(controller.text.length, 10);
    },
  );

  testWidgets(
    'shows_character_counter_when_maxLength_is_set',
    (tester) async {
      await tester.pumpWidget(buildHarness(maxLength: 1000));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '안녕');
      await tester.pump();

      // Material 기본 카운터 포맷: "{현재}/{최대}"
      expect(find.text('2/1000'), findsOneWidget);
    },
  );

  testWidgets(
    'omits_counter_when_maxLength_is_null',
    (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '안녕');
      await tester.pump();

      // 카운터 텍스트가 어떤 형태로도 보이지 않아야 함
      expect(find.textContaining('/'), findsNothing);
    },
  );
}
