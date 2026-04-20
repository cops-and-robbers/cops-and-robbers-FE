import 'package:cops_and_robbers/features/user/data/models/agreement_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgreementRequestModel', () {
    test('toJson은 4개 boolean 필드를 올바른 키로 직렬화한다', () {
      const model = AgreementRequestModel(
        termsOfService: true,
        privacyPolicy: true,
        locationTerms: true,
        marketing: false,
      );

      final json = model.toJson();

      expect(json, {
        'termsOfService': true,
        'privacyPolicy': true,
        'locationTerms': true,
        'marketing': false,
      });
    });

    test('fromJson은 JSON을 올바르게 역직렬화한다', () {
      final json = {
        'termsOfService': true,
        'privacyPolicy': false,
        'locationTerms': true,
        'marketing': true,
      };

      final model = AgreementRequestModel.fromJson(json);

      expect(model.termsOfService, true);
      expect(model.privacyPolicy, false);
      expect(model.locationTerms, true);
      expect(model.marketing, true);
    });

    test('copyWith는 지정된 필드만 변경한다', () {
      const original = AgreementRequestModel(
        termsOfService: true,
        privacyPolicy: true,
        locationTerms: true,
        marketing: false,
      );

      final updated = original.copyWith(marketing: true);

      expect(updated.termsOfService, true);
      expect(updated.privacyPolicy, true);
      expect(updated.locationTerms, true);
      expect(updated.marketing, true);
    });

    test('동일한 값의 두 인스턴스는 같다', () {
      const model1 = AgreementRequestModel(
        termsOfService: true,
        privacyPolicy: true,
        locationTerms: true,
        marketing: false,
      );

      const model2 = AgreementRequestModel(
        termsOfService: true,
        privacyPolicy: true,
        locationTerms: true,
        marketing: false,
      );

      expect(model1, model2);
      expect(model1.hashCode, model2.hashCode);
    });
  });
}
