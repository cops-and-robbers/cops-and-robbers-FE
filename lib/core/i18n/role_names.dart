import '../../l10n/app_localizations.dart';
import '../constants/game_mode.dart';

/// 팀/역할 표시 이름의 단일 출처. 서버 팀 값(POLICE/ROBBER)은 그대로 두고
/// 화면에 보이는 이름만 모드별로 바꾼다.
String teamName(
  AppLocalizations l10n,
  GameMode mode, {
  required bool isPolice,
}) {
  if (mode == GameMode.hideAndSeek) {
    return isPolice ? l10n.gameTeamSeeker : l10n.gameTeamHider;
  }
  return isPolice ? l10n.gameTeamCop : l10n.gameTeamRobber;
}

String roleLabel(
  AppLocalizations l10n,
  GameMode mode, {
  required bool isPolice,
}) {
  if (mode == GameMode.hideAndSeek) {
    return isPolice ? l10n.gameRoleSeekerLabel : l10n.gameRoleHiderLabel;
  }
  return isPolice ? l10n.gameRoleCopLabel : l10n.gameRoleRobberLabel;
}

String modeName(AppLocalizations l10n, GameMode mode) =>
    mode == GameMode.hideAndSeek
    ? l10n.gameModeHideAndSeek
    : l10n.gameModeCopsAndRobbers;

/// 술래잡기면 `tag`, 그 외(알 수 없는 모드 포함)는 `classic` 문구를 쓴다.
String byMode(GameMode mode, {required String classic, required String tag}) =>
    mode == GameMode.hideAndSeek ? tag : classic;
