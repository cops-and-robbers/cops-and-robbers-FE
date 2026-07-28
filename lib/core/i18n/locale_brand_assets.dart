import 'dart:ui';

import 'package:cops_and_robbers/core/i18n/locale_provider.dart';

/// 로케일별 인앱 브랜드 에셋 경로 해석.
///
/// 네이티브 런처 아이콘(`locale_app_icon_mapper.dart`)과 별개로,
/// 화면 안에서 직접 렌더링하는 워드마크 로고/스플래시 일러스트를 다룬다.
/// 미지원 로케일은 [kDefaultLocale](en)로 폴백해 인앱 텍스트와 톤을 맞춘다.

/// 워드마크 로고 (login, home 상단 브랜드) — SvgPicture로 렌더링
String localizedAppLogo(Locale locale) =>
    'assets/app_logos/app_logo_${_codeOrDefault(locale.languageCode)}.svg';

/// 로고 락업 (사이렌 심볼 + 워드마크 가로 조합) — 공유 이미지 하단 워터마크용
///
/// 워드마크 단독([localizedAppLogo])과 달리 심볼이 함께 있어 앱 식별이 쉽다.
/// 심볼 색이 팀 테마별로 달라(라이트=파랑 / 다크=초록) 단색 틴트로는 대체 못 하므로
/// 로케일 × 테마 조합만큼 에셋을 둔다.
String localizedAppLogoLockup(Locale locale, {required bool isDarkMode}) =>
    'assets/app_logos/app_logo_lockup_'
    '${_codeOrDefault(locale.languageCode)}_'
    '${isDarkMode ? 'dark' : 'light'}.svg';

/// 스플래시 일러스트 (splash, force_update, maintenance) — SvgPicture로 렌더링
String localizedAppSplash(Locale locale) =>
    'assets/app_splashs/app_splash_${_codeOrDefault(locale.languageCode)}.svg';

/// 지원 목록에 없는 코드는 기본 로케일 코드로 치환
String _codeOrDefault(String code) =>
    kSupportedLocales.any((l) => l.languageCode == code)
    ? code
    : kDefaultLocale.languageCode;
