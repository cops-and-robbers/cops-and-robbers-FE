import 'package:cops_and_robbers/features/community/data/models/community_post_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// 백엔드 v2.15.0이 실제로 보내는 형태 — 미도착 필드(address·currentParticipants
/// ·likeCount·bookmarkCount)가 전부 빠져 있다.
Map<String, dynamic> _currentServerJson() => {
  'id': 1,
  'writerId': 7,
  'title': '같이 경찰과 도둑 하실 분!',
  'content': '강남역 근처에서 5명 모집합니다.',
  'meetingAt': '2026-08-10T14:00:00+09:00',
  'location': {'latitude': 37.4979, 'longitude': 127.0276},
  'maxParticipants': 6,
  'status': 'RECRUITING',
  'createdAt': '2026-08-07T12:00:00+09:00',
  'updatedAt': '2026-08-07T12:00:00+09:00',
};

void main() {
  group('CommunityPostResponseModel', () {
    test('parses_response_when_pending_backend_fields_are_absent', () {
      // 이 테스트가 "백엔드 나오면 바로 연결"의 핵심 보증이다.
      // 지금 응답에 없는 필드가 null로 들어와야 하고, 파싱은 실패하면 안 된다.
      final model = CommunityPostResponseModel.fromJson(_currentServerJson());

      expect(model.id, 1);
      expect(model.title, '같이 경찰과 도둑 하실 분!');
      expect(model.maxParticipants, 6);
      expect(model.status, 'RECRUITING');
      expect(model.location.latitude, 37.4979);

      expect(model.location.address, isNull);
      expect(model.currentParticipants, isNull);
      expect(model.likeCount, isNull);
      expect(model.bookmarkCount, isNull);
    });

    test('reads_pending_fields_without_code_change_when_backend_adds_them', () {
      // 백엔드가 필드를 붙였을 때의 응답. DTO 선언만으로 값이 흘러들어와야 한다.
      final json = _currentServerJson()
        ..['location'] = {
          'latitude': 37.4979,
          'longitude': 127.0276,
          'address': '서울시 광진구 세종대학교',
        }
        ..['currentParticipants'] = 2
        ..['likeCount'] = 6
        ..['bookmarkCount'] = 3;

      final model = CommunityPostResponseModel.fromJson(json);

      expect(model.location.address, '서울시 광진구 세종대학교');
      expect(model.currentParticipants, 2);
      expect(model.likeCount, 6);
      expect(model.bookmarkCount, 3);
    });

    test('ignores_unknown_fields_when_backend_adds_extras', () {
      // json_serializable 기본 동작 확인 — 모르는 키가 와도 깨지지 않아야 한다.
      final json = _currentServerJson()..['someFutureField'] = 'whatever';

      expect(() => CommunityPostResponseModel.fromJson(json), returnsNormally);
    });
  });

  group('CommunityPostListResponseModel', () {
    test('parses_page_envelope_with_content_and_page_info', () {
      final model = CommunityPostListResponseModel.fromJson({
        'content': [_currentServerJson()],
        'page': {'size': 20, 'number': 0, 'totalElements': 1, 'totalPages': 1},
      });

      expect(model.content.single.id, 1);
      expect(model.page.number, 0);
      expect(model.page.totalPages, 1);
    });
  });
}
