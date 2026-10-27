import 'entities/notice_entity.dart';

/// 목록에서 가장 최근 공지의 id. 비었으면 null.
///
/// 맨 앞 항목이 아니라 최대 id를 본다 — 서버가 고정 공지를 먼저 정렬해 보내므로
/// 고정 공지가 있으면 맨 앞은 최신 공지가 아니다. id는 DB IDENTITY라 클수록 최근이다.
// ponytail: 첫 페이지(10개)만 본다 — 고정 공지가 10개 이상이면 새 일반 공지를 못 본다.
int? newestNoticeId(List<NoticeEntity> items) {
  if (items.isEmpty) return null;
  return items.map((n) => n.id).reduce((a, b) => a > b ? a : b);
}

/// 마지막으로 본 공지보다 새 공지가 있는가.
///
/// 저장값이 없으면(처음 설치·재설치) 공지가 하나라도 있으면 새 공지로 본다.
bool isNewerNotice({required int? newestId, required int? lastSeenId}) {
  if (newestId == null) return false;
  return lastSeenId == null || newestId > lastSeenId;
}
