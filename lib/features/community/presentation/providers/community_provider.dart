import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
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

    // 첫 요청은 커서 없이 보낸다.
    final page = await ref
        .watch(communityRepositoryProvider)
        .getPosts(size: _pageSize);

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
      final page = await ref
          .read(communityRepositoryProvider)
          .getPosts(cursor: current.nextCursor, size: _pageSize);

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
