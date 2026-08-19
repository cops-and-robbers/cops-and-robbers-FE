/// 모집 게시글의 모집 상태 — 서버 와이어 포맷 비의존 (순수 도메인 타입)
///
/// 와이어 문자열 매핑은 data 계층(`community_wire.dart`)에 있다.
enum CommunityPostStatus { recruiting, completed }
