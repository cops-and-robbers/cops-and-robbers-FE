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
String _$communityCommentRepositoryHash() =>
    r'b04599d9f6886eeaa973fcbffb5a88e84be63a56';

/// `CommunityCommentRepository` Provider
///
/// Copied from [communityCommentRepository].
@ProviderFor(communityCommentRepository)
final communityCommentRepositoryProvider =
    AutoDisposeProvider<CommunityCommentRepository>.internal(
      communityCommentRepository,
      name: r'communityCommentRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityCommentRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityCommentRepositoryRef =
    AutoDisposeProviderRef<CommunityCommentRepository>;
String _$communityReactionRepositoryHash() =>
    r'b211bf9d60fae1df02e98a6702c86bdf69618bdf';

/// `CommunityReactionRepository` Provider
///
/// 상태를 안 들고 있으므로 keepAlive가 필요 없다 — 서버가 상태를 갖는다.
///
/// Copied from [communityReactionRepository].
@ProviderFor(communityReactionRepository)
final communityReactionRepositoryProvider =
    AutoDisposeProvider<CommunityReactionRepository>.internal(
      communityReactionRepository,
      name: r'communityReactionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityReactionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityReactionRepositoryRef =
    AutoDisposeProviderRef<CommunityReactionRepository>;
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
String _$ensureLocationPermissionHash() =>
    r'dae506e0728cecbbb8d5726988cc89fffe6b4ee4';

/// 위치 권한을 확보하는 함수 Provider.
///
/// 권한 서비스는 시스템 경계라 여기서 갈라 둔다 — 위 [currentPositionResolverProvider]와
/// 같은 이유다. `LocationPermissionService.ensurePermission`이 static이라 테스트에서
/// 직접 갈아끼울 수 없으므로, 이 provider가 갈아끼울 자리를 대신 제공한다.
///
/// 값이 아니라 함수를 담는다 — 호출자가 시트에서 거리순을 고른 시점의 권한
/// 상태를 원하기 때문이다.
///
/// Copied from [ensureLocationPermission].
@ProviderFor(ensureLocationPermission)
final ensureLocationPermissionProvider =
    AutoDisposeProvider<Future<bool> Function()>.internal(
      ensureLocationPermission,
      name: r'ensureLocationPermissionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ensureLocationPermissionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EnsureLocationPermissionRef =
    AutoDisposeProviderRef<Future<bool> Function()>;
String _$checkLocationPermissionHash() =>
    r'8faf4533a731331613ad40f3ffb386557a1b53ca';

/// 위치 권한 상태를 확인하는 함수 Provider. 영구 거부 여부를 가릴 때 쓴다
/// (안내 문구를 설정 화면 유도로 바꾸는 분기).
///
/// [ensureLocationPermissionProvider]와 같은 이유로 감쌌다.
///
/// Copied from [checkLocationPermission].
@ProviderFor(checkLocationPermission)
final checkLocationPermissionProvider =
    AutoDisposeProvider<Future<LocationPermission> Function()>.internal(
      checkLocationPermission,
      name: r'checkLocationPermissionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$checkLocationPermissionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CheckLocationPermissionRef =
    AutoDisposeProviderRef<Future<LocationPermission> Function()>;
String _$clockHash() => r'3b571c5a0c08b7391c0eed04391003191bab6ccf';

/// 현재 시각.
///
/// 시간은 시스템 경계라 갈아끼울 자리가 필요하다 — 유효 시간 판정을 테스트하려면
/// 시계를 앞으로 돌릴 수 있어야 한다. 값이 아니라 함수를 담는 이유는 호출하는
/// 시점의 시각을 원하기 때문이다.
///
/// 세 번째 사용처가 생기면 `core`로 옮긴다. 지금은 목록 유효 시간만 쓴다.
///
/// Copied from [clock].
@ProviderFor(clock)
final clockProvider = AutoDisposeProvider<DateTime Function()>.internal(
  clock,
  name: r'clockProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clockHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClockRef = AutoDisposeProviderRef<DateTime Function()>;
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
    r'4313e2665ef6b2e7b9d7fcf305ef265e717a615d';

/// 목록을 어느 국가로 조회할지 정한다 — 앱 세션 내내 한 번.
///
/// 목록 API는 좌표를 받지 않고 `countryCode`만 받으므로, 그 값을 여기서 먼저
/// 구한다(DEC-0021). 서버 조회는 벤더를 한 번 부르고 Geoapify 일 3,000건 한도를
/// 공유하므로, provider가 결과를 들고 있어 페이지를 넘길 때마다 다시 부르지 않는다.
///
/// **절대 예외를 던지지 않는다.** 좌표가 없든, 벤더가 죽었든, 서버가 값을
/// 빠뜨렸든 기기 로케일로 물러선다 — 국가 하나 못 알아냈다고 목록 전체가 에러
/// 화면이 되는 것이 이 API를 목록에서 떼어낸 이유와 정면으로 어긋난다.
///
/// 무효화 경로는 `CommunityFeedList._ensureLocationForDistance()`가 거리순 선택
/// 시 위치 권한을 새로 얻었을 때 한 번 부르는 `ref.invalidate`가 유일하다 —
/// 그 전까지는 세션 내내 처음 판정한 값을 그대로 쓴다.
///
/// `keepAlive`인 이유: `CommunityFeedNotifier`(목록)가 이 provider를 watch하지만
/// 그 자신도 autoDispose라, 리스너 없이 무효화되면(글 작성·수정·삭제 등이 인자
/// 없는 invalidate를 부른다) 함께 폐기될 수 있다 — 그러면 다음 진입에서 GPS와
/// `/country`(Geoapify 일 3,000건 한도 공유)를 다시 태운다. 피드의 수명 관리와
/// 분리해 국가 판별만 화면 세션 내내 고정한다.
///
/// Copied from [communityCountryCode].
@ProviderFor(communityCountryCode)
final communityCountryCodeProvider = FutureProvider<String>.internal(
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
typedef CommunityCountryCodeRef = FutureProviderRef<String>;
String _$selectedCommunityScopeHash() =>
    r'd77dd28c42cafb2dcff07c40d57eff6f26922b6e';

/// 현재 선택된 목록 범위 필터
///
/// `CommunityFeedNotifier`의 family 키에 그대로 들어가므로, 값이 바뀌면 그
/// 스코프의 인스턴스가 커서 없이 첫 페이지를 부른다 — 리셋 로직이 따로 없다.
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
/// 목록 화면과 검색 화면이 이 하나를 공유한다 — "마감 임박순으로 보고 싶다"는
/// 화면에 따라 달라지는 선호가 아니다.
///
/// `CommunityFeedNotifier`의 family 키에 그대로 들어가므로, 값이 바뀌면 그 정렬의
/// 인스턴스가 커서 없이 첫 페이지를 부른다. 서버 커서에 정렬이 봉인돼 있어
/// 재사용하면 400이라, 이 구조가 곧 계약이다.
///
/// 인기순은 서버가 아직 400을 주므로 정렬 시트가 노출하지 않는다.
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
    r'12e578e8ebdd87e33a630f7ce4d7ca37b15c0c02';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CommunityFeedNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CommunityFeedState> {
  late final CommunityScope scope;
  late final CommunitySortOption sort;
  late final String? keyword;

  FutureOr<CommunityFeedState> build(
    CommunityScope scope,
    CommunitySortOption sort,
    String? keyword,
  );
}

/// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier
///
/// **조회 조건(스코프·정렬·검색어)마다 인스턴스가 따로 살아 있다.** 서버 커서에
/// 국가·정렬·검색어가 봉인돼 있어 조건이 바뀌면 커서를 재사용할 수 없으므로
/// (400), 조건을 family 키로 두면 새 인스턴스가 커서 없이 첫 페이지를 부른다 —
/// 리셋 로직이 따로 필요 없고 커서 불일치가 구조적으로 발생하지 않는다.
///
/// 목록(`keyword == null`)만 `keepAlive`한다. 예전에는 하나의 인스턴스가 선택된
/// 스코프를 watch 해서, 전체 → 우리동네 → 전체로 토글할 때마다 목록을 다시
/// 불렀다. 그때 딸려 나가는 건 목록 하나가 아니다 — 유일한 watcher가 사라지면서
/// `communityCountryCodeProvider`도 함께 폐기돼, 돌아올 때 GPS 측정과
/// `/country`(Geoapify 일 3,000건 한도 공유)까지 다시 탄다.
///
/// 반대로 검색은 자유 텍스트라 살려 두면 인스턴스가 무한히 늘어난다. 화면을
/// 나가면 폐기되게 둔다.
///
/// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
/// 무효화, 수정·삭제 시 그 자리 갱신.
///
/// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
/// 무효화하는 처리가 함께 필요하다.
///
/// Copied from [CommunityFeedNotifier].
@ProviderFor(CommunityFeedNotifier)
const communityFeedNotifierProvider = CommunityFeedNotifierFamily();

/// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier
///
/// **조회 조건(스코프·정렬·검색어)마다 인스턴스가 따로 살아 있다.** 서버 커서에
/// 국가·정렬·검색어가 봉인돼 있어 조건이 바뀌면 커서를 재사용할 수 없으므로
/// (400), 조건을 family 키로 두면 새 인스턴스가 커서 없이 첫 페이지를 부른다 —
/// 리셋 로직이 따로 필요 없고 커서 불일치가 구조적으로 발생하지 않는다.
///
/// 목록(`keyword == null`)만 `keepAlive`한다. 예전에는 하나의 인스턴스가 선택된
/// 스코프를 watch 해서, 전체 → 우리동네 → 전체로 토글할 때마다 목록을 다시
/// 불렀다. 그때 딸려 나가는 건 목록 하나가 아니다 — 유일한 watcher가 사라지면서
/// `communityCountryCodeProvider`도 함께 폐기돼, 돌아올 때 GPS 측정과
/// `/country`(Geoapify 일 3,000건 한도 공유)까지 다시 탄다.
///
/// 반대로 검색은 자유 텍스트라 살려 두면 인스턴스가 무한히 늘어난다. 화면을
/// 나가면 폐기되게 둔다.
///
/// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
/// 무효화, 수정·삭제 시 그 자리 갱신.
///
/// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
/// 무효화하는 처리가 함께 필요하다.
///
/// Copied from [CommunityFeedNotifier].
class CommunityFeedNotifierFamily
    extends Family<AsyncValue<CommunityFeedState>> {
  /// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier
  ///
  /// **조회 조건(스코프·정렬·검색어)마다 인스턴스가 따로 살아 있다.** 서버 커서에
  /// 국가·정렬·검색어가 봉인돼 있어 조건이 바뀌면 커서를 재사용할 수 없으므로
  /// (400), 조건을 family 키로 두면 새 인스턴스가 커서 없이 첫 페이지를 부른다 —
  /// 리셋 로직이 따로 필요 없고 커서 불일치가 구조적으로 발생하지 않는다.
  ///
  /// 목록(`keyword == null`)만 `keepAlive`한다. 예전에는 하나의 인스턴스가 선택된
  /// 스코프를 watch 해서, 전체 → 우리동네 → 전체로 토글할 때마다 목록을 다시
  /// 불렀다. 그때 딸려 나가는 건 목록 하나가 아니다 — 유일한 watcher가 사라지면서
  /// `communityCountryCodeProvider`도 함께 폐기돼, 돌아올 때 GPS 측정과
  /// `/country`(Geoapify 일 3,000건 한도 공유)까지 다시 탄다.
  ///
  /// 반대로 검색은 자유 텍스트라 살려 두면 인스턴스가 무한히 늘어난다. 화면을
  /// 나가면 폐기되게 둔다.
  ///
  /// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
  /// 무효화, 수정·삭제 시 그 자리 갱신.
  ///
  /// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
  /// 무효화하는 처리가 함께 필요하다.
  ///
  /// Copied from [CommunityFeedNotifier].
  const CommunityFeedNotifierFamily();

  /// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier
  ///
  /// **조회 조건(스코프·정렬·검색어)마다 인스턴스가 따로 살아 있다.** 서버 커서에
  /// 국가·정렬·검색어가 봉인돼 있어 조건이 바뀌면 커서를 재사용할 수 없으므로
  /// (400), 조건을 family 키로 두면 새 인스턴스가 커서 없이 첫 페이지를 부른다 —
  /// 리셋 로직이 따로 필요 없고 커서 불일치가 구조적으로 발생하지 않는다.
  ///
  /// 목록(`keyword == null`)만 `keepAlive`한다. 예전에는 하나의 인스턴스가 선택된
  /// 스코프를 watch 해서, 전체 → 우리동네 → 전체로 토글할 때마다 목록을 다시
  /// 불렀다. 그때 딸려 나가는 건 목록 하나가 아니다 — 유일한 watcher가 사라지면서
  /// `communityCountryCodeProvider`도 함께 폐기돼, 돌아올 때 GPS 측정과
  /// `/country`(Geoapify 일 3,000건 한도 공유)까지 다시 탄다.
  ///
  /// 반대로 검색은 자유 텍스트라 살려 두면 인스턴스가 무한히 늘어난다. 화면을
  /// 나가면 폐기되게 둔다.
  ///
  /// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
  /// 무효화, 수정·삭제 시 그 자리 갱신.
  ///
  /// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
  /// 무효화하는 처리가 함께 필요하다.
  ///
  /// Copied from [CommunityFeedNotifier].
  CommunityFeedNotifierProvider call(
    CommunityScope scope,
    CommunitySortOption sort,
    String? keyword,
  ) {
    return CommunityFeedNotifierProvider(scope, sort, keyword);
  }

  @override
  CommunityFeedNotifierProvider getProviderOverride(
    covariant CommunityFeedNotifierProvider provider,
  ) {
    return call(provider.scope, provider.sort, provider.keyword);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'communityFeedNotifierProvider';
}

/// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier
///
/// **조회 조건(스코프·정렬·검색어)마다 인스턴스가 따로 살아 있다.** 서버 커서에
/// 국가·정렬·검색어가 봉인돼 있어 조건이 바뀌면 커서를 재사용할 수 없으므로
/// (400), 조건을 family 키로 두면 새 인스턴스가 커서 없이 첫 페이지를 부른다 —
/// 리셋 로직이 따로 필요 없고 커서 불일치가 구조적으로 발생하지 않는다.
///
/// 목록(`keyword == null`)만 `keepAlive`한다. 예전에는 하나의 인스턴스가 선택된
/// 스코프를 watch 해서, 전체 → 우리동네 → 전체로 토글할 때마다 목록을 다시
/// 불렀다. 그때 딸려 나가는 건 목록 하나가 아니다 — 유일한 watcher가 사라지면서
/// `communityCountryCodeProvider`도 함께 폐기돼, 돌아올 때 GPS 측정과
/// `/country`(Geoapify 일 3,000건 한도 공유)까지 다시 탄다.
///
/// 반대로 검색은 자유 텍스트라 살려 두면 인스턴스가 무한히 늘어난다. 화면을
/// 나가면 폐기되게 둔다.
///
/// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
/// 무효화, 수정·삭제 시 그 자리 갱신.
///
/// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
/// 무효화하는 처리가 함께 필요하다.
///
/// Copied from [CommunityFeedNotifier].
class CommunityFeedNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CommunityFeedNotifier,
          CommunityFeedState
        > {
  /// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier
  ///
  /// **조회 조건(스코프·정렬·검색어)마다 인스턴스가 따로 살아 있다.** 서버 커서에
  /// 국가·정렬·검색어가 봉인돼 있어 조건이 바뀌면 커서를 재사용할 수 없으므로
  /// (400), 조건을 family 키로 두면 새 인스턴스가 커서 없이 첫 페이지를 부른다 —
  /// 리셋 로직이 따로 필요 없고 커서 불일치가 구조적으로 발생하지 않는다.
  ///
  /// 목록(`keyword == null`)만 `keepAlive`한다. 예전에는 하나의 인스턴스가 선택된
  /// 스코프를 watch 해서, 전체 → 우리동네 → 전체로 토글할 때마다 목록을 다시
  /// 불렀다. 그때 딸려 나가는 건 목록 하나가 아니다 — 유일한 watcher가 사라지면서
  /// `communityCountryCodeProvider`도 함께 폐기돼, 돌아올 때 GPS 측정과
  /// `/country`(Geoapify 일 3,000건 한도 공유)까지 다시 탄다.
  ///
  /// 반대로 검색은 자유 텍스트라 살려 두면 인스턴스가 무한히 늘어난다. 화면을
  /// 나가면 폐기되게 둔다.
  ///
  /// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
  /// 무효화, 수정·삭제 시 그 자리 갱신.
  ///
  /// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
  /// 무효화하는 처리가 함께 필요하다.
  ///
  /// Copied from [CommunityFeedNotifier].
  CommunityFeedNotifierProvider(
    CommunityScope scope,
    CommunitySortOption sort,
    String? keyword,
  ) : this._internal(
        () => CommunityFeedNotifier()
          ..scope = scope
          ..sort = sort
          ..keyword = keyword,
        from: communityFeedNotifierProvider,
        name: r'communityFeedNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$communityFeedNotifierHash,
        dependencies: CommunityFeedNotifierFamily._dependencies,
        allTransitiveDependencies:
            CommunityFeedNotifierFamily._allTransitiveDependencies,
        scope: scope,
        sort: sort,
        keyword: keyword,
      );

  CommunityFeedNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
    required this.sort,
    required this.keyword,
  }) : super.internal();

  final CommunityScope scope;
  final CommunitySortOption sort;
  final String? keyword;

  @override
  FutureOr<CommunityFeedState> runNotifierBuild(
    covariant CommunityFeedNotifier notifier,
  ) {
    return notifier.build(scope, sort, keyword);
  }

  @override
  Override overrideWith(CommunityFeedNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommunityFeedNotifierProvider._internal(
        () => create()
          ..scope = scope
          ..sort = sort
          ..keyword = keyword,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
        sort: sort,
        keyword: keyword,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    CommunityFeedNotifier,
    CommunityFeedState
  >
  createElement() {
    return _CommunityFeedNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityFeedNotifierProvider &&
        other.scope == scope &&
        other.sort == sort &&
        other.keyword == keyword;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);
    hash = _SystemHash.combine(hash, sort.hashCode);
    hash = _SystemHash.combine(hash, keyword.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommunityFeedNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CommunityFeedState> {
  /// The parameter `scope` of this provider.
  CommunityScope get scope;

  /// The parameter `sort` of this provider.
  CommunitySortOption get sort;

  /// The parameter `keyword` of this provider.
  String? get keyword;
}

class _CommunityFeedNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CommunityFeedNotifier,
          CommunityFeedState
        >
    with CommunityFeedNotifierRef {
  _CommunityFeedNotifierProviderElement(super.provider);

  @override
  CommunityScope get scope => (origin as CommunityFeedNotifierProvider).scope;
  @override
  CommunitySortOption get sort =>
      (origin as CommunityFeedNotifierProvider).sort;
  @override
  String? get keyword => (origin as CommunityFeedNotifierProvider).keyword;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
