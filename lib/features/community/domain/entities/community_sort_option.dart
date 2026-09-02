/// 커뮤니티 목록 정렬 기준 — 서버 와이어 포맷 비의존 (순수 도메인 타입)
///
/// 넷 다 `sort` 쿼리로 서버에 실어 보낸다. [popular]는 BE #175(v2.24.0)가
/// 열었다 — 점수 = 좋아요×1 + 스크랩×2 + 채팅 멤버×3, 최근 7일 글만 대상이며
/// 마감 글은 다른 정렬처럼 맨 뒤다. 점수 계산은 전부 서버 몫이다.
///
/// [distance]는 사용자 현재 위치가 필요하다 (`scope=NEARBY`와 같은 좌표를 쓴다).
enum CommunitySortOption { latest, popular, distance, deadline }
