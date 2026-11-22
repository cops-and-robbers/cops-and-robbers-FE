import 'package:cops_and_robbers/features/lobby/data/datasources/lobby_stomp_datasource.dart';
import 'package:cops_and_robbers/features/lobby/data/models/lobby_event_dto.dart';
import 'package:cops_and_robbers/features/lobby/presentation/providers/lobby_provider.dart';
import 'package:cops_and_robbers/features/session/data/models/game_settings_response.dart';
import 'package:cops_and_robbers/features/session/data/models/lobby_info_response.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/waiting_room_page.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'creation_flow_fakes.dart';

/// STOMP 경계만 대체 — 연결 요청이 오면 바로 연결된 것으로 알린다.
class _FakeLobby extends LobbyNotifier {
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
  void disconnectLobby() {}
}

const _lobby = LobbyInfoResponse(
  myParticipantId: 2,
  hostParticipantId: 1,
  participants: [
    LobbyParticipantInfo(participantId: 1, nickname: '방장', team: 'POLICE'),
    LobbyParticipantInfo(participantId: 2, nickname: '나', team: 'POLICE'),
  ],
);

/// 앱을 다시 켜 대기방으로 돌아온다 — 참가자 상태는 비어 있고 서버 조회로 채운다.
Future<ProviderContainer> _reopenWaitingRoom(
  WidgetTester tester, {
  required Map<String, dynamic> settingsJson,
}) async {
  SharedPreferences.setMockInitialValues({});
  final oldLocation = GeolocatorPlatform.instance;
  GeolocatorPlatform.instance = FakeLocation();
  addTearDown(() => GeolocatorPlatform.instance = oldLocation);
  tester.view.physicalSize = const Size(393, 852) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      lobbyNotifierProvider.overrideWith(_FakeLobby.new),
      fetchLobbyInfoProvider(7).overrideWith((ref) async => _lobby),
      fetchGameSettingsProvider(7).overrideWith(
        (ref) async => GameSettingsResponse.fromJson(settingsJson),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/room',
            routes: [
              GoRoute(
                path: '/room',
                builder: (_, _) => const WaitingRoomPage(sessionId: '7'),
              ),
            ],
          ),
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
  return container;
}

const _base = <String, dynamic>{
  'roundDurationMinutes': 30,
  'locationRevealIntervalMinutes': 5,
  'policeWaitMinutes': 5,
  'maxParticipants': 10,
};

void main() {
  setUpAll(loadAppFonts);

  // 방장이 무전을 켠 대기방에서 앱이 죽었다가 다시 켜졌다
  testWidgets('waiting_room_restores_radio_on_when_app_is_reopened_in_lobby', (
    tester,
  ) async {
    final container = await _reopenWaitingRoom(
      tester,
      settingsJson: {..._base, 'radioEnabled': true},
    );

    expect(
      container.read(gameParticipantNotifierProvider)?.radioEnabled,
      isTrue,
    );
  });

  // 방장이 무전을 켠 적 없는 방(응답에 키 없음)으로 돌아왔다
  testWidgets('waiting_room_keeps_radio_off_when_host_never_turned_it_on', (
    tester,
  ) async {
    final container = await _reopenWaitingRoom(tester, settingsJson: _base);

    expect(
      container.read(gameParticipantNotifierProvider)?.radioEnabled,
      isFalse,
    );
  });
}
