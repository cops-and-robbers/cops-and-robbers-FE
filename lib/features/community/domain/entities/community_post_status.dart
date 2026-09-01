/// 모집 게시글의 모집 상태 — 서버 와이어 포맷 비의존 (순수 도메인 타입)
///
/// [completed]는 작성자가 직접 마감한 것이고, [ended]는 모임 날짜가 지나
/// 서버가 조회 시점에 판정한 것이다. 서버는 [ended]를 저장하지 않으며, 날짜가
/// 작성자 마감보다 우선한다 — 마감된 글이라도 날짜가 지나면 [ended]로 온다.
///
/// 와이어 문자열 매핑은 data 계층(`community_wire.dart`)에 있다.
enum CommunityPostStatus { recruiting, completed, ended }
