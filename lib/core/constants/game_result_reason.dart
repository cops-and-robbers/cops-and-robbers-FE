import '../../l10n/app_localizations.dart';

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
String gameOverReasonMessage(AppLocalizations l10n, String? reason) {
  switch (reason) {
    case GameResultReason.allArrested:
      return l10n.gameOverReasonAllArrested;
    case GameResultReason.timeOver:
      return l10n.gameOverReasonTimeUp;
    case GameResultReason.policeForfeited:
      return l10n.gameOverReasonPoliceForfeited;
    case GameResultReason.robberForfeited:
      return l10n.gameOverReasonRobberForfeited;
    default:
      return l10n.gameOverFallbackMessage;
  }
}
