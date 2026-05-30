import 'dart:ui';

import 'package:cops_and_robbers/core/services/app_icon/app_icon_identifiers.dart';
import 'package:cops_and_robbers/core/services/app_icon/locale_app_icon_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('alternateIconNameFor', () {
    test('mapper_returns_null_when_locale_is_en', () {
      expect(alternateIconNameFor(const Locale('en')), isNull);
    });

    test('mapper_returns_ko_identifier_when_locale_is_ko', () {
      expect(alternateIconNameFor(const Locale('ko')), AppIconIdentifiers.ko);
    });

    test('mapper_returns_ja_identifier_when_locale_is_ja', () {
      expect(alternateIconNameFor(const Locale('ja')), AppIconIdentifiers.ja);
    });

    test('mapper_falls_back_to_en_primary_when_locale_unsupported', () {
      // 지원 외 로케일(프랑스어)은 기본 로케일(en=Primary)로 폴백 — 영어 앱 이름/UI와 일치
      expect(alternateIconNameFor(const Locale('fr')), isNull);
    });
  });

  test('AppIconIdentifiers_en_equals_app_icon_en', () {
    expect(AppIconIdentifiers.en, 'app_icon_en');
  });
}
