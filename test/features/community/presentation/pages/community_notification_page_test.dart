import 'package:cops_and_robbers/features/community/domain/entities/community_notification_entity.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_notification_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_notification_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../community_fakes.dart';

CommunityNotificationEntity _notification({
  required int id,
  required int postId,
  required String title,
  CommunityNotificationType type = CommunityNotificationType.comment,
}) => CommunityNotificationEntity(
  id: id,
  type: type,
  communityPostId: postId,
  postTitle: title,
  content: '몇 시에 만나나요?',
  read: false,
  createdAt: DateTime.now(),
);

/// 알림함 화면 전용 가짜 Repository — HTTP 경계만 대체한다.
///
/// [pages]는 조회 요청 순서대로 돌려줄 목록이다(첫 로드, 당겨서 새로고침 …).
/// 마지막 페이지를 넘어서는 요청은 마지막 것을 반복한다. 커서 페이징은
/// 스크랩 목록 테스트가 같은 Notifier 골격으로 이미 덮으므로 여기선 한 장만 준다.
class _FakeCommunityRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _FakeCommunityRepository({required this.pages});

  final List<List<CommunityNotificationEntity>> pages;

  /// `getNotifications`가 실제로 받은 커서 — 새로고침이 첫 장부터 다시 받는지 본다.
  final List<int?> requestedCursors = [];
  int readCalls = 0;
  int unreadCountCalls = 0;
  int _served = 0;

  @override
  Future<CommunityNotificationPageEntity> getNotifications({
    int? cursor,
    required int size,
  }) async {
    requestedCursors.add(cursor);
    final index = _served < pages.length ? _served : pages.length - 1;
    _served++;
    return CommunityNotificationPageEntity(
      items: pages[index],
      nextCursor: null,
      hasNext: false,
    );
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    unreadCountCalls++;
    return 1;
  }

  @override
  Future<void> readNotifications() async {
    readCalls++;
  }
}

/// 실제 앱과 같이 알림함과 상세가 커뮤니티 목록 아래 형제로 있는 라우터.
///
/// 상세는 무관한 의존성을 끌고 오는 실물 대신 어떤 postId로 도착했는지만
/// 보여주는 얕은 페이지다. `notifications`를 `:postId`보다 앞에 두는 순서도
/// 실제 라우터와 같다.
GoRouter _router() => GoRouter(
  initialLocation: '${RoutePaths.community}/notifications',
  routes: [
    GoRoute(
      path: RoutePaths.community,
      builder: (_, _) => const Scaffold(body: Text('community list')),
      routes: [
        GoRoute(
          path: 'notifications',
          name: RoutePaths.communityNotificationName,
          builder: (_, _) => const CommunityNotificationPage(),
        ),
        GoRoute(
          path: ':postId',
          name: RoutePaths.communityDetailName,
          builder: (_, state) =>
              Scaffold(body: Text('detail ${state.pathParameters['postId']}')),
        ),
      ],
    ),
  ],
);

Future<({GoRouter router, ProviderContainer container})> _pumpPage(
  WidgetTester tester,
  _FakeCommunityRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [communityRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  final router = _router();

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => MaterialApp.router(
          locale: const Locale('ko'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (router: router, container: container);
}

void main() {
  group('CommunityNotificationPage', () {
    testWidgets('shows_notifications_when_the_page_opens', (tester) async {
      final repo = _FakeCommunityRepository(
        pages: [
          [
            _notification(id: 2, postId: 8, title: '올림픽공원 대규모로 뛰어봅시다'),
            _notification(
              id: 1,
              postId: 3,
              title: '퇴근하고 한 판',
              type: CommunityNotificationType.reply,
            ),
          ],
        ],
      );

      await _pumpPage(tester, repo);

      expect(find.text('올림픽공원 대규모로 뛰어봅시다'), findsOneWidget);
      expect(find.text('퇴근하고 한 판'), findsOneWidget);
      expect(find.textContaining('새 댓글'), findsOneWidget);
      expect(find.textContaining('새 답글'), findsOneWidget);
      expect(repo.readCalls, 0, reason: '조회만으로는 읽음 처리되지 않는다');
    });

    testWidgets('shows_empty_message_when_there_are_no_notifications', (
      tester,
    ) async {
      final repo = _FakeCommunityRepository(pages: [[]]);

      await _pumpPage(tester, repo);

      expect(find.text('받은 알림이 없어요'), findsOneWidget);
    });

    testWidgets('marks_all_read_once_and_refetches_unread_count_when_popped', (
      tester,
    ) async {
      // 두 번 잘못됐던 로직(dispose 버전은 POST 미전송, ref-after-await 버전은
      // 크래시)의 회귀 방어. 배지 재조회는 커뮤니티 페이지가 watch 하는 것을
      // container.listen 으로 흉내낸다.
      final repo = _FakeCommunityRepository(
        pages: [
          [_notification(id: 1, postId: 8, title: '올림픽공원')],
        ],
      );
      final page = await _pumpPage(tester, repo);
      final sub = page.container.listen(
        communityNotificationUnreadCountProvider,
        (_, _) {},
      );
      addTearDown(sub.close);
      await tester.pumpAndSettle();
      expect(repo.unreadCountCalls, 1);

      page.router.pop();
      await tester.pumpAndSettle();

      expect(find.text('community list'), findsOneWidget);
      expect(repo.readCalls, 1);
      expect(repo.unreadCountCalls, 2, reason: '읽음 처리 뒤 배지를 다시 받는다');
    });

    testWidgets('opens_post_detail_when_a_notification_is_tapped', (
      tester,
    ) async {
      final repo = _FakeCommunityRepository(
        pages: [
          [_notification(id: 1, postId: 8, title: '올림픽공원')],
        ],
      );
      await _pumpPage(tester, repo);

      await tester.tap(find.text('올림픽공원'));
      await tester.pumpAndSettle();

      expect(find.text('detail 8'), findsOneWidget);
      expect(repo.readCalls, 0, reason: '상세로 가는 것은 pop이 아니다');
    });

    testWidgets('refetches_from_the_first_page_when_pulled', (tester) async {
      final repo = _FakeCommunityRepository(
        pages: [
          [_notification(id: 1, postId: 8, title: '올림픽공원')],
          [
            _notification(id: 2, postId: 9, title: '새로 온 알림'),
            _notification(id: 1, postId: 8, title: '올림픽공원'),
          ],
        ],
      );
      await _pumpPage(tester, repo);
      expect(find.text('새로 온 알림'), findsNothing);

      await tester.fling(find.text('올림픽공원'), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.text('새로 온 알림'), findsOneWidget);
      expect(repo.requestedCursors, [null, null]);
    });
  });
}
