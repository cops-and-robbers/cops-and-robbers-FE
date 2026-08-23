import '../entities/community_address_entity.dart';
import '../entities/community_post_entity.dart';
import '../entities/community_post_status.dart';
import '../entities/community_scope.dart';
import '../entities/community_sort_option.dart';

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
  /// 목록이 국가별로 나뉘므로 [countryCode]는 필수다(DEC-0021). 국가는
  /// [getCountryCode]로 먼저 구한다.
  ///
  /// [sort]가 [CommunitySortOption.distance]면 [latitude]·[longitude]가
  /// 필수다. 그 밖의 정렬에서는 좌표를 보내면 서버가 400을 주므로 구현체가
  /// 걸러낸다 — 호출자는 좌표를 항상 넘겨도 된다.
  ///
  /// [keyword]는 공백을 제외하고 2자 이상이어야 한다. 그보다 짧으면 서버가
  /// 400을 주므로 호출자가 미리 막는다.
  ///
  /// 커서에 국가·정렬·검색어가 봉인돼 있어, 셋 중 하나라도 직전 요청과 다르면
  /// [cursor]를 재사용할 수 없다(400).
  ///
  /// [scope]는 [CommunityScope.all] 외 값을 백엔드가 아직 400으로 막는다.
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
  });

  /// 좌표가 속한 국가 코드를 조회한다 (저장하지 않음).
  ///
  /// 목록 조회 전에 한 번 불러 국가를 정하는 용도다. 로그인 불필요.
  /// 서버가 값을 주지 않으면 `null` — 기기 로케일로 물러설지는 호출자가 정한다.
  /// 국가를 특정할 수 없는 좌표·벤더 장애는 `AppException` 계열 예외를 던진다.
  ///
  /// 엔티티로 감싸지 않는다 — 필드 하나짜리 응답이라 옮겨 담을 구조가 없다.
  Future<String?> getCountryCode({
    required double latitude,
    required double longitude,
  });

  /// 좌표에 해당하는 주소를 조회한다 (저장하지 않음).
  ///
  /// 작성 화면에서 핀을 찍은 직후 위치를 확인시키는 용도다.
  /// 주소가 없는 좌표면 `AppException` 계열 예외를 던진다.
  Future<CommunityAddressEntity> getAddress({
    required double latitude,
    required double longitude,
  });

  /// 모집 게시글을 작성한다.
  ///
  /// 로그인 필요. [meetingAt]이 과거이거나 [latitude]·[longitude]의 주소를
  /// 서버가 못 찾으면 예외를 던진다. 생성된 글을 돌려준다.
  Future<CommunityPostEntity> createPost({
    required String title,
    required String content,
    required DateTime meetingAt,
    required double latitude,
    required double longitude,
    required String placeName,
    required int maxParticipants,
  });

  /// 모집 게시글 한 건을 조회한다.
  ///
  /// 비로그인도 열람 가능하다 (DEC-0014).
  /// 없는 글이면 `NotFoundException` 계열 예외를 던진다.
  Future<CommunityPostEntity> getPost(int postId);

  /// 모집 게시글을 수정한다 (전체 교체).
  ///
  /// 작성자 본인만 가능하다 — 아니면 권한 예외를 던진다.
  /// 전체 교체라 바꾸지 않는 값도 현재 값을 그대로 다시 넘겨야 한다
  /// ([placeName]·좌표 포함 — 빠지면 서버가 400을 준다).
  /// 수정된 글을 돌려주므로 호출자가 화면 갱신에 바로 쓴다.
  Future<CommunityPostEntity> updatePost({
    required int postId,
    required String title,
    required String content,
    required DateTime meetingAt,
    required double latitude,
    required double longitude,
    required String placeName,
    required int maxParticipants,
  });

  /// 모집 게시글을 삭제한다.
  ///
  /// 작성자 본인만 가능하다 — 아니면 권한 예외를 던진다.
  Future<void> deletePost(int postId);

  /// 모집 상태를 변경한다 (모집중 ↔ 마감).
  ///
  /// 작성자 본인만 가능하다. 변경된 글을 돌려준다.
  Future<CommunityPostEntity> updateStatus({
    required int postId,
    required CommunityPostStatus status,
  });
}
