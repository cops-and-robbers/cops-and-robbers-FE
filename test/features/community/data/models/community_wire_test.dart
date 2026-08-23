import 'package:cops_and_robbers/features/community/data/models/community_wire.dart';
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
}
