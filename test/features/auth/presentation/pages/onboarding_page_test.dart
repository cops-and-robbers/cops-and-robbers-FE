import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/features/auth/presentation/pages/onboarding_page.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

/// 온보딩 캐러셀의 진행 분기 검증.
///
/// 마지막 장 판정이 틀어지면 "다음"만 계속 눌리거나(진행 불가) 중간 장에서
/// 온보딩이 닫힌다. 두 경우 모두 설치 후 첫 화면에서 사용자가 갇힌다.
Future<void> _pump(WidgetTester tester) async {
  // 테스트 기본 화면은 800x600이라 좁은 폰에서만 나는 오버플로우를 놓친다.
  // 실제로 2번 장의 캐릭터 두 개가 375 폭에서 20px 넘쳤는데 이 테스트가
  // 통과했었다 — 디자인 기준 폭으로 맞춰 렌더한다.
  tester.view.physicalSize = const Size(375 * 3, 812 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => const OnboardingPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 4장 구성 — 3번 넘기면 마지막 장.
Future<void> _goToLastSlide(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('onboarding_shows_the_next_button_when_slides_remain', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('다음'), findsOneWidget);
    expect(find.text('시작하기'), findsNothing);
  });

  testWidgets('onboarding_swaps_the_primary_button_on_the_last_slide', (
    tester,
  ) async {
    await _pump(tester);
    await _goToLastSlide(tester);

    expect(find.text('시작하기'), findsOneWidget);
    expect(find.text('다음'), findsNothing);
  });

  testWidgets('onboarding_hides_skip_when_on_the_last_slide', (tester) async {
    // 화면에 Opacity 가 여럿일 수 있어 건너뛰기 것만 집는다
    double skipOpacity() => tester
        .widget<Opacity>(
          find
              .ancestor(of: find.text('건너뛰기'), matching: find.byType(Opacity))
              .first,
        )
        .opacity;

    await _pump(tester);

    expect(skipOpacity(), 1);

    await _goToLastSlide(tester);

    expect(skipOpacity(), 0);
  });
}
