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
    r'd9db3ea7b066ac096d012d94fec8fd197e2de5d7';

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
String _$countryQueryResolverHash() =>
    r'bd43c8ec9853e2e0f10f1d8ca86811385adc5b18';

/// 국가 판별기 Provider
///
/// GPS·권한·기기 로케일은 전부 시스템 경계라 여기서 한 번 갈라 둔다. 테스트는
/// 이 provider만 갈아끼우면 플랫폼 채널을 건드리지 않고 "권한 있음/없음"을
/// 만들어 낼 수 있다.
///
/// Copied from [countryQueryResolver].
@ProviderFor(countryQueryResolver)
final countryQueryResolverProvider =
    AutoDisposeProvider<Future<CountryQuery> Function()>.internal(
      countryQueryResolver,
      name: r'countryQueryResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$countryQueryResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CountryQueryResolverRef =
    AutoDisposeProviderRef<Future<CountryQuery> Function()>;
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
String _$selectedCommunitySortHash() =>
    r'1b300f2efa9b39b4783fb0c07c0d4e868cc2aa7f';

/// 현재 선택된 정렬 기준.
///
/// 아직 `CommunityFeedNotifier`가 watch하지 않는다 — 백엔드가 `sort` 파라미터를
/// 받긴 하지만 기본값 `LATEST` 외에는 400이라 보낼 값이 없기 때문이다. 지금은
/// 정렬 라벨 표시 전용이며, 다른 값이 열리면 `SelectedCommunityScope`와 같은
/// 방식으로 build()에서 watch해 연결한다.
///
/// Copied from [SelectedCommunitySort].
@ProviderFor(SelectedCommunitySort)
final selectedCommunitySortProvider =
    AutoDisposeNotifierProvider<
      SelectedCommunitySort,
      CommunitySortOption
    >.internal(
      SelectedCommunitySort.new,
      name: r'selectedCommunitySortProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedCommunitySortHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedCommunitySort = AutoDisposeNotifier<CommunitySortOption>;
String _$communityFeedNotifierHash() =>
    r'ea95680ed85e1a11fd8cb82033142c9c73dba09d';

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
