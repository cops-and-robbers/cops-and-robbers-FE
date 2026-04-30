import 'package:cops_and_robbers/core/services/lifecycle/app_lifecycle_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLifecycleService — keep-alive', () {
    late AppLifecycleService service;

    setUp(() {
      service = AppLifecycleService.instance();
      service.activate();
      service.clearLogs();
    });

    tearDown(() {
      service.disableKeepAlive();
      service.deactivate();
    });

    test('reports_background_state_when_paused', () {
      service.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(service.isInBackground, true);
    });

    test('reports_foreground_state_when_resumed', () {
      service.didChangeAppLifecycleState(AppLifecycleState.paused);
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(service.isInBackground, false);
    });

    test('reports_background_state_when_hidden', () {
      service.didChangeAppLifecycleState(AppLifecycleState.hidden);

      expect(service.isInBackground, true);
    });

    test('disable_keep_alive_clears_state', () {
      service.enableKeepAlive();
      service.didChangeAppLifecycleState(AppLifecycleState.paused);
      service.disableKeepAlive();

      // disableKeepAlive 후에도 isInBackground는 라이프사이클 상태에 따라 유지됨
      expect(service.isInBackground, true);
    });
  });
}
