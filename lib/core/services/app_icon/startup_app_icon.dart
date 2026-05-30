import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:cops_and_robbers/core/i18n/locale_provider.dart';
import 'package:cops_and_robbers/core/services/app_icon/app_icon_service.dart';
import 'package:cops_and_robbers/core/services/app_icon/locale_app_icon_mapper.dart';

/// 앱 콜드 부팅 시 1회 호출 — 유효 로케일에 맞는 아이콘을 적용한다.
///
/// 흐름: 저장/시스템 로케일 해석 → alternate 식별자 매핑 → 서비스 적용.
Future<void> applyStartupLocaleIcon({AppIconService? service}) async {
  try {
    final locale = await resolveStartupLocale();
    await applyLocaleIcon(locale, service: service);
  } catch (e, stackTrace) {
    // 부팅 아이콘 적용은 비핵심 side effect — 실패해도 앱 흐름(main의 unawaited 경로)을 깨지 않도록 흡수
    debugPrint('[AppIcon] ❌ 부팅 아이콘 적용 실패(무시): $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

/// 지정한 로케일에 맞는 앱 아이콘을 즉시 적용한다.
Future<void> applyLocaleIcon(Locale locale, {AppIconService? service}) async {
  final target = alternateIconNameFor(locale);
  await (service ?? AppIconService()).applyIconForIdentifier(target);
}
