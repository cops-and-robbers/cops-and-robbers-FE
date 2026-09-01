import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/constants/game_team.dart';
import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/setup_playground_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/setup_prison_page.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

/// 구역 설정 화면의 다크는 **대기방에서 수정하러 들어왔을 때만** 적용된다.
///
/// 버그(#520): 다크 판정이 `editInitialShape != null`(초기 도형을 받았나)에 걸려
/// 있었는데, 생성 흐름도 되돌아올 때 초기 도형을 넘긴다(감옥은 첫 진입부터 넘긴다).
/// 그래서 도둑으로 참가 중인 사용자가 게임을 새로 만들면 구역 설정이 다크로 떴다.
const _shape = AreaShape.circle(
  center: GeoPoint(latitude: 37.5, longitude: 127.0),
  radiusInMeters: 300,
);

/// 감옥 화면은 `initialJail`이 없으면 기기 위치를 조회해(10초 타이머) 위젯 테스트가
/// 멈춘다. 다크 판정은 `initialJail` 유무와 무관하므로 채워서 연다.
Future<Color?> _scaffoldBg(WidgetTester tester, Widget page) async {
  // 설계 기준(375x812)보다 작은 기본 테스트 화면에선 지도 컨트롤이 넘쳐 실패한다
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  // 도둑으로 게임에 참가 중인 상태 — 역할 테마는 true
  container
      .read(gameParticipantNotifierProvider.notifier)
      .setGameInfo(gameId: 1, nickname: 'me', team: GameTeam.robber);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => page,
        ),
      ),
    ),
  );
  await tester.pump();

  return tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor;
}

void main() {
  testWidgets('생성 흐름의 플레이그라운드 — 초기 도형을 받아도 라이트', (tester) async {
    expect(
      await _scaffoldBg(
        tester,
        const SetupPlaygroundPage(editInitialShape: _shape),
      ),
      AppColors.white,
    );
  });

  testWidgets('대기방 수정의 플레이그라운드 — 도둑이면 다크', (tester) async {
    expect(
      await _scaffoldBg(
        tester,
        const SetupPlaygroundPage(editInitialShape: _shape, isInGameEdit: true),
      ),
      AppColors.black900,
    );
  });

  testWidgets('생성 흐름의 감옥 — editArgs를 받아도 라이트', (tester) async {
    expect(
      await _scaffoldBg(
        tester,
        const SetupPrisonPage(
          editArgs: PrisonEditArgs(playground: _shape, initialJail: _shape),
        ),
      ),
      AppColors.white,
    );
  });

  testWidgets('대기방 수정의 감옥 — 도둑이면 다크', (tester) async {
    expect(
      await _scaffoldBg(
        tester,
        const SetupPrisonPage(
          editArgs: PrisonEditArgs(playground: _shape, initialJail: _shape),
          isInGameEdit: true,
        ),
      ),
      AppColors.black900,
    );
  });
}
