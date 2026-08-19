import 'package:cops_and_robbers/features/community/data/models/community_wire.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
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
    });

    test('throws_format_exception_when_wire_status_is_unknown', () {
      // 폴백을 두면 마감된 글이 모집중으로 보인다 — 조용히 넘기지 않는다.
      expect(
        () => communityPostStatusFromWire('CANCELLED'),
        throwsA(isA<FormatException>()),
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
}
