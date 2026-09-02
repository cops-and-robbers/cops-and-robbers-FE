import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/community_notification_entity.dart';
import 'community_provider.dart';

part 'community_notification_provider.freezed.dart';
part 'community_notification_provider.g.dart';

/// 알림함 목록의 누적 상태
///
/// 스크랩 목록(`CommunityScrapState`)과 같은 이유로 `fetchedAt`이 없다 —
/// 화면을 나가면 provider가 폐기되므로 유효 시간을 잴 대상이 없다.
@freezed
class CommunityNotificationState with _$CommunityNotificationState {
  const factory CommunityNotificationState({
    required List<CommunityNotificationEntity> items,
    required int? nextCursor,
    required bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = _CommunityNotificationState;
}

/// 내 알림함 목록 상태
///
/// `keepAlive`를 쓰지 않는다 — 화면을 나가면 폐기하고 다음에 열 때 새로 받는다.
@riverpod
class CommunityNotificationNotifier extends _$CommunityNotificationNotifier {
  static const _pageSize = 20;

  @override
  FutureOr<CommunityNotificationState> build() async {
    final page = await ref
        .watch(communityRepositoryProvider)
        .getNotifications(size: _pageSize);
    return CommunityNotificationState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasNext,
    );
  }

  /// 당겨서 새로고침 — 첫 페이지부터 다시 받아 통째로 갈아끼운다.
  ///
  /// `ref.invalidateSelf()`를 쓰지 않는 이유: 상태가 loading으로 떨어져 보고
  /// 있던 목록이 스피너로 바뀌었다 돌아온다. 실패하면 보이는 목록을 남기고
  /// 다시 던진다 — 알림함은 소켓이 없어 이 당김이 새 알림을 확인할 유일한
  /// 수단이라, 실패를 조용히 삼키면 "당겼는데 아무 일도 없다"가 된다.
  Future<void> refresh() async {
    final page = await ref
        .read(communityRepositoryProvider)
        .getNotifications(size: _pageSize);
    state = AsyncData(
      CommunityNotificationState(
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasNext,
      ),
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
          .getNotifications(cursor: current.nextCursor, size: _pageSize);
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        latest.copyWith(
          items: [...latest.items, ...page.items],
          nextCursor: page.nextCursor,
          hasMore: page.hasNext,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(isLoadingMore: false),
      );
      rethrow;
    }
  }
}

/// 안 읽은 알림 개수 (종 아이콘 배지용)
///
/// 커뮤니티 페이지가 항상 watch하므로 `keepAlive`를 쓰지 않는다 — 알림함을
/// 열었다 나올 때 [invalidate]해 다시 받으면 배지가 즉시 내려간다.
@riverpod
Future<int> communityNotificationUnreadCount(Ref ref) {
  return ref.watch(communityRepositoryProvider).getUnreadNotificationCount();
}
