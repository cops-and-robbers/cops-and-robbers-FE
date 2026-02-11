// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionRemoteDataSourceHash() =>
    r'b0ce1a8d497f9d71b63a25c700cf5e0a2bffceba';

/// SessionRemoteDataSource Provider (Retrofit)
///
/// Copied from [sessionRemoteDataSource].
@ProviderFor(sessionRemoteDataSource)
final sessionRemoteDataSourceProvider =
    AutoDisposeProvider<SessionRemoteDataSource>.internal(
      sessionRemoteDataSource,
      name: r'sessionRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sessionRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionRemoteDataSourceRef =
    AutoDisposeProviderRef<SessionRemoteDataSource>;
String _$sessionRepositoryHash() => r'6037c53ad58d576c9aee1eaacd13646101e2fa03';

/// SessionRepository Provider
///
/// Copied from [sessionRepository].
@ProviderFor(sessionRepository)
final sessionRepositoryProvider =
    AutoDisposeProvider<SessionRepository>.internal(
      sessionRepository,
      name: r'sessionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sessionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionRepositoryRef = AutoDisposeProviderRef<SessionRepository>;
String _$sessionCreationNotifierHash() =>
    r'371323e1f00197619d881ff5dfd62103f3f7b80b';

/// 세션 생성 상태 관리 Notifier
///
/// 게임 방 생성 API 호출 및 결과 상태를 관리합니다.
/// `AsyncValue<CreateSessionResult?>` 상태를 통해 로딩/성공/에러를 표현합니다.
///
/// Copied from [SessionCreationNotifier].
@ProviderFor(SessionCreationNotifier)
final sessionCreationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      SessionCreationNotifier,
      CreateSessionResult?
    >.internal(
      SessionCreationNotifier.new,
      name: r'sessionCreationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sessionCreationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SessionCreationNotifier =
    AutoDisposeAsyncNotifier<CreateSessionResult?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
