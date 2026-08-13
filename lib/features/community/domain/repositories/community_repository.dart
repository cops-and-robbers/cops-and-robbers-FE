import '../entities/community_post_entity.dart';
import '../entities/community_scope.dart';

/// 커뮤니티 도메인 Repository 인터페이스
///
/// 데이터 출처(REST API, 캐시 등) 구체에 의존하지 않는다.
abstract class CommunityRepository {
  /// 모집 게시글 목록을 페이지 단위로 조회한다.
  ///
  /// [page]는 0-based, [size]는 페이지당 개수.
  /// 실패 시 `AppException` 계열 예외를 던진다.
  ///
  /// [scope]는 백엔드가 아직 지원하지 않는다. 호출자는 현재
  /// [CommunityScope.all]만 넘겨야 한다 — 다른 값을 넘기면 서버가 파라미터를
  /// 무시하고 전체 목록을 돌려주므로 화면이 에러 없이 조용히 틀어진다.
  Future<CommunityPostPageEntity> getPosts({
    required int page,
    required int size,
    CommunityScope scope = CommunityScope.all,
  });
}
