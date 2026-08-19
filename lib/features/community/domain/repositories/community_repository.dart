import '../entities/community_post_entity.dart';
import '../entities/community_scope.dart';

/// 커뮤니티 도메인 Repository 인터페이스
///
/// 데이터 출처(REST API, 캐시 등) 구체에 의존하지 않는다.
abstract class CommunityRepository {
  /// 모집 게시글 목록을 커서 단위로 조회한다.
  ///
  /// [cursor]는 직전 응답의 `nextCursor`를 그대로 넘긴다 — 첫 요청은 null.
  /// [size]는 한 번에 가져올 개수(1~100).
  /// 실패 시 `AppException` 계열 예외를 던진다.
  ///
  /// [scope]는 [CommunityScope.all] 외 값을 백엔드가 아직 400으로 막는다.
  /// 호출자는 현재 전체만 넘겨야 한다.
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
  });
}
