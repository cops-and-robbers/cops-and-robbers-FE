import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/core/widgets/buttons/previous_button.dart';
import 'package:dio/dio.dart';
import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/session/data/datasources/session_remote_datasource.dart';
import 'package:cops_and_robbers/features/session/data/models/game_create_request_model.dart';
import 'package:cops_and_robbers/features/session/data/models/game_mode_update_request_model.dart';
import 'package:cops_and_robbers/features/session/data/models/game_settings_response.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/game_settings_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/mode_change_page.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/widgets/radio_toggle_card.dart';
import 'package:cops_and_robbers/features/session/presentation/widgets/shrink_toggle_card.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'creation_flow_fakes.dart';

/// HTTP 경계만 가짜 — PUT /settings 본문을 기록한다.
class _FakeRemote extends Fake implements SessionRemoteDataSource {
  final sent = <GameSettingsRequestModel>[];
  final modeSent = <GameModeUpdateRequestModel>[];
  DioException? modeError;

  @override
  Future<void> updateGameMode(
    int gameId,
    GameModeUpdateRequestModel request,
  ) async {
    modeSent.add(request);
    if (modeError != null) throw modeError!;
  }

  @override
  Future<GameSettingsResponse> updateGameSettings(
    int gameId,
    GameSettingsRequestModel request,
  ) async {
    sent.add(request);
    return _settings(
      request.shrinkFinalRadiusInMeters,
      radio: request.radioEnabled,
    );
  }
}

GameSettingsResponse _settings(int? shrink, {bool radio = false}) =>
    GameSettingsResponse(
      roundDurationMinutes: 30,
      locationRevealIntervalMinutes: 5,
      policeWaitMinutes: 5,
      maxParticipants: 10,
      shrinkFinalRadiusInMeters: shrink,
      radioEnabled: radio,
    );

// 설정 화면에 스위치가 둘(구역 축소·무전)이라 카드로 좁혀 찾는다 (#723)
final _shrinkSwitch = find.descendant(
  of: find.byType(ShrinkToggleCard),
  matching: find.byType(Switch),
);
final _radioSwitch = find.descendant(
  of: find.byType(RadioToggleCard),
  matching: find.byType(Switch),
);

/// [_pump]가 만든 화면의 Riverpod 컨테이너 — 참가자 상태를 읽을 때 쓴다.
ProviderContainer _containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(GameSettingsPage)));

const _c = GeoPoint(latitude: 37.55, longitude: 127.07);
const _area = GameAreaEntity(
  playground: AreaShape.circle(center: _c, radiusInMeters: 500),
  jail: AreaShape.circle(center: _c, radiusInMeters: 100),
);

Future<_FakeRemote> _pump(
  WidgetTester tester, {
  DioException? modeError,
  required bool isHost,
  int? shrink,
  GameMode mode = GameMode.copsAndRobbers,
  bool isEventGame = false,
  bool radio = false,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final remote = _FakeRemote()..modeError = modeError;
  final container = ProviderContainer(
    overrides: [
      sessionRemoteDataSourceProvider.overrideWithValue(remote),
      fetchGameSettingsProvider(
        7,
      ).overrideWith((ref) async => _settings(shrink, radio: radio)),
      fetchGameAreaProvider(7).overrideWith((ref) async => _area),
    ],
  );
  addTearDown(container.dispose);
  container
      .read(gameParticipantNotifierProvider.notifier)
      .setGameInfo(
        gameId: 7,
        nickname: '방장',
        isHost: isHost,
        gameMode: mode,
        isEventGame: isEventGame,
      );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => MaterialApp.router(
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // 설정 → 모드 변경 화면 이동만 실제 라우트 이름으로 재현한다
          routerConfig: GoRouter(
            initialLocation: '/waiting-room/7/game-settings',
            routes: [
              GoRoute(
                path: '/waiting-room/:sessionId/game-settings',
                builder: (_, _) => const GameSettingsPage(sessionId: '7'),
                routes: [
                  GoRoute(
                    path: 'mode',
                    name: RoutePaths.gameSettingsModeName,
                    builder: (_, state) =>
                        ModeChangePage(current: state.extra! as GameMode),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return remote;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('host_turning_shrink_on_in_waiting_room_saves_200m', (
    tester,
  ) async {
    // 500m 구역·감옥 100m 대기방에서 방장이 구역 축소를 켠다
    final remote = await _pump(tester, isHost: true);

    await tester.tap(_shrinkSwitch);
    await tester.pumpAndSettle();

    expect(remote.sent.single.shrinkFinalRadiusInMeters, 200);
    expect(remote.sent.single.roundDurationMinutes, 30);
  });

  testWidgets('guest_cannot_toggle_shrink', (tester) async {
    final remote = await _pump(tester, isHost: false, shrink: 200);

    expect(tester.widget<Switch>(_shrinkSwitch).value, isTrue);
    expect(tester.widget<Switch>(_shrinkSwitch).onChanged, isNull);
    expect(remote.sent, isEmpty);
  });

  // 방장이 대기방에서 무전을 켠다 — 켜 둔 구역 축소(200m)는 그대로 실린다
  testWidgets(
    'host_turning_radio_on_in_waiting_room_saves_radio_on_and_keeps_shrink',
    (tester) async {
      final remote = await _pump(tester, isHost: true, shrink: 200);

      await tester.tap(_radioSwitch);
      await tester.pumpAndSettle();

      expect(
        (
          remote.sent.single.radioEnabled,
          remote.sent.single.shrinkFinalRadiusInMeters,
        ),
        (true, 200),
      );
    },
  );

  // 방장이 대기방에서 켜 둔 무전을 다시 끈다
  testWidgets('host_turning_radio_off_in_waiting_room_saves_radio_off', (
    tester,
  ) async {
    final remote = await _pump(tester, isHost: true, radio: true);

    await tester.tap(_radioSwitch);
    await tester.pumpAndSettle();

    expect(remote.sent.single.radioEnabled, isFalse);
  });

  // 무전을 켠 방에서 방장이 구역 축소를 켠다 — 무전이 꺼지면 안 된다
  testWidgets('host_turning_shrink_on_keeps_radio_on', (tester) async {
    final remote = await _pump(tester, isHost: true, radio: true);

    await tester.tap(_shrinkSwitch);
    await tester.pumpAndSettle();

    expect(
      (
        remote.sent.single.radioEnabled,
        remote.sent.single.shrinkFinalRadiusInMeters,
      ),
      (true, 200),
    );
  });

  // 참가자는 방장이 켠 무전을 보기만 한다
  testWidgets('guest_sees_radio_on_but_cannot_toggle', (tester) async {
    final remote = await _pump(tester, isHost: false, radio: true);

    expect(tester.widget<Switch>(_radioSwitch).value, isTrue);
    expect(tester.widget<Switch>(_radioSwitch).onChanged, isNull);
    expect(remote.sent, isEmpty);
  });

  // 방장이 무전을 켠 직후 게임을 시작해도 방장 폰에 무전 버튼이 나오도록,
  // 로비 알림을 기다리지 않고 방장 폰의 참가자 상태도 켜진다
  testWidgets('host_participant_radio_turns_on_right_after_saving', (
    tester,
  ) async {
    await _pump(tester, isHost: true);
    expect(
      _containerOf(tester).read(gameParticipantNotifierProvider)?.radioEnabled,
      isFalse,
    );

    await tester.tap(_radioSwitch);
    await tester.pumpAndSettle();

    expect(
      _containerOf(tester).read(gameParticipantNotifierProvider)?.radioEnabled,
      isTrue,
    );
  });

  // 무전 카드는 구역 축소 카드 바로 아래, 구역 카드 위다
  testWidgets('radio_card_sits_between_shrink_card_and_zone_card', (
    tester,
  ) async {
    await _pump(tester, isHost: true);

    final radioTop = tester.getTopLeft(find.byType(RadioToggleCard)).dy;
    expect(
      radioTop,
      greaterThan(tester.getBottomLeft(find.byType(ShrinkToggleCard)).dy),
    );
    expect(radioTop, lessThan(tester.getTopLeft(find.text('플레이그라운드')).dy));
  });

  // 이벤트 게임은 무전이 없다 — 눌러도 소용없는 스위치를 보이지 않는다
  testWidgets('radio_card_is_hidden_when_room_is_event_game', (tester) async {
    await _pump(tester, isHost: true, isEventGame: true);

    expect(find.byType(ShrinkToggleCard), findsOneWidget);
    expect(find.byType(RadioToggleCard), findsNothing);
  });

  testWidgets('shrink_card_sits_above_zone_card', (tester) async {
    await _pump(tester, isHost: true);
    expect(
      tester.getTopLeft(find.text('구역 축소')).dy,
      lessThan(tester.getTopLeft(find.text('플레이그라운드')).dy),
    );
  });

  testWidgets('mode_row_sits_above_shrink_card', (tester) async {
    await _pump(tester, isHost: true);
    expect(find.text('경찰과 도둑'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('모드')).dy,
      lessThan(tester.getTopLeft(find.text('구역 축소')).dy),
    );
  });

  testWidgets(
    'host_switching_500m_room_to_hide_and_seek_sends_area_without_jail_and_row_updates',
    (tester) async {
      final remote = await _pump(tester, isHost: true);

      await tester.tap(find.text('경찰과 도둑'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('술래잡기'));
      await tester.pump();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      final sent = remote.modeSent.single;
      expect(sent.gameMode, GameMode.hideAndSeek);
      expect(sent.area.toJson().containsKey('jailCenter'), isFalse);
      expect(find.text('술래잡기'), findsOneWidget);
    },
  );

  testWidgets(
    'host_sees_reason_and_mode_stays_when_server_rejects_mode_change',
    (tester) async {
      // 서버가 모드 변경을 거절(400 JAIL_AREA_NOT_ALLOWED)하면 사유를 보이고 모드는 그대로다
      final req = RequestOptions(path: '/api/games/7/mode');
      final remote = await _pump(
        tester,
        isHost: true,
        modeError: DioException(
          requestOptions: req,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: req,
            statusCode: 400,
            data: {'errorCode': 'JAIL_AREA_NOT_ALLOWED'},
          ),
        ),
      );

      await tester.tap(find.text('경찰과 도둑'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('술래잡기'));
      await tester.pump();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(remote.modeSent, isNotEmpty);
      expect(find.text('이 게임 모드에는 감옥 구역이 없어요'), findsOneWidget);
      expect(find.text('경찰과 도둑'), findsOneWidget);
      expect(find.text('술래잡기'), findsNothing);
      // 스낵바 자동 닫힘 타이머를 비운다
      await tester.pump(const Duration(seconds: 4));
    },
  );

  testWidgets(
    'host_tapping_mode_row_opens_mode_change_page_with_save_disabled',
    (tester) async {
      // 방장이 모드 행을 누르면 설정 수정처럼 전체 화면이 열리고, 지금 모드 그대로면 저장할 게 없다
      final remote = await _pump(tester, isHost: true);

      await tester.tap(find.text('경찰과 도둑'));
      await tester.pumpAndSettle();

      expect(find.text('모드 변경'), findsOneWidget);
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      expect(find.byType(ModeChangePage), findsOneWidget);
      expect(remote.modeSent, isEmpty);
    },
  );

  testWidgets('host_leaving_mode_change_page_with_back_keeps_mode', (
    tester,
  ) async {
    // 모드를 골랐다가 뒤로 가면 아무것도 보내지 않는다
    final remote = await _pump(tester, isHost: true);

    await tester.tap(find.text('경찰과 도둑'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('술래잡기'));
    await tester.pump();
    await tester.tap(find.byType(PreviousButton));
    await tester.pumpAndSettle();

    expect(remote.modeSent, isEmpty);
    expect(find.text('경찰과 도둑'), findsOneWidget);
  });

  testWidgets('guest_tapping_mode_row_does_not_open_mode_choice', (
    tester,
  ) async {
    await _pump(tester, isHost: false);

    await tester.tap(find.text('경찰과 도둑'));
    await tester.pumpAndSettle();

    expect(find.byType(ModeChangePage), findsNothing);
  });

  testWidgets('host_cannot_change_mode_when_room_is_event_game', (
    tester,
  ) async {
    // 이벤트 게임은 서버가 술래잡기 변경을 거절하므로 선택지를 열지 않는다
    await _pump(tester, isHost: true, isEventGame: true);

    await tester.tap(find.text('경찰과 도둑'));
    await tester.pumpAndSettle();

    expect(find.byType(ModeChangePage), findsNothing);
  });
}
