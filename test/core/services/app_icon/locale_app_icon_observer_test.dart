import 'package:cops_and_robbers/core/services/app_icon/locale_app_icon_observer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocaleAppIconObserver.didChangeAppLifecycleState', () {
    test('reconciles_on_paused', () {
      var calls = 0;
      final obs = LocaleAppIconObserver(onReconcile: () async => calls++);

      obs.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(calls, 1);
    });

    test('reconciles_on_hidden', () {
      var calls = 0;
      final obs = LocaleAppIconObserver(onReconcile: () async => calls++);

      obs.didChangeAppLifecycleState(AppLifecycleState.hidden);

      expect(calls, 1);
    });

    test('reconciles_on_detached', () {
      var calls = 0;
      final obs = LocaleAppIconObserver(onReconcile: () async => calls++);

      obs.didChangeAppLifecycleState(AppLifecycleState.detached);

      expect(calls, 1);
    });

    test('does_not_reconcile_on_resumed', () {
      var calls = 0;
      final obs = LocaleAppIconObserver(onReconcile: () async => calls++);

      obs.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(calls, 0);
    });

    test('does_not_reconcile_on_inactive', () {
      var calls = 0;
      final obs = LocaleAppIconObserver(onReconcile: () async => calls++);

      obs.didChangeAppLifecycleState(AppLifecycleState.inactive);

      expect(calls, 0);
    });

    test('reconciles_each_time_when_paused_then_hidden', () {
      var calls = 0;
      final obs = LocaleAppIconObserver(onReconcile: () async => calls++);

      obs.didChangeAppLifecycleState(AppLifecycleState.paused);
      obs.didChangeAppLifecycleState(AppLifecycleState.hidden);

      // 연속 발화 시 각각 호출됨 — AppIconService의 skip-if-same이 중복 토글을 흡수
      expect(calls, 2);
    });
  });
}
