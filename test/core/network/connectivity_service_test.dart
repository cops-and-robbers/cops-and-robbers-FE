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

  /// 실제 connectivity_plus는 새 리스너가 붙을 때마다(Android
  /// `ConnectivityBroadcastReceiver.onListen`, iOS `ConnectivityPlusPlugin.onListen`
  /// 둘 다) 그 순간의 현재 상태를 먼저 한 번 흘려보낸 뒤에야 실제 변화를 흘려보낸다.
  /// 이 재생 동작을 재현하지 않으면 재구독 시 자기 자신의 재생 이벤트를 "연결
  /// 복구"로 오인하는 버그(ISS 스플래시 무한 루프)를 테스트가 잡아내지 못한다.
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged async* {
    yield _current;
    yield* _controller.stream;
  }

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
      // 구독 직후 재생 이벤트(skip(1) 대상)가 먼저 정리될 시간을 준다 —
      // 그 전에 emit하면 아직 컨트롤러를 구독하지 않은 async* 제너레이터가
      // 그 값을 놓친다(broadcast 스트림은 리스너 없을 때 값을 버린다).
      await Future<void>.delayed(Duration.zero);

      fake.emit([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      fake.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);

      expect(events, equals([false, true]));

      await sub.cancel();
      await fake.dispose();
    });

    test('연결됨 상태에서 같은 연결됨 이벤트가 반복돼도 한 번만 흘려보낸다', () async {
      // Android는 실제 연결 상태 변화 없이도 NetworkCapabilities 재검증 등으로
      // onConnectivityChanged를 반복 발화할 수 있다. distinct 없이 그대로
      // 흘려보내면, 서버 장애로 차단된 스플래시가 그 이벤트마다 "연결 복구"로
      // 오인해 여전히 죽은 서버에 재시도 → 재차단을 반복한다.
      final fake = FakeConnectivity(initial: [ConnectivityResult.wifi]);
      final service = ConnectivityService(fake);

      final events = <bool>[];
      final sub = service.onConnectivityChanged.listen(events.add);
      await Future<void>.delayed(Duration.zero);

      fake.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);
      fake.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);

      expect(events, equals([true]));

      await sub.cancel();
      await fake.dispose();
    });

    test('구독 시점에 재생되는 현재 상태 이벤트는 흘려보내지 않는다', () async {
      // 스플래시가 서버 장애로 차단 → 연결 복구 스트림을 구독하는 상황을
      // 재현한다. 기기는 처음부터 연결돼 있었다(wifi) — 구독 자체가 만드는
      // "연결됨" 재생 이벤트가 "복구"로 오인되면, cancel 후 재구독하는 코드는
      // 재구독할 때마다 자기 자신이 쏜 이벤트에 반응해 여전히 죽어 있는
      // 서버에 무한 재시도한다(FE #554 후속 버그).
      final fake = FakeConnectivity(initial: [ConnectivityResult.wifi]);
      final service = ConnectivityService(fake);

      final events = <bool>[];
      final sub = service.onConnectivityChanged.listen(events.add);
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);

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
      await Future<void>.delayed(Duration.zero);

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
