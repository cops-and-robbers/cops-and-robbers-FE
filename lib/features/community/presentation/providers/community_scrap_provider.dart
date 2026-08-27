import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/community_post_entity.dart';
import 'community_provider.dart';

part 'community_scrap_provider.freezed.dart';
part 'community_scrap_provider.g.dart';

/// 스크랩 목록의 누적 상태
///
/// 피드와 달리 `fetchedAt`이 없다 — 화면을 나가면 provider가 폐기되므로
/// 유효 시간을 잴 대상이 없다.
@freezed
class CommunityScrapState with _$CommunityScrapState {
  const factory CommunityScrapState({
    required List<CommunityPostEntity> items,
    required int? nextCursor,
    required bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = _CommunityScrapState;
}

/// 내 스크랩 목록 상태
///
/// 피드(`CommunityFeedNotifier`)와 나눠 두는 이유: 엔드포인트가 다르고, 커서
/// 타입도 다르고(정수), 서버 정렬이 고정이라 family 키가 필요 없다.
///
/// `keepAlive`를 쓰지 않는다 — 화면을 나가면 폐기하고 다음에 열 때 새로 받는다.
/// 다른 화면에서 스크랩한 글이 이 목록에 없는 채로 남는 문제를 배관 없이 없앤다.
@riverpod
class CommunityScrapNotifier extends _$CommunityScrapNotifier {
  static const _pageSize = 20;

  @override
  FutureOr<CommunityScrapState> build() async {
    final page = await ref
        .watch(communityRepositoryProvider)
        .getScraps(size: _pageSize);
    return CommunityScrapState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasNext,
    );
  }

  /// 다음 페이지를 이어붙인다. 실패해도 보이는 목록은 지우지 않고 다시 던진다.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref
          .read(communityRepositoryProvider)
          .getScraps(cursor: current.nextCursor, size: _pageSize);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
          hasMore: page.hasNext,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  /// 상세에서 돌아왔을 때 그 글 하나만 다시 조회해 해제됐으면 걷어낸다.
  ///
  /// 목록 전체를 다시 받으면 커서와 스크롤 위치가 날아간다. 상세가 pop 결과를
  /// 돌려주거나 이 notifier를 직접 찾아가는 배관도 만들지 않는다 — 왕복 1회가
  /// 그 둘보다 싸다. 조회가 실패하면 아무것도 하지 않는다(행을 남긴다).
  Future<void> dropIfUnscrapped(int postId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    try {
      final post = await ref.read(communityRepositoryProvider).getPost(postId);
      if (post.isScrapped) return;
      state = AsyncData(
        current.copyWith(
          items: current.items.where((p) => p.id != postId).toList(),
        ),
      );
    } catch (_) {
      // 삭제된 글이면 404가 온다. 그때도 남겨 둔다 — 목록을 여는 다음 번에
      // 서버가 알아서 빼 준다.
    }
  }
}
