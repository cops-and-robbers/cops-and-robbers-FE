import 'package:cops_and_robbers/features/community/data/models/community_post_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// 백엔드 v2.17.0이 보내는 형태 — 주소 3종·작성자 닉네임이 들어오고
/// 목록 봉투는 `page`가 아니라 `cursor`다.
/// 아직 미도착 필드(currentParticipants·likeCount·bookmarkCount)는 빠져 있다.
Map<String, dynamic> _serverJson() => {
  'id': 1,
  'writerId': 7,
  'writerNickname': '무서운경찰관',
  'title': '같이 경찰과 도둑 하실 분!',
  'content': '강남역 근처에서 5명 모집합니다.',
  'meetingAt': '2026-08-10T14:00:00+09:00',
  'location': {
    'latitude': 37.5502,
    'longitude': 127.0736,
    'address': '서울 광진구 군자동 98',
    'roadAddress': '서울특별시 광진구 능동로 209',
    'buildingName': '세종대학교',
  },
  'maxParticipants': 6,
  'status': 'RECRUITING',
  'createdAt': '2026-08-07T12:00:00+09:00',
  'updatedAt': '2026-08-07T12:00:00+09:00',
};

void main() {
  group('CommunityPostResponseModel', () {
    test('parses_address_trio_when_backend_resolved_the_coordinates', () {
      final model = CommunityPostResponseModel.fromJson(_serverJson());

      expect(model.id, 1);
      expect(model.writerNickname, '무서운경찰관');
      expect(model.location.latitude, 37.5502);
      expect(model.location.address, '서울 광진구 군자동 98');
      expect(model.location.roadAddress, '서울특별시 광진구 능동로 209');
      expect(model.location.buildingName, '세종대학교');
    });

    test('leaves_address_trio_null_when_reverse_geocoding_failed', () {
      // 역지오코딩 실패해도 글 작성은 성공시키므로 셋 다 null로 올 수 있다.
      final json = _serverJson()
        ..['location'] = {'latitude': 37.5502, 'longitude': 127.0736};

      final model = CommunityPostResponseModel.fromJson(json);

      expect(model.location.address, isNull);
      expect(model.location.roadAddress, isNull);
      expect(model.location.buildingName, isNull);
    });

    test('leaves_writer_nickname_null_when_writer_withdrew', () {
      final json = _serverJson()..['writerNickname'] = null;

      expect(CommunityPostResponseModel.fromJson(json).writerNickname, isNull);
    });

    test('leaves_pending_backend_fields_null_when_absent', () {
      // 참여자 수·좋아요·스크랩은 2·3단계 예정이다. 미리 선언해 둔 자리가
      // 응답에 없어도 파싱이 깨지면 안 된다.
      final model = CommunityPostResponseModel.fromJson(_serverJson());

      expect(model.currentParticipants, isNull);
      expect(model.likeCount, isNull);
      expect(model.bookmarkCount, isNull);
    });

    test('ignores_unknown_fields_when_backend_adds_extras', () {
      // json_serializable 기본 동작 확인 — 모르는 키가 와도 깨지지 않아야 한다.
      final json = _serverJson()..['someFutureField'] = 'whatever';

      expect(() => CommunityPostResponseModel.fromJson(json), returnsNormally);
    });
  });

  group('CommunityPostListResponseModel', () {
    test('parses_cursor_envelope_when_more_pages_remain', () {
      final model = CommunityPostListResponseModel.fromJson({
        'content': [_serverJson()],
        'cursor': {
          'nextCursor': 'MjAyNi0wOC0xNVQxMjozMDo0NXw0Mg',
          'hasNext': true,
        },
      });

      expect(model.content.single.id, 1);
      expect(model.cursor.nextCursor, 'MjAyNi0wOC0xNVQxMjozMDo0NXw0Mg');
      expect(model.cursor.hasNext, true);
    });

    test('parses_null_next_cursor_when_last_page_reached', () {
      final model = CommunityPostListResponseModel.fromJson({
        'content': <Map<String, dynamic>>[],
        'cursor': {'nextCursor': null, 'hasNext': false},
      });

      expect(model.content, isEmpty);
      expect(model.cursor.nextCursor, isNull);
      expect(model.cursor.hasNext, false);
    });
  });
}
