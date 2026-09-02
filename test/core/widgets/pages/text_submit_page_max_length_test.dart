import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/widgets/pages/text_submit_page.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

/// `TextSubmitPage`의 `maxLength` 옵션 동작 검증.
///
/// 검증 대상 행동:
/// - maxLength 설정 시 그 길이에서 입력이 막힌다
/// - 남은 글자 수 같은 카운터는 보여 주지 않는다 (댓글·채팅 입력과 같은 방식)
/// - 서버와 같은 단위(UTF-16)로 센다 — 이모지는 두 자로 친다
/// - maxLength 미설정 시 길이 제한이 없다
void main() {
  Widget buildHarness({int? maxLength}) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => ProviderScope(
        child: MaterialApp(
          locale: const Locale('ko'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
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

  String enteredText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  testWidgets('limits_input_to_maxLength_when_maxLength_is_set', (
    tester,
  ) async {
    await tester.pumpWidget(buildHarness(maxLength: 10));
    await tester.pumpAndSettle();

    // 11자 입력 시도
    await tester.enterText(find.byType(TextField), '12345678901');
    await tester.pump();

    expect(enteredText(tester), '1234567890');
  });

  // 서버는 자바 문자열 길이(UTF-16)로 센다. 자소 단위로 세면 앱은 한 자로 보는데
  // 서버는 두 자로 세어, 한도 근처에서 앱만 통과시키고 서버가 400을 준다.
  testWidgets('counts_emoji_as_two_characters_like_the_server', (tester) async {
    await tester.pumpWidget(buildHarness(maxLength: 4));
    await tester.pumpAndSettle();

    // 이모지 둘이면 4자 — 셋째는 들어가면 안 된다.
    await tester.enterText(find.byType(TextField), '🙂🙂🙂');
    await tester.pump();

    expect(enteredText(tester), '🙂🙂');
  });

  testWidgets('keeps_emoji_whole_when_truncating_at_the_limit', (tester) async {
    await tester.pumpWidget(buildHarness(maxLength: 5));
    await tester.pumpAndSettle();

    // 4자 + 이모지(2자) = 6자 → 이모지가 한도를 넘긴다. 반 토막으로 남으면 안 된다.
    await tester.enterText(find.byType(TextField), '가나다라🙂');
    await tester.pump();

    expect(enteredText(tester), '가나다라');
  });

  testWidgets('shows_no_counter_when_maxLength_is_set', (tester) async {
    await tester.pumpWidget(buildHarness(maxLength: 1000));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '안녕');
    await tester.pump();

    expect(find.textContaining('/'), findsNothing);
    expect(find.textContaining('남'), findsNothing);
  });

  testWidgets('does_not_limit_input_when_maxLength_is_null', (tester) async {
    await tester.pumpWidget(buildHarness());
    await tester.pumpAndSettle();

    final long = '가' * 5000;
    await tester.enterText(find.byType(TextField), long);
    await tester.pump();

    expect(enteredText(tester).length, 5000);
  });
}
