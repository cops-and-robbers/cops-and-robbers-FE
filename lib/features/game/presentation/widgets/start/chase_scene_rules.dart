// lib/features/game/presentation/widgets/start/chase_scene_rules.dart
import '../../../../../core/constants/game_mode.dart';
import '../../../../../core/i18n/role_names.dart';
import '../../../../../l10n/app_localizations.dart';

/// 장면이 쓰이는 곳 — ② 경찰 대기, ③ 도둑 설명, ⑤ ⓘ 규칙 다시 보기
enum ChaseSceneMode { policeWait, robberExplainer, rulesReplay }

/// 장면 왼쪽 아래에서 3초마다 바뀌는 규칙 줄. 위치 공개 주기는 방 설정값.
List<String> chaseSceneRules(
  AppLocalizations l10n, {
  required GameMode gameMode,
  required ChaseSceneMode mode,
  required bool isPolice,
  required int revealMinutes,
}) => switch (mode) {
  ChaseSceneMode.policeWait => [
    byMode(
      gameMode,
      classic: l10n.startRuleQrArrest,
      tag: l10n.startRuleQrArrestTag,
    ),
    l10n.startRulePing,
    byMode(
      gameMode,
      classic: l10n.startRuleRobberReveal(revealMinutes),
      tag: l10n.startRuleRobberRevealTag(revealMinutes),
    ),
    l10n.startRuleZoneLock,
  ],
  ChaseSceneMode.robberExplainer => [
    byMode(
      gameMode,
      classic: l10n.startRuleQrCaught,
      tag: l10n.startRuleQrCaughtTag,
    ),
    byMode(
      gameMode,
      classic: l10n.startRuleMyReveal(revealMinutes),
      tag: l10n.startRuleMyRevealTag(revealMinutes),
    ),
    l10n.startRulePing,
    if (gameMode.usesJail) l10n.startRuleJailbreak,
  ],
  ChaseSceneMode.rulesReplay => [
    byMode(gameMode, classic: l10n.startRuleWin, tag: l10n.startRuleWinTag),
    byMode(
      gameMode,
      classic: l10n.startRuleTeamReveal(revealMinutes),
      tag: l10n.startRuleTeamRevealTag(revealMinutes),
    ),
    l10n.startRuleZone,
    isPolice
        ? byMode(
            gameMode,
            classic: l10n.startRuleQrArrest,
            tag: l10n.startRuleQrArrestTag,
          )
        : byMode(
            gameMode,
            classic: l10n.startRuleQrCaught,
            tag: l10n.startRuleQrCaughtTag,
          ),
    l10n.startRulePing,
    if (gameMode.usesJail) l10n.startRuleJailbreakReplay,
  ],
};
