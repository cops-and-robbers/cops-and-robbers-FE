import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/start_banners.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpOnPhone(
  WidgetTester tester,
  Widget banner, {
  Size size = const Size(393, 852),
  Locale locale = const Locale('ko'),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, _) => MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(children: [Positioned.fill(child: banner)]),
        ),
      ),
    ),
  );
}

Future<void> advance(WidgetTester tester, Duration d) async {
  for (var i = 0; i < d.inMilliseconds ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets(
    'police_role_banner_shows_mission_and_role_then_finishes_when_game_starts',
    (tester) async {
      var done = 0;
      await pumpOnPhone(
        tester,
        RoleBanner(isPolice: true, onDone: () => done++),
      );
      await advance(tester, const Duration(milliseconds: 1200));
      expect(find.text('내 역할'), findsOneWidget);
      expect(find.text('도둑을 찾아'), findsOneWidget);
      expect(find.text('모두를 체포하라!'), findsOneWidget);
      expect(find.text('당신의 역할은 경찰입니다', findRichText: true), findsOneWidget);
      await advance(tester, const Duration(milliseconds: 3000));
      expect(done, 1);
    },
  );

  // 왼쪽 위 긴 선은 왼쪽에서, 오른쪽 아래 긴 선은 오른쪽에서 그어진다.
  // 그리는 도중엔 시작점 쪽에만 선이 있어 중심이 다 그린 때보다 시작점에 가깝다.
  testWidgets('speed_lines_draw_from_opposite_sides_when_role_banner_enters', (
    tester,
  ) async {
    await pumpOnPhone(tester, RoleBanner(isPolice: true, onDone: () {}));
    const topLine = ValueKey('roleSpeedLine0');
    const bottomLine = ValueKey('roleSpeedLine2');
    await advance(tester, const Duration(milliseconds: 450));
    final topMid = tester.getCenter(find.byKey(topLine)).dx;
    final bottomMid = tester.getCenter(find.byKey(bottomLine)).dx;
    await advance(tester, const Duration(milliseconds: 600));
    expect(topMid, lessThan(tester.getCenter(find.byKey(topLine)).dx));
    expect(bottomMid, greaterThan(tester.getCenter(find.byKey(bottomLine)).dx));
    await advance(tester, const Duration(milliseconds: 3000));
  });

  // 들어온 뒤 약 1초는 거의 멈춘 듯 천천히 흐르고, 그다음 들어온 방향 그대로 화면 밖으로 빠진다.
  testWidgets('speed_lines_drift_slowly_then_leave_screen_while_banner_holds', (
    tester,
  ) async {
    await pumpOnPhone(tester, RoleBanner(isPolice: true, onDone: () {}));
    const topLine = ValueKey('roleSpeedLine0');
    const bottomLine = ValueKey('roleSpeedLine2');
    double topX() => tester.getCenter(find.byKey(topLine)).dx;
    double bottomX() => tester.getCenter(find.byKey(bottomLine)).dx;
    await advance(tester, const Duration(milliseconds: 800));
    final topSlow = topX();
    final bottomSlow = bottomX();
    await advance(tester, const Duration(milliseconds: 600));
    expect(topX(), inInclusiveRange(topSlow, topSlow + 20));
    expect(bottomX(), inInclusiveRange(bottomSlow - 20, bottomSlow));
    await advance(tester, const Duration(milliseconds: 800));
    expect(topX(), greaterThan(393));
    expect(bottomX(), lessThan(0));
    await advance(tester, const Duration(milliseconds: 3000));
  });

  // 쫀득한 등장: 아래에서 튀어 올라 제자리를 살짝 지나쳤다가 돌아와 멈춘다
  testWidgets('character_overshoots_then_settles_when_role_banner_enters', (
    tester,
  ) async {
    await pumpOnPhone(tester, RoleBanner(isPolice: true, onDone: () {}));
    double top() => tester.getTopLeft(find.byType(SvgPicture)).dy;
    final start = top();
    var highest = start;
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 40));
      if (top() < highest) highest = top();
    }
    await tester.pump(const Duration(milliseconds: 40));
    const rest = 852 - 317.0;
    expect(start, greaterThan(rest + 200));
    expect(highest, lessThan(rest - 8));
    expect(top(), closeTo(rest, 0.5));
    await advance(tester, const Duration(milliseconds: 3500));
  });

  // 쫀득한 퇴장: 나가기 전에 살짝 위로 움찔했다가 화면 아래로 완전히 빠진다
  testWidgets(
    'character_rises_briefly_then_drops_off_screen_when_banner_leaves',
    (tester) async {
      await pumpOnPhone(tester, RoleBanner(isPolice: true, onDone: () {}));
      double top() => tester.getTopLeft(find.byType(SvgPicture)).dy;
      await advance(tester, const Duration(milliseconds: 3200));
      const rest = 852 - 317.0;
      expect(top(), closeTo(rest, 0.5));
      var highest = top();
      var lowest = top();
      // 머묾이 끝난 뒤 나가기(0.7초)가 끝나기 직전까지 본다
      for (var i = 0; i < 34; i++) {
        await tester.pump(const Duration(milliseconds: 20));
        if (top() < highest) highest = top();
        if (top() > lowest) lowest = top();
      }
      expect(highest, lessThan(rest - 5));
      expect(lowest, greaterThan(852));
      await advance(tester, const Duration(milliseconds: 500));
    },
  );

  // 제목은 동사구만 팀 색이다. 앞 줄까지 칠해지면 시안과 달라진다.
  testWidgets('police_title_colors_only_arrest_phrase_when_banner_shows', (
    tester,
  ) async {
    await pumpOnPhone(tester, RoleBanner(isPolice: true, onDone: () {}));
    await advance(tester, const Duration(milliseconds: 1200));
    final spans =
        (tester.widget<Text>(find.text('모두를 체포하라!')).textSpan! as TextSpan)
            .children!
            .cast<TextSpan>();
    final colored = spans.where((span) => span.style?.color == AppColors.blue);
    expect(colored.map((span) => span.text), ['체포하라!']);
    await advance(tester, const Duration(milliseconds: 3500));
  });

  // 번역에서 강조 문구가 제목과 어긋나면 강조가 조용히 사라진다
  test('title_accent_appears_in_title_when_any_locale_is_used', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      expect(l10n.startTitlePolice, contains(l10n.startTitlePoliceAccent));
      expect(l10n.startTitleRobber, contains(l10n.startTitleRobberAccent));
    }
  });

  testWidgets('robber_role_banner_shows_robber_role_when_game_starts', (
    tester,
  ) async {
    await pumpOnPhone(tester, RoleBanner(isPolice: false, onDone: () {}));
    await advance(tester, const Duration(milliseconds: 1200));
    expect(find.text('당신의 역할은 도둑입니다', findRichText: true), findsOneWidget);
    await advance(tester, const Duration(milliseconds: 3000));
  });

  // 영어 제목은 한국어보다 길어 작은 폰에서 넘치기 쉽다. 넘치면 오버플로 예외로 실패한다.
  testWidgets('english_role_banner_fits_when_phone_is_small', (tester) async {
    await pumpOnPhone(
      tester,
      RoleBanner(isPolice: true, onDone: () {}),
      size: const Size(360, 640),
      locale: const Locale('en'),
    );
    await advance(tester, const Duration(milliseconds: 1200));
    expect(find.text('Your role is Cop', findRichText: true), findsOneWidget);
    await advance(tester, const Duration(milliseconds: 3000));
  });

  testWidgets('robber_dispatch_banner_warns_robber_when_police_moves_out', (
    tester,
  ) async {
    var done = 0;
    await pumpOnPhone(
      tester,
      DispatchBanner(isPolice: false, onDone: () => done++),
    );
    await advance(tester, const Duration(milliseconds: 1200));
    expect(find.text('경찰이 출동했어요'), findsOneWidget);
    expect(find.text('조심!'), findsOneWidget);
    // 들어오기 0.9 + 머묾 1.7 + 나가기 0.7 = 3.3초 (프레임 간격 여유 포함 3.7초까지)
    await advance(tester, const Duration(milliseconds: 2500));
    expect(done, 1);
  });
}
