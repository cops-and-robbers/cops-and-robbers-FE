/// 내 누적 이동 거리를 서버로 보낼지 결정하는 순수 정책 함수 (BE #212, DEC-0093).
///
/// 서버는 이 값을 게임 종료 시 팀 MVP 동점 판정에만 쓴다. 종료 순간에 이미 값이
/// 있어야 즉시 판정할 수 있으므로 게임 중에 주기적으로 보낸다.
/// 다음을 모두 만족할 때만 전송한다:
/// - 마지막 전송 이후 30초 이상 경과
/// - 마지막으로 보낸 값보다 거리가 늘었음 (안 움직이면 보내지 않는다)
///
/// 체포 여부와는 무관하다 — 경찰·도둑 공통 규칙이다.
bool shouldSendDistance({
  required DateTime? lastSentTime,
  required DateTime now,
  required double? lastSentMeters,
  required double currentMeters,
}) {
  if (lastSentTime != null && now.difference(lastSentTime).inSeconds < 30) {
    return false;
  }
  return currentMeters > (lastSentMeters ?? 0);
}
