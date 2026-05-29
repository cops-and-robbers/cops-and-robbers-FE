// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waiting_room_participants_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$waitingRoomParticipantsHash() =>
    r'7a4276ae06e255343a2a3e0c797ea0babb3e5300';

/// 대기실 참가자 목록 관리 Notifier
///
/// 흐름: WaitingRoomPage에서 fetchLobbyInfoProvider로 초기 목록 조회 →
/// [initFromApi]로 상태 초기화 → 이후 STOMP 로비 이벤트로 증분 업데이트.
///
/// Copied from [WaitingRoomParticipants].
@ProviderFor(WaitingRoomParticipants)
final waitingRoomParticipantsProvider =
    AutoDisposeNotifierProvider<
      WaitingRoomParticipants,
      WaitingRoomParticipantsState
    >.internal(
      WaitingRoomParticipants.new,
      name: r'waitingRoomParticipantsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$waitingRoomParticipantsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WaitingRoomParticipants =
    AutoDisposeNotifier<WaitingRoomParticipantsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
