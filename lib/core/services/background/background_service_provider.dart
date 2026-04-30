import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'background_service.dart';
import 'background_service_android.dart';
import 'background_service_ios.dart';

part 'background_service_provider.g.dart';

/// 플랫폼별 BackgroundService 구현체를 제공하는 싱글톤 Provider
///
/// keepAlive: true → 게임 세션 라이프사이클을 넘어서도 동일 인스턴스 유지.
/// 게임 화면이 dispose되어도 isRunning 상태가 보존되어 재진입 시 정확한
/// idempotent 동작을 보장한다.
@Riverpod(keepAlive: true)
BackgroundService backgroundService(Ref ref) {
  if (Platform.isAndroid) {
    return BackgroundServiceAndroid();
  }
  if (Platform.isIOS) {
    return BackgroundServiceIos();
  }
  // 웹·데스크톱 등 기타 플랫폼 fallback — iOS와 동일하게 no-op
  return BackgroundServiceIos();
}
