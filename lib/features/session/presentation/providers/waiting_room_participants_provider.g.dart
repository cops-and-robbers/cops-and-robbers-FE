// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waiting_room_participants_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$waitingRoomParticipantsHash() =>
    r'ddee6ddcdce124e97970f0a5b60f984f885a9123';

/// 대기실 참가자 목록 관리 Notifier
///
/// STOMP 로비 이벤트를 처리하여 참가자 목록을 실시간 관리합니다.
/// TODO: REST API 초기 참가자 목록 조회 추가 예정
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
