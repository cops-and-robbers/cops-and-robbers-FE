import '../../l10n/app_localizations.dart';
import '../i18n/role_names.dart';
import 'game_mode.dart';

/// 게임 종료 사유 (서버 API enum)
class GameResultReason {
  GameResultReason._();

  static const String allArrested = 'ALL_ARRESTED';
  static const String timeOver = 'TIME_OVER';
  static const String policeForfeited = 'POLICE_FORFEITED';
  static const String robberForfeited = 'ROBBER_FORFEITED';
}

/// 게임 종료 사유(서버 reason 문자열)를 현지화된 표시 문구로 변환한다.
///
/// 미상/null 사유는 중립 폴백(gameOverFallbackMessage)으로 처리한다.
String gameOverReasonMessage(
  AppLocalizations l10n,
  String? reason, {
  required GameMode mode,
}) {
  switch (reason) {
    case GameResultReason.allArrested:
      return byMode(
        mode,
        classic: l10n.gameOverReasonAllArrested,
        tag: l10n.gameOverReasonAllArrestedTag,
      );
    case GameResultReason.timeOver:
      return l10n.gameOverReasonTimeUp;
    case GameResultReason.policeForfeited:
      return byMode(
        mode,
        classic: l10n.gameOverReasonPoliceForfeited,
        tag: l10n.gameOverReasonPoliceForfeitedTag,
      );
    case GameResultReason.robberForfeited:
      return byMode(
        mode,
        classic: l10n.gameOverReasonRobberForfeited,
        tag: l10n.gameOverReasonRobberForfeitedTag,
      );
    default:
      return l10n.gameOverFallbackMessage;
  }
}
