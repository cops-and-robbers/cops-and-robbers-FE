/// 커뮤니티 목록 정렬 기준 — 서버 와이어 포맷 비의존 (순수 도메인 타입)
///
/// [popular]만 아직 서버가 400(`UNSUPPORTED_LIST_SORT`)을 준다 — 좋아요·스크랩
/// 테이블이 없어 셀 대상이 없다. 그래서 정렬 시트가 노출하지 않는다. 나머지
/// 셋([latest]·[distance]·[deadline])은 이미 `sort` 쿼리로 서버에 실어 보낸다.
///
/// [distance]는 사용자 현재 위치가 필요하다 (`scope=NEARBY`와 같은 좌표를 쓴다).
enum CommunitySortOption { latest, popular, distance, deadline }
