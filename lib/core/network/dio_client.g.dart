// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'81b126b0e131c021cfa8ca57f7a2f8f6d4908c3b';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
