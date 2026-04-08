// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lobby_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lobbyStompDatasourceHash() =>
    r'93fc1702988f74637c967c5df359838e3f272574';

/// LobbyStompDatasource Provider (싱글톤)
///
/// Copied from [lobbyStompDatasource].
@ProviderFor(lobbyStompDatasource)
final lobbyStompDatasourceProvider =
    AutoDisposeProvider<LobbyStompDatasource>.internal(
      lobbyStompDatasource,
      name: r'lobbyStompDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lobbyStompDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LobbyStompDatasourceRef = AutoDisposeProviderRef<LobbyStompDatasource>;
String _$lobbyNotifierHash() => r'22d000e70a716ab9a7af2a47c6c2a53f9584fb05';

/// 로비 상태 관리 Notifier
///
/// STOMP 연결/구독/이벤트 처리를 관리합니다.
/// WaitingRoomPage 진입 시 [connectAndSubscribe]를 호출하고,
/// 이탈 시 [disconnectLobby]를 호출합니다.
///
/// Copied from [LobbyNotifier].
@ProviderFor(LobbyNotifier)
final lobbyNotifierProvider =
    AutoDisposeNotifierProvider<LobbyNotifier, LobbyState>.internal(
      LobbyNotifier.new,
      name: r'lobbyNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lobbyNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LobbyNotifier = AutoDisposeNotifier<LobbyState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
