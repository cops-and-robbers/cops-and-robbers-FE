/// 도둑 잠금(감옥) 오버레이를 띄울지 판단.
///
/// 이벤트 모드에서는 도둑이 잡혀도 ALIVE로 유지되므로 항상 false.
/// 일반 모드에서는 "체포됨 && 탈옥 안 함"일 때만 true.
bool shouldShowArrestLock({
  required bool isRobber,
  required bool isEventGame,
  required bool isArrested,
  required bool isEscaped,
}) {
  if (!isRobber || isEventGame) return false;
  return isArrested && !isEscaped;
}
