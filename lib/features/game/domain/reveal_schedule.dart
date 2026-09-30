/// 다음 도둑 위치 공개 시각.
///
/// 게임 화면 타이머와 잠금 화면이 같은 규칙을 쓰도록 한곳에 둔다.
/// 공개는 `시작 + 경찰 대기 + 간격×k`(k≥1) 시각이다. 경찰 대기 중에도 첫 공개까지 센다.
/// 지금이 공개 시각과 정확히 같으면 그 시각을 돌려준다(게임 화면이 00:00을 보이는 순간).
/// 간격이 없거나 0 이하, 또는 대기 시간을 모르면 null.
DateTime? nextRevealAt({
  required DateTime start,
  required int? policeWaitMinutes,
  required int? intervalMinutes,
  required DateTime now,
}) {
  if (intervalMinutes == null || intervalMinutes <= 0) return null;
  if (policeWaitMinutes == null) return null;

  final period = Duration(minutes: intervalMinutes);
  var at = start.add(Duration(minutes: policeWaitMinutes) + period);
  while (at.isBefore(now)) {
    at = at.add(period);
  }
  return at;
}
