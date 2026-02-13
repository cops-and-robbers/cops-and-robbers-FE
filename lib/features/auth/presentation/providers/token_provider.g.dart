// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenProviderHash() => r'4e766bbacbcf7eefc0a472dbcadf4453a358c006';

/// TokenProvider Provider
///
/// SecureTokenStorage에서 서버 JWT를 제공합니다.
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
