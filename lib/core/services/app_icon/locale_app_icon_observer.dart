import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, visibleForTesting;
import 'package:flutter/widgets.dart';

import 'package:cops_and_robbers/core/services/app_icon/startup_app_icon.dart';

/// 플랫폼별로 로케일 앱 아이콘 reconcile를 수행해도 "안전한" lifecycle 상태 집합.
///
/// - iOS: resumed(앱 active)에서만. UIApplication.setAlternateIconName은 앱이
///   active 상태가 아니면 "작업이 취소되었습니다"로 실패한다(콜드 부팅 직후 호출 실패의 원인).
/// - Android: paused/hidden/detached(백그라운드)에서만. 포그라운드에서
///   activity-alias를 토글하면 런처가 앱 태스크를 재시작/강퇴시킬 수 있다.
/// - 그 외 플랫폼: null(미지원) → 옵저버를 등록하지 않는다(no-op).
Set<AppLifecycleState>? iconReconcileTriggers(TargetPlatform platform) {
  switch (platform) {
    case TargetPlatform.iOS:
      return const {AppLifecycleState.resumed};
    case TargetPlatform.android:
      return const {
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.detached,
      };
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return null;
  }
}

/// 앱 lifecycle 전환 시점에 저장된 로케일 기준으로 앱 아이콘을 reconcile한다.
///
/// 적용 시점은 [iconReconcileTriggers]가 플랫폼별로 결정한 [triggers] 집합으로 제어한다.
/// 콜드 부팅 직후(runApp 직후)의 동기 호출은 iOS에서 active 전이라 실패하므로,
/// 이 옵저버가 안전한 시점(iOS=resumed, Android=백그라운드)에만 적용한다.
class LocaleAppIconObserver with WidgetsBindingObserver {
  LocaleAppIconObserver({
    required Set<AppLifecycleState> triggers,
    Future<void> Function()? onReconcile,
    AppLifecycleState? Function()? currentState,
  }) : _triggers = triggers,
       _onReconcile = onReconcile ?? applyStartupLocaleIcon,
       _currentState =
           currentState ?? (() => WidgetsBinding.instance.lifecycleState);

  final Set<AppLifecycleState> _triggers;
  final Future<void> Function() _onReconcile;
  final AppLifecycleState? Function() _currentState;

  /// 등록 시점에 이미 trigger 상태(예: iOS resumed)면 이후 lifecycle 콜백이
  /// 오지 않을 수 있어 초기 catch-up이 필요한지 여부.
  @visibleForTesting
  bool needsInitialReconcile() {
    final current = _currentState();
    return current != null && _triggers.contains(current);
  }

  void start() {
    WidgetsBinding.instance.addObserver(this);
    // 초기 catch-up: 동기 즉시 호출은 runApp 직후 타이밍과 겹쳐 iOS "cancelled"를
    // 재현할 수 있으므로, 1프레임 뒤로 미뤄 앱이 확실히 그려진 뒤 적용한다.
    if (needsInitialReconcile()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_onReconcile());
      });
    }
  }

  void stop() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_triggers.contains(state)) {
      // 비차단 — reconcile 실패해도 앱 흐름에 영향 없음(서비스가 swallow)
      unawaited(_onReconcile());
    }
  }
}

/// 현재 플랫폼에 맞는 옵저버를 등록한다.
///
/// iOS·Android만 등록(트리거 시점이 다름). 그 외 플랫폼은 null 반환(no-op).
/// WidgetsBinding이 옵저버 참조를 보유하므로 GC되지 않는다.
LocaleAppIconObserver? startLocaleAppIconObserver({TargetPlatform? platform}) {
  final triggers = iconReconcileTriggers(platform ?? defaultTargetPlatform);
  if (triggers == null) return null;
  return LocaleAppIconObserver(triggers: triggers)..start();
}
