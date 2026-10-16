// lib/features/game/presentation/widgets/start/chase_scene_rules.dart
import '../../../../../l10n/app_localizations.dart';

/// 장면이 쓰이는 곳 — ② 경찰 대기, ③ 도둑 설명, ⑤ ⓘ 규칙 다시 보기
enum ChaseSceneMode { policeWait, robberExplainer, rulesReplay }

/// 장면 왼쪽 아래에서 3초마다 바뀌는 규칙 줄. 위치 공개 주기는 방 설정값.
List<String> chaseSceneRules(
  AppLocalizations l10n, {
  required ChaseSceneMode mode,
  required bool isPolice,
  required int revealMinutes,
}) => switch (mode) {
  ChaseSceneMode.policeWait => [
    l10n.startRuleQrArrest,
    l10n.startRulePing,
    l10n.startRuleRobberReveal(revealMinutes),
    l10n.startRuleZoneLock,
  ],
  ChaseSceneMode.robberExplainer => [
    l10n.startRuleQrCaught,
    l10n.startRuleMyReveal(revealMinutes),
    l10n.startRulePing,
    l10n.startRuleJailbreak,
  ],
  ChaseSceneMode.rulesReplay => [
    l10n.startRuleWin,
    l10n.startRuleTeamReveal(revealMinutes),
    l10n.startRuleZone,
    isPolice ? l10n.startRuleQrArrest : l10n.startRuleQrCaught,
    l10n.startRulePing,
    l10n.startRuleJailbreakReplay,
  ],
};
