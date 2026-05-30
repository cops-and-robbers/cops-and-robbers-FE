import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import 'package:cops_and_robbers/core/services/app_icon/dynamic_icon_client.dart';

/// 인앱 로케일에 맞춰 앱 아이콘을 적용하는 서비스.
///
/// 플랫폼별 [DynamicIconClient]를 선택한다:
/// - iOS·Android → [NativeAppIconClient] (자체 네이티브 채널 — iOS alternate 아이콘 / Android activity-alias)
/// - 그 외 → [NoopIconClient] (미지원, no-op)
///
/// 다음 경우 set을 호출하지 않는다(불필요한 토글/알럿 방지):
/// - client가 alternate 아이콘 미지원
/// - 현재 아이콘이 이미 목표와 동일
class AppIconService {
  AppIconService({DynamicIconClient? client})
    : _client = client ?? _defaultClientForPlatform();

  final DynamicIconClient _client;

  /// 목표 식별자로 아이콘 적용. `null`이면 Primary(en).
  Future<void> applyIconForIdentifier(String? targetAlternateName) async {
    final supported = await _client.supportsAlternateIcons();
    if (!supported) return;

    final current = await _client.currentAlternateIconName();
    if (current == targetAlternateName) return; // 변화 없음 → 토글/알럿 없음

    try {
      await _client.setAlternateIconName(targetAlternateName);
    } catch (e) {
      // 아이콘 교체 실패는 치명적이지 않음 — 로그만 남기고 앱 흐름 유지
      debugPrint('[AppIcon] ❌ 아이콘 교체 실패: $e');
    }
  }
}

/// 실행 플랫폼에 맞는 client 선택. 생성자에서 client 미주입 시에만 평가된다.
///
/// iOS·Android 모두 자체 네이티브 채널([NativeAppIconClient])을 공유한다
/// (iOS: AppDelegate, Android: MainActivity). 그 외 플랫폼은 no-op.
DynamicIconClient _defaultClientForPlatform() {
  if (Platform.isIOS || Platform.isAndroid) return const NativeAppIconClient();
  return const NoopIconClient();
}
