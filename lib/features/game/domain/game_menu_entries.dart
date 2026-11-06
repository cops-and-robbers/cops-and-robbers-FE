/// 인게임 플로팅 메뉴에 무엇을 펼칠지 정하는 순수 계산.
library;

enum GameMenuEntry {
  grid,
  participants,
  arrest,
  myQr,
  jailed,
  evidenceBoard,
  chat,
}

/// 지도는 왼쪽부터 좌표, 참가자, QR 자리, 증거보드 순서다. 많이 쓰는 QR을 오른쪽에 둔다.
///
/// 대기·설명 장면([isMapVisible] false)은 위로 펼쳐지는 메뉴라 위에서부터 QR 자리, 참가자,
/// (증거보드,) 채팅 순서다. 지도를 덮어 좌표는 빼고, 지도와 달리 채팅 전용 버튼이 없어
/// 채팅을 메뉴에 넣는다(DEC-0133).
///
/// 구역 이탈 중에는 체포·QR이 무의미해 참가자와 QR 자리를 뺀다. 증거보드는 읽기
/// 전용 현황이라 이탈 중에도 남긴다.
List<GameMenuEntry> gameMenuEntries({
  required bool isPolice,
  required bool isArrested,
  required bool isZoneExitActive,
  required bool isEventGame,
  bool isMapVisible = true,
}) {
  final qrSlot = isArrested
      ? GameMenuEntry.jailed
      : isPolice
      ? GameMenuEntry.arrest
      : GameMenuEntry.myQr;
  final evidence = [if (isEventGame && isPolice) GameMenuEntry.evidenceBoard];
  if (!isMapVisible) {
    return [
      if (!isZoneExitActive) ...[qrSlot, GameMenuEntry.participants],
      ...evidence,
      GameMenuEntry.chat,
    ];
  }
  return [
    GameMenuEntry.grid,
    if (!isZoneExitActive) ...[GameMenuEntry.participants, qrSlot],
    ...evidence,
  ];
}
