import 'package:cops_and_robbers/core/constants/app_urls.dart';
import 'package:cops_and_robbers/core/constants/legal_doc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUrls.legalDocument', () {
    test('returns_no_prefix_for_korean', () {
      expect(
        AppUrls.legalDocument(LegalDoc.terms, 'ko'),
        'https://copsandrobbers.app/legal/terms/embed',
      );
    });

    test('returns_language_prefix_for_japanese', () {
      expect(
        AppUrls.legalDocument(LegalDoc.privacy, 'ja'),
        'https://copsandrobbers.app/ja/legal/privacy/embed',
      );
    });

    test('returns_language_prefix_for_english', () {
      expect(
        AppUrls.legalDocument(LegalDoc.location, 'en'),
        'https://copsandrobbers.app/en/legal/location/embed',
      );
    });

    test('falls_back_to_korean_for_unsupported_language', () {
      expect(
        AppUrls.legalDocument(LegalDoc.marketing, 'fr'),
        'https://copsandrobbers.app/legal/marketing/embed',
      );
    });

    test('covers_every_document', () {
      // 문서가 늘어나면 웹 라우트도 같이 생겨야 한다. 여기서 slug 를 고정해 둔다.
      expect(LegalDoc.values.map((doc) => doc.slug).toList(), [
        'terms',
        'privacy',
        'location',
        'marketing',
      ]);
    });
  });
}
