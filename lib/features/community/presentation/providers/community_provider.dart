import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'
    show LocationAccuracy, LocationPermission;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/location/device_location_service.dart';
import '../../../../core/services/permission/location_permission_service.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/datasources/community_remote_datasource.dart';
import '../../data/repositories/community_comment_repository_impl.dart';
import '../../data/repositories/community_reaction_repository_impl.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../domain/repositories/community_comment_repository.dart';
import '../../domain/repositories/community_reaction_repository.dart';
import '../../domain/community_post_errors.dart';
import 'community_chat_rooms_provider.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/entities/community_post_status.dart';
import '../../domain/entities/community_scope.dart';
import '../../domain/entities/community_sort_option.dart';
import '../../domain/repositories/community_repository.dart';
import 'community_feed_state.dart';

part 'community_provider.g.dart';

// ============================================================================
// Data Layer Providers
// ============================================================================

/// `CommunityRemoteDataSource` Provider (Retrofit)
@riverpod
CommunityRemoteDataSource communityRemoteDataSource(Ref ref) {
  return CommunityRemoteDataSource(ref.watch(dioProvider));
}

// ============================================================================
// Domain Layer Providers
// ============================================================================

/// `CommunityRepository` Provider
@riverpod
CommunityRepository communityRepository(Ref ref) {
  return CommunityRepositoryImpl(ref.watch(communityRemoteDataSourceProvider));
}

/// `CommunityCommentRepository` Provider
@riverpod
CommunityCommentRepository communityCommentRepository(Ref ref) {
  return CommunityCommentRepositoryImpl(
    ref.watch(communityRemoteDataSourceProvider),
  );
}

/// `CommunityReactionRepository` Provider
///
/// 상태를 안 들고 있으므로 keepAlive가 필요 없다 — 서버가 상태를 갖는다.
@riverpod
CommunityReactionRepository communityReactionRepository(Ref ref) {
  return CommunityReactionRepositoryImpl(
    ref.watch(communityRemoteDataSourceProvider),
  );
}

// ============================================================================
// Presentation Layer Providers
// ============================================================================

/// 현재 선택된 목록 범위 필터
///
/// `CommunityFeedNotifier`의 family 키에 그대로 들어가므로, 값이 바뀌면 그
/// 스코프의 인스턴스가 커서 없이 첫 페이지를 부른다 — 리셋 로직이 따로 없다.
/// 토글 UI는 이 provider를 직접 watch 해서 네트워크 응답을 기다리지 않고
/// 탭 즉시 선택 표시를 바꾼다.
@riverpod
class SelectedCommunityScope extends _$SelectedCommunityScope {
  @override
  CommunityScope build() => CommunityScope.all;

  void select(CommunityScope scope) => state = scope;
}

/// 현재 선택된 정렬 기준.
///
/// 목록 화면과 검색 화면이 이 하나를 공유한다 — "마감 임박순으로 보고 싶다"는
/// 화면에 따라 달라지는 선호가 아니다.
///
/// `CommunityFeedNotifier`의 family 키에 그대로 들어가므로, 값이 바뀌면 그 정렬의
/// 인스턴스가 커서 없이 첫 페이지를 부른다. 서버 커서에 정렬이 봉인돼 있어
/// 재사용하면 400이라, 이 구조가 곧 계약이다.
@riverpod
class SelectedCommunitySort extends _$SelectedCommunitySort {
  @override
  CommunitySortOption build() => CommunitySortOption.latest;

  void select(CommunitySortOption option) => state = option;
}

/// 기기의 현재 좌표.
typedef DeviceCoordinates = ({double latitude, double longitude});

/// 현재 위치를 구한다 — 권한이 **이미 있을 때만**.
///
/// 목록 한 번 보자고, 장소 한 번 고르자고 권한 팝업을 띄우지 않는다. 권한이
/// 없거나 GPS가 응답하지 않으면 `null`이고, 호출자가 각자의 방식으로 물러선다
/// (목록은 기기 로케일, 장소 선택 화면은 기본 좌표).
///
/// 정확도를 [LocationAccuracy.medium](~100m)으로 낮추고 대기를 3초로 줄인 이유:
/// 두 호출처 모두 미터 정밀도가 필요 없다 — 국가 판별과 지도 시작점이다. 반면
/// 이 대기는 화면 진입을 그대로 막는다(국가 → 목록 순서라 직렬이다). 길게 잡아 봐야
/// 폴백을 늦게 줄 뿐이라, 백엔드가 VWorld 타임아웃을 2초로 되돌린 판단과 같은 이유로
/// 짧게 둔다.
Future<DeviceCoordinates?> resolveCurrentPosition() async {
  if (!await LocationPermissionService.canAccessLocation()) return null;

  final position = await DeviceLocationService.getCurrentPosition(
    accuracy: LocationAccuracy.medium,
    timeLimit: const Duration(seconds: 3),
  );
  if (position == null) return null;

  return (latitude: position.latitude, longitude: position.longitude);
}

/// 현재 위치 판별기 Provider
///
/// GPS·권한은 시스템 경계라 여기서 한 번 갈라 둔다. 테스트는 이 provider만
/// 갈아끼우면 플랫폼 채널을 건드리지 않고 "권한 있음/없음"을 만들어 낼 수 있다.
///
/// 값이 아니라 함수를 담는다 — 호출자가 부르는 시점의 위치를 원하기 때문이다.
/// (한 번 정하면 되는 국가 코드는 아래 [communityCountryCodeProvider]가 캐시한다.)
@riverpod
Future<DeviceCoordinates?> Function() currentPositionResolver(Ref ref) =>
    resolveCurrentPosition;

/// 위치 권한을 확보하는 함수 Provider.
///
/// 권한 서비스는 시스템 경계라 여기서 갈라 둔다 — 위 [currentPositionResolverProvider]와
/// 같은 이유다. `LocationPermissionService.ensurePermission`이 static이라 테스트에서
/// 직접 갈아끼울 수 없으므로, 이 provider가 갈아끼울 자리를 대신 제공한다.
///
/// 값이 아니라 함수를 담는다 — 호출자가 시트에서 거리순을 고른 시점의 권한
/// 상태를 원하기 때문이다.
@riverpod
Future<bool> Function() ensureLocationPermission(Ref ref) =>
    LocationPermissionService.ensurePermission;

/// 위치 권한 상태를 확인하는 함수 Provider. 영구 거부 여부를 가릴 때 쓴다
/// (안내 문구를 설정 화면 유도로 바꾸는 분기).
///
/// [ensureLocationPermissionProvider]와 같은 이유로 감쌌다.
@riverpod
Future<LocationPermission> Function() checkLocationPermission(Ref ref) =>
    LocationPermissionService.checkPermission;

/// 현재 시각.
///
/// 시간은 시스템 경계라 갈아끼울 자리가 필요하다 — 유효 시간 판정을 테스트하려면
/// 시계를 앞으로 돌릴 수 있어야 한다. 값이 아니라 함수를 담는 이유는 호출하는
/// 시점의 시각을 원하기 때문이다.
///
/// 세 번째 사용처가 생기면 `core`로 옮긴다. 지금은 목록 유효 시간만 쓴다.
@riverpod
DateTime Function() clock(Ref ref) => DateTime.now;

/// 기기 로케일의 국가 코드. 로케일에 국가가 없으면(`en` 같은 경우) 주 시장인
/// 한국으로 둔다 — 국가를 못 정하면 목록 자체를 못 부른다.
///
/// provider로 감싼 이유: `PlatformDispatcher`는 시스템 경계라 테스트에서 값을
/// 바꿀 수 없다. 폴백 분기를 검증하려면 갈아끼울 자리가 필요하다.
@riverpod
String deviceCountryCode(Ref ref) =>
    PlatformDispatcher.instance.locale.countryCode ?? 'KR';

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
@Riverpod(keepAlive: true)
Future<String> communityCountryCode(Ref ref) async {
  final fallback = ref.watch(deviceCountryCodeProvider);

  try {
    final position = await ref.read(currentPositionResolverProvider)();
    if (position == null) return fallback;

    final code = await ref
        .read(communityRepositoryProvider)
        .getCountryCode(
          latitude: position.latitude,
          longitude: position.longitude,
        );
    return code ?? fallback;
  } catch (e) {
    debugPrint('[커뮤니티] ⚠️ 국가 판별 실패 → 기기 로케일($fallback) 사용: $e');
    return fallback;
  }
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
@riverpod
class CommunityFeedNotifier extends _$CommunityFeedNotifier {
  static const _pageSize = 20;

  /// 마지막 조회로부터 이 시간이 지나면 낡은 것으로 본다.
  ///
  /// 모집글은 실시간 데이터가 아니라 잠깐 낡은 화면을 보는 것은 허용한다.
  /// 다만 게임 한 판이 보통 이보다 길어, 끝내고 돌아오면 새로 받게 된다.
  static const _staleAfter = Duration(minutes: 3);

  @override
  FutureOr<CommunityFeedState> build(
    CommunityScope scope,
    CommunitySortOption sort,
    String? keyword,
  ) async {
    // 목록은 살려 둔다(위 주석). 검색은 화면을 나가면 폐기되게 둔다.
    if (keyword == null) ref.keepAlive();

    // 백엔드가 scope=NEARBY/MINE에 400을 준다. 확정 실패를 왕복시키지 않고
    // 호출 자체를 건너뛰어 빈 목록을 돌려준다 — 화면은 이 상태를 "준비 중"
    // 안내로 그린다.
    if (scope != CommunityScope.all) {
      return CommunityFeedState(
        items: const [],
        nextCursor: null,
        hasMore: false,
        // 서버를 부르지 않았지만 "이 시점의 판정 결과"라 시각을 남긴다.
        // 낡음 판정은 걸리지만 결과가 항상 같은 빈 목록이라 무해하다.
        fetchedAt: ref.read(clockProvider)(),
      );
    }

    final coordinates = await _resolveSortCoordinates(sort);
    // 거리순인데 좌표가 없으면 서버가 400을 준다. 화면이 권한을 확보한 뒤에만
    // 거리순을 고르게 하므로 정상 경로에서는 오지 않는다 — 권한이 나중에
    // 회수된 경우의 안전망이다.
    final effectiveSort =
        sort == CommunitySortOption.distance && coordinates == null
        ? CommunitySortOption.latest
        : sort;
    if (effectiveSort != sort) {
      debugPrint('[커뮤니티] ⚠️ 거리순 좌표 없음 → 최신순으로 조회');
    }

    // 첫 요청은 커서 없이, 대신 국가 코드를 실어 보낸다. 국가 판별은
    // communityCountryCodeProvider가 앱 세션 내내 한 번만 하고 결과를 들고 있는다.
    final countryCode = await ref.watch(communityCountryCodeProvider.future);
    final page = await ref
        .watch(communityRepositoryProvider)
        .getPosts(
          size: _pageSize,
          countryCode: countryCode,
          sort: effectiveSort,
          keyword: keyword,
          latitude: coordinates?.latitude,
          longitude: coordinates?.longitude,
        );

    return CommunityFeedState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasNext,
      latitude: coordinates?.latitude,
      longitude: coordinates?.longitude,
      fetchedAt: ref.read(clockProvider)(),
    );
  }

  /// 거리순일 때만 좌표를 구한다. 권한이 없거나 조회가 실패하면 null —
  /// build()의 [effectiveSort] 폴백이 그대로 받아 최신순으로 물러선다.
  /// communityCountryCode와 같은 이유로 예외를 밖으로 던지지 않는다: 좌표
  /// 하나 못 구했다고 목록 전체가 에러 화면이 되면 안 된다.
  Future<DeviceCoordinates?> _resolveSortCoordinates(
    CommunitySortOption sort,
  ) async {
    if (sort != CommunitySortOption.distance) return null;
    try {
      return await ref.read(currentPositionResolverProvider)();
    } catch (e) {
      debugPrint('[커뮤니티] ⚠️ 거리순 좌표 조회 실패 → null 처리: $e');
      return null;
    }
  }

  /// 다음 페이지를 이어붙인다.
  ///
  /// 실패해도 이미 보이는 목록은 지우지 않고 예외를 다시 던진다 — 화면이
  /// 스낵바로만 알리게 하기 위함이다.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    // 이 대입은 첫 await 이전이라 동기적으로 끝난다. 스크롤 리스너가 프레임마다
    // 호출해도 두 번째 호출은 위 isLoadingMore 가드에 걸린다.
    // pending을 별도로 들고 있는 이유: family 키가 스코프·정렬·검색어별로 갈려
    // 있어 이 인스턴스의 state가 다른 인스턴스로 교체되는 일은 없다. 대신
    // await 도중 refresh()가 끼어들면 invalidateSelf가 build()를 다시 돌려
    // 같은 인스턴스의 state를 이 pending과 다른 값으로 바꿔치운다. 응답이
    // 돌아왔을 때 state가 여전히 pending과 identical한지 확인해야 그 새 state를
    // 낡은 응답으로 덮어쓰지 않는다.
    final pending = current.copyWith(isLoadingMore: true);
    state = AsyncData(pending);

    try {
      // 첫 페이지에서 이미 해석돼 provider가 들고 있는 값이라 즉시 돌아온다 —
      // 스크롤할 때마다 GPS를 켜거나 벤더를 부르지 않는다.
      final countryCode = await ref.read(communityCountryCodeProvider.future);

      final page = await ref
          .read(communityRepositoryProvider)
          .getPosts(
            cursor: current.nextCursor,
            size: _pageSize,
            countryCode: countryCode,
            // 커서에 봉인된 조건과 같아야 한다 — 다르면 서버가 400을 준다.
            // build가 좌표 없이 물러섰다면(첫 페이지에 latitude가 없다면) 커서도
            // LATEST로 봉인돼 있으므로 여기도 같은 판정을 다시 밟는다.
            sort:
                sort == CommunitySortOption.distance && current.latitude == null
                ? CommunitySortOption.latest
                : sort,
            keyword: keyword,
            // 첫 페이지에서 구한 좌표를 그대로 쓴다 (GPS 재측정 없음).
            latitude: current.latitude,
            longitude: current.longitude,
          );

      // refresh()가 끼어들어 state가 이미 교체됐다면 이 응답은 낡은 것이다 —
      // 최신 상태를 덮지 않고 조용히 버린다.
      if (!identical(state.valueOrNull, pending)) return;

      // 커서는 "몇 번째"가 아니라 "어디까지 봤는지"를 들고 다니므로, 스크롤 중
      // 새 글이 올라와도 경계가 밀리지 않는다 — id 중복 제거가 필요 없다.
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
          hasMore: page.hasNext,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      // 그 사이 refresh()가 끼어들어 state가 이미 교체됐다면 건드리지 않는다.
      if (identical(state.valueOrNull, pending)) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      }
      rethrow;
    }
  }

  /// 목록을 0페이지부터 다시 조회한다 (pull-to-refresh).
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// 낡았으면 첫 페이지부터 다시 받는다. 화면이 다시 보이는 순간 호출한다.
  ///
  /// 사용자가 부른 동작이 아니므로 조용히 갱신하고, 아래 세 경우에는 손대지
  /// 않는다 — 건드려 봐야 이득이 없거나 진행 중인 일을 망친다.
  Future<void> refreshIfStale() async {
    final current = state.valueOrNull;
    // 한 번도 성공한 적 없는 상태다 — 첫 로드 중이거나 첫 로드가 실패했다.
    // 전자는 곧 최신이 되고, 후자는 되살릴 목록 자체가 없다.
    //
    // 반대로 한 번 성공한 뒤 실패한 상태는 여기를 통과해 다시 받는다.
    // Riverpod의 AsyncError가 이전 성공 값을 그대로 들고 있어서인데
    // (`copyWithPrevious`), 그게 맞는 동작이다 — 화면에 다시 들어오는 순간은
    // 일시 장애로 실패한 조회를 재시도하기 가장 좋은 때다.
    if (current == null) return;
    // 페이지를 이어붙이는 중이면 그 요청을 버리게 된다.
    if (current.isLoadingMore) return;
    // 이미 갱신이 진행 중이면(사용자의 당겨서 새로고침이든, 겹친 트리거든)
    // state가 AsyncLoading이라 valueOrNull이 옛 fetchedAt을 그대로 돌려준다 —
    // 이 가드가 없으면 두 트리거가 겹칠 때 요청이 한 번 더 나간다.
    if (state.isLoading) return;
    // 여러 페이지를 이미 불러온 목록은 건드리지 않는다. 0페이지부터 다시 받으면
    // 읽던 자리를 잃고, 스크롤이 새 목록 끝으로 밀리면서 loadMore까지 딸려
    // 나간다. 그 사용자는 당겨서 새로고침으로 직접 갱신할 수 있다.
    if (current.items.length > _pageSize) return;
    if (ref.read(clockProvider)().difference(current.fetchedAt) < _staleAfter) {
      return;
    }
    // 배경 갱신은 사용자가 부른 것이 아니다. 실패했다고 보고 있던 목록을
    // 에러 화면으로 갈아치우면, 아무것도 안 누른 사용자가 지하철에서
    // 목록을 잃는다. 이전 상태를 그대로 되돌린다 — fetchedAt도 옛날 값이라
    // 다음 복귀에 다시 시도한다.
    // (당겨서 새로고침은 사용자가 요청한 것이므로 refresh()가 그대로 에러를
    //  화면에 반영하는 것이 맞다.)
    final previous = state;
    try {
      await refresh();
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  /// 모집 상태를 뒤집는다 (모집중 ↔ 마감). 서버가 돌려준 글로 그 카드만 간다.
  ///
  /// 목록을 통째로 무효화하지 않는 이유: 커서 페이지네이션이라 무효화는 0페이지
  /// 부터 다시 당긴다 — 3페이지까지 내려온 사용자가 마감 한 번에 맨 위로 튕긴다.
  ///
  /// 실패는 그대로 올린다(화면이 스낵바로 알린다). 다만 그 사이 다른 사용자가
  /// 지워 버린 글이면 되돌릴 상태 자체가 없으므로 목록에서도 걷어낸다.
  Future<void> toggleStatus(CommunityPostEntity post) async {
    // 메뉴가 이미 감추지만, 종료 글은 서버가 조회 시 다시 ENDED로 판정하므로
    // 여기까지 왔다면 왕복만 낭비하는 요청이다.
    if (post.status == CommunityPostStatus.ended) return;

    final next = post.status == CommunityPostStatus.recruiting
        ? CommunityPostStatus.completed
        : CommunityPostStatus.recruiting;

    try {
      final updated = await ref
          .read(communityRepositoryProvider)
          .updateStatus(postId: post.id, status: next);
      replacePost(updated);
    } on AppException catch (e) {
      if (isCommunityPostGone(e)) removePost(post.id);
      rethrow;
    }
  }

  /// 게시글을 삭제하고 목록에서 뺀다.
  ///
  /// 이미 사라진 글(404)이어도 결과는 같다 — 목록에 남을 이유가 없으므로 걷어낸
  /// 뒤 예외를 올린다.
  Future<void> deletePost(int postId) async {
    try {
      await ref.read(communityRepositoryProvider).deletePost(postId);
    } on AppException catch (e) {
      if (isCommunityPostGone(e)) removePost(postId);
      rethrow;
    }
    removePost(postId);
    // 글이 지워지면 서버가 그 채팅방도 지운다. 채팅방 목록은 keepAlive라 스스로
    // 다시 받지 않고, 사라진 방은 소켓 이벤트도 만들지 않는다 (LSN-0042).
    // 아직 안 만들어졌으면 두는 이유: 없는 걸 invalidate하면 그 자리에서 빌드돼
    // 로그인 상태·소켓까지 끌고 온다. 처음 열 때 어차피 새로 받는다.
    if (ref.exists(communityChatRoomsProvider)) {
      ref.invalidate(communityChatRoomsProvider);
    }
  }

  /// 글 하나를 최신 값으로 갈아끼운다 (네트워크 없음).
  ///
  /// 수정 화면이 돌려준 글을 반영하는 통로다. 목록에 없는 글이면 아무 일도
  /// 일어나지 않는다 — 상세만 열려 있는 동안 목록이 폐기됐을 수 있다.
  void replacePost(CommunityPostEntity updated) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        items: [
          for (final post in current.items)
            post.id == updated.id ? updated : post,
        ],
      ),
    );
  }

  /// 글 하나를 목록에서 걷어낸다 (네트워크 없음).
  void removePost(int postId) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        items: [
          for (final post in current.items)
            if (post.id != postId) post,
        ],
      ),
    );
  }
}
