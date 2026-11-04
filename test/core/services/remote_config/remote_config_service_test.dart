import 'dart:async';

import 'package:cops_and_robbers/core/services/remote_config/remote_config_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _MockRemoteConfig extends Mock implements FirebaseRemoteConfig {}

RemoteConfigUpdate _update() => RemoteConfigUpdate(const {'maintenance'});

void main() {
  late _MockRemoteConfig remoteConfig;
  late StreamController<RemoteConfigUpdate> signals;
  late RemoteConfigService service;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(
      RemoteConfigSettings(
        fetchTimeout: Duration.zero,
        minimumFetchInterval: Duration.zero,
      ),
    );
    registerFallbackValue(<String, dynamic>{});
    PackageInfo.setMockInitialValues(
      appName: 'test',
      packageName: 'test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  setUp(() {
    remoteConfig = _MockRemoteConfig();
    signals = StreamController<RemoteConfigUpdate>();
    service = RemoteConfigService.forTesting(remoteConfig);

    when(() => remoteConfig.setConfigSettings(any())).thenAnswer((_) async {});
    when(() => remoteConfig.setDefaults(any())).thenAnswer((_) async {});
    when(() => remoteConfig.fetchAndActivate()).thenAnswer((_) async => true);
    when(() => remoteConfig.activate()).thenAnswer((_) async => true);
    when(() => remoteConfig.getString(any())).thenReturn('');
    when(() => remoteConfig.getBool(any())).thenReturn(false);
    when(() => remoteConfig.onConfigUpdated).thenAnswer((_) => signals.stream);
  });

  tearDown(() async {
    await signals.close();
  });

  test('activates_published_values_even_when_no_screen_is_listening', () async {
    await service.initialize();

    signals.add(_update());
    await pumpEventQueue();

    verify(() => remoteConfig.activate()).called(1);
  });

  test('subscribes_to_signals_only_once_however_many_listen', () async {
    await service.initialize();
    await service.initialize();

    final first = service.onConfigUpdated.listen((_) {});
    final second = service.onConfigUpdated.listen((_) {});
    addTearDown(first.cancel);
    addTearDown(second.cancel);

    expect(signals.hasListener, isTrue);
    verify(() => remoteConfig.onConfigUpdated).called(1);
  });

  test('notifies_every_listener_after_activation', () async {
    await service.initialize();
    final order = <String>[];
    when(() => remoteConfig.activate()).thenAnswer((_) async {
      order.add('activate');
      return true;
    });

    final first = service.onConfigUpdated.listen((_) => order.add('first'));
    final second = service.onConfigUpdated.listen((_) => order.add('second'));
    addTearDown(first.cancel);
    addTearDown(second.cancel);

    signals.add(_update());
    await pumpEventQueue();

    expect(order, ['activate', 'first', 'second']);
  });

  test('a_listener_subscribed_before_initialize_still_gets_updates', () async {
    var received = 0;
    final early = service.onConfigUpdated.listen((_) => received++);
    addTearDown(early.cancel);

    await service.initialize();
    signals.add(_update());
    await pumpEventQueue();

    expect(received, 1);
  });

  test('a_leaving_listener_does_not_stop_later_signals', () async {
    await service.initialize();

    final leaving = service.onConfigUpdated.listen((_) {});
    await leaving.cancel();

    signals.add(_update());
    await pumpEventQueue();

    expect(signals.hasListener, isTrue);
    verify(() => remoteConfig.activate()).called(1);
  });

  test('keeps_listening_after_activate_fails_or_the_stream_errors', () async {
    await service.initialize();
    var received = 0;
    final listener = service.onConfigUpdated.listen((_) => received++);
    addTearDown(listener.cancel);

    when(() => remoteConfig.activate()).thenThrow(Exception('activate failed'));
    signals.add(_update());
    await pumpEventQueue();

    signals.addError(Exception('connection failed'));
    await pumpEventQueue();

    when(() => remoteConfig.activate()).thenAnswer((_) async => true);
    signals.add(_update());
    await pumpEventQueue();

    expect(received, 2);
  });

  test('initialize_survives_a_failed_fetch_and_still_listens', () async {
    when(
      () => remoteConfig.fetchAndActivate(),
    ).thenThrow(Exception('fetch failed'));

    await service.initialize();
    signals.add(_update());
    await pumpEventQueue();

    verify(() => remoteConfig.activate()).called(1);
  });
}
