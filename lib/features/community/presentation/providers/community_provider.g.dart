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
    r'7467da990c8582b7c0d4ec85c4140f066087c9be';

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
    extends BuildlessAsyncNotifier<CommunityFeedState> {
  late final CommunityScope scope;

  FutureOr<CommunityFeedState> build(CommunityScope scope);
}

/// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier (스코프별)
///
/// **스코프마다 인스턴스가 따로 살아 있고, 각각 최초 1회만 조회한다.**
/// 예전에는 하나의 인스턴스가 선택된 스코프를 watch 해서, 전체 → 우리동네 →
/// 전체로 토글할 때마다 목록을 다시 불렀다. 그런데 그때 딸려 나가는 건 목록
/// 하나가 아니다 — 유일한 watcher가 사라지면서 `communityCountryCodeProvider`도
/// 함께 폐기돼, 돌아올 때 GPS 측정과 `/country`(Geoapify 일 3,000건 한도 공유)
/// 까지 다시 탄다. 토글 몇 번으로 벤더 한도를 갉아먹는 셈이었다.
///
/// `keepAlive`인 이유: 다른 스코프를 보는 동안에는 이 인스턴스를 watch 하는
/// 위젯이 없다. autoDispose면 그 순간 폐기돼 family로 나눈 의미가 사라진다.
///
/// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
/// 무효화, 수정·삭제 시 그 자리 갱신. 남는 건 "남이 올린 새 글은 당겨야 보인다"
/// 하나뿐이다.
///
/// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
/// 무효화하는 처리가 함께 필요하다.
///
/// Copied from [CommunityFeedNotifier].
@ProviderFor(CommunityFeedNotifier)
const communityFeedNotifierProvider = CommunityFeedNotifierFamily();

/// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier (스코프별)
///
/// **스코프마다 인스턴스가 따로 살아 있고, 각각 최초 1회만 조회한다.**
/// 예전에는 하나의 인스턴스가 선택된 스코프를 watch 해서, 전체 → 우리동네 →
/// 전체로 토글할 때마다 목록을 다시 불렀다. 그런데 그때 딸려 나가는 건 목록
/// 하나가 아니다 — 유일한 watcher가 사라지면서 `communityCountryCodeProvider`도
/// 함께 폐기돼, 돌아올 때 GPS 측정과 `/country`(Geoapify 일 3,000건 한도 공유)
/// 까지 다시 탄다. 토글 몇 번으로 벤더 한도를 갉아먹는 셈이었다.
///
/// `keepAlive`인 이유: 다른 스코프를 보는 동안에는 이 인스턴스를 watch 하는
/// 위젯이 없다. autoDispose면 그 순간 폐기돼 family로 나눈 의미가 사라진다.
///
/// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
/// 무효화, 수정·삭제 시 그 자리 갱신. 남는 건 "남이 올린 새 글은 당겨야 보인다"
/// 하나뿐이다.
///
/// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
/// 무효화하는 처리가 함께 필요하다.
///
/// Copied from [CommunityFeedNotifier].
class CommunityFeedNotifierFamily
    extends Family<AsyncValue<CommunityFeedState>> {
  /// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier (스코프별)
  ///
  /// **스코프마다 인스턴스가 따로 살아 있고, 각각 최초 1회만 조회한다.**
  /// 예전에는 하나의 인스턴스가 선택된 스코프를 watch 해서, 전체 → 우리동네 →
  /// 전체로 토글할 때마다 목록을 다시 불렀다. 그런데 그때 딸려 나가는 건 목록
  /// 하나가 아니다 — 유일한 watcher가 사라지면서 `communityCountryCodeProvider`도
  /// 함께 폐기돼, 돌아올 때 GPS 측정과 `/country`(Geoapify 일 3,000건 한도 공유)
  /// 까지 다시 탄다. 토글 몇 번으로 벤더 한도를 갉아먹는 셈이었다.
  ///
  /// `keepAlive`인 이유: 다른 스코프를 보는 동안에는 이 인스턴스를 watch 하는
  /// 위젯이 없다. autoDispose면 그 순간 폐기돼 family로 나눈 의미가 사라진다.
  ///
  /// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
  /// 무효화, 수정·삭제 시 그 자리 갱신. 남는 건 "남이 올린 새 글은 당겨야 보인다"
  /// 하나뿐이다.
  ///
  /// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
  /// 무효화하는 처리가 함께 필요하다.
  ///
  /// Copied from [CommunityFeedNotifier].
  const CommunityFeedNotifierFamily();

  /// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier (스코프별)
  ///
  /// **스코프마다 인스턴스가 따로 살아 있고, 각각 최초 1회만 조회한다.**
  /// 예전에는 하나의 인스턴스가 선택된 스코프를 watch 해서, 전체 → 우리동네 →
  /// 전체로 토글할 때마다 목록을 다시 불렀다. 그런데 그때 딸려 나가는 건 목록
  /// 하나가 아니다 — 유일한 watcher가 사라지면서 `communityCountryCodeProvider`도
  /// 함께 폐기돼, 돌아올 때 GPS 측정과 `/country`(Geoapify 일 3,000건 한도 공유)
  /// 까지 다시 탄다. 토글 몇 번으로 벤더 한도를 갉아먹는 셈이었다.
  ///
  /// `keepAlive`인 이유: 다른 스코프를 보는 동안에는 이 인스턴스를 watch 하는
  /// 위젯이 없다. autoDispose면 그 순간 폐기돼 family로 나눈 의미가 사라진다.
  ///
  /// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
  /// 무효화, 수정·삭제 시 그 자리 갱신. 남는 건 "남이 올린 새 글은 당겨야 보인다"
  /// 하나뿐이다.
  ///
  /// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
  /// 무효화하는 처리가 함께 필요하다.
  ///
  /// Copied from [CommunityFeedNotifier].
  CommunityFeedNotifierProvider call(CommunityScope scope) {
    return CommunityFeedNotifierProvider(scope);
  }

  @override
  CommunityFeedNotifierProvider getProviderOverride(
    covariant CommunityFeedNotifierProvider provider,
  ) {
    return call(provider.scope);
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

/// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier (스코프별)
///
/// **스코프마다 인스턴스가 따로 살아 있고, 각각 최초 1회만 조회한다.**
/// 예전에는 하나의 인스턴스가 선택된 스코프를 watch 해서, 전체 → 우리동네 →
/// 전체로 토글할 때마다 목록을 다시 불렀다. 그런데 그때 딸려 나가는 건 목록
/// 하나가 아니다 — 유일한 watcher가 사라지면서 `communityCountryCodeProvider`도
/// 함께 폐기돼, 돌아올 때 GPS 측정과 `/country`(Geoapify 일 3,000건 한도 공유)
/// 까지 다시 탄다. 토글 몇 번으로 벤더 한도를 갉아먹는 셈이었다.
///
/// `keepAlive`인 이유: 다른 스코프를 보는 동안에는 이 인스턴스를 watch 하는
/// 위젯이 없다. autoDispose면 그 순간 폐기돼 family로 나눈 의미가 사라진다.
///
/// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
/// 무효화, 수정·삭제 시 그 자리 갱신. 남는 건 "남이 올린 새 글은 당겨야 보인다"
/// 하나뿐이다.
///
/// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
/// 무효화하는 처리가 함께 필요하다.
///
/// Copied from [CommunityFeedNotifier].
class CommunityFeedNotifierProvider
    extends
        AsyncNotifierProviderImpl<CommunityFeedNotifier, CommunityFeedState> {
  /// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier (스코프별)
  ///
  /// **스코프마다 인스턴스가 따로 살아 있고, 각각 최초 1회만 조회한다.**
  /// 예전에는 하나의 인스턴스가 선택된 스코프를 watch 해서, 전체 → 우리동네 →
  /// 전체로 토글할 때마다 목록을 다시 불렀다. 그런데 그때 딸려 나가는 건 목록
  /// 하나가 아니다 — 유일한 watcher가 사라지면서 `communityCountryCodeProvider`도
  /// 함께 폐기돼, 돌아올 때 GPS 측정과 `/country`(Geoapify 일 3,000건 한도 공유)
  /// 까지 다시 탄다. 토글 몇 번으로 벤더 한도를 갉아먹는 셈이었다.
  ///
  /// `keepAlive`인 이유: 다른 스코프를 보는 동안에는 이 인스턴스를 watch 하는
  /// 위젯이 없다. autoDispose면 그 순간 폐기돼 family로 나눈 의미가 사라진다.
  ///
  /// 목록이 낡는 문제는 이미 다른 길로 해결돼 있다 — 당겨서 새로고침, 글 작성 시
  /// 무효화, 수정·삭제 시 그 자리 갱신. 남는 건 "남이 올린 새 글은 당겨야 보인다"
  /// 하나뿐이다.
  ///
  /// 주의: `MINE`이 열리면 그건 사용자별 목록이므로, 로그인·로그아웃 때
  /// 무효화하는 처리가 함께 필요하다.
  ///
  /// Copied from [CommunityFeedNotifier].
  CommunityFeedNotifierProvider(CommunityScope scope)
    : this._internal(
        () => CommunityFeedNotifier()..scope = scope,
        from: communityFeedNotifierProvider,
        name: r'communityFeedNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$communityFeedNotifierHash,
        dependencies: CommunityFeedNotifierFamily._dependencies,
        allTransitiveDependencies:
            CommunityFeedNotifierFamily._allTransitiveDependencies,
        scope: scope,
      );

  CommunityFeedNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
  }) : super.internal();

  final CommunityScope scope;

  @override
  FutureOr<CommunityFeedState> runNotifierBuild(
    covariant CommunityFeedNotifier notifier,
  ) {
    return notifier.build(scope);
  }

  @override
  Override overrideWith(CommunityFeedNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommunityFeedNotifierProvider._internal(
        () => create()..scope = scope,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<CommunityFeedNotifier, CommunityFeedState>
  createElement() {
    return _CommunityFeedNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityFeedNotifierProvider && other.scope == scope;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommunityFeedNotifierRef on AsyncNotifierProviderRef<CommunityFeedState> {
  /// The parameter `scope` of this provider.
  CommunityScope get scope;
}

class _CommunityFeedNotifierProviderElement
    extends
        AsyncNotifierProviderElement<CommunityFeedNotifier, CommunityFeedState>
    with CommunityFeedNotifierRef {
  _CommunityFeedNotifierProviderElement(super.provider);

  @override
  CommunityScope get scope => (origin as CommunityFeedNotifierProvider).scope;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
