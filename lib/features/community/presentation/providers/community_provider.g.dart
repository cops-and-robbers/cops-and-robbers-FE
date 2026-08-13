// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityRemoteDataSourceHash() =>
    r'cafda569cdf69a53297691eede2adea5aa0aba1a';

/// `CommunityRemoteDataSource` Provider (Retrofit)
///
/// Copied from [communityRemoteDataSource].
@ProviderFor(communityRemoteDataSource)
final communityRemoteDataSourceProvider =
    AutoDisposeProvider<CommunityRemoteDataSource>.internal(
      communityRemoteDataSource,
      name: r'communityRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityRemoteDataSourceRef =
    AutoDisposeProviderRef<CommunityRemoteDataSource>;
String _$communityRepositoryHash() =>
    r'c1498ebe17f8cf37aef73a1f07d6c7b6a0bbffcb';

/// `CommunityRepository` Provider
///
/// Copied from [communityRepository].
@ProviderFor(communityRepository)
final communityRepositoryProvider =
    AutoDisposeProvider<CommunityRepository>.internal(
      communityRepository,
      name: r'communityRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityRepositoryRef = AutoDisposeProviderRef<CommunityRepository>;
String _$selectedCommunityScopeHash() =>
    r'd77dd28c42cafb2dcff07c40d57eff6f26922b6e';

/// 현재 선택된 목록 범위 필터
///
/// `CommunityFeedNotifier.build()`가 이 값을 watch 하므로, 값이 바뀌면 build가
/// 재실행되며 자동으로 0페이지부터 다시 조회된다 — 리셋 로직이 따로 없다.
/// 토글 UI는 이 provider를 직접 watch 해서 네트워크 응답을 기다리지 않고
/// 탭 즉시 선택 표시를 바꾼다.
///
/// Copied from [SelectedCommunityScope].
@ProviderFor(SelectedCommunityScope)
final selectedCommunityScopeProvider =
    AutoDisposeNotifierProvider<
      SelectedCommunityScope,
      CommunityScope
    >.internal(
      SelectedCommunityScope.new,
      name: r'selectedCommunityScopeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedCommunityScopeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedCommunityScope = AutoDisposeNotifier<CommunityScope>;
String _$communityFeedNotifierHash() =>
    r'87e929a147db1a7080a0a8950531806f043f13ee';

/// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier
///
/// Copied from [CommunityFeedNotifier].
@ProviderFor(CommunityFeedNotifier)
final communityFeedNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      CommunityFeedNotifier,
      CommunityFeedState
    >.internal(
      CommunityFeedNotifier.new,
      name: r'communityFeedNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityFeedNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommunityFeedNotifier = AutoDisposeAsyncNotifier<CommunityFeedState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
