// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userRemoteDataSourceHash() =>
    r'b1fa5886c2738db2132aef83101460191ae7b925';

/// UserRemoteDataSource Provider (Retrofit)
///
/// Copied from [userRemoteDataSource].
@ProviderFor(userRemoteDataSource)
final userRemoteDataSourceProvider =
    AutoDisposeProvider<UserRemoteDataSource>.internal(
      userRemoteDataSource,
      name: r'userRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRemoteDataSourceRef = AutoDisposeProviderRef<UserRemoteDataSource>;
String _$userRepositoryHash() => r'78606b68c038a0b347d86931701bc33a28996c87';

/// UserRepository Provider
///
/// Copied from [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = AutoDisposeProvider<UserRepository>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = AutoDisposeProviderRef<UserRepository>;
String _$deleteAccountUseCaseHash() =>
    r'd993a978fb237900e04ca974fcf0341de9ddc008';

/// 회원 탈퇴 UseCase Provider
///
/// Copied from [deleteAccountUseCase].
@ProviderFor(deleteAccountUseCase)
final deleteAccountUseCaseProvider =
    AutoDisposeProvider<DeleteAccountUseCase>.internal(
      deleteAccountUseCase,
      name: r'deleteAccountUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteAccountUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteAccountUseCaseRef = AutoDisposeProviderRef<DeleteAccountUseCase>;
String _$gamePushNotifierHash() => r'd34c1d27b4ea78fde34fa429e0e725a5b0a9c9ed';

/// 게임 푸시 알림 동의 상태 Provider
///
/// build: GET /api/user/agreements/game-push
/// toggle: PUT /api/user/agreements/game-push (낙관적 업데이트, 실패 시 원복)
///
/// Copied from [GamePushNotifier].
@ProviderFor(GamePushNotifier)
final gamePushNotifierProvider =
    AutoDisposeAsyncNotifierProvider<GamePushNotifier, bool>.internal(
      GamePushNotifier.new,
      name: r'gamePushNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gamePushNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GamePushNotifier = AutoDisposeAsyncNotifier<bool>;
String _$communityPushNotifierHash() =>
    r'777c4bd3cfe7a1b000eb889af4d09759614f9b88';

/// 커뮤니티 푸시 알림 동의 상태 Provider
///
/// build: GET /api/user/agreements/community-push
/// toggle: PUT /api/user/agreements/community-push (낙관적 업데이트, 실패 시 원복)
///
/// 끄면 푸시만 막힌다 — 알림함·게시글별·댓글별 설정은 서버 의미가 독립이라
/// 이 값으로 그쪽 UI를 비활성화하지 않는다.
///
/// Copied from [CommunityPushNotifier].
@ProviderFor(CommunityPushNotifier)
final communityPushNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CommunityPushNotifier, bool>.internal(
      CommunityPushNotifier.new,
      name: r'communityPushNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityPushNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommunityPushNotifier = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
