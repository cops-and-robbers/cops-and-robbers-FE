/// 공지사항 카테고리 필터 — 서버 와이어 포맷 비의존 (순수 도메인 타입)
///
/// [all]은 서버 enum에 없는 UI 전용 값으로 "필터 없음"을 뜻한다.
/// 와이어 문자열 매핑은 data 계층(`notice_category_query.dart`)에 있다.
enum NoticeCategory { all, notice, maintenance, event, update }
