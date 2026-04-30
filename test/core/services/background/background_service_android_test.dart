import 'package:cops_and_robbers/core/services/background/background_service_android.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackgroundServiceAndroid', () {
    late BackgroundServiceAndroid service;
    late List<MethodCall> calls;

    setUp(() {
      calls = [];
      const channel = MethodChannel(BackgroundServiceAndroid.channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return null;
          });
      service = BackgroundServiceAndroid(channel: channel);
    });

    tearDown(() {
      const channel = MethodChannel(BackgroundServiceAndroid.channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('starts_native_service_when_first_called', () async {
      await service.start(gameId: 42);

      expect(calls.map((c) => c.method).toList(), ['start']);
      expect(service.isRunning, true);
    });

    test('start_is_idempotent_when_already_running', () async {
      await service.start(gameId: 1);
      await service.start(gameId: 1);

      // 두 번 호출해도 native start는 한 번만 전달되어야 함
      expect(calls.where((c) => c.method == 'start').length, 1);
    });

    test('stops_native_service_after_start', () async {
      await service.start(gameId: 1);
      await service.stop();

      expect(calls.map((c) => c.method).toList(), ['start', 'stop']);
      expect(service.isRunning, false);
    });

    test('stop_is_no_op_when_not_running', () async {
      await service.stop();

      // 실행 중이 아닐 때 stop → native 채널 호출 없음
      expect(calls, isEmpty);
      expect(service.isRunning, false);
    });

    test('marks_as_stopped_even_when_native_stop_throws', () async {
      // native stop이 PlatformException을 던지는 시나리오 시뮬레이션
      const channel = MethodChannel(BackgroundServiceAndroid.channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'stop') {
              throw PlatformException(
                code: 'ERROR',
                message: 'Service not found',
              );
            }
            return null;
          });

      final failingService = BackgroundServiceAndroid(channel: channel);
      await failingService.start(gameId: 1);

      // native stop 실패해도 Dart 상태는 false로 정리되어야 함
      await failingService.stop();
      expect(failingService.isRunning, false);
    });
  });
}
