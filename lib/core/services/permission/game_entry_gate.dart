import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cops_and_robbers/core/services/background/background_service_provider.dart';
import 'package:cops_and_robbers/core/services/permission/location_permission_messages.dart';
import 'package:cops_and_robbers/core/services/permission/location_permission_service.dart';
import 'package:cops_and_robbers/core/widgets/dialogs/app_dialog.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

part 'game_entry_gate.g.dart';

/// 게임 진입 전 위치 권한 + (Android) 배터리 최적화 게이트.
///
/// 두 진입 화면(home_page, deeplink_join_page)이 공유한다.
/// 테스트에서 [gameEntryGateProvider] 를 override 해 결과를 주입할 수 있도록
/// 인터페이스로 노출한다.
abstract interface class GameEntryGate {
  /// 위치 권한 → (Android) 배터리 최적화 무시 게이트를 순차 평가한다.
  ///
  /// 모두 통과하면 true. 차단되면 안내 다이얼로그를 띄우고 **닫힐 때까지
  /// await 한 뒤** false 를 반환한다 (호출자가 라우팅 등 후속 처리를 안전한
  /// 시점에 수행하도록).
  ///
  /// 차단되어 false 를 반환한 경우, 사용자가 설정에서 권한을 허용하고 돌아와도
  /// 자동으로 재평가하지 않는다. 호출자가 적절한 시점(버튼 재탭/앱 resume 등)에
  /// 다시 [ensure] 를 호출해야 한다.
  Future<bool> ensure({
    required BuildContext context,
    required LocationPermissionContext locationContext,
  });
}

/// 실제 권한/배터리 판정을 수행하는 구현체.
///
/// home_page 의 기존 `_ensureLocationPermission` / `_ensureBatteryOptimization`
/// 로직을 그대로 이전했다. `State.mounted` 는 `context.mounted` 로 치환.
class GameEntryGateImpl implements GameEntryGate {
  GameEntryGateImpl(this._ref);

  final Ref _ref;

  @override
  Future<bool> ensure({
    required BuildContext context,
    required LocationPermissionContext locationContext,
  }) async {
    if (!await _ensureLocation(context, locationContext)) return false;
    if (!context.mounted) return false;
    return _ensureBattery(context);
  }

  /// 위치 권한 확인. 통과 시 true, 미허용 시 안내 다이얼로그 후 false.
  Future<bool> _ensureLocation(
    BuildContext context,
    LocationPermissionContext locationContext,
  ) async {
    // 네이티브 권한 판정이 throw 하면 호출자(딥링크)가 무한 로딩에 갇힐 수 있어
    // 본문 전체를 try-catch 로 감싸고, 예외 시 거부(false) 취급한다.
    try {
      if (await LocationPermissionService.canAccessLocation()) return true;

      final serviceEnabled = await LocationPermissionService.isServiceEnabled();
      if (!context.mounted) return false;

      final text = LocationPermissionMessages.getText(
        context: context,
        isServiceDisabled: !serviceEnabled,
        locationContext: locationContext,
      );
      final l10n = AppLocalizations.of(context);

      // 다이얼로그가 닫힐 때까지 await — 닫힌 뒤 false 를 반환해야 호출자(딥링크)가
      // 안전한 시점에 홈으로 라우팅할 수 있다.
      await AppDialog.show(
        context: context,
        title: text.title,
        message: text.message,
        confirmText: l10n.buttonGoToSettings,
        cancelText: l10n.buttonCancel,
        onConfirm: () async {
          if (!serviceEnabled) {
            await LocationPermissionService.openLocationSettings();
          } else {
            await LocationPermissionService.openAppSettings();
          }
        },
      );
      return false;
    } catch (e) {
      debugPrint('[GameEntryGate] 위치 권한 확인 실패: $e');
      return false;
    }
  }

  /// 배터리 최적화 무시 확인. Android release 만 검사, 그 외 즉시 true.
  Future<bool> _ensureBattery(BuildContext context) async {
    if (!Platform.isAndroid) return true;
    // 디버그 빌드에서는 테스트 편의를 위해 배터리 최적화 체크 생략
    if (kDebugMode) return true;

    // 네이티브 판정이 throw 하면 호출자(딥링크)가 무한 로딩에 갇힐 수 있어
    // 본문을 try-catch 로 감싸고, 예외 시 거부(false) 취급한다.
    try {
      // 다이얼로그 await 중 _ref 무효화 위험을 피하려 서비스 인스턴스를 미리 캡처
      final backgroundService = _ref.read(backgroundServiceProvider);
      final isIgnoring = await backgroundService
          .isIgnoringBatteryOptimizations();
      if (isIgnoring) return true;

      if (!context.mounted) return false;
      final l10n = AppLocalizations.of(context);
      await AppDialog.show(
        context: context,
        title: l10n.dialogBatteryGuideTitle,
        message:
            '${l10n.homePageBatteryGuideStep1}'
            '${l10n.homePageBatteryGuideStep2}',
        confirmText: l10n.buttonGoToSettings,
        cancelText: l10n.buttonCancel,
        onConfirm: () async {
          await backgroundService.openAppSettings();
        },
      );
      return false;
    } catch (e) {
      debugPrint('[GameEntryGate] 배터리 최적화 확인 실패: $e');
      return false;
    }
  }
}

/// 게임 진입 게이트 provider. 테스트에서 override 가능.
@Riverpod(keepAlive: true)
GameEntryGate gameEntryGate(Ref ref) => GameEntryGateImpl(ref);
