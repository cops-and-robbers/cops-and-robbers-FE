/// 게임 이벤트 배너 및 시스템 채팅 메시지 상수
///
/// 배너(game_event_provider)와 전체채팅 시스템 메시지(game_page)에서
/// 동일한 문자열을 사용하기 위한 단일 소스.
abstract final class GameEventMessages {
  /// START 이벤트 — 게임 시작 안내
  static const gameStart = '게임이 곧 시작됩니다. 모든 플레이어는 준비하세요!';

  /// POLICE_MOVE_START 이벤트 — 경찰 출동 안내
  static const policeMove = '경찰이 출동합니다!';

  /// LOCATION_REVEAL 이벤트 — 도둑 위치 공개 안내
  static const locationReveal = '현재 도둑의 위치가 공개됩니다!';

  /// GAME_OVER 이벤트 — 게임 종료 안내
  static const gameOver = '게임이 종료되었습니다!';
}
