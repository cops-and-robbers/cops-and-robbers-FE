import 'package:flutter/services.dart';

import 'package:cops_and_robbers/core/services/app_icon/app_icon_identifiers.dart';

/// 동적 아이콘 네이티브 API에 대한 얇은 경계 래퍼.
///
/// 테스트에서는 이 인터페이스를 fake로 대체해 서비스 로직만 검증한다
/// (시스템 경계만 모킹 — `.claude/rules/Agents.md`).
abstract class DynamicIconClient {
  /// 단말이 alternate 아이콘을 지원하는지
  Future<bool> supportsAlternateIcons();

  /// 현재 적용된 alternate 식별자(null = Primary)
  Future<String?> currentAlternateIconName();

  /// 아이콘 적용(null = Primary로 리셋)
  Future<void> setAlternateIconName(String? name);
}

/// 동적 아이콘 미지원 플랫폼(iOS/Android 외)용 no-op 구현.
///
/// `supportsAlternateIcons()`가 false라 [AppIconService]가 set 호출 전에
/// early-return 한다. 이전의 `if(!_isIOS) return` 가드를 대체한다.
class NoopIconClient implements DynamicIconClient {
  const NoopIconClient();

  @override
  Future<bool> supportsAlternateIcons() async => false;

  @override
  Future<String?> currentAlternateIconName() async => null;

  @override
  Future<void> setAlternateIconName(String? name) async {}
}

/// 네이티브 채널(`cops_and_robbers/app_icon`) 기반 구현 — iOS·Android 공통.
///
/// 네이티브 해석:
/// - iOS: `app_icon_en`은 Primary(nil)로 매핑(`UIApplication.setAlternateIconName`).
/// - Android: `app_icon_en`은 기본 activity-alias enable.
///
/// 외부 의미는 `null = Primary(en)`을 유지하고, **네이티브 진입 직전에만**
/// `null → AppIconIdentifiers.en`으로 변환한다. 채널 미구현/예외 시 안전 기본값을 반환해
/// 부팅 흐름을 깨지 않는다(set은 [AppIconService]의 try-catch가 감싸므로 예외 전파 허용).
class NativeAppIconClient implements DynamicIconClient {
  const NativeAppIconClient();

  static const MethodChannel _channel = MethodChannel('cops_and_robbers/app_icon');

  @override
  Future<bool> supportsAlternateIcons() async {
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> currentAlternateIconName() async {
    try {
      final name = await _channel.invokeMethod<String>('getCurrentIcon');
      // en(기본/Primary)은 외부 의미상 null로 역변환 — skip-if-same 비교를 iOS와 일치시킴
      if (name == null || name == AppIconIdentifiers.en) return null;
      return name;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setAlternateIconName(String? name) async {
    // null(Primary)은 네이티브 진입 직전 en alias로 변환
    final target = name ?? AppIconIdentifiers.en;
    await _channel.invokeMethod<void>('setIcon', {'name': target});
  }
}
