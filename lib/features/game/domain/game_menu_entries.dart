/// 인게임 플로팅 메뉴에 무엇을 펼칠지 정하는 순수 계산.
library;

enum GameMenuEntry { grid, participants, arrest, myQr, jailed, evidenceBoard }

/// 왼쪽부터 좌표, 참가자, QR 자리, 증거보드 순서다. 많이 쓰는 QR을 오른쪽에 둔다.
///
/// 구역 이탈 중에는 체포·QR이 무의미해 참가자와 QR 자리를 뺀다. 증거보드는 읽기
/// 전용 현황이라 이탈 중에도 남긴다.
List<GameMenuEntry> gameMenuEntries({
  required bool isPolice,
  required bool isArrested,
  required bool isZoneExitActive,
  required bool isEventGame,
  bool isMapVisible = true,
}) => [
  // 대기·설명 장면은 지도를 덮고 있어 좌표를 켜도 보이지 않는다.
  if (isMapVisible) GameMenuEntry.grid,
  if (!isZoneExitActive) ...[
    GameMenuEntry.participants,
    if (isArrested)
      GameMenuEntry.jailed
    else if (isPolice)
      GameMenuEntry.arrest
    else
      GameMenuEntry.myQr,
  ],
  if (isEventGame && isPolice) GameMenuEntry.evidenceBoard,
];
