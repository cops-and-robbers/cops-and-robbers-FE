import 'package:cops_and_robbers/features/user/domain/entities/agreement_status_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgreementStatusEntity.hasAllRequired', () {
    test('필수 3종 모두 true이면 true를 반환한다', () {
      const entity = AgreementStatusEntity(
        termsOfService: true,
        privacyPolicy: true,
        locationTerms: true,
        marketing: false,
      );

      expect(entity.hasAllRequired, true);
    });

    test('필수 중 하나라도 false이면 false를 반환한다', () {
      const entity = AgreementStatusEntity(
        termsOfService: true,
        privacyPolicy: false,
        locationTerms: true,
        marketing: true,
      );

      expect(entity.hasAllRequired, false);
    });

    test('마케팅만 true이고 필수가 모두 false이면 false를 반환한다', () {
      const entity = AgreementStatusEntity(
        termsOfService: false,
        privacyPolicy: false,
        locationTerms: false,
        marketing: true,
      );

      expect(entity.hasAllRequired, false);
    });
  });
}
