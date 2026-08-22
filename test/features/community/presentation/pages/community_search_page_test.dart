import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/data/datasources/community_recent_keyword_storage.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_sort_option.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_search_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../community_fakes.dart';

/// 목록 테스트의 `_FakeCommunityRepository`와 같되, 검색이 실제로 받은 keyword를
/// 기록한다 — 타이핑 도중에는 요청이 나가지 않는지, 검색 실행 시점에만 원문이
/// 그대로 전달되는지를 이 기록으로 검증한다.
class _FakeCommunityRepository
    with CommunityRepositoryDetailStubs
    implements CommunityRepository {
  _FakeCommunityRepository(this.items);

  final List<CommunityPostEntity> items;
  int callCount = 0;
  String? lastKeyword;

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
    lastKeyword = keyword;
    return CommunityPostPageEntity(
      items: items,
      nextCursor: null,
      hasNext: false,
    );
  }
}

Widget _wrap(CommunityRepository repo) => ProviderScope(
  overrides: [
    communityRepositoryProvider.overrideWithValue(repo),
    // 검색 결과 카드의 더보기 메뉴가 로그인 사용자 id를 watch한다. 덮지 않으면
    // 실제 AuthNotifier가 Firebase까지 끌고 들어온다.
    currentUserIdProvider.overrideWithValue(null),
    // 검색도 목록과 같은 CommunityFeedNotifier를 타므로 국가 판별이 먼저 돈다.
    // 덮지 않으면 GPS·권한 플랫폼 채널이 응답하지 않아 pumpAndSettle이 끝나지 않는다.
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
      home: const CommunitySearchPage(),
    ),
  ),
);

/// 검색 화면을 세팅해 최근 검색어 로드까지 끝낸다.
Future<void> _pumpSearchPage(
  WidgetTester tester,
  CommunityRepository repo,
) async {
  await tester.pumpWidget(_wrap(repo));
  await tester.pumpAndSettle();
}

void main() {
  group('CommunitySearchPage', () {
    setUp(() {
      // SharedPreferences는 시스템 경계다 — 인메모리 구현으로 갈아끼운다.
      // (최근 검색어 로드는 화면 진입 즉시 일어나므로 모든 테스트에 필요하다.)
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('does_not_query_when_keyword_is_shorter_than_two_letters', (
      tester,
    ) async {
      final repo = _FakeCommunityRepository([]);
      await _pumpSearchPage(tester, repo);

      await tester.enterText(find.byType(TextField), '서');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // 확정 400을 왕복시키지 않는다.
      expect(repo.callCount, 0);
      expect(find.text('두 글자 이상 입력해주세요'), findsOneWidget);

      // 스낵바의 3초 자동 닫힘 타이머가 남아 있으면 테스트 종료 시
      // "Timer still pending"으로 깨진다 — 흘려보내고 끝낸다.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('counts_only_non_space_letters_when_validating_keyword', (
      tester,
    ) async {
      final repo = _FakeCommunityRepository([]);
      await _pumpSearchPage(tester, repo);

      // 서버가 공백을 제거하고 재므로 앱도 같은 규칙으로 잰다.
      await tester.enterText(find.byType(TextField), '서 ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(repo.callCount, 0);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('stores_keyword_in_recent_searches_when_search_runs', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final repo = _FakeCommunityRepository([]);
      await _pumpSearchPage(tester, repo);

      await tester.enterText(find.byType(TextField), '서울');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(repo.lastKeyword, '서울');
      expect(await CommunityRecentKeywordStorage().load(), ['서울']);
    });
  });
}
