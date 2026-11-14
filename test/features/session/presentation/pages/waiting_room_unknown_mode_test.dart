import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/lobby/data/datasources/lobby_stomp_datasource.dart';
import 'package:cops_and_robbers/features/lobby/data/models/lobby_event_dto.dart';
import 'package:cops_and_robbers/features/lobby/presentation/providers/lobby_provider.dart';
import 'package:cops_and_robbers/features/session/data/models/game_settings_response.dart';
import 'package:cops_and_robbers/features/session/data/models/lobby_info_response.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/waiting_room_page.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'creation_flow_fakes.dart';

/// STOMP 경계만 대체 — 연결 요청이 오면 바로 연결된 것으로 알리고, 해제 호출을 센다.
class _FakeLobby extends LobbyNotifier {
  int disconnects = 0;

  @override
  LobbyState build() => const LobbyState();

  @override
  Future<void> connectAndSubscribe({
    required int gameId,
    void Function(LobbyEventDto event)? onGameStart,
  }) async {
    state = state.copyWith(connectionState: StompConnectionState.connected);
  }

  @override
  void disconnectLobby() => disconnects++;
}

GameSettingsResponse _settings(GameMode mode) => GameSettingsResponse(
  roundDurationMinutes: 30,
  locationRevealIntervalMinutes: 5,
  policeWaitMinutes: 5,
  maxParticipants: 10,
  gameMode: mode,
);

const _lobby = LobbyInfoResponse(
  myParticipantId: 2,
  hostParticipantId: 1,
  participants: [
    LobbyParticipantInfo(participantId: 1, nickname: '방장', team: 'POLICE'),
    LobbyParticipantInfo(participantId: 2, nickname: '나', team: 'ROBBER'),
  ],
);

Future<({_FakeLobby lobby, ProviderContainer container})> _enter(
  WidgetTester tester, {
  required GameMode roomMode,
}) async {
  SharedPreferences.setMockInitialValues({});
  final oldLocation = GeolocatorPlatform.instance;
  GeolocatorPlatform.instance = FakeLocation();
  addTearDown(() => GeolocatorPlatform.instance = oldLocation);
  tester.view.physicalSize = const Size(393, 852) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final lobby = _FakeLobby();
  final container = ProviderContainer(
    overrides: [
      lobbyNotifierProvider.overrideWith(() => lobby),
      fetchLobbyInfoProvider(7).overrideWith((ref) async => _lobby),
      fetchGameSettingsProvider(
        7,
      ).overrideWith((ref) async => _settings(roomMode)),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: '/room',
    routes: [
      GoRoute(
        path: '/room',
        builder: (_, _) => const WaitingRoomPage(sessionId: '7'),
      ),
      GoRoute(
        path: RoutePaths.forceUpdate,
        builder: (_, _) => const Scaffold(body: Text('업데이트 안내')),
      ),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => MaterialApp.router(
          routerConfig: router,
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    ),
  );
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  return (lobby: lobby, container: container);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('waiting_room_opens_force_update_when_room_mode_is_unknown', (
    tester,
  ) async {
    final r = await _enter(tester, roomMode: GameMode.unknown);

    expect(find.text('업데이트 안내'), findsOneWidget);
    expect(r.lobby.disconnects, 1);
  });

  testWidgets(
    'guest_goes_to_force_update_when_host_switches_to_mode_this_app_does_not_know',
    (tester) async {
      final r = await _enter(tester, roomMode: GameMode.copsAndRobbers);
      expect(find.text('업데이트 안내'), findsNothing);

      // 로비 MODE_UPDATED 핸들러가 하는 일과 같다
      r.container
          .read(gameParticipantNotifierProvider.notifier)
          .setGameMode(GameMode.unknown);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('업데이트 안내'), findsOneWidget);
      expect(r.lobby.disconnects, 1);
    },
  );
}
