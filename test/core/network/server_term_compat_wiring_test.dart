import 'dart:convert';
import 'dart:io';

import 'package:cops_and_robbers/core/network/dio_client.dart';
import 'package:cops_and_robbers/core/storage/secure_token_storage.dart';
import 'package:cops_and_robbers/features/chat/data/datasources/chat_stomp_datasource.dart';
import 'package:cops_and_robbers/features/chat/data/models/chat_message_dto.dart';
import 'package:cops_and_robbers/features/game/data/datasources/game_event_stomp_datasource.dart';
import 'package:cops_and_robbers/features/game/data/models/game_event_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// 서버 팀 용어 호환(BE #254)이 실제 통신 경로에 걸려 있는지 본다.
/// 변환 규칙 자체는 `server_term_compat_test.dart`가 본다.
void main() {
  group('앱이 실제로 쓰는 HTTP 클라이언트', () {
    late HttpServer server;

    /// 강제 업데이트 뒤 서버(새 이름만)가 주는 참가자 목록.
    const stage4Participants = {
      'chasers': [
        {'participantId': 1, 'nickname': '경찰1', 'status': 'CHASER_WAITING'},
      ],
      'runners': <Object>[],
    };

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      dotenv.loadFromString(
        envString: 'API_BASE_URL=http://127.0.0.1:${server.port}',
      );
    });

    tearDown(() => server.close(force: true));

    Future<void> reply(HttpRequest request, int status, Object body) async {
      request.response
        ..statusCode = status
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(body));
      await request.response.close();
    }

    Future<SecureTokenStorage> storageWithTokens() async {
      final storage = SecureTokenStorage(storage: _FakeSecureStorage());
      await storage.saveTokens(
        accessToken: 'expired-access-token',
        refreshToken: 'valid-refresh-token',
      );
      return storage;
    }

    test('caller_gets_app_terms_when_stage4_server_answers', () async {
      server.listen((request) => reply(request, 200, stage4Participants));
      final dio = DioClient.create(
        tokenStorage: await storageWithTokens(),
        currentLanguageCode: () => 'ko',
        onForceLogout: ({String? messageKey}) async {},
        onRequiredTermsNotAgreed: () {},
      );

      final response = await dio.get<Map<String, dynamic>>(
        '/api/games/1/participants',
      );

      expect(
        (response.data!['police'] as List).single['status'],
        'POLICE_WAITING',
      );
    });

    test(
      'caller_gets_app_terms_when_request_is_retried_after_token_reissue',
      () async {
        // 게임 중 access token이 만료됐다. 첫 요청은 401, 재발급 뒤 재시도가 성공한다.
        server.listen((request) async {
          if (request.uri.path == '/api/auth/reissue') {
            return reply(request, 200, {
              'tokens': {
                'accessToken': 'new-access-token',
                'refreshToken': 'new-refresh-token',
              },
            });
          }
          final auth = request.headers.value('authorization');
          return auth == 'Bearer new-access-token'
              ? reply(request, 200, stage4Participants)
              : reply(request, 401, {'errorCode': 'EXPIRED_ACCESS_TOKEN'});
        });
        final dio = DioClient.create(
          tokenStorage: await storageWithTokens(),
          currentLanguageCode: () => 'ko',
          onForceLogout: ({String? messageKey}) async {},
          onRequiredTermsNotAgreed: () {},
        );

        final response = await dio.get<Map<String, dynamic>>(
          '/api/games/1/participants',
        );

        expect(
          (response.data!['police'] as List).single['status'],
          'POLICE_WAITING',
        );
      },
    );
  });

  group('팀 채팅 소켓', () {
    test('subscribes_new_team_path_when_police_joins_chat', () {
      final ds = _TestChatDatasource()..subscribeChat(1, 'police');

      expect(ds.client.subscriptions, [
        '/subscribe/game/1/chat/all',
        '/subscribe/game/1/chat/chaser',
      ]);
    });

    test(
      'message_arrives_in_app_terms_when_stage4_server_sends_runner_team',
      () async {
        // 도둑 팀원이 팀 채팅에 "RUNNER"라고 쳤다. 팀 값만 바뀌고 본문은 그대로다.
        final ds = _TestChatDatasource()..subscribeChat(1, 'robber');
        final received = ds.onMessage.first;

        ds.client.deliver(
          '/subscribe/game/1/chat/runner',
          jsonEncode({
            'id': 'm1',
            'gameId': 1,
            'sender': {
              'participantId': 5,
              'nickname': '창희도둑',
              'team': 'RUNNER',
            },
            'message': 'RUNNER',
            'timestamp': '2026-11-26T12:00:00',
            'scope': 'TEAM',
          }),
        );

        final ChatMessageDto dto = await received;
        expect(dto.sender.team, 'ROBBER');
        expect(dto.message, 'RUNNER');
      },
    );
  });

  group('게임 이벤트 소켓', () {
    test('subscribes_new_ping_path_when_robber_enters_game', () {
      final ds = _TestEventDatasource()..subscribeEvents(1, team: 'robber');

      expect(ds.client.subscriptions, [
        '/subscribe/game/1/system',
        '/subscribe/game/1/ping/runner',
      ]);
    });

    test(
      'move_start_event_is_recognized_when_stage4_server_sends_new_type',
      () async {
        final ds = _TestEventDatasource()..subscribeEvents(1, team: 'police');
        final received = ds.onEvent.first;

        ds.client.deliver(
          '/subscribe/game/1/system',
          jsonEncode({
            'type': 'CHASER_MOVE_START',
            'data': <String, dynamic>{},
          }),
        );

        expect((await received).type, GameEventType.policeMoveStart);
      },
    );
  });
}

/// 실 소켓(시스템 경계)만 대역으로 세운다. 구독 경로를 기록하고 [deliver]로
/// 서버가 보낸 프레임을 흘려 넣는다.
class _FakeStompClient implements StompClient {
  final subscriptions = <String>[];
  final _callbacks = <String, void Function(StompFrame)>{};

  @override
  StompUnsubscribe subscribe({
    required String destination,
    required void Function(StompFrame) callback,
    Map<String, String>? headers,
  }) {
    subscriptions.add(destination);
    _callbacks[destination] = callback;
    return ({Map<String, String>? unsubscribeHeaders}) {};
  }

  void deliver(String destination, String body) =>
      _callbacks[destination]!(StompFrame(command: 'MESSAGE', body: body));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestChatDatasource extends ChatStompDatasource {
  final client = _FakeStompClient();

  @override
  StompClient? get stompClient => client;

  @override
  StompConnectionState get currentState => StompConnectionState.connected;
}

class _TestEventDatasource extends GameEventStompDatasource {
  final client = _FakeStompClient();

  @override
  StompClient? get stompClient => client;

  @override
  StompConnectionState get currentState => StompConnectionState.connected;
}

class _FakeSecureStorage implements FlutterSecureStorage {
  final _store = <String, String>{};

  @override
  Future<void> write({
    required String key,
    String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => value == null ? _store.remove(key) : _store[key] = value;

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _store[key];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
