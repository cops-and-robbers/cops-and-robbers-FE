// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pingNotifierHash() => r'55195ee452739ad346eaa5c82101280b5494c570';

/// 핑 상태 관리자 (@riverpod, autoDispose)
///
/// echo 기반: [addPing]은 전송 요청만 하고, 서버가 팀 채널로 돌려준 핑을
/// [_onPingReceived]에서 수신해 표시한다. 소멸 2.5초 / rate-limit(5초 8회) 유지.
/// game_page는 build()에서 watch로 생존을 유지해야 함(autoDispose).
///
/// Copied from [PingNotifier].
@ProviderFor(PingNotifier)
final pingNotifierProvider =
    AutoDisposeNotifierProvider<PingNotifier, List<Ping>>.internal(
      PingNotifier.new,
      name: r'pingNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pingNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PingNotifier = AutoDisposeNotifier<List<Ping>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
