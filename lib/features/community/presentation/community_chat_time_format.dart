import '../../../l10n/app_localizations.dart';

/// `오후 5:34` — 12시간제. `DateFormat.jm`은 로케일 데이터 초기화가 필요해
/// (`initializeDateFormatting`, 이 앱은 안 부른다) ARB로 조립한다
/// (`community_post_card.dart`의 요일 라벨과 같은 이유).
String formatChatTime(AppLocalizations l10n, DateTime dt) {
  final period = dt.hour < 12 ? l10n.timePeriodAm : l10n.timePeriodPm;
  final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  return l10n.communityChatTime(
    period,
    hour12.toString(),
    dt.minute.toString().padLeft(2, '0'),
  );
}

/// 목록용 — 오늘이면 시각, 아니면 `8/2`
String formatChatListTime(AppLocalizations l10n, DateTime dt, DateTime now) {
  final sameDay =
      dt.year == now.year && dt.month == now.month && dt.day == now.day;
  return sameDay
      ? formatChatTime(l10n, dt)
      : l10n.communityChatDateShort(dt.month.toString(), dt.day.toString());
}

/// `9/10 (목) 18:00` — 상단 모임 카드용
///
/// `community_post_card.dart`·`community_detail_page.dart`에 같은 조립이 private으로
/// 있다. 셋을 합치는 건 이 작업 범위 밖이라 여기서는 채팅용만 둔다.
String formatCommunityMeetingAt(AppLocalizations l10n, DateTime dt) {
  final weekdays = [
    l10n.weekdayMon,
    l10n.weekdayTue,
    l10n.weekdayWed,
    l10n.weekdayThu,
    l10n.weekdayFri,
    l10n.weekdaySat,
    l10n.weekdaySun,
  ];
  final time =
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
  return l10n.communityMeetingAt(
    dt.month.toString(),
    dt.day.toString(),
    weekdays[dt.weekday - 1],
    time,
  );
}
