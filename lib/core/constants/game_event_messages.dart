import '../../l10n/app_localizations.dart';

/// 게임 이벤트 배너 및 시스템 채팅 메시지의 i18n 키 + 변환 헬퍼
///
/// 배너(game_event_provider)와 전체채팅 시스템 메시지(game_page)에서
/// 동일한 ARB 키를 참조하기 위한 단일 소스.
///
/// **사용 패턴:**
/// - **Notifier (BuildContext 없음)**: state에 [GameEventMessageKey] 상수와
///   필요한 args를 저장 → UI 위젯이 [resolve]로 변환
/// - **UI (BuildContext 있음)**: `AppLocalizations.of(context).gameEventXxx`
///   직접 호출 또는 [resolve] 사용
///
/// 체포 공지 등 일부 메시지에는 `@icon_police` / `@icon_robber` 마커가 포함되며,
/// `chat_message_bubble`의 `_buildSystemMessage`에서 인라인 SVG로 치환된다.
///
/// **참고:** 게임 시작 시퀀스(`startReady`/`startReportTip`/`startTime`)는
/// game_page에서 직접 `l10n.gameEventStartXxx` 호출로 처리되므로 이 클래스에
/// 상수를 두지 않는다. Notifier 경유가 필요한 키만 등록한다.
abstract final class GameEventMessageKey {
  // ── START 이벤트 ──
  // startReady/startReportTip/startTime은 game_page.dart에서 직접 호출
  static const startGo = 'gameEventStartGo';

  // ── POLICE_MOVE_START 이벤트 ──
  static const policeMove = 'gameEventPoliceMove';

  // ── LOCATION_REVEAL 이벤트 ──
  static const locationReveal = 'gameEventLocationReveal';

  // ── ARREST 이벤트 ──
  // args: [String policeNickname, String robberNickname]
  static const arrestNotice = 'gameEventArrestNotice';

  // ── ESCAPE 이벤트 ──
  static const escapeNotice = 'gameEventEscapeNotice';

  // ── PLAYER_LEFT 이벤트 (인게임 중도 퇴장) ──
  // args: [String nickname, String teamLabel]
  static const playerLeftNotice = 'gameEventPlayerLeftNotice';
}

/// 게임 이벤트 메시지를 ARB 키로 변환하는 헬퍼.
///
/// Notifier에서 state에 저장한 키 + args 쌍을 UI 위젯이 build 시점에 변환할 때 사용한다.
/// 알 수 없는 키는 키 문자열 자체를 반환(개발 중 fallback).
String resolveGameEventMessage(
  AppLocalizations l10n,
  String key, [
  List<Object?>? args,
]) {
  switch (key) {
    case GameEventMessageKey.startGo:
      return l10n.gameEventStartGo;
    case GameEventMessageKey.policeMove:
      return l10n.gameEventPoliceMove;
    case GameEventMessageKey.locationReveal:
      return l10n.gameEventLocationReveal;
    case GameEventMessageKey.arrestNotice:
      // 호출부에서 [String, String] 보장 (game_event_provider._handleArrest)
      return l10n.gameEventArrestNotice(args![0] as String, args[1] as String);
    case GameEventMessageKey.escapeNotice:
      return l10n.gameEventEscapeNotice;
    case GameEventMessageKey.playerLeftNotice:
      // 호출부에서 [nickname, teamLabel] 보장 (game_event_provider._handlePlayerLeft)
      return l10n.gameEventPlayerLeftNotice(
        args![0] as String,
        args[1] as String,
      );
    default:
      return key;
  }
}
