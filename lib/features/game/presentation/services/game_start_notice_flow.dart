import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/battery_impact_notice_dialog.dart';
import '../widgets/battery_optimization_notice_dialog.dart';

/// 게임 시작 시 1회성 안내 다이얼로그 플로우
///
/// 표시 순서 (각각 1회만):
/// 1. 배터리 최적화 안내 (Android 전용) — 절전 모드 제외 방법 안내
/// 2. 배터리 영향 안내 (iOS/Android 공통) — GPS·통신 소모 사전 고지
///
/// SharedPreferences로 표시 여부 영속화.
/// 첫 번째 다이얼로그를 [확인]으로 닫아야 두 번째가 나타남 (await 순차 처리).
class GameStartNoticeFlow {
  // 유틸 클래스 — 인스턴스화 금지
  GameStartNoticeFlow._();

  // SharedPreferences 키: 충돌 방지를 위해 background_service_ 접두어 사용
  static const _kBatteryOptShownKey = 'background_service_battery_opt_shown';
  static const _kBatteryNoticeShownKey =
      'background_service_battery_notice_shown';

  /// 아직 보여주지 않은 안내 다이얼로그를 순서대로 표시
  ///
  /// [context]는 유효한 BuildContext여야 함. 비동기 사이마다 mounted를 검사하므로
  /// context가 무효화되면 즉시 반환.
  ///
  /// 호출 위치: GamePage initState의 addPostFrameCallback 내부.
  static Future<void> showOnceIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. 배터리 최적화 안내 (Android만, 1회)
    if (Platform.isAndroid) {
      final shown = prefs.getBool(_kBatteryOptShownKey) ?? false;
      if (!shown) {
        // 저장을 먼저 해서 다이얼로그 중 앱이 종료돼도 재표시되지 않게 함
        await prefs.setBool(_kBatteryOptShownKey, true);
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (_) => const BatteryOptimizationNoticeDialog(),
        );
      }
    }

    // 2. 배터리 영향 안내 (양 플랫폼, 1회)
    if (!context.mounted) return;
    final noticeShown = prefs.getBool(_kBatteryNoticeShownKey) ?? false;
    if (!noticeShown) {
      await prefs.setBool(_kBatteryNoticeShownKey, true);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => const BatteryImpactNoticeDialog(),
      );
    }
  }
}
