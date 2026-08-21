import 'package:cops_and_robbers/features/community/data/models/community_post_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// 백엔드 v2.18.0이 보내는 형태 — 장소는 `region`(서버 역지오코딩) +
/// `placeName`(작성자 입력) + `countryCode` 셋이고, 목록 봉투는 `page`가 아니라
/// `cursor`다. 아직 미도착 필드(currentParticipants·likeCount·bookmarkCount)는
/// 빠져 있다.
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
    'region': '서울특별시 광진구 군자동',
    'placeName': '어린이대공원 정문',
    'countryCode': 'KR',
  },
  'maxParticipants': 6,
  'status': 'RECRUITING',
  'createdAt': '2026-08-07T12:00:00+09:00',
  'updatedAt': '2026-08-07T12:00:00+09:00',
};

void main() {
  group('CommunityPostResponseModel', () {
    test(
      'parses_region_and_place_name_when_backend_resolved_the_coordinates',
      () {
        final model = CommunityPostResponseModel.fromJson(_serverJson());

        expect(model.id, 1);
        expect(model.writerNickname, '무서운경찰관');
        expect(model.location.latitude, 37.5502);
        expect(model.location.region, '서울특별시 광진구 군자동');
        expect(model.location.placeName, '어린이대공원 정문');
        expect(model.location.countryCode, 'KR');
      },
    );

    test('leaves_region_and_country_null_when_reverse_geocoding_failed', () {
      // 역지오코딩이 실패해도 글 작성은 성공시키므로 region·countryCode가 null로
      // 올 수 있다. placeName은 작성자 입력이라 이 경우에도 살아 있다.
      final json = _serverJson()
        ..['location'] = {
          'latitude': 37.5502,
          'longitude': 127.0736,
          'placeName': '어린이대공원 정문',
        };

      final model = CommunityPostResponseModel.fromJson(json);

      expect(model.location.region, isNull);
      expect(model.location.countryCode, isNull);
      expect(model.location.placeName, '어린이대공원 정문');
    });

    test('leaves_place_name_null_when_post_predates_the_field', () {
      // 스키마상 placeName은 non-null이지만, v2.17.0 이전에 쓰인 글까지 서버가
      // 채웠다는 보장이 없다. 외부 데이터는 신뢰하지 않는다 — 없으면 null로 받고
      // 화면이 장소 행을 숨긴다.
      final json = _serverJson()
        ..['location'] = {'latitude': 37.5502, 'longitude': 127.0736};

      final model = CommunityPostResponseModel.fromJson(json);

      expect(model.location.placeName, isNull);
    });

    test('leaves_writer_nickname_null_when_writer_withdrew', () {
      final json = _serverJson()..['writerNickname'] = null;

      expect(CommunityPostResponseModel.fromJson(json).writerNickname, isNull);
    });

    test('leaves_pending_backend_fields_null_when_absent', () {
      // 참여자 수·좋아요·스크랩·지번 주소는 추가 예정이다. 미리 선언해 둔 자리가
      // 응답에 없어도 파싱이 깨지면 안 된다.
      final model = CommunityPostResponseModel.fromJson(_serverJson());

      expect(model.currentParticipants, isNull);
      expect(model.likeCount, isNull);
      expect(model.bookmarkCount, isNull);
      expect(model.location.address, isNull);
    });

    test('parses_lot_address_when_backend_starts_sending_it', () {
      // 상세 화면이 복사에 쓰는 값이다 — 실리기 시작하면 region 대신 이게 담긴다.
      final json = _serverJson()
        ..['location'] = {
          ...(_serverJson()['location'] as Map<String, dynamic>),
          'address': '서울특별시 광진구 화양동 164-2',
        };

      final model = CommunityPostResponseModel.fromJson(json);

      expect(model.location.address, '서울특별시 광진구 화양동 164-2');
      // 동 단위 region은 그대로 남는다 — 화면 라벨은 여전히 이쪽을 쓴다.
      expect(model.location.region, '서울특별시 광진구 군자동');
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

  group('CommunityCountryResponseModel', () {
    test('parses_country_code_when_lookup_succeeds', () {
      final model = CommunityCountryResponseModel.fromJson({
        'countryCode': 'JP',
      });

      expect(model.countryCode, 'JP');
    });

    test('leaves_country_code_null_when_field_absent', () {
      // 스키마에 required가 없다 — non-null로 못 박으면 서버가 값을 빠뜨리는
      // 순간 파싱이 통째로 터진다 (LSN-0009).
      final model = CommunityCountryResponseModel.fromJson(<String, dynamic>{});

      expect(model.countryCode, isNull);
    });
  });

  group('CommunityAddressResponseModel', () {
    test('parses_region_address_and_country_when_pin_dropped', () {
      final model = CommunityAddressResponseModel.fromJson({
        'region': '서울특별시 광진구 화양동',
        'address': '서울특별시 광진구 화양동 1-20',
        'countryCode': 'KR',
      });

      // region은 글에 저장될 값, address는 작성자에게 위치를 확인시키는 값이다.
      expect(model.region, '서울특별시 광진구 화양동');
      expect(model.address, '서울특별시 광진구 화양동 1-20');
      expect(model.countryCode, 'KR');
    });
  });

  group('CommunityPostWriteRequestModel', () {
    test('serializes_place_name_and_utc_meeting_at_when_submitted', () {
      final json = CommunityPostWriteRequestModel(
        title: '같이 하실 분',
        content: '어린이대공원에서 봐요',
        meetingAt: DateTime.utc(2026, 8, 10, 5),
        location: const CommunityLocationRequestModel(
          latitude: 37.5502,
          longitude: 127.0736,
          placeName: '어린이대공원 정문',
        ),
        maxParticipants: 6,
      ).toJson();

      expect(json['meetingAt'], '2026-08-10T05:00:00.000Z');
      expect(json['location'], {
        'latitude': 37.5502,
        'longitude': 127.0736,
        'placeName': '어린이대공원 정문',
      });
    });
  });
}
