import 'package:cops_and_robbers/features/game/presentation/widgets/start/start_banners.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpOnPhone(WidgetTester tester, Widget banner) async {
  tester.view.physicalSize = const Size(393 * 3, 852 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, _) => MaterialApp(
        locale: const Locale('ko'),
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
  testWidgets('police_role_banner_shows_team_and_qr_mission_when_game_starts', (
    tester,
  ) async {
    var done = 0;
    await pumpOnPhone(tester, RoleBanner(isPolice: true, onDone: () => done++));
    await advance(tester, const Duration(milliseconds: 1200));
    expect(find.text('내 역할'), findsOneWidget);
    expect(find.text('경찰'), findsOneWidget);
    expect(find.text('도둑을 찾아 QR로 모두 체포하세요'), findsOneWidget);
    await advance(tester, const Duration(milliseconds: 3000));
    expect(done, 1);
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
