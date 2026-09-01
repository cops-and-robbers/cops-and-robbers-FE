/// 커뮤니티 목록 필터 범위 — 서버 와이어 포맷 비의존 (순수 도메인 타입)
///
/// [all]만 현재 백엔드가 지원한다. [nearby]/[mine]은 `scope` 쿼리가 생기면
/// 연결한다 — 그 전까지 Notifier가 API 호출 자체를 하지 않는다.
/// 와이어 문자열 매핑은 data 계층(`community_wire.dart`)에 있다.
enum CommunityScope { all, nearby, mine }
