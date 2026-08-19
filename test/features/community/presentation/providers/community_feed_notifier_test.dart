import 'dart:async';

import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

CommunityPostEntity _post(int id) => CommunityPostEntity(
  id: id,
  writerId: 7,
  title: '모집글 $id',
  content: '본문',
  meetingAt: DateTime(2026, 9, 10, 18, 0),
  latitude: 37.4979,
  longitude: 127.0276,
  maxParticipants: 10,
  status: CommunityPostStatus.recruiting,
  createdAt: DateTime(2026, 9, 1),
);

/// 시스템 경계 대체 — Repository 인터페이스만 가짜고 Notifier 로직은 실물이다.
///
/// [pagesByCursor]의 키는 요청에 실리는 커서다. 첫 요청은 커서가 없으므로 `null`.
class _FakeCommunityRepository implements CommunityRepository {
  _FakeCommunityRepository(this.pagesByCursor);

  final Map<String?, ({List<CommunityPostEntity> items, String? next})>
  pagesByCursor;

  final List<String?> requestedCursors = [];

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
  }) async {
    requestedCursors.add(cursor);
    final page =
        pagesByCursor[cursor] ?? (items: <CommunityPostEntity>[], next: null);
    return CommunityPostPageEntity(
      items: page.items,
      nextCursor: page.next,
      hasNext: page.next != null,
    );
  }
}

/// 첫 페이지는 즉시 응답하고, 두 번째 페이지(loadMore)는 외부에서 [secondPage]를
/// complete할 때까지 대기한다 — scope 전환이 응답 도착보다 먼저 끼어드는
/// 경쟁 조건을 재현하기 위한 시스템 경계 대체.
class _DelayedSecondPageRepository implements CommunityRepository {
  _DelayedSecondPageRepository(this.firstPageItems, this.secondPage);

  final List<CommunityPostEntity> firstPageItems;
  final Future<CommunityPostPageEntity> secondPage;

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
  }) {
    if (cursor == null) {
      return Future.value(
        CommunityPostPageEntity(
          items: firstPageItems,
          nextCursor: 'c1',
          hasNext: true,
        ),
      );
    }
    return secondPage;
  }
}

ProviderContainer _containerWith(CommunityRepository repo) {
  final container = ProviderContainer(
    overrides: [communityRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('CommunityFeedNotifier', () {
    test('appends_second_page_onto_first_when_load_more_called', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1), _post(2)], next: 'c1'),
        'c1': (items: [_post(3), _post(4)], next: null),
      });
      final container = _containerWith(repo);

      await container.read(communityFeedNotifierProvider.future);
      await container.read(communityFeedNotifierProvider.notifier).loadMore();

      final state = container.read(communityFeedNotifierProvider).requireValue;
      expect(state.items.map((e) => e.id), [1, 2, 3, 4]);
      // 커서는 이전 응답의 nextCursor를 그대로 실어 보낸다.
      expect(repo.requestedCursors, [null, 'c1']);
    });

    test('reports_no_more_pages_when_server_says_has_next_is_false', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: 'c1'),
        'c1': (items: [_post(2)], next: null),
      });
      final container = _containerWith(repo);

      final first = await container.read(communityFeedNotifierProvider.future);
      expect(first.hasMore, true);

      await container.read(communityFeedNotifierProvider.notifier).loadMore();

      final state = container.read(communityFeedNotifierProvider).requireValue;
      expect(state.hasMore, false);
    });

    test('ignores_load_more_when_no_pages_remain', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: null),
      });
      final container = _containerWith(repo);

      await container.read(communityFeedNotifierProvider.future);
      await container.read(communityFeedNotifierProvider.notifier).loadMore();

      // 첫 조회 1번만. hasMore=false면 추가 요청이 나가면 안 된다.
      expect(repo.requestedCursors, [null]);
    });

    test('does_not_call_api_when_scope_is_nearby', () async {
      // 백엔드가 scope=NEARBY에 400을 준다. 확정 실패를 왕복시키지 않고
      // 호출 자체를 막는다 — 화면은 이 빈 상태를 "준비 중"으로 그린다.
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: null),
      });
      final container = _containerWith(repo);

      container
          .read(selectedCommunityScopeProvider.notifier)
          .select(CommunityScope.nearby);

      final state = await container.read(communityFeedNotifierProvider.future);

      expect(repo.requestedCursors, isEmpty);
      expect(state.items, isEmpty);
      expect(state.hasMore, false);
    });

    test('refetches_from_first_page_when_scope_returns_to_all', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: null),
      });
      final container = _containerWith(repo);

      await container.read(communityFeedNotifierProvider.future);
      container
          .read(selectedCommunityScopeProvider.notifier)
          .select(CommunityScope.mine);
      await container.read(communityFeedNotifierProvider.future);
      container
          .read(selectedCommunityScopeProvider.notifier)
          .select(CommunityScope.all);
      await container.read(communityFeedNotifierProvider.future);

      // 전체 → 내 모임(호출 없음) → 전체. 커서 없이 두 번 조회한다.
      expect(repo.requestedCursors, [null, null]);
    });

    test(
      'keeps_scope_switched_empty_state_when_stale_load_more_resolves_late',
      () async {
        // loadMore()가 응답을 기다리는 사이 nearby로 전환하면 build()가
        // 재실행되어 상태가 빈 값으로 바뀐다. 그 뒤에 지연됐던 응답이 도착해도
        // all 스코프의 병합 결과로 nearby용 빈 상태를 덮으면 안 된다.
        final secondPage = Completer<CommunityPostPageEntity>();
        final repo = _DelayedSecondPageRepository([
          _post(1),
        ], secondPage.future);
        final container = _containerWith(repo);

        await container.read(communityFeedNotifierProvider.future);
        final loadMoreDone = container
            .read(communityFeedNotifierProvider.notifier)
            .loadMore();

        container
            .read(selectedCommunityScopeProvider.notifier)
            .select(CommunityScope.nearby);
        await container.read(communityFeedNotifierProvider.future);

        secondPage.complete(
          CommunityPostPageEntity(
            items: [_post(2)],
            nextCursor: null,
            hasNext: false,
          ),
        );
        await loadMoreDone;

        final state = container
            .read(communityFeedNotifierProvider)
            .requireValue;
        expect(state.items, isEmpty);
        expect(state.hasMore, false);
      },
    );
  });
}
