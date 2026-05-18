import '../../../../l10n/app_localizations.dart';

/// 채팅 신고 카테고리
///
/// API reportType 매핑:
/// bait→FISHING, abuse→VERBAL_ABUSE, impersonation→IMPERSONATION,
/// spam→SPAM, exploit→CHEATING, teamSabotage→DEMORALIZATION, other→ETC
enum ReportCategory {
  bait('낚시/놀람/도배', 'FISHING'),
  abuse('욕설/비하', 'VERBAL_ABUSE'),
  impersonation('사칭/사기', 'IMPERSONATION'),
  spam('광고/스팸', 'SPAM'),
  exploit('부정 행위/버그 악용', 'CHEATING'),
  teamSabotage('팀 사기 저하', 'DEMORALIZATION'),
  other('기타(직접 작성)', 'ETC');

  const ReportCategory(this.label, this.apiType);

  /// UI에 표시할 한글 라벨 (i18n 폴백용)
  ///
  /// 사용자 노출용으로는 [localizedLabel]을 사용한다.
  final String label;

  /// API reportType 값
  final String apiType;

  /// 다국어 라벨 — UI에서 사용
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ReportCategory.bait => l10n.reportCategoryBait,
    ReportCategory.abuse => l10n.reportCategoryAbuse,
    ReportCategory.impersonation => l10n.reportCategoryImpersonation,
    ReportCategory.spam => l10n.reportCategorySpam,
    ReportCategory.exploit => l10n.reportCategoryExploit,
    ReportCategory.teamSabotage => l10n.reportCategoryTeamSabotage,
    ReportCategory.other => l10n.reportCategoryOther,
  };
}
