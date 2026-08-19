/// 커뮤니티 목록 정렬 기준 — 서버 와이어 포맷 비의존 (순수 도메인 타입)
///
/// [latest]만 현재 백엔드가 지원한다. 나머지 셋은 `sort` 쿼리가 생기면 연결한다
/// — `scope`와 같은 이유로, 지원 전에 보내면 Spring이 조용히 무시해 정렬이 안 된
/// 목록이 "인기순"으로 표시된다.
///
/// [distance]는 사용자 현재 위치가 필요하다 (`scope=NEARBY`와 같은 좌표를 쓴다).
enum CommunitySortOption { latest, popular, distance, deadline }
