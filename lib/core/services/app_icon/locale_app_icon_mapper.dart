import 'dart:ui';

import 'package:cops_and_robbers/core/i18n/locale_provider.dart';
import 'package:cops_and_robbers/core/services/app_icon/app_icon_identifiers.dart';

/// 인앱 유효 로케일 → iOS alternate 아이콘 식별자.
///
/// 반환 `null` = Primary(영어) 아이콘 사용.
/// 지원 외 로케일은 [kDefaultLocale](현재 en=Primary) 기준으로 매핑하여
/// 인앱 UI 폴백·영어 런처 이름과 아이콘을 일치시킨다.
String? alternateIconNameFor(Locale locale) {
  final code = _supportedCodeOrDefault(locale.languageCode);
  switch (code) {
    case 'ko':
      return AppIconIdentifiers.ko;
    case 'ja':
      return AppIconIdentifiers.ja;
    case 'en':
    default:
      return null; // Primary
  }
}

/// 지원 목록에 없는 코드는 기본 로케일 코드로 치환
String _supportedCodeOrDefault(String code) {
  final isSupported = kSupportedLocales.any((l) => l.languageCode == code);
  return isSupported ? code : kDefaultLocale.languageCode;
}
