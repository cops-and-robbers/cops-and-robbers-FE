import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cops_and_robbers/core/network/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeConnectivity implements Connectivity {
  FakeConnectivity({List<ConnectivityResult>? initial})
    : _current = initial ?? [ConnectivityResult.none];

  List<ConnectivityResult> _current;
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  void emit(List<ConnectivityResult> result) {
    _current = result;
    _controller.add(result);
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _current;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  group('ConnectivityService.isConnected()', () {
    test('none만 있으면 false를 반환한다', () async {
      final fake = FakeConnectivity(initial: [ConnectivityResult.none]);
      final service = ConnectivityService(fake);
      expect(await service.isConnected(), isFalse);
      await fake.dispose();
    });

    test('wifi가 있으면 true를 반환한다', () async {
      final fake = FakeConnectivity(initial: [ConnectivityResult.wifi]);
      final service = ConnectivityService(fake);
      expect(await service.isConnected(), isTrue);
      await fake.dispose();
    });

    test('mobile이 있으면 true를 반환한다', () async {
      final fake = FakeConnectivity(initial: [ConnectivityResult.mobile]);
      final service = ConnectivityService(fake);
      expect(await service.isConnected(), isTrue);
      await fake.dispose();
    });

    test('빈 리스트는 false를 반환한다', () async {
      final fake = FakeConnectivity(initial: []);
      final service = ConnectivityService(fake);
      expect(await service.isConnected(), isFalse);
      await fake.dispose();
    });

    test('wifi와 none이 섞여 있으면 true를 반환한다', () async {
      final fake = FakeConnectivity(
        initial: [ConnectivityResult.wifi, ConnectivityResult.none],
      );
      final service = ConnectivityService(fake);
      expect(await service.isConnected(), isTrue);
      await fake.dispose();
    });
  });

  group('ConnectivityService.onConnectivityChanged', () {
    test('none → wifi 이벤트가 false → true로 매핑된다', () async {
      final fake = FakeConnectivity(initial: [ConnectivityResult.none]);
      final service = ConnectivityService(fake);

      final events = <bool>[];
      final sub = service.onConnectivityChanged.listen(events.add);

      fake.emit([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      fake.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);

      expect(events, equals([false, true]));

      await sub.cancel();
      await fake.dispose();
    });

    test('broadcast 스트림이라 여러 구독자를 지원한다', () async {
      final fake = FakeConnectivity(initial: [ConnectivityResult.none]);
      final service = ConnectivityService(fake);

      final eventsA = <bool>[];
      final eventsB = <bool>[];
      final subA = service.onConnectivityChanged.listen(eventsA.add);
      final subB = service.onConnectivityChanged.listen(eventsB.add);

      fake.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);

      expect(eventsA, equals([true]));
      expect(eventsB, equals([true]));

      await subA.cancel();
      await subB.cancel();
      await fake.dispose();
    });
  });
}
