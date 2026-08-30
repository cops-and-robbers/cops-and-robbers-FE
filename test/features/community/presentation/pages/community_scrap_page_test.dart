import 'dart:async';

import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_scrap_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_scrap_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../community_fakes.dart';

CommunityPostEntity _post({
  required int id,
  required String title,
  bool isScrapped = true,
  int likeCount = 0,
  bool isLiked = false,
}) => CommunityPostEntity(
  id: id,
  writerId: 7,
  title: title,
  content: '본문',
  meetingAt: DateTime(2026, 9, 10, 18, 0),
  latitude: 37.4979,
  longitude: 127.0276,
  maxParticipants: 10,
  status: CommunityPostStatus.recruiting,
  createdAt: DateTime(2026, 9, 1),
  likeCount: likeCount,
  isLiked: isLiked,
  scrapCount: 0,
  isScrapped: isScrapped,
);

/// 스크랩 목록 화면 전용 가짜 Repository.
///
/// [getPost]는 상세에서 돌아왔을 때의 단건 재조회를 흉내낸다 — [refetched]에
/// 지정된 id만 다른 값을 돌려주고, 나머지는 원래 목록의 값을 그대로 돌려줘
/// "해제되지 않았다"로 판정되게 한다. [failingGetPost]에 담긴 id는 대신 예외를
/// 던진다 — 재조회 자체가 실패했을 때(일시 장애 등) 행을 그대로 남기는지 검증한다.
///
/// [secondPage]는 `loadMore`가 요청하는 두 번째 페이지다 — null이면 첫 페이지가
/// 끝이다(`hasNext: false`, 커서 없는 대부분의 테스트가 이 기본값을 쓴다).
/// [failSecondPage]면 두 번째 페이지 요청이 예외를 던진다.
class _FakeCommunityRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _FakeCommunityRepository({
    required this.posts,
    this.refetched = const {},
    this.failingGetPost = const {},
    this.secondPage,
    this.failSecondPage = false,
    this.refreshedPosts,
    this.failFirstLoad = false,
    this.failRefresh = false,
    this.secondPageGate,
  });

  final List<CommunityPostEntity> posts;
  final Map<int, CommunityPostEntity> refetched;
  final Set<int> failingGetPost;
  final List<CommunityPostEntity>? secondPage;
  final bool failSecondPage;

  /// 당겨서 새로고침이 받아올 첫 페이지. null이면 [posts]를 그대로 다시 준다.
  final List<CommunityPostEntity>? refreshedPosts;

  /// 첫 로드만 실패시킨다 — 에러 화면에서 당겨 재시도하면 성공하는 흐름을 만든다.
  final bool failFirstLoad;

  /// 첫 로드는 성공시키고 새로고침만 실패시킨다.
  final bool failRefresh;

  /// 주어지면 두 번째 페이지 응답이 이 Completer가 끝날 때까지 미뤄진다 —
  /// `loadMore`가 날아가 있는 동안 새로고침이 끼어드는 순서를 만든다.
  final Completer<void>? secondPageGate;

  /// 두 번째 페이지 요청에 실려야 하는 커서 — 첫 응답의 `nextCursor`.
  static const secondPageCursor = 100;

  /// `getScraps`가 실제로 받은 커서 목록 — loadMore가 이전 응답의 nextCursor를
  /// 그대로 실어 보냈는지 검증한다.
  final List<int?> requestedCursors = [];

  @override
  Future<CommunityScrapPageEntity> getScraps({
    int? cursor,
    required int size,
  }) async {
    requestedCursors.add(cursor);
    if (cursor == null) {
      final isFirstLoad = requestedCursors.length == 1;
      if (isFirstLoad ? failFirstLoad : failRefresh) {
        throw const ServerException(message: '서버 오류');
      }
      return CommunityScrapPageEntity(
        items: isFirstLoad ? posts : (refreshedPosts ?? posts),
        nextCursor: secondPage == null ? null : secondPageCursor,
        hasNext: secondPage != null,
      );
    }
    if (failSecondPage) {
      throw const ServerException(message: '서버 오류');
    }
    await secondPageGate?.future;
    return CommunityScrapPageEntity(
      items: secondPage!,
      nextCursor: null,
      hasNext: false,
    );
  }

  @override
  Future<CommunityPostEntity> getPost(int postId) async {
    if (failingGetPost.contains(postId)) {
      throw const ServerException(message: '서버 오류');
    }
    return refetched[postId] ?? posts.firstWhere((p) => p.id == postId);
  }
}

/// `loadMore`와 `syncAfterDetail`이 동시에 도달하는 경쟁을 재현하는 가짜
/// Repository. 두 요청을 각각 Completer로 붙잡아 두어 끝나는 순서를 테스트가
/// 직접 통제한다 — [getPostCompleter]는 상세 재조회를, [secondPageGate]는
/// 두 번째 페이지를 붙잡는다. 후자를 주면 `loadMore`가 나중에 끝나는 역순이 된다.
class _RacingCommunityRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _RacingCommunityRepository({
    required this.firstPage,
    required this.secondPage,
    required this.getPostCompleter,
    this.secondPageGate,
  });

  final List<CommunityPostEntity> firstPage;
  final List<CommunityPostEntity> secondPage;
  final Completer<CommunityPostEntity> getPostCompleter;
  final Completer<void>? secondPageGate;

  @override
  Future<CommunityScrapPageEntity> getScraps({
    int? cursor,
    required int size,
  }) async {
    if (cursor == null) {
      return CommunityScrapPageEntity(
        items: firstPage,
        nextCursor: 100,
        hasNext: true,
      );
    }
    await secondPageGate?.future;
    return CommunityScrapPageEntity(
      items: secondPage,
      nextCursor: null,
      hasNext: false,
    );
  }

  @override
  Future<CommunityPostEntity> getPost(int postId) => getPostCompleter.future;
}

/// 스크랩 목록 화면을 세팅해 첫 로드까지 끝내고, 이 화면의 notifier를 돌려준다.
///
/// 반환값은 `syncAfterDetail`·`loadMore`처럼 화면 밖(상세 복귀, 스크롤)에서
/// 불리는 동작을 실제 라우터·스크롤 없이도 직접 검증하기 위해서다.
/// [repository]를 넘기면 커서 응답을 직접 제어해야 하는 테스트(loadMore)가
/// 반환 전에 만들어 둔 인스턴스를 그대로 쓸 수 있다.
Future<CommunityScrapNotifier> _pumpScrapPage(
  WidgetTester tester, {
  List<CommunityPostEntity> posts = const [],
  Map<int, CommunityPostEntity> refetched = const {},
  Set<int> failingGetPost = const {},
  CommunityRepository? repository,
}) async {
  final container = ProviderContainer(
    overrides: [
      communityRepositoryProvider.overrideWithValue(
        repository ??
            _FakeCommunityRepository(
              posts: posts,
              refetched: refetched,
              failingGetPost: failingGetPost,
            ),
      ),
      // 카드의 더보기 메뉴가 로그인 사용자 id를 watch 한다. 덮지 않으면 실제
      // AuthNotifier가 Firebase까지 끌고 들어와, 목록과 무관한 이유로 깨진다
      // (community_page_test.dart의 `_wrap`과 같은 이유).
      currentUserIdProvider.overrideWithValue(null),
    ],
  );
  addTearDown(container.dispose);
  final notifier = container.read(communityScrapNotifierProvider.notifier);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => MaterialApp(
          locale: const Locale('ko'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CommunityScrapPage(),
        ),
      ),
    ),
  );
  return notifier;
}

/// 소유자 메뉴(수정·마감·삭제)가 실제로 상세로 이동시키는지 검증하기 위한 라우터.
///
/// 실제 앱 라우터와 같이 스크랩 목록은 마이페이지 하위, 상세는 커뮤니티 하위다.
/// 상세는 댓글·좋아요 등 무관한 의존성을 끌고 오는 실물 대신, 어떤 postId로
/// 도착했는지만 보여주는 얕은 페이지로 대신한다.
Future<void> _pumpScrapPageWithRouter(
  WidgetTester tester, {
  required List<CommunityPostEntity> posts,
}) async {
  final router = GoRouter(
    initialLocation: RoutePaths.myScraps,
    routes: [
      GoRoute(
        path: RoutePaths.mypage,
        builder: (_, _) => const SizedBox.shrink(),
        routes: [
          GoRoute(
            path: 'scraps',
            name: RoutePaths.myScrapsName,
            builder: (_, _) => const CommunityScrapPage(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.community,
        builder: (_, _) => const SizedBox.shrink(),
        routes: [
          GoRoute(
            path: ':postId',
            name: RoutePaths.communityDetailName,
            builder: (context, state) =>
                Text('상세 ${state.pathParameters['postId']}'),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  final container = ProviderContainer(
    overrides: [
      communityRepositoryProvider.overrideWithValue(
        _FakeCommunityRepository(posts: posts),
      ),
      // 소유자 메뉴(수정·마감·삭제)를 보이게 하려면 글쓴이(writerId: 7)와 같은
      // id로 로그인해 있어야 한다.
      currentUserIdProvider.overrideWithValue(7),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => MaterialApp.router(
          routerConfig: router,
          locale: const Locale('ko'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 카드의 더보기(⋮)를 열고 [label] 항목을 누른다.
Future<void> _tapOwnerMenuItem(WidgetTester tester, String label) async {
  await tester.tap(find.byType(PopupMenuButton<void>).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  group('CommunityScrapPage', () {
    testWidgets('shows_scrapped_posts_when_the_page_opens', (tester) async {
      await _pumpScrapPage(tester, posts: [_post(id: 1, title: '첫 글')]);
      await tester.pumpAndSettle();

      expect(find.text('첫 글'), findsOneWidget);
    });

    testWidgets('shows_empty_notice_when_nothing_is_scrapped', (tester) async {
      await _pumpScrapPage(tester, posts: []);
      await tester.pumpAndSettle();

      expect(find.text('스크랩한 글이 없어요'), findsOneWidget);
    });

    testWidgets('drops_the_row_when_the_post_came_back_unscrapped', (
      tester,
    ) async {
      // 해제는 상세에서만 일어난다(카드는 표시 전용). 돌아올 때 그 글만 다시
      // 조회해서 판정한다 — 목록 전체를 다시 받으면 커서와 스크롤이 날아간다.
      final notifier = await _pumpScrapPage(
        tester,
        posts: [
          _post(id: 1, title: '첫 글'),
          _post(id: 2, title: '둘째 글'),
        ],
        refetched: {1: _post(id: 1, title: '첫 글', isScrapped: false)},
      );
      await tester.pumpAndSettle();

      await notifier.syncAfterDetail(1);
      await tester.pumpAndSettle();

      expect(find.text('첫 글'), findsNothing);
      expect(find.text('둘째 글'), findsOneWidget);
    });

    testWidgets(
      'updates_the_row_with_fresh_reaction_when_the_post_is_still_scrapped',
      (tester) async {
        // 상세에서 하트를 누르고 돌아온 상황 — 여전히 스크랩 중이니 행을
        // 지우지 않고, 방금 받아온 fresh 값(좋아요 수 포함)으로 갈아끼운다.
        final notifier = await _pumpScrapPage(
          tester,
          posts: [_post(id: 1, title: '첫 글', likeCount: 0, isLiked: false)],
          refetched: {
            1: _post(id: 1, title: '첫 글', likeCount: 5, isLiked: true),
          },
        );
        await tester.pumpAndSettle();

        await notifier.syncAfterDetail(1);
        await tester.pumpAndSettle();

        expect(find.text('첫 글'), findsOneWidget);
        // 갱신 분기를 걷어내면(스크랩 중일 때 그냥 return) 여기서 여전히
        // '0'이 보인다.
        expect(find.text('5'), findsOneWidget);
      },
    );

    testWidgets('keeps_both_rows_when_the_refetch_after_returning_fails', (
      tester,
    ) async {
      // 일시 장애 등으로 재조회 자체가 실패하면 판정할 근거가 없다 — 행을
      // 그대로 남긴다(다음에 목록을 열 때 서버가 알아서 반영한다).
      final notifier = await _pumpScrapPage(
        tester,
        posts: [
          _post(id: 1, title: '첫 글'),
          _post(id: 2, title: '둘째 글'),
        ],
        failingGetPost: {1},
      );
      await tester.pumpAndSettle();

      await notifier.syncAfterDetail(1);
      await tester.pumpAndSettle();

      expect(find.text('첫 글'), findsOneWidget);
      expect(find.text('둘째 글'), findsOneWidget);
    });

    testWidgets(
      'appends_the_second_page_using_the_first_pages_cursor_when_load_more_succeeds',
      (tester) async {
        final repo = _FakeCommunityRepository(
          posts: [
            _post(id: 1, title: '첫 글'),
            _post(id: 2, title: '둘째 글'),
          ],
          secondPage: [_post(id: 3, title: '셋째 글')],
        );
        final notifier = await _pumpScrapPage(tester, repository: repo);
        await tester.pumpAndSettle();

        await notifier.loadMore();
        await tester.pumpAndSettle();

        // 이어붙이기다 — 교체였다면 첫 페이지의 두 글이 사라졌을 것이다.
        expect(find.text('첫 글'), findsOneWidget);
        expect(find.text('둘째 글'), findsOneWidget);
        expect(find.text('셋째 글'), findsOneWidget);
        // 두 번째 요청은 첫 응답의 nextCursor를 그대로 실어 보낸다.
        expect(repo.requestedCursors, [
          null,
          _FakeCommunityRepository.secondPageCursor,
        ]);
      },
    );

    testWidgets('keeps_the_visible_rows_when_the_second_page_fails', (
      tester,
    ) async {
      final repo = _FakeCommunityRepository(
        posts: [_post(id: 1, title: '첫 글')],
        secondPage: [_post(id: 2, title: '둘째 글')],
        failSecondPage: true,
      );
      final notifier = await _pumpScrapPage(tester, repository: repo);
      await tester.pumpAndSettle();

      await expectLater(notifier.loadMore(), throwsA(isA<ServerException>()));
      await tester.pumpAndSettle();

      // loadMore의 문서화된 계약: 실패해도 보이던 목록은 지우지 않는다.
      expect(find.text('첫 글'), findsOneWidget);
    });

    testWidgets(
      'keeps_the_loaded_second_page_when_load_more_and_sync_after_detail_race',
      (tester) async {
        // 상세 왕복(느림)이 스크롤에 의한 loadMore(빠름)보다 먼저 시작해 나중에
        // 끝나는 순서를 재현한다 — _openDetail이 pop 시점에 syncAfterDetail을
        // 쏘는 동안 목록은 여전히 화면에 있고 스크롤 가능하다.
        final getPostCompleter = Completer<CommunityPostEntity>();
        final repo = _RacingCommunityRepository(
          firstPage: [
            _post(id: 1, title: '첫 글'),
            _post(id: 2, title: '둘째 글'),
          ],
          secondPage: [_post(id: 3, title: '셋째 글')],
          getPostCompleter: getPostCompleter,
        );
        final notifier = await _pumpScrapPage(tester, repository: repo);
        await tester.pumpAndSettle();

        final syncFuture = notifier.syncAfterDetail(1);
        final loadMoreFuture = notifier.loadMore();
        // loadMore가 먼저 끝난다 — 서버 조회가 즉시 응답하기 때문이다.
        await loadMoreFuture;
        // 그 다음에야 상세 재조회(느린 왕복)가 끝난다. 이 시점에 첫 글은
        // 스크랩이 풀려 있다.
        getPostCompleter.complete(
          _post(id: 1, title: '첫 글', isScrapped: false),
        );
        await syncFuture;
        await tester.pumpAndSettle();

        // loadMore가 붙인 셋째 글이 살아 있어야 한다 — syncAfterDetail이
        // loadMore 이전 스냅샷(current)으로 덮어쓰면 사라진다(Important 2).
        expect(find.text('셋째 글'), findsOneWidget);
        // 해제된 첫 글은 그 위에서도 걷어낸다.
        expect(find.text('첫 글'), findsNothing);
        expect(find.text('둘째 글'), findsOneWidget);
      },
    );

    testWidgets('keeps_the_unscrapped_row_out_when_load_more_finishes_last', (
      tester,
    ) async {
      // 위 테스트의 역순이다 — 두 번째 페이지(느림)가 상세 왕복(빠름)보다
      // 나중에 끝난다. 어느 쪽이 먼저 끝나든 결과가 같아야 하므로 양방향을
      // 모두 고정한다. 이 방향은 loadMore가 await 이후 state를 다시 읽는지가
      // 관건이다(시작 시점 스냅샷으로 덮으면 걷어낸 글이 되살아난다).
      final getPostCompleter = Completer<CommunityPostEntity>();
      final secondPageGate = Completer<void>();
      final repo = _RacingCommunityRepository(
        firstPage: [
          _post(id: 1, title: '첫 글'),
          _post(id: 2, title: '둘째 글'),
        ],
        secondPage: [_post(id: 3, title: '셋째 글')],
        getPostCompleter: getPostCompleter,
        secondPageGate: secondPageGate,
      );
      final notifier = await _pumpScrapPage(tester, repository: repo);
      await tester.pumpAndSettle();

      final loadMoreFuture = notifier.loadMore();
      final syncFuture = notifier.syncAfterDetail(1);
      // 상세 재조회가 먼저 끝난다 — 첫 글은 그 사이 스크랩이 풀렸다.
      getPostCompleter.complete(_post(id: 1, title: '첫 글', isScrapped: false));
      await syncFuture;
      // 그 뒤에야 두 번째 페이지가 도착한다.
      secondPageGate.complete();
      await loadMoreFuture;
      await tester.pumpAndSettle();

      // 걷어낸 첫 글이 되살아나면 안 된다.
      expect(find.text('첫 글'), findsNothing);
      expect(find.text('둘째 글'), findsOneWidget);
      expect(find.text('셋째 글'), findsOneWidget);
    });
  });

  group('CommunityScrapPage 당겨서 새로고침', () {
    testWidgets('refetches_from_the_first_page_when_pulled', (tester) async {
      final repo = _FakeCommunityRepository(
        posts: [_post(id: 1, title: '첫 글')],
        refreshedPosts: [
          _post(id: 2, title: '새로 스크랩한 글'),
          _post(id: 1, title: '첫 글'),
        ],
      );
      await _pumpScrapPage(tester, repository: repo);
      await tester.pumpAndSettle();
      expect(find.text('새로 스크랩한 글'), findsNothing);

      await tester.fling(find.text('첫 글'), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.text('새로 스크랩한 글'), findsOneWidget);
      // 이어붙이기가 아니라 통째로 갈아끼운다 — 이어붙였다면 첫 글이 둘이 된다.
      expect(find.text('첫 글'), findsOneWidget);
      // 첫 장부터 다시 받는다 — 커서를 싣지 않는다.
      expect(repo.requestedCursors, [null, null]);
    });

    testWidgets('keeps_the_visible_list_when_the_refresh_fails', (
      tester,
    ) async {
      // 새로고침 실패는 스낵바로만 알린다 — 사용자가 보고 있던 목록을 지우면
      // 지하철에서 당긴 사람이 목록을 통째로 잃는다.
      final repo = _FakeCommunityRepository(
        posts: [_post(id: 1, title: '첫 글')],
        failRefresh: true,
      );
      await _pumpScrapPage(tester, repository: repo);
      await tester.pumpAndSettle();

      await tester.fling(find.text('첫 글'), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.text('첫 글'), findsOneWidget);

      // 실패를 알리는 스낵바가 스스로 닫히는 타이머(3초)를 흘려보낸다 —
      // 남겨 두면 테스트가 pending timer로 깨진다.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets(
      'drops_the_stale_page_when_load_more_finishes_after_a_refresh',
      (tester) async {
        // 바닥에서 당긴 다음 페이지가 날아가 있는 동안 위로 올라가 새로고침을
        // 하면, 뒤늦게 도착한 그 페이지는 이미 갈아엎힌 목록에 대한 답이다.
        // 이어붙이면 방금 받은 첫 장 위에 옛 페이지가 겹치고 커서도 되돌아간다.
        final gate = Completer<void>();
        final repo = _FakeCommunityRepository(
          posts: [_post(id: 1, title: '첫 글')],
          secondPage: [_post(id: 2, title: '둘째 글')],
          refreshedPosts: [_post(id: 3, title: '새로 스크랩한 글')],
          secondPageGate: gate,
        );
        final notifier = await _pumpScrapPage(tester, repository: repo);
        await tester.pumpAndSettle();

        final loadMoreFuture = notifier.loadMore();
        await notifier.refresh();
        gate.complete();
        await loadMoreFuture;
        await tester.pumpAndSettle();

        expect(find.text('새로 스크랩한 글'), findsOneWidget);
        expect(find.text('둘째 글'), findsNothing);
        expect(find.text('첫 글'), findsNothing);
      },
    );

    testWidgets('recovers_the_list_when_the_failed_first_load_is_pulled', (
      tester,
    ) async {
      // 첫 로드가 실패하면 목록이 아예 없어, 당길 곳이 없으면 화면을 나갔다
      // 들어오는 수밖에 없다. 에러 화면 자체가 재시도 손잡이여야 한다.
      final repo = _FakeCommunityRepository(
        posts: [_post(id: 1, title: '첫 글')],
        failFirstLoad: true,
      );
      await _pumpScrapPage(tester, repository: repo);
      await tester.pumpAndSettle();
      expect(find.text('첫 글'), findsNothing);

      await tester.fling(find.text('서버 오류'), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.text('첫 글'), findsOneWidget);
    });
  });

  group('CommunityScrapPage 소유자 메뉴 → 상세 이동', () {
    testWidgets('navigates_to_detail_when_edit_is_tapped', (tester) async {
      await _pumpScrapPageWithRouter(
        tester,
        posts: [_post(id: 1, title: '내 글')],
      );

      await _tapOwnerMenuItem(tester, '수정하기');

      expect(find.text('상세 1'), findsOneWidget);
    });

    testWidgets('navigates_to_detail_when_toggle_status_is_tapped', (
      tester,
    ) async {
      await _pumpScrapPageWithRouter(
        tester,
        posts: [_post(id: 1, title: '내 글')],
      );

      await _tapOwnerMenuItem(tester, '마감하기');

      expect(find.text('상세 1'), findsOneWidget);
    });

    testWidgets('navigates_to_detail_when_delete_is_tapped', (tester) async {
      await _pumpScrapPageWithRouter(
        tester,
        posts: [_post(id: 1, title: '내 글')],
      );

      await _tapOwnerMenuItem(tester, '삭제하기');

      expect(find.text('상세 1'), findsOneWidget);
    });
  });
}
