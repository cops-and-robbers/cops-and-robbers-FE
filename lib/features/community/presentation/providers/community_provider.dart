import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' show LocationAccuracy;
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

/// 기기 로케일의 국가 코드. 로케일에 국가가 없으면(`en` 같은 경우) 주 시장인
/// 한국으로 둔다 — 국가를 못 정하면 목록 자체를 못 부른다.
///
/// provider로 감싼 이유: `PlatformDispatcher`는 시스템 경계라 테스트에서 값을
/// 바꿀 수 없다. 폴백 분기를 검증하려면 갈아끼울 자리가 필요하다.
@riverpod
String deviceCountryCode(Ref ref) =>
    PlatformDispatcher.instance.locale.countryCode ?? 'KR';

/// 목록을 어느 국가로 조회할지 정한다 — 화면 진입당 한 번.
///
/// 목록 API는 좌표를 받지 않고 `countryCode`만 받으므로, 그 값을 여기서 먼저
/// 구한다(DEC-0021). 서버 조회는 벤더를 한 번 부르고 Geoapify 일 3,000건 한도를
/// 공유하므로, provider가 결과를 들고 있어 페이지를 넘길 때마다 다시 부르지 않는다.
///
/// **절대 예외를 던지지 않는다.** 좌표가 없든, 벤더가 죽었든, 서버가 값을
/// 빠뜨렸든 기기 로케일로 물러선다 — 국가 하나 못 알아냈다고 목록 전체가 에러
/// 화면이 되는 것이 이 API를 목록에서 떼어낸 이유와 정면으로 어긋난다.
@riverpod
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

    // 첫 요청은 커서 없이, 대신 국가 코드를 실어 보낸다. 국가 판별은
    // communityCountryCodeProvider가 진입당 한 번만 하고 결과를 들고 있는다.
    final countryCode = await ref.watch(communityCountryCodeProvider.future);
    final page = await ref
        .watch(communityRepositoryProvider)
        .getPosts(size: _pageSize, countryCode: countryCode);

    return CommunityFeedState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasNext,
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
      // 첫 페이지에서 이미 해석돼 provider가 들고 있는 값이라 즉시 돌아온다 —
      // 스크롤할 때마다 GPS를 켜거나 벤더를 부르지 않는다.
      final countryCode = await ref.read(communityCountryCodeProvider.future);

      final page = await ref
          .read(communityRepositoryProvider)
          .getPosts(
            cursor: current.nextCursor,
            size: _pageSize,
            countryCode: countryCode,
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
