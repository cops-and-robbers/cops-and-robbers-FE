import 'package:flutter/foundation.dart';

import 'background_service.dart';

/// iOS no-op BackgroundService 구현체
///
/// iOS는 UIBackgroundModes=location + geolocator AppleSettings 설정으로
/// OS가 자동으로 백그라운드 위치 추적을 처리한다. 별도 native 호출 불필요.
///
/// 일관된 인터페이스 제공 + 논리적 실행 상태 추적을 위해 추상화 안에 둔다.
class BackgroundServiceIos implements BackgroundService {
  bool _isRunning = false;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> start({required int gameId}) async {
    // 멱등: 이미 "실행 중"으로 표시되어 있으면 중복 로그 방지
    if (_isRunning) return;

    _isRunning = true;
    debugPrint(
      '[BackgroundService.iOS] ✅ start (gameId=$gameId) '
      '— no-op (geolocator AppleSettings에 위임)',
    );
  }

  @override
  Future<void> stop() async {
    // 멱등: 실행 중이 아니면 상태 변경 없음
    if (!_isRunning) return;

    _isRunning = false;
    debugPrint('[BackgroundService.iOS] ✅ stop — no-op');
  }

  @override
  Future<void> openAppSettings() async {
    // iOS는 별도 배터리 최적화 설정이 없어 no-op
    debugPrint('[BackgroundService.iOS] ✅ openAppSettings — no-op');
  }
}
