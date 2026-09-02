import 'package:cops_and_robbers/core/constants/legal_doc.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('ko'));

  group('legalDocFromSlug', () {
    test('returns_document_for_every_known_slug', () {
      for (final doc in LegalDoc.values) {
        expect(legalDocFromSlug(doc.slug), doc);
      }
    });

    test('returns_null_for_unknown_slug', () {
      expect(legalDocFromSlug('unknown'), isNull);
      expect(legalDocFromSlug(''), isNull);
      expect(legalDocFromSlug(null), isNull);
    });
  });

  group('legalDocTitle', () {
    test('returns_matching_title_for_each_document', () {
      expect(legalDocTitle(l10n, LegalDoc.terms), l10n.linkTermsOfService);
      expect(legalDocTitle(l10n, LegalDoc.privacy), l10n.linkPrivacyPolicy);
      expect(legalDocTitle(l10n, LegalDoc.location), l10n.linkLocationTerms);
      expect(
        legalDocTitle(l10n, LegalDoc.marketing),
        l10n.linkMarketingConsent,
      );
      expect(
        legalDocTitle(l10n, LegalDoc.licenses),
        l10n.settingsGuideOpenSourceLicenses,
      );
    });

    test('returns_distinct_titles', () {
      // 제목이 겹치면 화면에서 어느 문서인지 구분되지 않는다.
      final titles = LegalDoc.values.map((d) => legalDocTitle(l10n, d)).toSet();
      expect(titles.length, LegalDoc.values.length);
    });
  });

  group('legalDocumentOf', () {
    test('builds_path_the_router_guard_recognizes', () {
      // 라우터가 로그인·약관 동의 이전에도 통과시키는 조건이 이 접두사다.
      for (final doc in LegalDoc.values) {
        final path = RoutePaths.legalDocumentOf(doc);
        expect(path.startsWith('${RoutePaths.legalDocument}/'), isTrue);
        expect(legalDocFromSlug(Uri.parse(path).pathSegments.last), doc);
      }
    });
  });
}
