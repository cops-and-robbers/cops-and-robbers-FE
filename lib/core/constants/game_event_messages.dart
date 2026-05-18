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
abstract final class GameEventMessageKey {
  // ── START 이벤트 (4단계 시퀀스) ──
  static const startTime = 'gameEventStartTime'; // args: [int minutes]
  static const startReady = 'gameEventStartReady';
  static const startReportTip = 'gameEventStartReportTip';
  static const startGo = 'gameEventStartGo';

  // ── POLICE_MOVE_START 이벤트 (2단계 시퀀스) ──
  static const policeMoveWarning = 'gameEventPoliceMoveWarning';
  static const policeMove = 'gameEventPoliceMove';

  // ── LOCATION_REVEAL 이벤트 ──
  static const locationReveal = 'gameEventLocationReveal';
  static const remainingRobbers =
      'gameEventRemainingRobbers'; // args: [int count]

  // ── ARREST 이벤트 ──
  // args: [String policeNickname, String robberNickname]
  static const arrestNotice = 'gameEventArrestNotice';

  // ── ESCAPE 이벤트 ──
  static const escapeNotice = 'gameEventEscapeNotice';

  // ── 게임 종료 5분 전 ──
  static const fiveMinutesLeft = 'gameEventFiveMinutesLeft';
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
    case GameEventMessageKey.startTime:
      return l10n.gameEventStartTime(args![0] as int);
    case GameEventMessageKey.startReady:
      return l10n.gameEventStartReady;
    case GameEventMessageKey.startReportTip:
      return l10n.gameEventStartReportTip;
    case GameEventMessageKey.startGo:
      return l10n.gameEventStartGo;
    case GameEventMessageKey.policeMoveWarning:
      return l10n.gameEventPoliceMoveWarning;
    case GameEventMessageKey.policeMove:
      return l10n.gameEventPoliceMove;
    case GameEventMessageKey.locationReveal:
      return l10n.gameEventLocationReveal;
    case GameEventMessageKey.remainingRobbers:
      return l10n.gameEventRemainingRobbers(args![0] as int);
    case GameEventMessageKey.arrestNotice:
      return l10n.gameEventArrestNotice(args![0] as String, args[1] as String);
    case GameEventMessageKey.escapeNotice:
      return l10n.gameEventEscapeNotice;
    case GameEventMessageKey.fiveMinutesLeft:
      return l10n.gameEventFiveMinutesLeft;
    default:
      return key;
  }
}
