import 'dart:async';

import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../community_fakes.dart';

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
class _FakeCommunityRepository
    with CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _FakeCommunityRepository(this.pagesByCursor);

  final Map<String?, ({List<CommunityPostEntity> items, String? next})>
  pagesByCursor;

  final List<String?> requestedCursors = [];
  final List<String> requestedCountryCodes = [];

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
  }) async {
    requestedCursors.add(cursor);
    requestedCountryCodes.add(countryCode);
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
class _DelayedSecondPageRepository
    with CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _DelayedSecondPageRepository(this.firstPageItems, this.secondPage);

  final List<CommunityPostEntity> firstPageItems;
  final Future<CommunityPostPageEntity> secondPage;

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
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

/// 목록에서 바로 하는 마감·삭제를 위한 시스템 경계 대체.
///
/// [goneIds]에 든 글은 서버가 이미 지운 것으로 취급해 404 `POST_NOT_FOUND`를
/// 돌려준다 — 다른 사용자가 먼저 지운 상황을 재현한다.
class _MutatingRepository
    with CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _MutatingRepository(this.items, {this.goneIds = const {}});

  final List<CommunityPostEntity> items;
  final Set<int> goneIds;

  final List<int> deletedIds = [];
  final List<({int postId, CommunityPostStatus status})> statusCalls = [];

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
  }) async =>
      CommunityPostPageEntity(items: items, nextCursor: null, hasNext: false);

  @override
  Future<CommunityPostEntity> updateStatus({
    required int postId,
    required CommunityPostStatus status,
  }) async {
    statusCalls.add((postId: postId, status: status));
    if (goneIds.contains(postId)) throw _gone();
    return items.firstWhere((p) => p.id == postId).copyWith(status: status);
  }

  @override
  Future<void> deletePost(int postId) async {
    deletedIds.add(postId);
    if (goneIds.contains(postId)) throw _gone();
  }
}

/// 남이 이미 지운 글을 만졌을 때 서버가 주는 응답 (404 `POST_NOT_FOUND`).
ServerException _gone() => const ServerException(
  message: 'not found',
  messageKey: 'errorTemporaryRetry',
  code: 'POST_NOT_FOUND',
);

ProviderContainer _containerWith(
  CommunityRepository repo, {
  String countryCode = 'KR',
}) {
  final container = ProviderContainer(
    overrides: [
      communityRepositoryProvider.overrideWithValue(repo),
      // 국가 판별은 GPS·권한·벤더를 거친다 — 전부 시스템 경계라 여기서 끊는다.
      communityCountryCodeProvider.overrideWith((ref) async => countryCode),
    ],
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

      await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );
      await container
          .read(communityFeedNotifierProvider(CommunityScope.all).notifier)
          .loadMore();

      final state = container
          .read(communityFeedNotifierProvider(CommunityScope.all))
          .requireValue;
      expect(state.items.map((e) => e.id), [1, 2, 3, 4]);
      // 커서는 이전 응답의 nextCursor를 그대로 실어 보낸다.
      expect(repo.requestedCursors, [null, 'c1']);
    });

    test('sends_resolved_country_code_on_every_page', () async {
      // 목록은 국가별로 나뉜다. 판별 결과를 안 싣거나 첫 페이지에만 실으면
      // 다른 나라 글이 섞이거나 400을 맞는다 (DEC-0021).
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: 'c1'),
        'c1': (items: [_post(2)], next: null),
      });
      final container = _containerWith(repo, countryCode: 'JP');

      await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );
      await container
          .read(communityFeedNotifierProvider(CommunityScope.all).notifier)
          .loadMore();

      expect(repo.requestedCountryCodes, ['JP', 'JP']);
    });

    test('reuses_resolved_country_when_refreshed', () async {
      // 당겨서 새로고침은 목록만 다시 부른다. 국가까지 재해석하면 새로고침할
      // 때마다 GPS를 켜고 벤더를 부르게 되는데, 그건 국가 조회를 목록에서
      // 떼어낸 이유(진입당 1회, Geoapify 일 3,000건 한도)를 되돌리는 것이다.
      var resolveCount = 0;
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: null),
      });
      final container = ProviderContainer(
        overrides: [
          communityRepositoryProvider.overrideWithValue(repo),
          communityCountryCodeProvider.overrideWith((ref) async {
            resolveCount++;
            return 'KR';
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );
      await container
          .read(communityFeedNotifierProvider(CommunityScope.all).notifier)
          .refresh();

      // 목록은 0페이지부터 다시, 국가는 그대로.
      expect(repo.requestedCursors, [null, null]);
      expect(resolveCount, 1);
    });

    test('reports_no_more_pages_when_server_says_has_next_is_false', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: 'c1'),
        'c1': (items: [_post(2)], next: null),
      });
      final container = _containerWith(repo);

      final first = await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );
      expect(first.hasMore, true);

      await container
          .read(communityFeedNotifierProvider(CommunityScope.all).notifier)
          .loadMore();

      final state = container
          .read(communityFeedNotifierProvider(CommunityScope.all))
          .requireValue;
      expect(state.hasMore, false);
    });

    test('ignores_load_more_when_no_pages_remain', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: null),
      });
      final container = _containerWith(repo);

      await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );
      await container
          .read(communityFeedNotifierProvider(CommunityScope.all).notifier)
          .loadMore();

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

      final state = await container.read(
        communityFeedNotifierProvider(CommunityScope.nearby).future,
      );

      expect(repo.requestedCursors, isEmpty);
      expect(state.items, isEmpty);
      expect(state.hasMore, false);
    });

    test('keeps_the_cached_list_when_scope_returns_to_all', () async {
      // 토글 왕복마다 다시 부르면 목록뿐 아니라 국가 판별(GPS + /country)까지
      // 다시 탄다 — Geoapify 일 3,000건 한도를 토글로 갉아먹는 셈이다.
      // 스코프마다 인스턴스가 따로 살아 있으므로 돌아와도 그대로다.
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: null),
      });
      final container = _containerWith(repo);

      await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );
      await container.read(
        communityFeedNotifierProvider(CommunityScope.mine).future,
      );
      final state = await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );

      // 전체는 처음 한 번만 조회했다.
      expect(repo.requestedCursors, [null]);
      expect(state.items.map((e) => e.id), [1]);
    });

    test('drops_a_stale_load_more_when_refresh_lands_first', () async {
      // loadMore()가 응답을 기다리는 사이 당겨서 새로고침이 끼어들면 build()가
      // 다시 돌아 상태가 새 목록으로 바뀐다. 그 뒤에 지연됐던 페이지가 도착해도
      // 낡은 병합 결과로 새 목록을 덮으면 안 된다.
      //
      // (예전에는 스코프 전환이 같은 경쟁을 만들었지만, 이제 스코프마다 인스턴스가
      //  따로라 서로 덮어쓸 수 없다 — 남은 경쟁은 새로고침뿐이다.)
      final secondPage = Completer<CommunityPostPageEntity>();
      final repo = _DelayedSecondPageRepository([_post(1)], secondPage.future);
      final container = _containerWith(repo);

      await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );
      final loadMoreDone = container
          .read(communityFeedNotifierProvider(CommunityScope.all).notifier)
          .loadMore();

      container.invalidate(communityFeedNotifierProvider(CommunityScope.all));
      await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );

      secondPage.complete(
        CommunityPostPageEntity(
          items: [_post(2)],
          nextCursor: null,
          hasNext: false,
        ),
      );
      await loadMoreDone;

      final state = container
          .read(communityFeedNotifierProvider(CommunityScope.all))
          .requireValue;
      // 새로고침이 만든 첫 페이지만 남는다 — 낡은 2페이지가 붙지 않는다.
      expect(state.items.map((e) => e.id), [1]);
    });
  });

  group('CommunityFeedNotifier 목록 액션', () {
    test('replaces_only_the_target_post_when_status_toggled', () async {
      final repo = _MutatingRepository([_post(1), _post(2)]);
      final container = _containerWith(repo);
      await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );

      await container
          .read(communityFeedNotifierProvider(CommunityScope.all).notifier)
          .toggleStatus(_post(2));

      final items = container
          .read(communityFeedNotifierProvider(CommunityScope.all))
          .requireValue
          .items;
      // 목록을 다시 당기지 않고 그 카드만 바뀐다 — 무효화하면 커서가 0으로
      // 돌아가 스크롤 위치가 날아간다.
      expect(items.map((e) => e.id), [1, 2]);
      expect(items[0].status, CommunityPostStatus.recruiting);
      expect(items[1].status, CommunityPostStatus.completed);
      expect(repo.statusCalls, [
        (postId: 2, status: CommunityPostStatus.completed),
      ]);
    });

    test('keeps_post_unchanged_when_toggling_status_of_ended_post', () async {
      // 메뉴가 이미 항목을 감추지만, 종료 글은 서버가 조회 시 다시 ENDED로
      // 판정하므로 여기까지 호출이 와도 왕복 자체를 막아야 한다.
      final endedPost = _post(2).copyWith(status: CommunityPostStatus.ended);
      final repo = _MutatingRepository([_post(1), endedPost]);
      final container = _containerWith(repo);
      await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );

      await container
          .read(communityFeedNotifierProvider(CommunityScope.all).notifier)
          .toggleStatus(endedPost);

      final items = container
          .read(communityFeedNotifierProvider(CommunityScope.all))
          .requireValue
          .items;
      expect(items[1].status, CommunityPostStatus.ended);
      expect(repo.statusCalls, isEmpty);
    });

    test('removes_the_post_from_the_list_when_deleted', () async {
      final repo = _MutatingRepository([_post(1), _post(2), _post(3)]);
      final container = _containerWith(repo);
      await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );

      await container
          .read(communityFeedNotifierProvider(CommunityScope.all).notifier)
          .deletePost(2);

      expect(
        container
            .read(communityFeedNotifierProvider(CommunityScope.all))
            .requireValue
            .items
            .map((e) => e.id),
        [1, 3],
      );
      expect(repo.deletedIds, [2]);
    });

    test('removes_the_post_when_server_says_it_is_already_gone', () async {
      // 남이 먼저 지운 글을 마감하려 한 경우. 되돌릴 상태가 없으므로 예외는
      // 그대로 올리되(화면이 알린다) 목록에서는 걷어낸다 — 안 그러면 사용자가
      // 유령 카드를 계속 누르게 된다.
      final repo = _MutatingRepository([_post(1), _post(2)], goneIds: {2});
      final container = _containerWith(repo);
      await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );

      await expectLater(
        container
            .read(communityFeedNotifierProvider(CommunityScope.all).notifier)
            .toggleStatus(_post(2)),
        throwsA(isA<AppException>()),
      );

      expect(
        container
            .read(communityFeedNotifierProvider(CommunityScope.all))
            .requireValue
            .items
            .map((e) => e.id),
        [1],
      );
    });

    test('replaces_the_post_when_edit_returns_an_updated_one', () async {
      final repo = _MutatingRepository([_post(1), _post(2)]);
      final container = _containerWith(repo);
      await container.read(
        communityFeedNotifierProvider(CommunityScope.all).future,
      );

      container
          .read(communityFeedNotifierProvider(CommunityScope.all).notifier)
          .replacePost(_post(2).copyWith(title: '제목을 고쳤어요'));

      final items = container
          .read(communityFeedNotifierProvider(CommunityScope.all))
          .requireValue
          .items;
      expect(items.map((e) => e.title), ['모집글 1', '제목을 고쳤어요']);
    });
  });
}
