import 'package:cops_and_robbers/core/services/app_icon/locale_app_icon_observer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iconReconcileTriggers', () {
    test('returns_only_resumed_for_ios', () {
      expect(iconReconcileTriggers(TargetPlatform.iOS), {
        AppLifecycleState.resumed,
      });
    });

    test('returns_background_states_for_android', () {
      expect(iconReconcileTriggers(TargetPlatform.android), {
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.detached,
      });
    });

    test('returns_null_for_unsupported_platforms', () {
      for (final p in const [
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.fuchsia,
      ]) {
        expect(iconReconcileTriggers(p), isNull, reason: '$p must be no-op');
      }
    });
  });

  group('LocaleAppIconObserver.didChangeAppLifecycleState', () {
    test('reconciles_when_state_in_triggers', () {
      var calls = 0;
      final obs = LocaleAppIconObserver(
        triggers: const {AppLifecycleState.resumed},
        onReconcile: () async => calls++,
        currentState: () => null,
      );

      obs.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(calls, 1);
    });

    test('does_not_reconcile_when_state_not_in_triggers', () {
      var calls = 0;
      final obs = LocaleAppIconObserver(
        triggers: const {AppLifecycleState.resumed},
        onReconcile: () async => calls++,
        currentState: () => null,
      );

      obs.didChangeAppLifecycleState(AppLifecycleState.paused);
      obs.didChangeAppLifecycleState(AppLifecycleState.inactive);

      expect(calls, 0);
    });

    test('reconciles_on_each_android_background_state', () {
      var calls = 0;
      final obs = LocaleAppIconObserver(
        triggers: const {
          AppLifecycleState.paused,
          AppLifecycleState.hidden,
          AppLifecycleState.detached,
        },
        onReconcile: () async => calls++,
        currentState: () => null,
      );

      obs.didChangeAppLifecycleState(AppLifecycleState.paused);
      obs.didChangeAppLifecycleState(AppLifecycleState.hidden);
      obs.didChangeAppLifecycleState(AppLifecycleState.detached);
      obs.didChangeAppLifecycleState(AppLifecycleState.resumed); // 무시됨

      expect(calls, 3);
    });
  });

  group('LocaleAppIconObserver.needsInitialReconcile', () {
    test('true_when_current_state_in_triggers', () {
      final obs = LocaleAppIconObserver(
        triggers: const {AppLifecycleState.resumed},
        onReconcile: () async {},
        currentState: () => AppLifecycleState.resumed,
      );

      expect(obs.needsInitialReconcile(), isTrue);
    });

    test('false_when_current_state_not_in_triggers', () {
      final obs = LocaleAppIconObserver(
        triggers: const {AppLifecycleState.resumed},
        onReconcile: () async {},
        currentState: () => AppLifecycleState.inactive,
      );

      expect(obs.needsInitialReconcile(), isFalse);
    });

    test('false_when_current_state_null', () {
      final obs = LocaleAppIconObserver(
        triggers: const {AppLifecycleState.resumed},
        onReconcile: () async {},
        currentState: () => null,
      );

      expect(obs.needsInitialReconcile(), isFalse);
    });
  });

  group('LocaleAppIconObserver.maybeRunInitialReconcile', () {
    test('reconciles_when_still_in_trigger_state_at_callback', () {
      var calls = 0;
      final obs = LocaleAppIconObserver(
        triggers: const {AppLifecycleState.resumed},
        onReconcile: () async => calls++,
        currentState: () => AppLifecycleState.resumed,
      );

      obs.maybeRunInitialReconcile();

      expect(calls, 1);
    });

    test('does_not_reconcile_when_state_left_trigger_before_frame', () {
      var calls = 0;
      // 등록 시점엔 resumed였다가 첫 프레임 전 inactive로 전환되는 상황 모사
      var state = AppLifecycleState.resumed;
      final obs = LocaleAppIconObserver(
        triggers: const {AppLifecycleState.resumed},
        onReconcile: () async => calls++,
        currentState: () => state,
      );

      // 등록 시점엔 catch-up이 예약될 조건(trigger 상태)
      expect(obs.needsInitialReconcile(), isTrue);

      // 콜백 실행 전 lifecycle이 trigger를 벗어남 (iOS not-active)
      state = AppLifecycleState.inactive;
      obs.maybeRunInitialReconcile();

      expect(calls, 0, reason: 'iOS not-active 상태에서 reconcile 시도하면 안 됨');
    });
  });
}
