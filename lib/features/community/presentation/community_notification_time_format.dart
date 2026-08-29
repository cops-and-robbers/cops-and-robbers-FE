import '../../../l10n/app_localizations.dart';

/// 알림 카드 시각 표기 — `communityCommentXxxAgo` 문구를 재사용한다(댓글 작성
/// 시각과 동일한 상대시간 규칙). 하루 이상 지나면 `8/09`처럼 날짜로 바꾼다
/// (`communityChatDateShort` 재사용, 일은 시안대로 2자리 패딩).
String formatNotificationTime(
  AppLocalizations l10n,
  DateTime dt,
  DateTime now,
) {
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return l10n.communityCommentJustNow;
  if (diff.inMinutes < 60) {
    return l10n.communityCommentMinutesAgo(diff.inMinutes);
  }
  if (diff.inHours < 24) return l10n.communityCommentHoursAgo(diff.inHours);
  return l10n.communityChatDateShort(
    dt.month.toString(),
    dt.day.toString().padLeft(2, '0'),
  );
}
