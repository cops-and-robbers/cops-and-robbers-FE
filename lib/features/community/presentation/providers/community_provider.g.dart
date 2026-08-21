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
/// 좋아요·스크랩·댓글은 백엔드에 API가 없어 아직 목이다
/// (`communityInteractionRepositoryProvider`). 게시글 CRUD는 전부 실서버다.
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
String _$currentPositionResolverHash() =>
    r'c44ee30313052542cd510b7f078f5d9688a6901a';

/// 현재 위치 판별기 Provider
///
/// GPS·권한은 시스템 경계라 여기서 한 번 갈라 둔다. 테스트는 이 provider만
/// 갈아끼우면 플랫폼 채널을 건드리지 않고 "권한 있음/없음"을 만들어 낼 수 있다.
///
/// 값이 아니라 함수를 담는다 — 호출자가 부르는 시점의 위치를 원하기 때문이다.
/// (한 번 정하면 되는 국가 코드는 아래 [communityCountryCodeProvider]가 캐시한다.)
///
/// Copied from [currentPositionResolver].
@ProviderFor(currentPositionResolver)
final currentPositionResolverProvider =
    AutoDisposeProvider<Future<DeviceCoordinates?> Function()>.internal(
      currentPositionResolver,
      name: r'currentPositionResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentPositionResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentPositionResolverRef =
    AutoDisposeProviderRef<Future<DeviceCoordinates?> Function()>;
String _$deviceCountryCodeHash() => r'd4b198fec31c6b21a5a2139af6a226ec346db3d3';

/// 기기 로케일의 국가 코드. 로케일에 국가가 없으면(`en` 같은 경우) 주 시장인
/// 한국으로 둔다 — 국가를 못 정하면 목록 자체를 못 부른다.
///
/// provider로 감싼 이유: `PlatformDispatcher`는 시스템 경계라 테스트에서 값을
/// 바꿀 수 없다. 폴백 분기를 검증하려면 갈아끼울 자리가 필요하다.
///
/// Copied from [deviceCountryCode].
@ProviderFor(deviceCountryCode)
final deviceCountryCodeProvider = AutoDisposeProvider<String>.internal(
  deviceCountryCode,
  name: r'deviceCountryCodeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceCountryCodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeviceCountryCodeRef = AutoDisposeProviderRef<String>;
String _$communityCountryCodeHash() =>
    r'781947da7aa0355f897726eb182cb778be444161';

/// 목록을 어느 국가로 조회할지 정한다 — 화면 진입당 한 번.
///
/// 목록 API는 좌표를 받지 않고 `countryCode`만 받으므로, 그 값을 여기서 먼저
/// 구한다(DEC-0021). 서버 조회는 벤더를 한 번 부르고 Geoapify 일 3,000건 한도를
/// 공유하므로, provider가 결과를 들고 있어 페이지를 넘길 때마다 다시 부르지 않는다.
///
/// **절대 예외를 던지지 않는다.** 좌표가 없든, 벤더가 죽었든, 서버가 값을
/// 빠뜨렸든 기기 로케일로 물러선다 — 국가 하나 못 알아냈다고 목록 전체가 에러
/// 화면이 되는 것이 이 API를 목록에서 떼어낸 이유와 정면으로 어긋난다.
///
/// Copied from [communityCountryCode].
@ProviderFor(communityCountryCode)
final communityCountryCodeProvider = AutoDisposeFutureProvider<String>.internal(
  communityCountryCode,
  name: r'communityCountryCodeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$communityCountryCodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityCountryCodeRef = AutoDisposeFutureProviderRef<String>;
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
    r'644e2749c551a877a42ff0526f1d3fc24ba8e96f';

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
