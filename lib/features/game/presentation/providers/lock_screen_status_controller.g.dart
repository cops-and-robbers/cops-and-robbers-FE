// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lock_screen_status_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lockScreenStatusControllerHash() =>
    r'0a8977be5c4b9f92d8347c9eb440120e6e9a450b';

/// 게임 상태를 잠금 화면 현황으로 바꿔 BackgroundService에 보낸다.
///
/// 게임 화면이 watch해 게임 화면 수명 동안만 산다. 값이 바뀔 때만 보내고,
/// 다음 위치 공개 시각에만 깨어난다(매초 타이머 없음 — 초는 OS가 그린다).
///
/// 네트워크를 쓰지 않는다. 도둑 명단은 게임 화면의 참가자 동기화(소켓 연결·재연결 때)가
/// 상태에 남긴 것을 쓰고, 그 위에 체포·탈옥·퇴장 집합을 얹어 센다.
/// 따로 조회하면 백그라운드에서 토큰 만료 시 강제 로그아웃될 수 있고(ISS-0096),
/// 같은 조회 provider를 동기화와 함께 새로고침해 서로 간섭한다.
///
/// Copied from [LockScreenStatusController].
@ProviderFor(LockScreenStatusController)
final lockScreenStatusControllerProvider =
    AutoDisposeNotifierProvider<LockScreenStatusController, void>.internal(
      LockScreenStatusController.new,
      name: r'lockScreenStatusControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lockScreenStatusControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LockScreenStatusController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
