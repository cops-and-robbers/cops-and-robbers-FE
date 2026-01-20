import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_lifecycle_service.dart';
import 'lifecycle_log.dart';

part 'lifecycle_provider.g.dart';

/// AppLifecycleService 싱글톤 Provider
///
/// 앱 전체에서 하나의 생명주기 서비스 인스턴스를 공유합니다.
/// Provider dispose 시 서비스도 자동으로 정리됩니다.
///
/// ⚠️ 중요: Widget의 dispose()에서 직접 deactivate()를 호출하지 마세요.
/// Provider가 자동으로 처리합니다. (ref after disposed 에러 방지)
@riverpod
AppLifecycleService appLifecycleService(Ref ref) {
  final service = AppLifecycleService.instance();

  // Provider dispose 시 서비스 정리
  // ✅ Observer 제거 → StreamController 닫기 순서로 처리
  ref.onDispose(() {
    // 1. 먼저 Observer 제거 (더 이상 이벤트 안 받음)
    if (service.isActive) {
      service.deactivate();
    }
    // 2. 그 다음 StreamController 닫기
    service.dispose();
  });

  return service;
}

/// 현재 생명주기 상태 Stream Provider
///
/// 생명주기 상태가 변경될 때마다 새로운 값을 방출합니다.
/// UI에서 실시간으로 상태를 감시할 때 사용합니다.
///
/// 사용 예시:
/// ```dart
/// final stateAsync = ref.watch(lifecycleStateProvider);
/// stateAsync.when(
///   data: (state) => Text(state.name),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('에러: $e'),
/// );
/// ```
@riverpod
Stream<AppLifecycleState> lifecycleState(Ref ref) {
  final service = ref.watch(appLifecycleServiceProvider);
  return service.stateStream;
}

/// 생명주기 로그 이력 Notifier
///
/// 상태 변화 이력을 관리하며, 서비스의 로그가 업데이트될 때마다
/// UI를 자동으로 재빌드합니다.
@riverpod
class LifecycleLogsNotifier extends _$LifecycleLogsNotifier {
  @override
  List<LifecycleLog> build() {
    final service = ref.watch(appLifecycleServiceProvider);

    // 서비스의 상태 변화를 구독하여 로그 업데이트 시 재빌드
    final subscription = service.stateStream.listen((_) {
      // ✅ 상태가 변경되면 로그 목록도 업데이트 (새 리스트로 복사)
      state = List.from(service.logs);
    });

    ref.onDispose(subscription.cancel);

    // ✅ 초기 로그 목록 반환 (새 리스트로 복사하여 변경 감지 보장)
    return List.from(service.logs);
  }

  /// 모든 로그 삭제
  ///
  /// 테스트 화면에서 로그를 초기화할 때 사용합니다.
  void clearLogs() {
    final service = ref.read(appLifecycleServiceProvider);
    service.clearLogs();
    state = [];
  }
}
