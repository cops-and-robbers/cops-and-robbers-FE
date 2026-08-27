import 'package:cops_and_robbers/features/community/data/models/community_chat_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// 백엔드 v2.25.0이 보내는 형태 — `GET /api/community-posts/chat/rooms`의 원소.
Map<String, dynamic> _roomJson() => {
  'postId': 42,
  'title': '같이 경찰과 도둑 하실 분!',
  'status': 'RECRUITING',
  'meetingAt': '2026-08-24T19:00:00+09:00',
  'memberCount': 8,
  'lastMessage': {
    'id': 1234,
    'senderNickname': '도둑쥐',
    'senderProfileIcon': 3,
    'message': '다들 고생하셨어요',
    'messageType': 'TEXT',
    'createdAt': '2026-08-20T14:30:00+09:00',
  },
};

/// `GET /api/community-posts/{postId}/chat/messages`의 원소.
Map<String, dynamic> _messageJson() => {
  'id': 1234,
  'messageKey': '3f9a1c02-5b7e-4d61-9a83-0c2e4f8b1d67',
  'senderId': 7,
  'senderNickname': '홍길동',
  'senderProfileIcon': 5,
  'message': '안녕하세요!',
  'messageType': 'TEXT',
  'createdAt': '2026-08-20T14:30:00+09:00',
};

/// `GET /api/community-posts/{postId}/chat/members`의 원소 (v2.25.0 신규).
Map<String, dynamic> _memberJson() => {
  'userId': 7,
  'nickname': '무서운경찰관',
  'profileIcon': 1,
  'isAuthor': true,
};

void main() {
  group('CommunityChatRoomResponseModel', () {
    test('parses_last_message_when_room_has_conversation', () {
      final model = CommunityChatRoomResponseModel.fromJson(_roomJson());

      expect(model.postId, 42);
      expect(model.title, '같이 경찰과 도둑 하실 분!');
      expect(model.memberCount, 8);
      expect(model.lastMessage?.id, 1234);
      expect(model.lastMessage?.message, '다들 고생하셨어요');
    });

    test('leaves_last_message_null_when_room_has_no_conversation', () {
      // 아직 아무도 말하지 않은 방. 목록에서 맨 뒤로 밀린다.
      final json = _roomJson()..['lastMessage'] = null;

      expect(CommunityChatRoomResponseModel.fromJson(json).lastMessage, isNull);
    });

    test('parses_last_message_sender_when_backend_sends_it', () {
      // v2.25.0(BE #173)에서 붙은 값이다 — 이게 있어야 미리보기가 타입별 일반
      // 문구 대신 "OO님이 참여했어요"로 나온다.
      final last = CommunityChatRoomResponseModel.fromJson(
        _roomJson(),
      ).lastMessage;

      expect(last?.senderNickname, '도둑쥐');
      expect(last?.senderProfileIcon, 3);
    });

    test('leaves_last_message_sender_null_when_backend_omits_it', () {
      // 스키마에 required가 없다 — 구버전 서버나 누락 한 건에 목록 전체가
      // 날아가지 않게 nullable로 받는다 (LSN-0009).
      final json = _roomJson()
        ..['lastMessage'] = {
          'id': 1234,
          'message': '다들 고생하셨어요',
          'messageType': 'TEXT',
          'createdAt': '2026-08-20T14:30:00+09:00',
        };

      final last = CommunityChatRoomResponseModel.fromJson(json).lastMessage;

      expect(last?.senderNickname, isNull);
      expect(last?.senderProfileIcon, isNull);
    });

    test('keeps_status_as_wire_string_when_meeting_date_has_passed', () {
      // 도메인 enum 변환은 Repository 경계에서 한다 — 모르는 값이 와도 DTO는
      // 깨지지 않고, `ENDED` 같은 신규 값이 목록 한 장을 날리지 않는다.
      final json = _roomJson()..['status'] = 'ENDED';

      expect(CommunityChatRoomResponseModel.fromJson(json).status, 'ENDED');
    });

    test('ignores_unknown_fields_when_backend_adds_extras', () {
      // 서버가 필드를 더해도 앱이 먼저 깨지면 안 된다 — 실제로 v2.25.0이
      // `senderProfileIcon`을 이렇게 더했다.
      final json = _roomJson()..['unreadCount'] = 3;

      expect(
        () => CommunityChatRoomResponseModel.fromJson(json),
        returnsNormally,
      );
    });
  });

  group('CommunityChatRoomListResponseModel', () {
    test('parses_room_list_when_user_joined_rooms', () {
      final model = CommunityChatRoomListResponseModel.fromJson({
        'chatRooms': [_roomJson()],
      });

      expect(model.chatRooms.single.postId, 42);
    });

    test('leaves_rooms_empty_when_field_absent', () {
      // 참여한 방이 없을 때 서버가 빈 배열을 주는지 키를 빼는지 스키마가 말하지
      // 않는다. 없으면 빈 목록으로 받는다 (LSN-0009).
      final model = CommunityChatRoomListResponseModel.fromJson(
        <String, dynamic>{},
      );

      expect(model.chatRooms, isEmpty);
    });
  });

  group('CommunityChatHistoryResponseModel', () {
    test('parses_next_cursor_when_more_messages_remain', () {
      final model = CommunityChatHistoryResponseModel.fromJson({
        'messages': [_messageJson()],
        'nextCursor': 1200,
        'hasNext': true,
      });

      expect(model.messages.single.messageKey, isNotEmpty);
      expect(model.nextCursor, 1200);
      expect(model.hasNext, true);
    });

    test('leaves_next_cursor_null_when_last_page_reached', () {
      // 서버는 `hasNext`가 true일 때만 `nextCursor`를 싣는다.
      final model = CommunityChatHistoryResponseModel.fromJson({
        'messages': <Map<String, dynamic>>[],
        'hasNext': false,
      });

      expect(model.messages, isEmpty);
      expect(model.nextCursor, isNull);
      expect(model.hasNext, false);
    });
  });

  group('CommunityChatMessageResponseModel', () {
    test('parses_sender_and_body_when_message_is_text', () {
      final model = CommunityChatMessageResponseModel.fromJson(_messageJson());

      expect(model.id, 1234);
      expect(model.senderId, 7);
      expect(model.senderNickname, '홍길동');
      expect(model.senderProfileIcon, 5);
      expect(model.message, '안녕하세요!');
      expect(model.messageType, 'TEXT');
    });

    test('leaves_sender_profile_icon_null_when_backend_omits_it', () {
      // 스키마에 required가 없다 — 구버전 서버나 누락 한 건에 대화 한 페이지가
      // 날아가지 않게 nullable로 받고, 화면이 기본 아이콘으로 물러선다 (LSN-0009).
      final json = _messageJson()..remove('senderProfileIcon');

      expect(
        CommunityChatMessageResponseModel.fromJson(json).senderProfileIcon,
        isNull,
      );
    });

    test('parses_json_body_as_raw_string_when_message_is_system', () {
      // 본문 해석은 `communityChatMessageBodyFromWire`가 한다 — DTO는 서버가 준
      // 문자열을 그대로 들고만 있는다.
      final json = _messageJson()
        ..['message'] = '{"event":"JOIN"}'
        ..['messageType'] = 'SYSTEM';

      final model = CommunityChatMessageResponseModel.fromJson(json);

      expect(model.message, '{"event":"JOIN"}');
      expect(model.messageType, 'SYSTEM');
    });

    test('leaves_sender_nickname_null_when_backend_omits_it', () {
      // 스키마에 required가 없다 — non-null로 못 박으면 서버가 한 건만 빠뜨려도
      // 대화 한 페이지가 통째로 날아간다 (LSN-0009).
      final json = _messageJson()..['senderNickname'] = null;

      expect(
        CommunityChatMessageResponseModel.fromJson(json).senderNickname,
        isNull,
      );
    });
  });

  group('CommunityChatMemberListResponseModel', () {
    test('parses_member_with_author_flag_when_room_has_members', () {
      final model = CommunityChatMemberListResponseModel.fromJson({
        'members': [_memberJson()],
      });

      final member = model.members.single;
      expect(member.userId, 7);
      expect(member.nickname, '무서운경찰관');
      expect(member.profileIcon, 1);
      expect(member.isAuthor, true);
    });

    test('treats_member_as_not_author_when_flag_absent', () {
      // 방장 표시가 없으면 일반 멤버로 본다 — 없는 권한을 열어 주는 쪽으로
      // 물러서면 안 된다(나가기 버튼 노출이 여기서 갈린다).
      final json = _memberJson()..remove('isAuthor');

      expect(
        CommunityChatMemberListResponseModel.fromJson({
          'members': [json],
        }).members.single.isAuthor,
        false,
      );
    });

    test('leaves_members_empty_when_field_absent', () {
      expect(
        CommunityChatMemberListResponseModel.fromJson(
          <String, dynamic>{},
        ).members,
        isEmpty,
      );
    });
  });
}
