import 'package:cops_and_robbers/core/services/background/lock_screen_status.dart';
import 'package:cops_and_robbers/core/services/background/method_channel_background_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

LockScreenStatus _status(int alive) => LockScreenStatus(
  startAt: DateTime.utc(2026, 9, 30, 10),
  endAt: DateTime.utc(2026, 9, 30, 10, 30),
  nextRevealAt: null,
  aliveRobbers: alive,
  totalRobbers: 5,
  title: 't',
  robbersText: 'r$alive',
  revealText: null,
  remainingTimeLabel: 'a',
  remainingRobbersLabel: 'b',
  locationRevealLabel: 'c',
  gameOverLabel: 'd',
  isRobberTeam: false,
  teamLabel: 'e',
  localeCode: 'ko',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelBackgroundService', () {
    late MethodChannelBackgroundService service;
    late List<MethodCall> calls;

    setUp(() {
      calls = [];
      const channel = MethodChannel(MethodChannelBackgroundService.channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return null;
          });
      service = MethodChannelBackgroundService(channel: channel);
    });

    tearDown(() {
      const channel = MethodChannel(MethodChannelBackgroundService.channelName);
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

    test('stop_clears_native_activity_when_dart_has_restarted', () async {
      await service.stop();
      await service.stop();

      // Dart의 초기 상태만으로 OS에 남은 Activity가 없다고 판단할 수 없다.
      expect(calls.map((c) => c.method).toList(), ['stop']);
      expect(service.isRunning, false);
    });

    test('marks_as_stopped_even_when_native_stop_throws', () async {
      // native stop이 PlatformException을 던지는 시나리오 시뮬레이션
      const channel = MethodChannel(MethodChannelBackgroundService.channelName);
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

      final failingService = MethodChannelBackgroundService(channel: channel);
      await failingService.start(gameId: 1);

      // native stop 실패해도 Dart 상태는 false로 정리되어야 함
      await failingService.stop();
      expect(failingService.isRunning, false);
    });
    test(
      'sends_latest_status_right_after_start_when_update_came_before_start',
      () async {
        await service.update(_status(4));
        await service.start(gameId: 1);

        expect(calls.map((c) => c.method).toList(), ['start', 'update']);
        expect(calls.last.arguments, {..._status(4).toMap(), 'gameId': 1});
      },
    );

    test(
      'sends_only_last_status_when_updated_several_times_before_start',
      () async {
        await service.update(_status(4));
        await service.update(_status(3));
        await service.start(gameId: 1);

        expect(
          calls
              .where((c) => c.method == 'update')
              .map((c) => c.arguments)
              .toList(),
          [
            {..._status(3).toMap(), 'gameId': 1},
          ],
        );
      },
    );

    test('sends_status_immediately_when_running', () async {
      await service.start(gameId: 1);
      await service.update(_status(2));

      expect(calls.map((c) => c.method).toList(), ['start', 'update']);
    });

    test(
      'does_not_resend_previous_game_status_when_restarted_after_stop',
      () async {
        await service.start(gameId: 1);
        await service.update(_status(2));
        await service.stop();
        calls.clear();

        await service.start(gameId: 2);

        expect(calls.map((c) => c.method).toList(), ['start']);
      },
    );

    test('clears_status_when_stopped_while_not_running', () async {
      await service.start(gameId: 1);
      await service.stop();
      await service.update(_status(2)); // 종료 뒤 늦게 온 값
      await service.stop(); // 실행 중이 아니어도 비워야 한다
      calls.clear();

      await service.start(gameId: 2);

      expect(calls.map((c) => c.method).toList(), ['start']);
    });

    test('keeps_status_for_next_start_when_native_start_fails', () async {
      const channel = MethodChannel(MethodChannelBackgroundService.channelName);
      var failStart = true;
      final recorded = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            recorded.add(call);
            if (call.method == 'start' && failStart) {
              throw PlatformException(code: 'FGS_NOT_ALLOWED');
            }
            return null;
          });
      final flaky = MethodChannelBackgroundService(channel: channel);

      await flaky.update(_status(4));
      await expectLater(
        flaky.start(gameId: 1),
        throwsA(isA<PlatformException>()),
      );
      failStart = false;
      await flaky.start(gameId: 1);

      expect(recorded.map((c) => c.method).toList(), [
        'start',
        'start',
        'update',
      ]);
    });

    test('update_does_not_throw_when_native_update_errors', () async {
      const channel = MethodChannel(MethodChannelBackgroundService.channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'update') throw PlatformException(code: 'ERROR');
            return null;
          });
      final failing = MethodChannelBackgroundService(channel: channel);
      await failing.start(gameId: 1);

      await expectLater(failing.update(_status(1)), completes);
    });
  });
}
