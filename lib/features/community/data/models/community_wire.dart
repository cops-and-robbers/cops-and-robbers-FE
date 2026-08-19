import '../../domain/entities/community_post_status.dart';
import '../../domain/entities/community_scope.dart';

/// 모집 상태의 서버 와이어 문자열.
///
/// `@JsonValue`를 쓰지 않는 이유: 그 어노테이션은 json_serializable이
/// `fromJson`/`toJson`을 만들 때만 읽히고 결과가 `.g.dart`의 private
/// `_$...EnumMap`에 들어간다. DTO는 `status`를 `String`으로 받아 Repository
/// 경계에서 도메인 enum으로 바꾸므로 그 맵에 닿지 못한다.
extension CommunityPostStatusWire on CommunityPostStatus {
  String get wireValue => switch (this) {
    CommunityPostStatus.recruiting => 'RECRUITING',
    CommunityPostStatus.completed => 'COMPLETED',
  };
}

/// 와이어 문자열 → 도메인 enum.
///
/// 알 수 없는 값에 폴백을 두지 않는다. 마감된 글이 모집중으로 보이면 사용자가
/// 끝난 모임에 참여를 시도하므로, 조용히 넘기는 대신 파싱 단계에서 끊는다.
/// (Repository가 이 예외를 `ServerException`으로 감싼다.)
CommunityPostStatus communityPostStatusFromWire(String wire) => switch (wire) {
  'RECRUITING' => CommunityPostStatus.recruiting,
  'COMPLETED' => CommunityPostStatus.completed,
  _ => throw FormatException('알 수 없는 모집 상태: $wire'),
};

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
