import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';

import 'package:cops_and_robbers/core/services/app_icon/startup_app_icon.dart';

/// 백그라운드 전환 시점에 앱 아이콘을 reconcile하는 옵저버.
///
/// Android는 사용 중(포그라운드) 토글이 강제 종료/런처 글리치를 유발할 수 있어,
/// 저장된 로케일에서 desired를 재계산해 **백그라운드 진입(paused/hidden)** ·
/// **종료 직전(detached, best-effort)** 에만 적용한다.
/// 등록은 [startLocaleAppIconObserver]가 Android에서만 수행한다.
///
/// paused → hidden이 연속으로 발화해도 [AppIconService.applyIconForIdentifier]의
/// skip-if-same 로직이 두 번째 호출을 흡수하므로 중복 토글은 발생하지 않는다.
class LocaleAppIconObserver with WidgetsBindingObserver {
  LocaleAppIconObserver({Future<void> Function()? onReconcile})
    : _onReconcile = onReconcile ?? applyStartupLocaleIcon;

  final Future<void> Function() _onReconcile;

  void start() => WidgetsBinding.instance.addObserver(this);

  void stop() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      // 비차단 — reconcile 실패해도 앱 흐름에 영향 없음(서비스가 swallow)
      unawaited(_onReconcile());
    }
  }
}

/// Android에서만 옵저버를 등록한다(iOS는 즉시 적용이라 불필요).
///
/// WidgetsBinding이 옵저버 참조를 보유하므로 GC되지 않는다.
LocaleAppIconObserver? startLocaleAppIconObserver() {
  if (!Platform.isAndroid) return null;
  return LocaleAppIconObserver()..start();
}
