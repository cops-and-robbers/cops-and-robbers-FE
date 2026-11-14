import 'dart:async';

import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/token_provider.dart';
import 'package:cops_and_robbers/features/lobby/data/datasources/lobby_stomp_datasource.dart';
import 'package:cops_and_robbers/features/lobby/data/models/lobby_event_dto.dart';
import 'package:cops_and_robbers/features/lobby/presentation/providers/lobby_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 소켓 대신 테스트가 이벤트를 밀어 넣는 로비 datasource (시스템 경계만 대체)
class _FakeLobbyDatasource extends LobbyStompDatasource {
  final events = StreamController<LobbyEventDto>.broadcast();

  @override
  Stream<LobbyEventDto> get onEvent => events.stream;

  @override
  void connect(String wsUrl, String accessToken) {}

  @override
  void subscribeLobby(int gameId) {}
}

class _FakeTokenProvider implements TokenProvider {
  @override
  Future<String?> getAccessToken() async => 'test-token';

  @override
  Future<String?> refreshAccessTokenIfNeeded() async => 'test-token';
}

void main() {
  // connectAndSubscribe가 .env의 소켓 주소를 읽으므로 dotenv 초기화
  setUpAll(() => dotenv.loadFromString(envString: '', isOptional: true));

  test(
    'participant_sees_hide_and_seek_when_host_changes_mode_in_waiting_room',
    () async {
      final fake = _FakeLobbyDatasource();
      final container = ProviderContainer(
        overrides: [
          lobbyStompDatasourceProvider.overrideWithValue(fake),
          tokenProviderProvider.overrideWithValue(_FakeTokenProvider()),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(gameParticipantNotifierProvider.notifier)
          .setGameInfo(gameId: 7, nickname: '참가자');
      await container
          .read(lobbyNotifierProvider.notifier)
          .connectAndSubscribe(gameId: 7);

      // 방장이 경찰과 도둑 → 술래잡기로 바꿨다 (BE LobbyModeUpdatedData)
      fake.events.add(
        const LobbyEventDto(
          eventId: 'e1',
          gameId: 7,
          type: LobbyEventType.modeUpdated,
          timestamp: '2026-11-14T10:00:00',
          data: {'gameMode': 'TAG', 'areaData': <String, dynamic>{}},
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(gameParticipantNotifierProvider)?.gameMode,
        GameMode.hideAndSeek,
      );
    },
  );
}
