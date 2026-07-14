// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_game_record_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$playerGameRecordNotifierHash() =>
    r'fb99d578f14f23866d9835038faee1b1fbccbad3';

/// 게임 중 내 활동(경로·거리·개인 카운트)을 누적하는 휘발성 Notifier.
///
/// `keepAlive: true` — 게임 종료 정리 시 위치 스트림이 결과 다이얼로그보다 먼저
/// 종료되므로(game_page `_prepareGameOverPresentation`), 누적값을 이 provider에
/// 담아 다이얼로그가 읽을 수 있게 한다. 다음 게임 진입(GamePage initState)에서 [reset].
///
/// Copied from [PlayerGameRecordNotifier].
@ProviderFor(PlayerGameRecordNotifier)
final playerGameRecordNotifierProvider =
    NotifierProvider<PlayerGameRecordNotifier, PlayerGameRecord>.internal(
      PlayerGameRecordNotifier.new,
      name: r'playerGameRecordNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$playerGameRecordNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlayerGameRecordNotifier = Notifier<PlayerGameRecord>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
