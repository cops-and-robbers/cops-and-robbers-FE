import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// `connectivity_plus` 패키지를 앱 도메인 계층에서 격리하기 위한 래퍼.
///
/// 스플래시 오프라인 가드 등 호출자는 이 서비스에만 의존하고
/// 플랫폼 SDK를 직접 import하지 않는다.
///
/// 연결 판정 규칙: `ConnectivityResult.none` 외의 값이 하나라도 있으면 연결됨.
/// captive portal 같은 "링크만 있고 실제 통신은 안 되는" 케이스는 여기서
/// 잡지 않으며, 후속 API 호출의 네트워크성 실패를 통해 상위에서 복구된다.
class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  /// 현재 연결 상태를 단발성으로 조회한다.
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnectivity(result);
  }

  /// 연결 상태 변화를 bool 스트림으로 노출한다.
  ///
  /// `true` = 연결됨, `false` = 끊김.
  /// broadcast 스트림이라 여러 구독자가 동시에 구독 가능하다.
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnectivity);

  bool _hasConnectivity(List<ConnectivityResult> result) {
    if (result.isEmpty) return false;
    return result.any((r) => r != ConnectivityResult.none);
  }
}

/// 앱 전역 `ConnectivityService` 싱글턴.
///
/// keepAlive로 유지되어 화면 전환 시에도 동일 인스턴스를 재사용한다.
@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityService(Connectivity());
}
