import 'dart:async';

import 'package:cops_and_robbers/features/community/data/datasources/community_chat_stomp_datasource.dart';
import 'package:cops_and_robbers/features/community/data/datasources/community_remote_datasource.dart';
import 'package:cops_and_robbers/features/community/data/models/community_chat_model.dart';
import 'package:cops_and_robbers/features/community/data/repositories/community_chat_repository_impl.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_event.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

const _postId = 42;

/// 시스템 경계(HTTP)만 대역으로 세운다 — Repository는 진짜 코드가 돈다.
class _FakeApi implements CommunityRemoteDataSource {
  _FakeApi({this.rooms, this.history, this.members});

  final CommunityChatRoomListResponseModel? rooms;
  final CommunityChatHistoryResponseModel? history;
  final CommunityChatMemberListResponseModel? members;

  Object? joinError;
  final calls = <String>[];
  int? lastCursor;

  @override
  Future<CommunityChatRoomListResponseModel> getChatRooms() async {
    calls.add('getChatRooms');
    return rooms!;
  }

  @override
  Future<void> joinChat(int postId) async {
    calls.add('joinChat');
    if (joinError != null) throw joinError!;
  }

  @override
  Future<void> leaveChat(int postId) async => calls.add('leaveChat');

  @override
  Future<CommunityChatHistoryResponseModel> getChatMessages(
    int postId, {
    int? cursor,
    int? size,
  }) async {
    calls.add('getChatMessages');
    lastCursor = cursor;
    return history!;
  }

  @override
  Future<CommunityChatMemberListResponseModel> getChatMembers(
    int postId,
  ) async {
    calls.add('getChatMembers');
    return members!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// 소켓 경계 대역 — 손으로 프레임을 흘려 넣는다.
class _FakeStomp implements CommunityChatStompDatasource {
  final messages =
      StreamController<CommunityChatMessageResponseModel>.broadcast();
  final connection = StreamController<StompConnectionState>.broadcast();
  final errors = StreamController<StompErrorInfo>.broadcast();

  final calls = <String>[];
  int? subscribedPostId;

  @override
  Stream<CommunityChatMessageResponseModel> get onChatMessage =>
      messages.stream;

  @override
  Stream<StompConnectionState> get onConnectionState => connection.stream;

  @override
  Stream<StompErrorInfo> get onError => errors.stream;

  @override
  void subscribeRoom(int postId) => subscribedPostId = postId;

  @override
  void connect(String wsUrl, String accessToken) => calls.add('connect');

  @override
  void disconnect() => calls.add('disconnect');

  @override
  void publishMessage(
    int postId, {
    required String messageKey,
    required String text,
  }) => calls.add('publish:$messageKey');

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

CommunityChatRepositoryImpl _repo(_FakeApi api, _FakeStomp stomp) =>
    CommunityChatRepositoryImpl(api, stomp, () async => 'token');

Map<String, dynamic> _messageJson({
  String messageType = 'TEXT',
  String message = '안녕하세요!',
}) => {
  'id': 1234,
  'messageKey': 'key-1',
  'senderId': 7,
  'senderNickname': '홍길동',
  'senderProfileIcon': 5,
  'message': message,
  'messageType': messageType,
  // UTC로 오는 값 — 화면은 기기 시간대로 그려야 한다.
  'createdAt': '2026-08-20T05:30:00Z',
};

void main() {
  // 소켓 연결이 ApiEndpoints.gameConnectionUrl(.env)을 읽는다 (게임 쪽 테스트와 동일).
  setUpAll(() => dotenv.loadFromString(envString: '', isOptional: true));

  group('getRooms', () {
    test(
      'maps_last_message_body_and_status_when_room_has_conversation',
      () async {
        final api = _FakeApi(
          rooms: CommunityChatRoomListResponseModel.fromJson({
            'chatRooms': [
              {
                'postId': _postId,
                'title': '같이 하실 분',
                'status': 'ENDED',
                'meetingAt': '2026-08-24T19:00:00+09:00',
                'memberCount': 8,
                'lastMessage': {
                  'id': 1234,
                  'senderNickname': '도둑쥐',
                  'senderProfileIcon': 3,
                  'message': '{"event":"JOIN"}',
                  'messageType': 'SYSTEM',
                  'createdAt': '2026-08-20T14:30:00+09:00',
                },
              },
            ],
          }),
        );

        final room = (await _repo(api, _FakeStomp()).getRooms()).single;

        expect(room.postId, _postId);
        expect(room.status, CommunityPostStatus.ended);
        expect(room.memberCount, 8);
        expect(
          room.lastMessage?.body,
          const CommunityChatMessageBody.system(CommunityChatSystemEvent.join),
        );
        expect(room.lastMessage?.senderNickname, '도둑쥐');
        expect(room.lastMessage?.senderProfileIcon, 3);
      },
    );

    test('leaves_last_message_null_when_room_has_no_conversation', () async {
      final api = _FakeApi(
        rooms: CommunityChatRoomListResponseModel.fromJson({
          'chatRooms': [
            {
              'postId': _postId,
              'title': '조용한 방',
              'status': 'RECRUITING',
              'meetingAt': '2026-08-24T19:00:00+09:00',
              'memberCount': 1,
            },
          ],
        }),
      );

      final room = (await _repo(api, _FakeStomp()).getRooms()).single;

      expect(room.lastMessage, isNull);
    });
  });

  group('join', () {
    test('swallows_already_joined_so_the_screen_can_just_enter', () async {
      // 서버가 `chatJoined`를 주지 않아 앱은 참여 여부를 미리 모른다. 무조건
      // 보내고 409면 이미 멤버라는 뜻이므로 입장으로 이어져야 한다.
      final api = _FakeApi()
        ..joinError = DioException(
          requestOptions: RequestOptions(path: '/join'),
          response: Response(
            requestOptions: RequestOptions(path: '/join'),
            statusCode: 409,
            data: {'errorCode': 'ALREADY_JOINED'},
          ),
        );

      await expectLater(_repo(api, _FakeStomp()).join(_postId), completes);
    });

    test('rethrows_when_the_room_is_full', () async {
      final api = _FakeApi()
        ..joinError = DioException(
          requestOptions: RequestOptions(path: '/join'),
          response: Response(
            requestOptions: RequestOptions(path: '/join'),
            statusCode: 400,
            data: {'errorCode': 'CHAT_ROOM_FULL'},
          ),
        );

      await expectLater(
        _repo(api, _FakeStomp()).join(_postId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getMessages', () {
    test('converts_created_at_to_local_time', () async {
      // 서버는 UTC로 준다 — 그대로 두면 한국에서 9시간 이르게 보인다.
      final api = _FakeApi(
        history: CommunityChatHistoryResponseModel.fromJson({
          'messages': [_messageJson()],
          'nextCursor': 1200,
          'hasNext': true,
        }),
      );

      final page = await _repo(api, _FakeStomp()).getMessages(_postId);

      expect(page.messages.single.createdAt.isUtc, false);
      expect(page.messages.single.senderProfileIcon, 5);
      expect(page.nextCursor, 1200);
      expect(page.hasNext, true);
    });
  });

  group('getMembers', () {
    test('maps_members_with_author_flag', () async {
      final api = _FakeApi(
        members: CommunityChatMemberListResponseModel.fromJson({
          'members': [
            {
              'userId': 7,
              'nickname': '무서운경찰관',
              'profileIcon': 2,
              'isAuthor': true,
            },
          ],
        }),
      );

      final member = (await _repo(
        api,
        _FakeStomp(),
      ).getMembers(_postId)).single;

      expect(member.userId, 7);
      expect(member.nickname, '무서운경찰관');
      expect(member.profileIcon, 2);
      expect(member.isAuthor, true);
    });
  });

  group('connect', () {
    test('merges_messages_connection_and_errors_into_one_stream', () async {
      final stomp = _FakeStomp();
      final repo = _repo(_FakeApi(), stomp);

      final events = <CommunityChatEvent>[];
      repo.connect(_postId).listen(events.add);
      await Future<void>.delayed(Duration.zero);

      stomp.connection.add(StompConnectionState.connected);
      stomp.messages.add(
        CommunityChatMessageResponseModel.fromJson(_messageJson()),
      );
      stomp.errors.add(
        const StompErrorInfo(
          errorCode: 'NOT_A_CHAT_MEMBER',
          title: '',
          status: 403,
          detail: '',
          instance: 'STOMP',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, [
        const CommunityChatEvent.connection(
          CommunityChatConnectionState.connected,
        ),
        isA<CommunityChatMessageEvent>(),
        const CommunityChatEvent.error('NOT_A_CHAT_MEMBER'),
      ]);
      expect(stomp.subscribedPostId, _postId);
    });
  });

  group('disconnect', () {
    test('ignores_a_room_it_no_longer_owns', () async {
      // 방 A에서 방 B로 옮기면 A의 provider가 B보다 늦게 정리될 수 있다.
      // 방 번호를 확인하지 않으면 그때 B의 소켓이 끊긴다.
      final stomp = _FakeStomp();
      final repo = _repo(_FakeApi(), stomp);

      repo.connect(_postId);
      repo.connect(43);
      await repo.disconnect(_postId);

      expect(stomp.calls, isNot(contains('disconnect')));
    });

    test('closes_the_socket_when_the_room_still_owns_it', () async {
      final stomp = _FakeStomp();
      final repo = _repo(_FakeApi(), stomp);

      repo.connect(_postId);
      await repo.disconnect(_postId);

      expect(stomp.calls, contains('disconnect'));
    });
  });
}
