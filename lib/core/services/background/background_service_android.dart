import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'background_service.dart';

/// Android Foreground Service를 MethodChannel로 호출하는 구현체
///
/// MainActivity.kt에 등록된 `cops_and_robbers/background_service` 채널과
/// 통신하여 Foreground Service의 생애주기를 제어한다.
class BackgroundServiceAndroid implements BackgroundService {
  /// MethodChannel 명. MainActivity.kt와 반드시 일치해야 함.
  @visibleForTesting
  static const channelName = 'cops_and_robbers/background_service';

  final MethodChannel _channel;
  bool _isRunning = false;

  BackgroundServiceAndroid({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> start({required int gameId}) async {
    // 멱등 + 동시성 가드: 상태를 await 이전에 선반영(optimistic)해서
    // start/stop 교차 호출(예: 게임 화면 진입 직후 즉시 dispose) 시
    // stop 쪽 멱등 가드가 잘못 빠져나가는 race를 방지.
    if (_isRunning) return;
    _isRunning = true;

    try {
      await _channel.invokeMethod('start');
      debugPrint('[BackgroundService.Android] ✅ start (gameId=$gameId)');
    } catch (e, stack) {
      _isRunning = false; // 실패 시 롤백
      debugPrint('[BackgroundService.Android] ❌ start 실패: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    // 멱등 + 동시성 가드: start와 동일한 이유로 선반영.
    if (!_isRunning) return;
    _isRunning = false;

    try {
      await _channel.invokeMethod('stop');
      debugPrint('[BackgroundService.Android] ✅ stop');
    } catch (e, stack) {
      // native stop 실패해도 Dart 상태는 종료로 유지.
      // FGS는 어차피 OS가 정리하거나 다음 start에서 재초기화됨.
      debugPrint('[BackgroundService.Android] ❌ stop 실패: $e');
      debugPrint('Stack: $stack');
    }
  }

  @override
  Future<void> openAppSettings() async {
    // 사용자 명시적 [설정 열기] 탭에 의해서만 호출됨.
    // MainActivity.kt의 openAppSettings()가 Settings.ACTION_APPLICATION_DETAILS_SETTINGS 실행.
    try {
      await _channel.invokeMethod('openAppSettings');
      debugPrint('[BackgroundService.Android] ✅ openAppSettings');
    } catch (e, stack) {
      debugPrint('[BackgroundService.Android] ❌ openAppSettings 실패: $e');
      debugPrint('Stack: $stack');
    }
  }

  @override
  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isIgnoringBatteryOptimizations',
      );
      return result ?? false;
    } catch (e, stack) {
      debugPrint(
        '[BackgroundService.Android] ❌ isIgnoringBatteryOptimizations 실패: $e',
      );
      debugPrint('Stack: $stack');
      // 실패 시 false 반환 → 사용자에게 다이얼로그 표시 (안전 디폴트)
      return false;
    }
  }
}
