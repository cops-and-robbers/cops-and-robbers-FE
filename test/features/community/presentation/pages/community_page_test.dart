import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/widgets/buttons/app_button.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_create_page.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_detail_page.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_post_card.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_post_menu.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:cops_and_robbers/core/utils/custom_page_transitions.dart';
import 'package:go_router/go_router.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class _FakeCommunityRepository
    with CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _FakeCommunityRepository(this.items);

  final List<CommunityPostEntity> items;
  int callCount = 0;

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
  }) async {
    callCount++;
    return CommunityPostPageEntity(
      items: items,
      nextCursor: null,
      hasNext: false,
    );
  }
}

/// 첫 로드에서 항상 지정된 예외를 던지는 가짜 Repository.
/// AuthException 무반응 분기와 일반 AppException 안내 분기를 각각 검증하는 데 쓴다.
class _ThrowingCommunityRepository
    with CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _ThrowingCommunityRepository(this.exception);

  final AppException exception;

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
  }) async {
    throw exception;
  }
}

/// 최초 호출은 실패하고 이후 호출은 성공하는 가짜 Repository.
/// pull-to-refresh가 실제 재조회로 이어져 에러 상태에서 복구되는지 검증하는 데 쓴다.
class _RecoveringCommunityRepository
    with CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _RecoveringCommunityRepository(this.items);

  final List<CommunityPostEntity> items;
  int callCount = 0;

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
  }) async {
    callCount++;
    if (callCount == 1) {
      throw const ServerException(message: '서버 오류');
    }
    return CommunityPostPageEntity(
      items: items,
      nextCursor: null,
      hasNext: false,
    );
  }
}

/// 목록 카드에서 바로 하는 수정·마감·삭제에 응답하는 가짜 Repository.
class _CardActionRepository
    with CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _CardActionRepository(this.items);

  final List<CommunityPostEntity> items;

  final List<int> deletedIds = [];

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
  }) async =>
      CommunityPostPageEntity(items: items, nextCursor: null, hasNext: false);

  @override
  Future<CommunityPostEntity> getPost(int postId) async =>
      items.firstWhere((p) => p.id == postId);

  @override
  Future<CommunityPostEntity> updateStatus({
    required int postId,
    required CommunityPostStatus status,
  }) async => items.firstWhere((p) => p.id == postId).copyWith(status: status);

  @override
  Future<void> deletePost(int postId) async => deletedIds.add(postId);
}

/// 목록 → 상세 → 수정 스택을 실제로 쌓아 보려면 진짜 GoRouter가 필요하다.
/// 앱 라우터 전체는 인증 리다이렉트를 끌고 들어오므로, 검증 대상인 세 경로만
/// 같은 전환 헬퍼로 똑같이 세워 둔다.
///
/// 진짜 `CommunityDetailPage`를 끼운다 — 이 흐름에서 상세가 수정 화면에 덮이며
/// 지도 플랫폼 뷰가 터지던 실기기 크래시가 있었고(`hasSize` assert), 그 회귀를
/// 여기서 함께 잡는다 (`community_map_preview_test` 참고).
GoRouter _communityRouter() => GoRouter(
  initialLocation: RoutePaths.community,
  routes: [
    GoRoute(
      path: RoutePaths.community,
      name: RoutePaths.communityName,
      builder: (_, _) => const CommunityPage(),
      routes: [
        GoRoute(
          path: ':postId',
          name: RoutePaths.communityDetailName,
          pageBuilder: (context, state) {
            final page = CommunityDetailPage(
              postId: int.parse(state.pathParameters['postId']!),
            );
            return state.extra == CommunityDetailEntry.silent
                ? buildInstantTransition(key: state.pageKey, child: page)
                : buildSmoothFade(key: state.pageKey, child: page);
          },
          routes: [
            GoRoute(
              path: 'edit',
              name: RoutePaths.communityEditName,
              pageBuilder: (context, state) => buildSlideUp(
                key: state.pageKey,
                child: CommunityCreatePage(
                  post: state.extra as CommunityPostEntity,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// 상세가 함께 깔리면 좋아요·댓글 목이 200ms 지연 타이머를 건다. 프레임을
/// 만들지 않는 타이머라 `pumpAndSettle`이 그냥 지나쳐, 남은 채로 테스트가 끝나면
/// "A Timer is still pending"으로 깨진다 — 시간을 명시적으로 흘려보낸다.
Future<void> _settleDetailMocks(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}

/// 커서 두 장을 돌려주는 가짜 Repository — 무한 스크롤 검증용.
class _PagingCommunityRepository
    with CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _PagingCommunityRepository(this.firstPage, this.secondPage);

  final List<CommunityPostEntity> firstPage;
  final List<CommunityPostEntity> secondPage;

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
  }) async => cursor == null
      ? CommunityPostPageEntity(
          items: firstPage,
          nextCursor: 'c1',
          hasNext: true,
        )
      : CommunityPostPageEntity(
          items: secondPage,
          nextCursor: null,
          hasNext: false,
        );
}

Widget _wrapRouted(CommunityRepository repo, {int? currentUserId}) {
  final router = _communityRouter();
  addTearDown(router.dispose);
  return ProviderScope(
    overrides: [
      communityRepositoryProvider.overrideWithValue(repo),
      currentUserIdProvider.overrideWithValue(currentUserId),
      communityCountryCodeProvider.overrideWith((ref) async => 'KR'),
    ],
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
  );
}

Widget _wrap(CommunityRepository repo, {int? currentUserId}) => ProviderScope(
  overrides: [
    communityRepositoryProvider.overrideWithValue(repo),
    // 카드의 더보기 메뉴가 로그인 사용자 id를 watch 한다. 덮지 않으면 실제
    // AuthNotifier가 Firebase까지 끌고 들어와, 목록과 무관한 이유로 깨진다.
    currentUserIdProvider.overrideWithValue(currentUserId),
    // 목록 조회 전에 국가를 정하느라 GPS·권한·벤더를 친다. 덮지 않으면 플랫폼
    // 채널이 응답하지 않아 pumpAndSettle이 영원히 안 끝난다.
    communityCountryCodeProvider.overrideWith((ref) async => 'KR'),
  ],
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
      home: const CommunityPage(),
    ),
  ),
);

void main() {
  group('CommunityPage', () {
    testWidgets('lists_posts_when_all_scope_returns_results', (tester) async {
      final repo = _FakeCommunityRepository([_post(1), _post(2)]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityPostCard), findsNWidgets(2));
    });

    testWidgets('shows_empty_message_when_all_scope_has_no_posts', (
      tester,
    ) async {
      final repo = _FakeCommunityRepository([]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.text('등록된 모집글이 없어요'), findsOneWidget);
      // 글이 하나도 없을 때가 바로 첫 글을 써야 하는 순간 — 작성 버튼이 있어야 한다.
      expect(find.text('모집글 작성'), findsOneWidget);
    });

    testWidgets('shows_coming_soon_without_calling_api_when_nearby_selected', (
      tester,
    ) async {
      final repo = _FakeCommunityRepository([_post(1)]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      final callsAfterFirstLoad = repo.callCount;

      await tester.tap(find.text('우리 동네'));
      await tester.pumpAndSettle();

      expect(find.text('준비 중이에요'), findsOneWidget);
      expect(find.byType(CommunityPostCard), findsNothing);
      // 백엔드 scope 미지원 — 추가 호출이 나가면 안 된다.
      expect(repo.callCount, callsAfterFirstLoad);
      // 작성은 스코프와 무관한 전역 진입점 — 준비 중 탭에서도 떠 있어야 한다.
      expect(find.text('모집글 작성'), findsOneWidget);
    });

    testWidgets('returns_to_list_when_all_scope_selected_again', (
      tester,
    ) async {
      final repo = _FakeCommunityRepository([_post(1)]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('내 모임'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('전체'));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityPostCard), findsOneWidget);
    });

    testWidgets('reuses_create_button_instance_when_scope_changes', (
      tester,
    ) async {
      final repo = _FakeCommunityRepository([_post(1)]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      final before = tester.widget<AppButton>(find.byType(AppButton));

      await tester.tap(find.text('우리 동네'));
      await tester.pumpAndSettle();

      final after = tester.widget<AppButton>(find.byType(AppButton));

      // 작성 버튼은 스코프·목록 상태와 무관하다. build()가 provider를 watch하거나
      // 각 분기가 버튼을 새로 만들면 탭을 옮길 때마다 이 서브트리(SvgPicture 포함)가
      // 통째로 재생성된다. 같은 인스턴스가 유지되는지로 그 회귀를 잡는다.
      expect(identical(before, after), isTrue);
    });

    testWidgets('hides_error_message_when_first_load_throws_auth_exception', (
      tester,
    ) async {
      final repo = _ThrowingCommunityRepository(
        const AuthException(message: '인증 만료'),
      );
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      // AuthInterceptor가 강제 로그아웃을 처리한다 — 화면은 실패 안내를 그리지 않는다.
      expect(find.text('모집글을 불러오지 못했어요'), findsNothing);
      expect(find.byType(CommunityPostCard), findsNothing);
      // 화면 자체가 무반응이어야 하므로 작성 버튼도 뜨지 않는다.
      expect(find.text('모집글 작성'), findsNothing);
    });

    testWidgets(
      'shows_error_message_when_first_load_throws_generic_app_exception',
      (tester) async {
        final repo = _ThrowingCommunityRepository(
          const ServerException(message: '서버 오류'),
        );
        await tester.pumpWidget(_wrap(repo));
        await tester.pumpAndSettle();

        // errorByException은 messageKey/code가 없으면 e.message로 폴백한다 —
        // 고정 문구 대신 예외가 실어온 문구가 떠야 한다.
        expect(find.text('서버 오류'), findsOneWidget);
        // 에러 상태에서도 첫 글을 쓸 방법은 남아 있어야 한다.
        expect(find.text('모집글 작성'), findsOneWidget);
      },
    );

    testWidgets('recovers_list_when_pulled_to_refresh_after_first_load_error', (
      tester,
    ) async {
      final repo = _RecoveringCommunityRepository([_post(1)]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      // 첫 로드는 실패 — 에러 플레이스홀더.
      expect(find.text('서버 오류'), findsOneWidget);
      expect(find.byType(CommunityPostCard), findsNothing);

      // 실제 당김 제스처로 새로고침을 건다. 에러 화면은 SliverFillRemaining이
      // 뷰포트를 채워 둬서 당길 여지가 있다 (없으면 오버스크롤이 안 생겨
      // 새로고침 자체가 불가능하다).
      await tester.fling(find.text('서버 오류'), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.byType(CommunityPostCard), findsOneWidget);
    });

    testWidgets('appends_the_next_page_when_scrolled_to_the_bottom', (
      tester,
    ) async {
      // 목록을 CustomScrollView로 바꾸면서 스크롤 컨트롤러·maxScrollExtent 기준이
      // 그대로인지 확인한다 — 여기가 깨지면 다음 페이지가 영영 안 붙는다.
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final repo = _PagingCommunityRepository(
        [for (var i = 1; i <= 8; i++) _post(i)],
        [for (var i = 9; i <= 12; i++) _post(i)],
      );
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityPostCard), findsWidgets);
      expect(find.text('모집글 9'), findsNothing);

      await tester.fling(find.text('모집글 1'), const Offset(0, -2000), 3000);
      await tester.pumpAndSettle();

      expect(find.text('모집글 12'), findsOneWidget);
    });
  });

  group('CommunityPage 카드 더보기 메뉴', () {
    /// [index]번 카드의 더보기(⋮)를 열고 [label] 항목을 고른다.
    Future<void> pickCardMenu(
      WidgetTester tester,
      int index,
      String label,
    ) async {
      await tester.tap(
        find.descendant(
          of: find.byType(CommunityPostCard).at(index),
          matching: find.byType(CommunityPostMenu),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    testWidgets('marks_only_the_picked_card_completed_when_close_is_picked', (
      tester,
    ) async {
      final repo = _CardActionRepository([_post(1), _post(2)]);
      await tester.pumpWidget(_wrap(repo, currentUserId: 7));
      await tester.pumpAndSettle();

      await pickCardMenu(tester, 0, '마감하기');

      // 목록을 다시 당기지 않고 그 카드만 바뀐다.
      expect(find.text('마감'), findsOneWidget);
      expect(find.text('모집중'), findsOneWidget);
      expect(find.byType(CommunityPostCard), findsNWidgets(2));
    });

    testWidgets('removes_the_card_from_the_list_when_delete_is_confirmed', (
      tester,
    ) async {
      final repo = _CardActionRepository([_post(1), _post(2)]);
      await tester.pumpWidget(_wrap(repo, currentUserId: 7));
      await tester.pumpAndSettle();

      await pickCardMenu(tester, 0, '삭제하기');
      // 확인 다이얼로그의 삭제 버튼.
      await tester.tap(find.text('삭제하기').last);
      await tester.pumpAndSettle();

      expect(repo.deletedIds, [1]);
      expect(find.byType(CommunityPostCard), findsOneWidget);
      expect(find.text('모집글 1'), findsNothing);
      expect(find.text('모집글 2'), findsOneWidget);
    });

    testWidgets('opens_the_edit_form_over_the_detail_when_edit_is_picked', (
      tester,
    ) async {
      final repo = _CardActionRepository([_post(1), _post(2)]);
      await tester.pumpWidget(_wrapRouted(repo, currentUserId: 7));
      await tester.pumpAndSettle();

      await pickCardMenu(tester, 1, '수정하기');
      await _settleDetailMocks(tester);

      // 고른 카드의 글이 수정 모드로 열린다 — 첫 카드가 아니라 두 번째다.
      expect(find.byType(CommunityCreatePage), findsOneWidget);
      expect(find.text('모집글 수정'), findsOneWidget);
      expect(find.text('모집글 2'), findsOneWidget);
    });

    testWidgets('lands_on_the_detail_not_the_list_when_edit_is_dismissed', (
      tester,
    ) async {
      // 목록에서 바로 수정을 열어도 닫으면 방금 보던 글이 나와야 한다 —
      // 목록으로 튕기면 뭘 고쳤는지 확인할 수가 없다.
      final repo = _CardActionRepository([_post(1), _post(2)]);
      await tester.pumpWidget(_wrapRouted(repo, currentUserId: 7));
      await tester.pumpAndSettle();

      await pickCardMenu(tester, 1, '수정하기');
      await _settleDetailMocks(tester);
      // 앱바 좌측 닫기(×).
      await tester.tap(find.byTooltip('닫기'));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityCreatePage), findsNothing);
      expect(find.byType(CommunityDetailPage), findsOneWidget);
      expect(find.byType(CommunityPage), findsNothing);
    });
  });
}
