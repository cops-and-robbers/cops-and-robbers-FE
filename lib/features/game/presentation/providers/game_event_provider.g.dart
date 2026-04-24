// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameEventStompDatasourceHash() =>
    r'456acbf010848f20c40c4e90ac91e5185125dc77';

/// GameEventStompDatasource Provider (싱글톤)
///
/// Copied from [gameEventStompDatasource].
@ProviderFor(gameEventStompDatasource)
final gameEventStompDatasourceProvider =
    AutoDisposeProvider<GameEventStompDatasource>.internal(
      gameEventStompDatasource,
      name: r'gameEventStompDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gameEventStompDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GameEventStompDatasourceRef =
    AutoDisposeProviderRef<GameEventStompDatasource>;
String _$gameSystemApiHash() => r'938956ae90567392f9f0b3cd399bdeb312c631a6';

/// GameSystemApi Provider
///
/// Copied from [gameSystemApi].
@ProviderFor(gameSystemApi)
final gameSystemApiProvider = AutoDisposeProvider<GameSystemApi>.internal(
  gameSystemApi,
  name: r'gameSystemApiProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gameSystemApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GameSystemApiRef = AutoDisposeProviderRef<GameSystemApi>;
String _$gameEventNotifierHash() => r'3a81d8fa6b8b29e427a07ba74215b7e68b049335';

/// 게임 이벤트 상태 관리 Notifier
///
/// STOMP 연결/구독/이벤트 처리 및 체포·탈옥 API 호출을 관리합니다.
/// GamePage 진입 시 [connectAndSubscribe]를 호출합니다.
///
/// Copied from [GameEventNotifier].
@ProviderFor(GameEventNotifier)
final gameEventNotifierProvider =
    AutoDisposeNotifierProvider<GameEventNotifier, GameEventState>.internal(
      GameEventNotifier.new,
      name: r'gameEventNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gameEventNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GameEventNotifier = AutoDisposeNotifier<GameEventState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
