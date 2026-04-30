// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$backgroundServiceHash() => r'eb0afcbb9d9438cf1662d6471018b49850bd16e0';

/// 플랫폼별 BackgroundService 구현체를 제공하는 싱글톤 Provider
///
/// keepAlive: true → 게임 세션 라이프사이클을 넘어서도 동일 인스턴스 유지.
/// 게임 화면이 dispose되어도 isRunning 상태가 보존되어 재진입 시 정확한
/// idempotent 동작을 보장한다.
///
/// Copied from [backgroundService].
@ProviderFor(backgroundService)
final backgroundServiceProvider = Provider<BackgroundService>.internal(
  backgroundService,
  name: r'backgroundServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backgroundServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BackgroundServiceRef = ProviderRef<BackgroundService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
