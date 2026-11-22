import 'dart:async';

import 'package:cops_and_robbers/features/auth/presentation/providers/token_provider.dart';
import 'package:cops_and_robbers/features/lobby/data/datasources/lobby_stomp_datasource.dart';
import 'package:cops_and_robbers/features/lobby/data/models/lobby_event_dto.dart';
import 'package:cops_and_robbers/features/lobby/presentation/providers/lobby_provider.dart';
import 'package:cops_and_robbers/features/session/data/datasources/session_remote_datasource.dart';
import 'package:cops_and_robbers/features/session/data/models/game_settings_response.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';
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

/// HTTP 경계만 가짜 — `GET /api/games/{id}`가 돌려줄 본문을 테스트가 정한다.
class _FakeRemote extends Fake implements SessionRemoteDataSource {
  _FakeRemote(this.settingsJson);

  final Map<String, dynamic> settingsJson;

  @override
  Future<GameSettingsResponse> fetchGameSettings(int gameId) async =>
      GameSettingsResponse.fromJson(settingsJson);
}

const _base = <String, dynamic>{
  'roundDurationMinutes': 30,
  'locationRevealIntervalMinutes': 5,
  'policeWaitMinutes': 3,
  'maxParticipants': 10,
};

/// 대기방에 있는 참가자 폰 — 방장이 설정을 바꾼 뒤 서버가 [settingsJson]을 돌려준다.
Future<bool?> _radioAfterHostChangesSettings({
  required bool radioBefore,
  required Map<String, dynamic> settingsJson,
}) async {
  final fake = _FakeLobbyDatasource();
  final container = ProviderContainer(
    overrides: [
      lobbyStompDatasourceProvider.overrideWithValue(fake),
      tokenProviderProvider.overrideWithValue(_FakeTokenProvider()),
      sessionRemoteDataSourceProvider.overrideWithValue(
        _FakeRemote(settingsJson),
      ),
    ],
  );
  addTearDown(container.dispose);
  container.read(gameParticipantNotifierProvider.notifier)
    ..setGameInfo(gameId: 7, nickname: '참가자')
    ..initFromLobby(participantId: 5, radioEnabled: radioBefore);
  await container
      .read(lobbyNotifierProvider.notifier)
      .connectAndSubscribe(gameId: 7);

  fake.events.add(
    const LobbyEventDto(
      eventId: 'e1',
      gameId: 7,
      type: LobbyEventType.settingsUpdated,
      timestamp: '2026-11-23T10:00:00',
    ),
  );
  // 이벤트 전달 → 설정 재조회 → 참가자 상태 반영까지 기다린다
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);

  return container.read(gameParticipantNotifierProvider)?.radioEnabled;
}

void main() {
  // connectAndSubscribe가 .env의 소켓 주소를 읽으므로 dotenv 초기화
  setUpAll(() => dotenv.loadFromString(envString: '', isOptional: true));

  // 방장이 대기방에서 무전을 끈다 → 참가자 폰도 꺼진다
  test(
    'participant_radio_turns_off_when_host_turns_it_off_in_waiting_room',
    () async {
      expect(
        await _radioAfterHostChangesSettings(
          radioBefore: true,
          settingsJson: {..._base, 'radioEnabled': false},
        ),
        isFalse,
      );
    },
  );

  // 방장이 대기방에서 무전을 켠다 → 참가자 폰도 켜진다
  test(
    'participant_radio_turns_on_when_host_turns_it_on_in_waiting_room',
    () async {
      expect(
        await _radioAfterHostChangesSettings(
          radioBefore: false,
          settingsJson: {..._base, 'radioEnabled': true},
        ),
        isTrue,
      );
    },
  );

  // 무전 설정이 없는 구버전 서버: 설정 응답에 키가 없다 → 꺼짐
  test(
    'participant_radio_turns_off_when_settings_response_omits_field',
    () async {
      expect(
        await _radioAfterHostChangesSettings(
          radioBefore: true,
          settingsJson: _base,
        ),
        isFalse,
      );
    },
  );
}
