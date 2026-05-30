import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import 'package:cops_and_robbers/core/services/app_icon/dynamic_icon_client.dart';

/// 인앱 로케일에 맞춰 iOS 앱 아이콘을 적용하는 서비스.
///
/// 부팅 시 1회 호출되며, 다음 경우 아무것도 하지 않는다:
/// - iOS가 아님(Android는 이번 범위 밖)
/// - 단말이 alternate 아이콘 미지원
/// - 현재 아이콘이 이미 목표와 동일(불필요한 iOS 시스템 알럿 방지)
class AppIconService {
  AppIconService({DynamicIconClient? client, bool? isIOS})
    : _client = client ?? const FlutterDynamicIconClient(),
      _isIOS = isIOS ?? Platform.isIOS;

  final DynamicIconClient _client;
  final bool _isIOS;

  /// 목표 alternate 식별자로 아이콘 적용. `null`이면 Primary(영어).
  Future<void> applyIconForIdentifier(String? targetAlternateName) async {
    if (!_isIOS) return;

    final supported = await _client.supportsAlternateIcons();
    if (!supported) return;

    final current = await _client.currentAlternateIconName();
    if (current == targetAlternateName) return; // 변화 없음 → 알럿 없음

    try {
      await _client.setAlternateIconName(targetAlternateName);
    } catch (e) {
      // 아이콘 교체 실패는 치명적이지 않음 — 로그만 남기고 앱 흐름 유지
      debugPrint('[AppIcon] ❌ 아이콘 교체 실패: $e');
    }
  }
}
