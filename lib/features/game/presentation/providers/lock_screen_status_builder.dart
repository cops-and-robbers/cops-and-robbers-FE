import 'package:intl/intl.dart';

import '../../../../core/services/background/lock_screen_status.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/reveal_schedule.dart';

/// 게임 값과 언어로 잠금 화면 현황을 만든다. 시각·네트워크에 닿지 않는 순수 함수.
LockScreenStatus buildLockScreenStatus({
  required DateTime start,
  required int roundMinutes,
  required int? policeWaitMinutes,
  required int? intervalMinutes,
  required DateTime now,
  required int? aliveRobbers,
  required int? totalRobbers,
  required bool isEventGame,
  required bool isRobberTeam,
  required AppLocalizations l10n,
}) {
  final nextReveal = nextRevealAt(
    start: start,
    policeWaitMinutes: policeWaitMinutes,
    intervalMinutes: intervalMinutes,
    now: now,
  );
  // 이벤트 모드는 체포해도 수감되지 않아 도주 중 수가 줄지 않는다 — 보여 주면 오해를 부른다.
  final showRobbers =
      !isEventGame && aliveRobbers != null && totalRobbers != null;

  return LockScreenStatus(
    startAt: start,
    endAt: start.add(Duration(minutes: roundMinutes)),
    nextRevealAt: nextReveal,
    aliveRobbers: showRobbers ? aliveRobbers : null,
    totalRobbers: showRobbers ? totalRobbers : null,
    title: l10n.appTitle,
    robbersText: showRobbers
        ? l10n.lockScreenRemainingRobbers(aliveRobbers, totalRobbers)
        : null,
    revealText: nextReveal == null
        ? null
        : l10n.lockScreenRevealAt(
            DateFormat.Hm(l10n.localeName).format(nextReveal.toLocal()),
          ),
    remainingTimeLabel: l10n.lockScreenRemainingTime,
    remainingRobbersLabel: l10n.fieldRemainingRobbers,
    locationRevealLabel: l10n.lockScreenLocationReveal,
    gameOverLabel: l10n.lockScreenGameOver,
    isRobberTeam: isRobberTeam,
    teamLabel: isRobberTeam ? l10n.gameRoleRobberLabel : l10n.gameRoleCopLabel,
    localeCode: l10n.localeName,
  );
}
