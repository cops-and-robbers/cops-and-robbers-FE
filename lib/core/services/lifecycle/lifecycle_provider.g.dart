// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lifecycle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appLifecycleServiceHash() =>
    r'5a893d629aedaf80fd7d4e400c8777c016eafb47';

/// AppLifecycleService 싱글톤 Provider
///
/// 앱 전체에서 하나의 생명주기 서비스 인스턴스를 공유합니다.
/// Provider dispose 시 서비스도 자동으로 정리됩니다.
///
/// ⚠️ 중요: Widget의 dispose()에서 직접 deactivate()를 호출하지 마세요.
/// Provider가 자동으로 처리합니다. (ref after disposed 에러 방지)
///
/// Copied from [appLifecycleService].
@ProviderFor(appLifecycleService)
final appLifecycleServiceProvider =
    AutoDisposeProvider<AppLifecycleService>.internal(
      appLifecycleService,
      name: r'appLifecycleServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appLifecycleServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppLifecycleServiceRef = AutoDisposeProviderRef<AppLifecycleService>;
String _$lifecycleStateHash() => r'794b2e02fae56201530b0ba2eb7a3a1f2f6d7744';

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
///
/// Copied from [lifecycleState].
@ProviderFor(lifecycleState)
final lifecycleStateProvider =
    AutoDisposeStreamProvider<AppLifecycleState>.internal(
      lifecycleState,
      name: r'lifecycleStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lifecycleStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LifecycleStateRef = AutoDisposeStreamProviderRef<AppLifecycleState>;
String _$lifecycleLogsNotifierHash() =>
    r'4a0cdb8ee8c90f4520427dc3b2e83418e742c43b';

/// 생명주기 로그 이력 Notifier
///
/// 상태 변화 이력을 관리하며, 서비스의 로그가 업데이트될 때마다
/// UI를 자동으로 재빌드합니다.
///
/// Copied from [LifecycleLogsNotifier].
@ProviderFor(LifecycleLogsNotifier)
final lifecycleLogsNotifierProvider =
    AutoDisposeNotifierProvider<
      LifecycleLogsNotifier,
      List<LifecycleLog>
    >.internal(
      LifecycleLogsNotifier.new,
      name: r'lifecycleLogsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lifecycleLogsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LifecycleLogsNotifier = AutoDisposeNotifier<List<LifecycleLog>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
