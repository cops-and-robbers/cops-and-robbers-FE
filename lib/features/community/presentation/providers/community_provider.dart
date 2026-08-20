import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/location/device_location_service.dart';
import '../../../../core/services/permission/location_permission_service.dart';
import '../../data/datasources/community_remote_datasource.dart';
import '../../data/repositories/community_repository_impl.dart';
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
///
/// 좋아요·스크랩·댓글은 백엔드에 API가 없어 아직 목이다
/// (`communityInteractionRepositoryProvider`). 게시글 CRUD는 전부 실서버다.
@riverpod
CommunityRepository communityRepository(Ref ref) {
  return CommunityRepositoryImpl(ref.watch(communityRemoteDataSourceProvider));
}

// ============================================================================
// Presentation Layer Providers
// ============================================================================

/// 현재 선택된 목록 범위 필터
///
/// `CommunityFeedNotifier.build()`가 이 값을 watch 하므로, 값이 바뀌면 build가
/// 재실행되며 자동으로 0페이지부터 다시 조회된다 — 리셋 로직이 따로 없다.
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
/// 아직 `CommunityFeedNotifier`가 watch하지 않는다 — 백엔드가 `sort` 파라미터를
/// 받긴 하지만 기본값 `LATEST` 외에는 400이라 보낼 값이 없기 때문이다. 지금은
/// 정렬 라벨 표시 전용이며, 다른 값이 열리면 `SelectedCommunityScope`와 같은
/// 방식으로 build()에서 watch해 연결한다.
@riverpod
class SelectedCommunitySort extends _$SelectedCommunitySort {
  @override
  CommunitySortOption build() => CommunitySortOption.latest;

  void select(CommunitySortOption option) => state = option;
}

/// 목록 조회에 실을 국가 식별자 — 좌표 한 쌍 **또는** 국가 코드 하나.
///
/// 서버는 둘 중 하나를 요구하고 둘 다 없으면 400(`COUNTRY_NOT_SPECIFIED`)이다.
typedef CountryQuery = ({
  double? latitude,
  double? longitude,
  String? countryCode,
});

/// 목록을 어느 국가로 조회할지 정한다.
///
/// 위치 권한이 **이미 있을 때만** 좌표를 쓴다 — 목록 한 번 보자고 권한 팝업을
/// 띄우지 않는다. 권한이 없거나 GPS가 응답하지 않으면 기기 로케일의 국가 코드로
/// 물러선다. 그래서 권한을 거부해도 목록은 항상 뜬다.
Future<CountryQuery> resolveCountryQuery() async {
  if (await LocationPermissionService.canAccessLocation()) {
    final position = await DeviceLocationService.getCurrentPosition();
    if (position != null) {
      return (
        latitude: position.latitude,
        longitude: position.longitude,
        countryCode: null,
      );
    }
  }
  return (latitude: null, longitude: null, countryCode: _deviceCountryCode());
}

/// 기기 로케일의 국가 코드. 로케일에 국가가 없으면(`en` 같은 경우) 주 시장인
/// 한국으로 둔다 — 국가를 못 정하면 목록 자체를 못 부른다.
String _deviceCountryCode() =>
    PlatformDispatcher.instance.locale.countryCode ?? 'KR';

/// 국가 판별기 Provider
///
/// GPS·권한·기기 로케일은 전부 시스템 경계라 여기서 한 번 갈라 둔다. 테스트는
/// 이 provider만 갈아끼우면 플랫폼 채널을 건드리지 않고 "권한 있음/없음"을
/// 만들어 낼 수 있다.
@riverpod
Future<CountryQuery> Function() countryQueryResolver(Ref ref) =>
    resolveCountryQuery;

/// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier
@riverpod
class CommunityFeedNotifier extends _$CommunityFeedNotifier {
  static const _pageSize = 20;

  @override
  FutureOr<CommunityFeedState> build() async {
    final scope = ref.watch(selectedCommunityScopeProvider);

    // 백엔드가 scope=NEARBY/MINE에 400을 준다. 확정 실패를 왕복시키지 않고
    // 호출 자체를 건너뛰어 빈 목록을 돌려준다 — 화면은 이 상태를 "준비 중"
    // 안내로 그린다.
    if (scope != CommunityScope.all) {
      return const CommunityFeedState(
        items: [],
        nextCursor: null,
        hasMore: false,
      );
    }

    // 첫 요청은 커서 없이, 대신 국가 식별자를 실어 보낸다.
    final query = await ref.read(countryQueryResolverProvider)();
    final page = await ref
        .watch(communityRepositoryProvider)
        .getPosts(
          size: _pageSize,
          countryCode: query.countryCode,
          latitude: query.latitude,
          longitude: query.longitude,
        );

    return CommunityFeedState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasNext,
      // 좌표로 물었으면 서버가 판별한 국가가 응답에 실려 온다. 안 실려 오면
      // 우리가 보낸 값을 그대로 들고 있는다 — 어느 쪽이든 다음 페이지는 좌표 없이 간다.
      countryCode: page.countryCode ?? query.countryCode,
    );
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
    // pending을 별도로 들고 있는 이유: await 도중 scope가 바뀌면 build()가
    // 재실행되어 state가 이 인스턴스에서 다른 인스턴스로 교체된다. 응답이
    // 돌아왔을 때 state가 여전히 pending과 identical한지 확인해야 그 사이
    // build()가 세팅한 새 스코프의 상태를 낡은 응답으로 덮어쓰지 않는다.
    final pending = current.copyWith(isLoadingMore: true);
    state = AsyncData(pending);

    try {
      // 첫 페이지에서 국가 코드를 받아 뒀으면 그걸 쓴다 — 스크롤할 때마다 GPS를
      // 다시 켜지 않으려는 것이다. 못 받아 둔 경우에만 좌표를 다시 구한다.
      final CountryQuery query = current.countryCode != null
          ? (latitude: null, longitude: null, countryCode: current.countryCode)
          : await ref.read(countryQueryResolverProvider)();

      final page = await ref
          .read(communityRepositoryProvider)
          .getPosts(
            cursor: current.nextCursor,
            size: _pageSize,
            countryCode: query.countryCode,
            latitude: query.latitude,
            longitude: query.longitude,
          );

      // scope 전환이나 refresh()가 끼어들어 state가 이미 교체됐다면 이 응답은
      // 낡은 것이다 — 최신 상태를 덮지 않고 조용히 버린다.
      if (!identical(state.valueOrNull, pending)) return;

      // 커서는 "몇 번째"가 아니라 "어디까지 봤는지"를 들고 다니므로, 스크롤 중
      // 새 글이 올라와도 경계가 밀리지 않는다 — id 중복 제거가 필요 없다.
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
          hasMore: page.hasNext,
          isLoadingMore: false,
          // 이번에 좌표로 물어 국가를 알아냈다면 여기서 붙잡아 둔다 — 다음
          // 페이지부터는 좌표가 필요 없어진다.
          countryCode: page.countryCode ?? current.countryCode,
        ),
      );
    } catch (_) {
      // 낡은 요청이면 최신 상태(다른 scope 등)를 건드리지 않는다.
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
}
