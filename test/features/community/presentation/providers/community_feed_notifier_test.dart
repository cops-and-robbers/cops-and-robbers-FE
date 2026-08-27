import 'dart:async';

import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_comment_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_sort_option.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_comment_repository.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_reaction_repository.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_detail_provider.dart';
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
  likeCount: 0,
  isLiked: false,
  scrapCount: 0,
  isScrapped: false,
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
  final List<CommunitySortOption> requestedSorts = [];
  final List<({double? lat, double? lng})> requestedCoordinates = [];
  final List<String?> requestedKeywords = [];

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
  }) async {
    requestedCursors.add(cursor);
    requestedCountryCodes.add(countryCode);
    requestedSorts.add(sort);
    requestedCoordinates.add((lat: latitude, lng: longitude));
    requestedKeywords.add(keyword);
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
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
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
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
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

/// 첫 조회는 성공하고 이후 호출은 던지는 가짜 Repository.
/// 배경 갱신이 실패해도 이전 목록이 유지되는지(I-2) 검증하는 데 쓴다.
class _FailingAfterFirstRepository
    with CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _FailingAfterFirstRepository(this.items);

  final List<CommunityPostEntity> items;
  int callCount = 0;

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
  }) async {
    callCount++;
    if (callCount > 1) throw const ServerException(message: '서버 오류');
    return CommunityPostPageEntity(
      items: items,
      nextCursor: null,
      hasNext: false,
    );
  }
}

/// 목록과 상세를 함께 쓰는 가짜 — 상세에서 토글한 결과가 피드의 그 칸에
/// 반영되는지 끝까지 태우려면(`_syncFeedCard`) 둘 다 진짜로 응답해야 한다.
/// `CommunityRepositoryDetailStubs`가 채워 주는 나머지(수정·작성·주소·삭제·
/// 상태변경)는 이 테스트가 건드리지 않는다.
class _ListAndDetailRepository
    with CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _ListAndDetailRepository(this.items);

  final List<CommunityPostEntity> items;

  /// 피드가 안 살아있을 때 `_syncFeedCard`가 조회를 유발하지 않는지 세는 용도.
  int getPostsCallCount = 0;

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
  }) async {
    getPostsCallCount++;
    return CommunityPostPageEntity(items: items, nextCursor: null, hasNext: false);
  }

  @override
  Future<CommunityPostEntity> getPost(int postId) async =>
      items.firstWhere((p) => p.id == postId);
}

/// 댓글은 이 테스트의 관심사가 아니다 — 상세 build()가 요구하니 빈 목록만 준다.
class _EmptyCommentRepository implements CommunityCommentRepository {
  @override
  Future<List<CommunityCommentEntity>> getComments(int postId) async => [];

  @override
  Future<CommunityCommentEntity> addComment({
    required int postId,
    required String content,
    int? parentId,
  }) => throw UnimplementedError('이 테스트는 댓글 작성을 쓰지 않는다');

  @override
  Future<void> deleteComment(int commentId) =>
      throw UnimplementedError('이 테스트는 댓글 삭제를 쓰지 않는다');
}

/// 좋아요·스크랩 토글이 항상 성공하는 가짜.
class _SucceedingReactionRepository implements CommunityReactionRepository {
  @override
  Future<void> like(int postId) async {}

  @override
  Future<void> unlike(int postId) async {}

  @override
  Future<void> scrap(int postId) async {}

  @override
  Future<void> unscrap(int postId) async {}
}

ProviderContainer _containerWith(
  CommunityRepository repo, {
  String countryCode = 'KR',
  DateTime Function()? now,
  List<Override> extraOverrides = const [],
}) {
  final container = ProviderContainer(
    overrides: [
      communityRepositoryProvider.overrideWithValue(repo),
      // 국가 판별은 GPS·권한·벤더를 거친다 — 전부 시스템 경계라 여기서 끊는다.
      communityCountryCodeProvider.overrideWith((ref) async => countryCode),
      // GPS는 시스템 경계다 — 고정 좌표로 갈아끼운다.
      currentPositionResolverProvider.overrideWithValue(
        () async => (latitude: 37.4979, longitude: 127.0276),
      ),
      // 시계도 시스템 경계다 — 유효 시간 판정을 검증하려면 앞으로 돌릴 수 있어야 한다.
      if (now != null) clockProvider.overrideWithValue(now),
      ...extraOverrides,
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
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );
      await container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ).notifier,
          )
          .loadMore();

      final state = container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ),
          )
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
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );
      await container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ).notifier,
          )
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
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );
      await container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ).notifier,
          )
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
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );
      expect(first.hasMore, true);

      await container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ).notifier,
          )
          .loadMore();

      final state = container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ),
          )
          .requireValue;
      expect(state.hasMore, false);
    });

    test('ignores_load_more_when_no_pages_remain', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: null),
      });
      final container = _containerWith(repo);

      await container.read(
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );
      await container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ).notifier,
          )
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
        communityFeedNotifierProvider(
          CommunityScope.nearby,
          CommunitySortOption.latest,
          null,
        ).future,
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
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );
      await container.read(
        communityFeedNotifierProvider(
          CommunityScope.mine,
          CommunitySortOption.latest,
          null,
        ).future,
      );
      final state = await container.read(
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
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
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );
      final loadMoreDone = container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ).notifier,
          )
          .loadMore();

      container.invalidate(
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ),
      );
      await container.read(
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
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
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ),
          )
          .requireValue;
      // 새로고침이 만든 첫 페이지만 남는다 — 낡은 2페이지가 붙지 않는다.
      expect(state.items.map((e) => e.id), [1]);
    });

    test('starts_from_first_page_when_sort_changes', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: 'cursor-1'),
      });
      final container = _containerWith(repo);

      final first = await container.read(
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );
      final second = await container.read(
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.deadline,
          null,
        ).future,
      );

      // 커서에 정렬이 봉인돼 있어 재사용하면 400이다 — 둘 다 커서 없이 시작한다.
      expect(repo.requestedCursors, [null, null]);
      expect(repo.requestedSorts, [
        CommunitySortOption.latest,
        CommunitySortOption.deadline,
      ]);
      // family가 갈라졌을 뿐 각 인스턴스는 정상적으로 첫 페이지를 받는다.
      expect(first.items.map((e) => e.id), [1]);
      expect(second.items.map((e) => e.id), [1]);
    });

    test(
      'reuses_first_page_coordinates_when_loading_more_by_distance',
      () async {
        final repo = _FakeCommunityRepository({
          null: (items: [_post(1)], next: 'cursor-1'),
          'cursor-1': (items: [_post(2)], next: null),
        });
        final container = _containerWith(repo);

        final provider = communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.distance,
          null,
        );
        await container.read(provider.future);
        await container.read(provider.notifier).loadMore();

        // 페이지를 넘길 때마다 GPS를 다시 켜지 않는다.
        expect(repo.requestedCoordinates, [
          (lat: 37.4979, lng: 127.0276),
          (lat: 37.4979, lng: 127.0276),
        ]);
        // 좌표만 맞고 페이지가 실제로는 안 붙는 회귀를 잡는다.
        final state = container.read(provider).requireValue;
        expect(state.items.map((e) => e.id), [1, 2]);
      },
    );

    test(
      'falls_back_to_latest_on_both_pages_when_distance_has_no_coordinates',
      () async {
        // build()가 좌표 없이 최신순으로 물러서면 그 응답의 커서는 LATEST로
        // 봉인된다. loadMore가 family의 sort(distance)를 그대로 보내면 커서
        // 불일치(400)다 — build와 같은 폴백을 loadMore에서도 다시 밟아야 한다.
        final repo = _FakeCommunityRepository({
          null: (items: [_post(1)], next: 'cursor-1'),
          'cursor-1': (items: [_post(2)], next: null),
        });
        final container = ProviderContainer(
          overrides: [
            communityRepositoryProvider.overrideWithValue(repo),
            communityCountryCodeProvider.overrideWith((ref) async => 'KR'),
            // GPS 권한이 없는 상황을 재현한다.
            currentPositionResolverProvider.overrideWithValue(() async => null),
          ],
        );
        addTearDown(container.dispose);

        final provider = communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.distance,
          null,
        );
        await container.read(provider.future);
        await container.read(provider.notifier).loadMore();

        expect(repo.requestedSorts, [
          CommunitySortOption.latest,
          CommunitySortOption.latest,
        ]);
        expect(repo.requestedCoordinates, [
          (lat: null, lng: null),
          (lat: null, lng: null),
        ]);
        final state = container.read(provider).requireValue;
        expect(state.items.map((e) => e.id), [1, 2]);
      },
    );

    test('sends_the_same_keyword_on_both_pages_when_searching', () async {
      // 커서에는 국가·정렬·검색어가 봉인돼 있다 — 2페이지 요청이 1페이지와
      // 다른 검색어를 실으면 서버가 400을 준다. loadMore가 family의 keyword를
      // 그대로 다시 보내야 한다.
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: 'cursor-1'),
        'cursor-1': (items: [_post(2)], next: null),
      });
      final container = _containerWith(repo);

      final provider = communityFeedNotifierProvider(
        CommunityScope.all,
        CommunitySortOption.latest,
        '서울',
      );
      await container.read(provider.future);
      await container.read(provider.notifier).loadMore();

      expect(repo.requestedKeywords, ['서울', '서울']);
      // 검색어만 맞고 페이지가 실제로는 안 붙는 회귀를 잡는다.
      final state = container.read(provider).requireValue;
      expect(state.items.map((e) => e.id), [1, 2]);
    });

    test(
      'keeps_resolved_country_when_feed_family_is_invalidated_without_listeners',
      () async {
        // communityCountryCodeProvider(autoDispose)가 계속 살아 있는 유일한
        // 근거는 피드 인스턴스가 그것을 watch하며 스스로도 keepAlive되는 것이다.
        // 피드가 리스너 없이 무효화되면(글 작성·수정·삭제·상태변경이 인자 없는
        // invalidate를 부른다) 이 근거가 흔들리는지 실측한다.
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

        final provider = communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        );
        await container.read(provider.future);

        // 화면을 나가 아무도 watch하지 않는 상태에서 글 작성 등이 무효화를 부른다.
        container.invalidate(communityFeedNotifierProvider);
        // autoDispose 폐기 검사는 마이크로태스크 단위로 예약된다 — 통과시킨다.
        await Future<void>.delayed(Duration.zero);

        await container.read(provider.future);

        expect(resolveCount, 1);
      },
    );
  });

  group('CommunityFeedNotifier 목록 액션', () {
    test('replaces_only_the_target_post_when_status_toggled', () async {
      final repo = _MutatingRepository([_post(1), _post(2)]);
      final container = _containerWith(repo);
      await container.read(
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );

      await container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ).notifier,
          )
          .toggleStatus(_post(2));

      final items = container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ),
          )
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
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );

      await container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ).notifier,
          )
          .toggleStatus(endedPost);

      final items = container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ),
          )
          .requireValue
          .items;
      expect(items[1].status, CommunityPostStatus.ended);
      expect(repo.statusCalls, isEmpty);
    });

    test('removes_the_post_from_the_list_when_deleted', () async {
      final repo = _MutatingRepository([_post(1), _post(2), _post(3)]);
      final container = _containerWith(repo);
      await container.read(
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );

      await container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ).notifier,
          )
          .deletePost(2);

      expect(
        container
            .read(
              communityFeedNotifierProvider(
                CommunityScope.all,
                CommunitySortOption.latest,
                null,
              ),
            )
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
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );

      await expectLater(
        container
            .read(
              communityFeedNotifierProvider(
                CommunityScope.all,
                CommunitySortOption.latest,
                null,
              ).notifier,
            )
            .toggleStatus(_post(2)),
        throwsA(isA<AppException>()),
      );

      expect(
        container
            .read(
              communityFeedNotifierProvider(
                CommunityScope.all,
                CommunitySortOption.latest,
                null,
              ),
            )
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
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );

      container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ).notifier,
          )
          .replacePost(_post(2).copyWith(title: '제목을 고쳤어요'));

      final items = container
          .read(
            communityFeedNotifierProvider(
              CommunityScope.all,
              CommunitySortOption.latest,
              null,
            ),
          )
          .requireValue
          .items;
      expect(items.map((e) => e.title), ['모집글 1', '제목을 고쳤어요']);
    });

    test('replaces_only_the_touched_card_when_reaction_changes', () async {
      // 무효화가 아니라 그 한 칸만 갈아끼운다 — 커서로 쌓아 둔 나머지가
      // 그대로 남아야 한다.
      final repo = _MutatingRepository([_post(1), _post(2)]);
      final container = _containerWith(repo);
      final notifier = container.read(
        communityFeedNotifierProvider(CommunityScope.all, CommunitySortOption.latest, null).notifier,
      );
      await container.read(
        communityFeedNotifierProvider(CommunityScope.all, CommunitySortOption.latest, null).future,
      );

      final before = container
          .read(communityFeedNotifierProvider(CommunityScope.all, CommunitySortOption.latest, null))
          .value!;
      final target = before.items.first;

      notifier.replacePost(target.copyWith(isLiked: true, likeCount: target.likeCount + 1));

      final after = container
          .read(communityFeedNotifierProvider(CommunityScope.all, CommunitySortOption.latest, null))
          .value!;
      expect(after.items.first.isLiked, isTrue);
      expect(after.items.length, before.items.length);
      expect(after.items.skip(1).toList(), before.items.skip(1).toList());
    });

    test(
      'reflects_a_detail_like_toggle_onto_the_matching_feed_card',
      () async {
        // 위 테스트는 replacePost 단독 계약(그 칸만 갈아끼움)을 지킨다. 이
        // 테스트는 CommunityDetailNotifier.toggleLike()가 실제로
        // _syncFeedCard()를 거쳐 피드까지 닿는지 배선 자체를 끝까지 태운다.
        final repo = _ListAndDetailRepository([_post(1), _post(2)]);
        final container = _containerWith(
          repo,
          extraOverrides: [
            communityCommentRepositoryProvider.overrideWithValue(
              _EmptyCommentRepository(),
            ),
            communityReactionRepositoryProvider.overrideWithValue(
              _SucceedingReactionRepository(),
            ),
          ],
        );

        // _syncFeedCard가 읽는 family 키(스코프 all·정렬 latest·keyword null)와
        // 같은 인스턴스를 먼저 살려 둔다.
        await container.read(
          communityFeedNotifierProvider(
            CommunityScope.all,
            CommunitySortOption.latest,
            null,
          ).future,
        );
        await container.read(communityDetailNotifierProvider(2).future);

        await container
            .read(communityDetailNotifierProvider(2).notifier)
            .toggleLike();

        final items = container
            .read(
              communityFeedNotifierProvider(
                CommunityScope.all,
                CommunitySortOption.latest,
                null,
              ),
            )
            .requireValue
            .items;
        expect(items[1].isLiked, isTrue);
        expect(items[1].likeCount, _post(2).likeCount + 1);
        // 건드리지 않은 행은 그대로다.
        expect(items[0], _post(1));
      },
    );

    test(
      'does_not_query_the_feed_when_toggling_like_while_the_feed_is_not_alive',
      () async {
        // 상세는 피드를 거치지 않고도 도달한다(채팅방에서 곧장 push). 그
        // 경로에서 _syncFeedCard가 죽어 있는 피드 인스턴스를 가드 없이
        // .notifier로 읽으면 그 자리에서 빌드가 걸려 getPosts()가 실제로
        // 조회된다 — 화면에 보이지도 않는 조회가 조용히 나가는 회귀를 잡는다.
        final repo = _ListAndDetailRepository([_post(1), _post(2)]);
        final container = _containerWith(
          repo,
          extraOverrides: [
            communityCommentRepositoryProvider.overrideWithValue(
              _EmptyCommentRepository(),
            ),
            communityReactionRepositoryProvider.overrideWithValue(
              _SucceedingReactionRepository(),
            ),
          ],
        );

        // 피드는 한 번도 read하지 않는다 — 채팅방에서 상세로 곧장 온 상황.
        await container.read(communityDetailNotifierProvider(2).future);
        await container
            .read(communityDetailNotifierProvider(2).notifier)
            .toggleLike();
        // 가드 없이 .notifier를 읽었다면 build()가 마이크로태스크로 이어지며
        // getPosts()를 나중에 부른다 — 그 잔여 마이크로태스크까지 흘려보낸
        // 뒤에 세야 가드 부재를 놓치지 않는다.
        await Future<void>.delayed(Duration.zero);

        expect(repo.getPostsCallCount, 0);
      },
    );
  });

  group('CommunityFeedNotifier.refreshIfStale', () {
    /// 시계를 원하는 시각으로 고정한다. `advance`를 바꿔 시간을 앞으로 돌린다.
    ({DateTime Function() clock, void Function(Duration) advance}) fakeClock() {
      var now = DateTime(2026, 8, 23, 12);
      return (clock: () => now, advance: (d) => now = now.add(d));
    }

    test(
      'keeps_the_cached_list_when_refetched_within_the_stale_window',
      () async {
        final repo = _FakeCommunityRepository({
          null: (items: [_post(1)], next: null),
        });
        final fake = fakeClock();
        final container = _containerWith(repo, now: fake.clock);
        final provider = communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        );
        await container.read(provider.future);

        fake.advance(const Duration(minutes: 2, seconds: 59));
        await container.read(provider.notifier).refreshIfStale();

        // 3분이 안 지났으면 캐시를 그대로 쓴다 — 서버를 다시 부르지 않는다.
        expect(repo.requestedCursors, hasLength(1));
        expect(container.read(provider).value!.items.single.id, 1);
      },
    );

    test(
      'refetches_from_the_first_page_when_the_stale_window_has_passed',
      () async {
        final repo = _FakeCommunityRepository({
          null: (items: [_post(1)], next: null),
        });
        final fake = fakeClock();
        final container = _containerWith(repo, now: fake.clock);
        final provider = communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        );
        await container.read(provider.future);

        fake.advance(const Duration(minutes: 3, seconds: 1));
        await container.read(provider.notifier).refreshIfStale();

        // 커서 없이 첫 페이지부터 다시 받는다.
        expect(repo.requestedCursors, [null, null]);
        expect(container.read(provider).value!.items.single.id, 1);
      },
    );

    test('refetches_when_exactly_the_stale_window_has_passed', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: null),
      });
      final fake = fakeClock();
      final container = _containerWith(repo, now: fake.clock);
      final provider = communityFeedNotifierProvider(
        CommunityScope.all,
        CommunitySortOption.latest,
        null,
      );
      await container.read(provider.future);

      fake.advance(const Duration(minutes: 3));
      await container.read(provider.notifier).refreshIfStale();

      // 정확히 3분은 "낡은 것"으로 분류돼 재시도한다.
      expect(repo.requestedCursors, [null, null]);
      expect(container.read(provider).value!.items.single.id, 1);
    });

    test('does_not_refetch_when_another_page_is_still_loading', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: 'cursor-1'),
        'cursor-1': (items: [_post(2)], next: null),
      });
      final fake = fakeClock();
      final container = _containerWith(repo, now: fake.clock);
      final provider = communityFeedNotifierProvider(
        CommunityScope.all,
        CommunitySortOption.latest,
        null,
      );
      await container.read(provider.future);

      fake.advance(const Duration(minutes: 5));
      // 이어붙이기를 기다리지 않고 그 사이에 낡음 판정을 걸어 본다.
      final pending = container.read(provider.notifier).loadMore();
      await container.read(provider.notifier).refreshIfStale();
      await pending;

      // 진행 중인 요청을 버리지 않는다 — 두 페이지가 그대로 이어붙는다.
      expect(container.read(provider).value!.items.map((e) => e.id), [1, 2]);
      expect(repo.requestedCursors, [null, 'cursor-1']);
    });

    test('records_the_fetch_time_when_the_first_page_arrives', () async {
      final repo = _FakeCommunityRepository({
        null: (items: [_post(1)], next: null),
      });
      final fake = fakeClock();
      final container = _containerWith(repo, now: fake.clock);

      final state = await container.read(
        communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        ).future,
      );

      expect(state.fetchedAt, DateTime(2026, 8, 23, 12));
    });

    test('keeps_the_cached_list_when_background_refresh_fails', () async {
      final repo = _FailingAfterFirstRepository([_post(1)]);
      final fake = fakeClock();
      final container = _containerWith(repo, now: fake.clock);
      final provider = communityFeedNotifierProvider(
        CommunityScope.all,
        CommunitySortOption.latest,
        null,
      );
      await container.read(provider.future);

      fake.advance(const Duration(minutes: 4));
      await expectLater(
        container.read(provider.notifier).refreshIfStale(),
        throwsA(isA<ServerException>()),
      );

      // 실패했다고 보고 있던 목록을 에러 상태로 갈아치우지 않는다(I-2).
      final state = container.read(provider);
      expect(state.hasError, isFalse);
      expect(state.value!.items.single.id, 1);
    });

    test(
      'does_not_refetch_when_more_than_one_page_is_already_loaded',
      () async {
        final repo = _FakeCommunityRepository({
          null: (items: [for (var i = 1; i <= 20; i++) _post(i)], next: 'c1'),
          'c1': (items: [_post(21)], next: null),
        });
        final fake = fakeClock();
        final container = _containerWith(repo, now: fake.clock);
        final provider = communityFeedNotifierProvider(
          CommunityScope.all,
          CommunitySortOption.latest,
          null,
        );
        await container.read(provider.future);
        await container.read(provider.notifier).loadMore();
        expect(container.read(provider).value!.items, hasLength(21));

        fake.advance(const Duration(minutes: 4));
        await container.read(provider.notifier).refreshIfStale();

        // 0페이지부터 다시 받으면 스크롤 위치를 잃는다 — 두 페이지 이상 불러온
        // 목록은 배경 갱신에서 제외한다(I-3).
        expect(repo.requestedCursors, [null, 'c1']);
        expect(container.read(provider).value!.items, hasLength(21));
      },
    );
  });
}
