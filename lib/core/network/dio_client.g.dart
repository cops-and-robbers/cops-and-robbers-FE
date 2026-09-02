// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'9afc63beca28bab6c5c1e47c0c7dc3d5995e3953';

/// Dio Provider (AuthInterceptor 포함)
///
/// 앱 생애주기 동안 유지 (keepAlive) — HTTP 클라이언트는 dispose되면 안 됨.
/// [forceLogoutCallbackNotifier]를 통해 강제 로그아웃 동작을 외부에서 주입받습니다.
///
/// Copied from [dio].
@ProviderFor(dio)
final dioProvider = Provider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioRef = ProviderRef<Dio>;
String _$forceLogoutCallbackNotifierHash() =>
    r'11b51bf41013bbf90ec9e5b2ba79747031721301';

/// 강제 로그아웃 콜백 Provider
///
/// auth 모듈에서 구체적인 로그아웃 동작을 등록합니다.
/// core 모듈이 feature 모듈에 의존하지 않기 위한 역전 패턴입니다.
///
/// Copied from [ForceLogoutCallbackNotifier].
@ProviderFor(ForceLogoutCallbackNotifier)
final forceLogoutCallbackNotifierProvider =
    NotifierProvider<ForceLogoutCallbackNotifier, ForceLogoutFn?>.internal(
      ForceLogoutCallbackNotifier.new,
      name: r'forceLogoutCallbackNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$forceLogoutCallbackNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ForceLogoutCallbackNotifier = Notifier<ForceLogoutFn?>;
String _$requiredTermsCallbackNotifierHash() =>
    r'8e3fad1d90a483f51eeebc0f476e26078c3dc790';

/// 필수 약관 미동의 감지 콜백 Provider
///
/// [ForceLogoutCallbackNotifier]와 같은 역전 패턴. auth 모듈이
/// `markNeedsAgreement` 호출을 등록한다.
///
/// Copied from [RequiredTermsCallbackNotifier].
@ProviderFor(RequiredTermsCallbackNotifier)
final requiredTermsCallbackNotifierProvider =
    NotifierProvider<RequiredTermsCallbackNotifier, VoidCallback?>.internal(
      RequiredTermsCallbackNotifier.new,
      name: r'requiredTermsCallbackNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$requiredTermsCallbackNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RequiredTermsCallbackNotifier = Notifier<VoidCallback?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
