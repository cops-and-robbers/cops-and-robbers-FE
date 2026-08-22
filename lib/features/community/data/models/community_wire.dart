import 'package:flutter/foundation.dart' show debugPrint;

import '../../domain/entities/community_post_status.dart';
import '../../domain/entities/community_scope.dart';
import '../../domain/entities/community_sort_option.dart';

/// 모집 상태의 서버 와이어 문자열.
///
/// `@JsonValue`를 쓰지 않는 이유: 그 어노테이션은 json_serializable이
/// `fromJson`/`toJson`을 만들 때만 읽히고 결과가 `.g.dart`의 private
/// `_$...EnumMap`에 들어간다. DTO는 `status`를 `String`으로 받아 Repository
/// 경계에서 도메인 enum으로 바꾸므로 그 맵에 닿지 못한다.
extension CommunityPostStatusWire on CommunityPostStatus {
  /// [CommunityPostStatus.ended]까지 매핑해 switch를 total로 둔다. 요청 스키마
  /// (`CommunityPostStatusRequest`)에도 `ENDED`가 있어 유효한 값이지만, 상태 변경은
  /// 모집중 ↔ 마감 이진 전환이라 이 값이 실려 나가지는 않는다.
  String get wireValue => switch (this) {
    CommunityPostStatus.recruiting => 'RECRUITING',
    CommunityPostStatus.completed => 'COMPLETED',
    CommunityPostStatus.ended => 'ENDED',
  };
}

/// 와이어 문자열 → 도메인 enum.
///
/// 모르는 값은 '마감'으로 본다. 모집중으로 보여 끝난 모임에 참여를 시도하게
/// 두느니 보수적으로 막는 쪽이 안전하고, 예외를 던지면 그 글 하나 때문에 목록
/// 한 장이 통째로 에러 화면이 된다 — `ENDED`가 추가됐을 때 실제로 그랬다.
CommunityPostStatus communityPostStatusFromWire(String wire) {
  switch (wire) {
    case 'RECRUITING':
      return CommunityPostStatus.recruiting;
    case 'COMPLETED':
      return CommunityPostStatus.completed;
    case 'ENDED':
      return CommunityPostStatus.ended;
    default:
      // 조용히 묻히면 다음 미지 값이 언제 들어왔는지 알 길이 없다.
      debugPrint('[커뮤니티] ⚠️ 알 수 없는 모집 상태: $wire → 마감으로 처리');
      return CommunityPostStatus.completed;
  }
}

/// `GET /api/community-posts`의 `scope` 쿼리 값.
extension CommunityScopeQuery on CommunityScope {
  /// `null`이면 Retrofit이 생성한 `removeWhere((k, v) => v == null)`가
  /// 파라미터 자체를 제외하므로 "전체 = 파라미터 생략"이 그대로 표현된다.
  ///
  /// 주의: 백엔드가 `scope` 파라미터는 받지만 `NEARBY`·`MINE`은 아직
  /// 400(`UNSUPPORTED_LIST_SCOPE`)이다 — 지원 전까지 호출자가
  /// [CommunityScope.all]만 넘겨야 한다.
  String? get queryValue => switch (this) {
    CommunityScope.all => null,
    CommunityScope.nearby => 'NEARBY',
    CommunityScope.mine => 'MINE',
  };
}

/// `GET /api/community-posts`의 `sort` 쿼리 값.
///
/// [CommunitySortOption.popular]까지 매핑해 switch를 total로 둔다 — 서버가
/// `UNSUPPORTED_LIST_SORT`(400)를 주는 값이라 정렬 시트가 노출하지 않으므로
/// 실제로 전송되지는 않는다.
extension CommunitySortOptionWire on CommunitySortOption {
  String get wireValue => switch (this) {
    CommunitySortOption.latest => 'LATEST',
    CommunitySortOption.popular => 'POPULAR',
    CommunitySortOption.distance => 'DISTANCE',
    CommunitySortOption.deadline => 'DEADLINE',
  };
}
