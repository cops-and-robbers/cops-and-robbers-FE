import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/community_remote_datasource.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../domain/entities/community_scope.dart';
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

/// 커뮤니티 목록 무한 스크롤 상태 관리 Notifier
@riverpod
class CommunityFeedNotifier extends _$CommunityFeedNotifier {
  static const _pageSize = 20;

  @override
  FutureOr<CommunityFeedState> build() async {
    final scope = ref.watch(selectedCommunityScopeProvider);

    // 백엔드에 scope 쿼리가 없다. Spring은 모르는 파라미터를 무시하므로
    // NEARBY/MINE으로 요청하면 전체 목록이 돌아와 그 탭에 전국 글이 뜬다.
    // 지원되기 전까지 호출 자체를 하지 않고 빈 목록을 돌려준다 — 화면은
    // 이 상태를 "준비 중" 안내로 그린다.
    if (scope != CommunityScope.all) {
      return const CommunityFeedState(
        items: [],
        nextPage: 0,
        hasMore: false,
      );
    }

    final page = await ref
        .watch(communityRepositoryProvider)
        .getPosts(page: 0, size: _pageSize);

    return CommunityFeedState(
      items: page.items,
      nextPage: 1,
      hasMore: page.currentPage + 1 < page.totalPages,
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
          .getPosts(page: current.nextPage, size: _pageSize);

      // scope 전환이나 refresh()가 끼어들어 state가 이미 교체됐다면 이 응답은
      // 낡은 것이다 — 최신 상태를 덮지 않고 조용히 버린다.
      if (!identical(state.valueOrNull, pending)) return;

      // 오프셋 페이지네이션은 스크롤 중 새 글이 등록되면 목록 전체가 밀려
      // 이미 본 글이 다음 페이지에 다시 내려온다. id로 걸러낸다.
      // (백엔드가 커서 기반으로 바뀌면 자연히 사라지는 문제다.)
      final seen = current.items.map((e) => e.id).toSet();
      final fresh = page.items.where((e) => !seen.contains(e.id)).toList();

      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...fresh],
          nextPage: current.nextPage + 1,
          hasMore: page.currentPage + 1 < page.totalPages,
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
