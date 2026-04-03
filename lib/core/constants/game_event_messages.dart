/// 게임 이벤트 배너 및 시스템 채팅 메시지 상수
///
/// 배너(game_event_provider)와 전체채팅 시스템 메시지(game_page)에서
/// 동일한 문자열을 사용하기 위한 단일 소스.
/// 체포 공지 등 일부 메시지에는 @icon_police / @icon_robber 마커가 포함되며,
/// chat_message_bubble의 _buildSystemMessage에서 인라인 SVG로 치환된다.
abstract final class GameEventMessages {
  // ── START 이벤트 (4단계 시퀀스) ──

  /// START 1단계 — 제한 시간 안내 (동적 n분)
  static String gameStartTime(int minutes) => '제한 시간은 $minutes분입니다.';

  /// START 2단계 — 게임 시작 예고
  static const gameStartReady = '잠시 후 게임이 시작됩니다. 모든 플레이어는 준비하세요!';

  /// START 3단계 — 신고/차단 안내
  static const gameStartReportTip = '게임 중 채팅을 길게 눌러 불편한 유저를 신고 및 차단할 수 있습니다.';

  /// START 4단계 — 게임 시작 확정
  static const gameStartGo = '게임 시작! 행운을 빕니다!';

  // ── POLICE_MOVE_START 이벤트 (2단계 시퀀스) ──

  /// 경찰 출동 예고
  static const policeMoveWarning = '경찰이 곧 출동합니다. 도둑은 서둘러 이동하세요!';

  /// 경찰 출동 확정
  static const policeMove = '경찰 출동! 도둑은 도망치세요!';

  // ── LOCATION_REVEAL 이벤트 ──

  /// 도둑 위치 공개 안내
  static const locationReveal = '현재 도둑의 위치가 공개됩니다!';

  /// 도주 중인 도둑 인원 (동적 n명)
  static String remainingRobbers(int count) => '현재 $count명 도주 중!';

  // ── ARREST 이벤트 ──

  /// 체포 공지 (동적 — 경찰·도둑 닉네임 + 인라인 아이콘 마커)
  static String arrestNotice(String policeNickname, String robberNickname) =>
      '@icon_police [$policeNickname]님이 @icon_robber [$robberNickname]님을 체포했습니다!';

  // ── ESCAPE 이벤트 ──

  /// 탈옥 공지
  static const escapeNotice = '도둑이 탈옥했습니다! 지금 바로 체포하세요!';

  // ── 게임 종료 5분 전 ──

  /// 게임 종료 5분 전 경고
  static const fiveMinutesLeft = '게임 종료까지 5분 남았습니다. 마지막 기회를 놓치지 마세요!';
}
