// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenProviderHash() => r'c1c674e928d9019bec6d8a54235a757b545a2a27';

/// TokenProvider Provider
///
/// 현재는 FirebaseTokenProvider를 사용합니다.
/// 서버 JWT 도입 시 ServerTokenProvider로 교체 예정.
///
/// Copied from [tokenProvider].
@ProviderFor(tokenProvider)
final tokenProviderProvider = AutoDisposeProvider<TokenProvider>.internal(
  tokenProvider,
  name: r'tokenProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tokenProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TokenProviderRef = AutoDisposeProviderRef<TokenProvider>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
