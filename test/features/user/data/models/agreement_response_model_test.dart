import 'package:cops_and_robbers/features/user/data/models/agreement_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgreementResponseModel', () {
    test('fromJson은 4개 boolean 필드와 시각 필드를 역직렬화한다', () {
      final json = {
        'termsOfServiceAgreed': true,
        'privacyPolicyAgreed': false,
        'locationTermsAgreed': true,
        'marketingAgreed': false,
        'termsAgreedAt': '2026-04-15T10:00:00+09:00',
        'marketingAgreedAt': null,
      };

      final model = AgreementResponseModel.fromJson(json);

      expect(model.termsOfServiceAgreed, true);
      expect(model.privacyPolicyAgreed, false);
      expect(model.locationTermsAgreed, true);
      expect(model.marketingAgreed, false);
      expect(model.termsAgreedAt, '2026-04-15T10:00:00+09:00');
      expect(model.marketingAgreedAt, isNull);
    });

    test('시각 필드 없이도 역직렬화된다 (nullable)', () {
      final json = {
        'termsOfServiceAgreed': false,
        'privacyPolicyAgreed': false,
        'locationTermsAgreed': false,
        'marketingAgreed': false,
      };

      final model = AgreementResponseModel.fromJson(json);

      expect(model.termsAgreedAt, isNull);
      expect(model.marketingAgreedAt, isNull);
    });
  });
}
