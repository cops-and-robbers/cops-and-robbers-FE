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
    // 멱등: 이미 실행 중이면 native 호출 생략
    if (_isRunning) return;

    try {
      await _channel.invokeMethod('start');
      _isRunning = true;
      debugPrint('[BackgroundService.Android] ✅ start (gameId=$gameId)');
    } catch (e, stack) {
      debugPrint('[BackgroundService.Android] ❌ start 실패: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    // 멱등: 실행 중이 아니면 native 호출 생략
    if (!_isRunning) return;

    try {
      await _channel.invokeMethod('stop');
      _isRunning = false;
      debugPrint('[BackgroundService.Android] ✅ stop');
    } catch (e, stack) {
      debugPrint('[BackgroundService.Android] ❌ stop 실패: $e');
      debugPrint('Stack: $stack');
      // native stop이 실패해도 Dart 상태는 종료로 정리.
      // 재시도 시 idempotent 동작을 보장하기 위함.
      _isRunning = false;
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
}
