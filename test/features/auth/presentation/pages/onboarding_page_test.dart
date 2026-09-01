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
///
/// `pumpAndSettle` 을 쓰지 않는다 — 프레임이 남아 있는 동안 계속 펌프하면서
/// 시계를 500ms 너머로 밀어버려, 두 번째 버튼이 "아직 안 나온" 구간을 관찰할 수
/// 없게 된다. 페이지 전환(300ms)만큼만 정확히 흘린다.
Future<void> _goToLastSlide(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.tap(find.text('다음'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
  }
}

void main() {
  testWidgets('onboarding_shows_the_next_button_when_slides_remain', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('다음'), findsOneWidget);
    expect(find.text('동심으로 들어가기'), findsNothing);
  });

  testWidgets('onboarding_swaps_the_primary_button_on_the_last_slide', (
    tester,
  ) async {
    await _pump(tester);
    await _goToLastSlide(tester);

    expect(find.text('게임 소개 보기'), findsOneWidget);
    expect(find.text('다음'), findsNothing);
  });

  testWidgets('onboarding_delays_the_enter_button_until_the_page_settles', (
    tester,
  ) async {
    await _pump(tester);
    await _goToLastSlide(tester);

    // 지연이 없으면 타이머가 이 펌프 안에서 터져 버튼이 붙는다.
    // (이 한 번을 빼면 지연을 0으로 만들어도 테스트가 통과해 버린다)
    await tester.pump(const Duration(milliseconds: 100));

    // 넘기자마자 버튼이 하나 더 생기면 방금 누른 자리가 움직여 이질감이 든다
    expect(find.text('동심으로 들어가기'), findsNothing);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('동심으로 들어가기'), findsOneWidget);
  });

  testWidgets('onboarding_hides_skip_when_on_the_last_slide', (tester) async {
    // 화면에 Opacity 가 여럿이라(마지막 장 버튼 등장 연출) 건너뛰기 것만 집는다
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
