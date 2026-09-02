import 'package:cops_and_robbers/features/community/data/models/community_wire.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_sort_option.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommunityPostStatus 와이어 매핑', () {
    test('round_trips_every_status_through_wire_string', () {
      for (final status in CommunityPostStatus.values) {
        expect(communityPostStatusFromWire(status.wireValue), status);
      }
    });

    test('maps_server_enum_names_exactly', () {
      // 서버 계약 고정 — 값이 바뀌면 여기서 먼저 깨져야 한다.
      expect(CommunityPostStatus.recruiting.wireValue, 'RECRUITING');
      expect(CommunityPostStatus.completed.wireValue, 'COMPLETED');
      expect(CommunityPostStatus.ended.wireValue, 'ENDED');
    });

    test('maps_ended_to_ended_status_when_meeting_date_has_passed', () {
      // 서버가 저장하지 않고 조회 시점에 판정해 내려주는 값이다.
      expect(communityPostStatusFromWire('ENDED'), CommunityPostStatus.ended);
    });

    test('falls_back_to_ended_when_wire_status_is_unknown', () {
      // 미지 상태를 '마감'으로 보면 작성자에게 "다시 모집하기"가 뜨고 누르면
      // RECRUITING이 나간다 — '종료'로 보면 참여 표시와 상태 변경이 둘 다
      // 막힌다. 던지면 목록 한 장이 통째로 에러 화면이 된다(ENDED 추가 때
      // 실제로 그랬다).
      expect(
        communityPostStatusFromWire('CANCELLED'),
        CommunityPostStatus.ended,
      );
    });
  });

  group('CommunityScope 쿼리 매핑', () {
    test('omits_query_parameter_for_all_scope', () {
      // null이면 Retrofit이 생성한 removeWhere가 파라미터 자체를 제외한다.
      expect(CommunityScope.all.queryValue, isNull);
    });

    test('maps_narrowing_scopes_to_server_enum_names', () {
      expect(CommunityScope.nearby.queryValue, 'NEARBY');
      expect(CommunityScope.mine.queryValue, 'MINE');
    });
  });

  group('CommunitySortOption 와이어 매핑', () {
    test('maps_server_enum_names_exactly', () {
      expect(CommunitySortOption.latest.wireValue, 'LATEST');
      expect(CommunitySortOption.deadline.wireValue, 'DEADLINE');
      expect(CommunitySortOption.distance.wireValue, 'DISTANCE');
      // 서버가 400을 주는 값이지만 switch를 total로 두기 위해 매핑은 해 둔다.
      expect(CommunitySortOption.popular.wireValue, 'POPULAR');
    });
  });

  group('채팅 메시지 본문 와이어 매핑', () {
    test('reads_text_body_from_message_when_type_is_text', () {
      expect(
        communityChatMessageBodyFromWire('TEXT', '안녕하세요!'),
        const CommunityChatMessageBody.text('안녕하세요!'),
      );
    });

    test('reads_join_event_from_json_when_type_is_system', () {
      // 서버는 본문에 이름을 넣지 않는다 — 문구는 앱이 senderNickname으로
      // 조립해야 닉네임 변경과 다국어가 따라온다(DOC-0037).
      expect(
        communityChatMessageBodyFromWire('SYSTEM', '{"event":"JOIN"}'),
        const CommunityChatMessageBody.system(CommunityChatSystemEvent.join),
      );
    });

    test('reads_leave_event_from_json_when_type_is_system', () {
      expect(
        communityChatMessageBodyFromWire('SYSTEM', '{"event":"LEAVE"}'),
        const CommunityChatMessageBody.system(CommunityChatSystemEvent.leave),
      );
    });

    test('reads_kick_event_from_json_when_type_is_system', () {
      // 강퇴당한 본인은 이 메시지를 보고 스스로 구독을 끊어야 한다 — 서버가
      // 세션을 끊지 않으므로(Swagger 명시) 접어 버리면 나간 방 메시지를 계속 받는다.
      expect(
        communityChatMessageBodyFromWire('SYSTEM', '{"event":"KICK"}'),
        const CommunityChatMessageBody.system(CommunityChatSystemEvent.kick),
      );
    });

    test('reads_pin_registered_event_from_json_when_type_is_system', () {
      // BE #190이 시스템 이벤트를 3종 → 6종으로 늘렸다. 모르는 값으로 접으면
      // 대화창에 아무것도 안 보인다 — 공지가 바뀐 사실을 방에서 알 길이 없다.
      expect(
        communityChatMessageBodyFromWire(
          'SYSTEM',
          '{"event":"PIN_REGISTERED"}',
        ),
        const CommunityChatMessageBody.system(
          CommunityChatSystemEvent.pinRegistered,
        ),
      );
    });

    test('reads_pin_updated_event_from_json_when_type_is_system', () {
      expect(
        communityChatMessageBodyFromWire('SYSTEM', '{"event":"PIN_UPDATED"}'),
        const CommunityChatMessageBody.system(
          CommunityChatSystemEvent.pinUpdated,
        ),
      );
    });

    test('reads_pin_deleted_event_from_json_when_type_is_system', () {
      expect(
        communityChatMessageBodyFromWire('SYSTEM', '{"event":"PIN_DELETED"}'),
        const CommunityChatMessageBody.system(
          CommunityChatSystemEvent.pinDeleted,
        ),
      );
    });

    test('reads_invite_code_from_json_when_type_is_game_invite', () {
      expect(
        communityChatMessageBodyFromWire(
          'GAME_INVITE',
          '{"inviteCode":"ABC123"}',
        ),
        const CommunityChatMessageBody.gameInvite('ABC123'),
      );
    });

    test('falls_back_to_unknown_when_message_type_is_unrecognized', () {
      // 던지면 새 타입 하나가 채팅방 한 장을 통째로 에러로 만든다 —
      // ENDED가 추가됐을 때 목록에서 실제로 그랬다.
      expect(
        communityChatMessageBodyFromWire('POLL', '{"question":"뭐 먹지"}'),
        const CommunityChatMessageBody.unknown(),
      );
    });

    test('falls_back_to_unknown_when_system_body_is_not_valid_json', () {
      expect(
        communityChatMessageBodyFromWire('SYSTEM', '홍길동님이 참여했습니다'),
        const CommunityChatMessageBody.unknown(),
      );
    });

    test('falls_back_to_unknown_when_system_event_is_unrecognized', () {
      expect(
        communityChatMessageBodyFromWire('SYSTEM', '{"event":"MUTED"}'),
        const CommunityChatMessageBody.unknown(),
      );
    });

    test('falls_back_to_unknown_when_game_invite_has_no_code', () {
      // 코드 없는 초대 카드는 눌러도 들어갈 방이 없다 — 그리지 않는다.
      expect(
        communityChatMessageBodyFromWire('GAME_INVITE', '{}'),
        const CommunityChatMessageBody.unknown(),
      );
    });
  });
}
