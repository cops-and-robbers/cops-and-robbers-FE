import '../../l10n/app_localizations.dart';

/// 법적 문서 5종
///
/// 문서 하나에 웹 주소 하나와 화면 제목 하나가 대응합니다. 호출부가 주소나 제목을
/// 따로 넘기지 않게 해서, 이용약관 제목에 개인정보 문서를 띄우는 조합이 나올 수 없게
/// 합니다.
enum LegalDoc {
  /// 서비스 이용약관
  terms('terms'),

  /// 개인정보 처리방침
  privacy('privacy'),

  /// 위치정보 이용약관
  location('location'),

  /// 마케팅 정보 수신 동의
  marketing('marketing'),

  /// 오픈소스 라이선스 및 데이터 출처
  licenses('licenses');

  const LegalDoc(this.slug);

  /// 웹 주소와 앱 라우트 경로에 들어가는 조각
  ///
  /// dongsim-web 의 `content/legal/<로케일>/<slug>.json` 과 같은 값입니다.
  /// 바꾸면 웹 쪽 라우트도 같이 바뀌어야 합니다.
  final String slug;
}

/// 경로 조각을 문서 종류로 바꿉니다. 모르는 값이면 null 입니다.
///
/// `/legal/:doc` 라우트가 임의의 문자열을 받을 수 있어 필요합니다.
LegalDoc? legalDocFromSlug(String? slug) {
  for (final doc in LegalDoc.values) {
    if (doc.slug == slug) return doc;
  }
  return null;
}

/// 문서 종류를 현지화된 화면 제목으로 바꿉니다.
String legalDocTitle(AppLocalizations l10n, LegalDoc doc) {
  switch (doc) {
    case LegalDoc.terms:
      return l10n.linkTermsOfService;
    case LegalDoc.privacy:
      return l10n.linkPrivacyPolicy;
    case LegalDoc.location:
      return l10n.linkLocationTerms;
    case LegalDoc.marketing:
      return l10n.linkMarketingConsent;
    case LegalDoc.licenses:
      return l10n.settingsGuideOpenSourceLicenses;
  }
}
