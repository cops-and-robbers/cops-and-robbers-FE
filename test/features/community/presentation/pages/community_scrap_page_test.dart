import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_scrap_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_scrap_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_fakes.dart';

CommunityPostEntity _post({
  required int id,
  required String title,
  bool isScrapped = true,
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
  likeCount: 0,
  isLiked: false,
  scrapCount: 0,
  isScrapped: isScrapped,
);

/// 스크랩 목록 화면 전용 가짜 Repository.
///
/// [getPost]는 상세에서 돌아왔을 때의 단건 재조회를 흉내낸다 — [refetched]에
/// 지정된 id만 다른 값을 돌려주고, 나머지는 원래 목록의 값을 그대로 돌려줘
/// "해제되지 않았다"로 판정되게 한다. [failingGetPost]에 담긴 id는 대신 예외를
/// 던진다 — 재조회 자체가 실패했을 때(일시 장애 등) 행을 그대로 남기는지 검증한다.
class _FakeCommunityRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _FakeCommunityRepository({
    required this.posts,
    this.refetched = const {},
    this.failingGetPost = const {},
  });

  final List<CommunityPostEntity> posts;
  final Map<int, CommunityPostEntity> refetched;
  final Set<int> failingGetPost;

  @override
  Future<CommunityScrapPageEntity> getScraps({
    int? cursor,
    required int size,
  }) async =>
      CommunityScrapPageEntity(items: posts, nextCursor: null, hasNext: false);

  @override
  Future<CommunityPostEntity> getPost(int postId) async {
    if (failingGetPost.contains(postId)) {
      throw const ServerException(message: '서버 오류');
    }
    return refetched[postId] ?? posts.firstWhere((p) => p.id == postId);
  }
}

/// 스크랩 목록 화면을 세팅해 첫 로드까지 끝낸다.
///
/// `notifier`는 여기서 만든 `ProviderContainer`에서 꺼내 테스트 스코프 변수에
/// 담아 둔다 — `dropIfUnscrapped`처럼 화면 밖(상세 복귀 시점)에서 불리는 동작을
/// 실제 라우터 없이도 직접 검증하기 위해서다.
late CommunityScrapNotifier notifier;

Future<void> _pumpScrapPage(
  WidgetTester tester, {
  required List<CommunityPostEntity> posts,
  Map<int, CommunityPostEntity> refetched = const {},
  Set<int> failingGetPost = const {},
}) async {
  final container = ProviderContainer(
    overrides: [
      communityRepositoryProvider.overrideWithValue(
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
  notifier = container.read(communityScrapNotifierProvider.notifier);

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
      await _pumpScrapPage(
        tester,
        posts: [
          _post(id: 1, title: '첫 글'),
          _post(id: 2, title: '둘째 글'),
        ],
        refetched: {1: _post(id: 1, title: '첫 글', isScrapped: false)},
      );
      await tester.pumpAndSettle();

      await notifier.dropIfUnscrapped(1);
      await tester.pumpAndSettle();

      expect(find.text('첫 글'), findsNothing);
      expect(find.text('둘째 글'), findsOneWidget);
    });

    testWidgets('keeps_both_rows_when_the_refetch_after_returning_fails', (
      tester,
    ) async {
      // 일시 장애 등으로 재조회 자체가 실패하면 판정할 근거가 없다 — 행을
      // 그대로 남긴다(다음에 목록을 열 때 서버가 알아서 반영한다).
      await _pumpScrapPage(
        tester,
        posts: [
          _post(id: 1, title: '첫 글'),
          _post(id: 2, title: '둘째 글'),
        ],
        failingGetPost: {1},
      );
      await tester.pumpAndSettle();

      await notifier.dropIfUnscrapped(1);
      await tester.pumpAndSettle();

      expect(find.text('첫 글'), findsOneWidget);
      expect(find.text('둘째 글'), findsOneWidget);
    });
  });
}
