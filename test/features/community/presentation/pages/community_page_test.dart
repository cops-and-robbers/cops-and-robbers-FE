import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_post_card.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class _FakeCommunityRepository implements CommunityRepository {
  _FakeCommunityRepository(this.items);

  final List<CommunityPostEntity> items;
  int callCount = 0;

  @override
  Future<CommunityPostPageEntity> getPosts({
    required int page,
    required int size,
    CommunityScope scope = CommunityScope.all,
  }) async {
    callCount++;
    return CommunityPostPageEntity(items: items, currentPage: 0, totalPages: 1);
  }
}

/// 첫 로드에서 항상 지정된 예외를 던지는 가짜 Repository.
/// AuthException 무반응 분기와 일반 AppException 안내 분기를 각각 검증하는 데 쓴다.
class _ThrowingCommunityRepository implements CommunityRepository {
  _ThrowingCommunityRepository(this.exception);

  final AppException exception;

  @override
  Future<CommunityPostPageEntity> getPosts({
    required int page,
    required int size,
    CommunityScope scope = CommunityScope.all,
  }) async {
    throw exception;
  }
}

/// 최초 호출은 실패하고 이후 호출은 성공하는 가짜 Repository.
/// pull-to-refresh가 실제 재조회로 이어져 에러 상태에서 복구되는지 검증하는 데 쓴다.
class _RecoveringCommunityRepository implements CommunityRepository {
  _RecoveringCommunityRepository(this.items);

  final List<CommunityPostEntity> items;
  int callCount = 0;

  @override
  Future<CommunityPostPageEntity> getPosts({
    required int page,
    required int size,
    CommunityScope scope = CommunityScope.all,
  }) async {
    callCount++;
    if (callCount == 1) {
      throw const ServerException(message: '서버 오류');
    }
    return CommunityPostPageEntity(items: items, currentPage: 0, totalPages: 1);
  }
}

Widget _wrap(CommunityRepository repo) => ProviderScope(
  overrides: [communityRepositoryProvider.overrideWithValue(repo)],
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

      // RefreshIndicatorState.show()가 반환하는 Future는 인디케이터 Ticker가
      // 끝나야 완료되는데, Ticker는 pump가 있어야 진행된다. 바로 await하면 pump할
      // 기회가 없어 영원히 멈춘다 — fire-and-forget 후 pumpAndSettle로 흘려보낸다.
      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show();
      await tester.pumpAndSettle();

      expect(find.byType(CommunityPostCard), findsOneWidget);
    });
  });
}
