// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_participant_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameParticipantNotifierHash() =>
    r'3aba74db02919144b362b7c65bb02674a4e0ab58';

/// 게임 참가 정보 관리 Notifier
///
/// 대기실에서 팀 선택 시 [setTeam] 호출,
/// 게임 시작 시 [setGameInfo] 호출하여 정보를 설정합니다.
///
/// Copied from [GameParticipantNotifier].
@ProviderFor(GameParticipantNotifier)
final gameParticipantNotifierProvider =
    NotifierProvider<GameParticipantNotifier, GameParticipantInfo?>.internal(
      GameParticipantNotifier.new,
      name: r'gameParticipantNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gameParticipantNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GameParticipantNotifier = Notifier<GameParticipantInfo?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
