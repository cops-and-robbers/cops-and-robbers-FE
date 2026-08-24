import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_member_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_chat_room_menu_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../community_chat_fakes.dart';
import '../../community_fakes.dart';

const _postId = 42;
const _authorId = 7;

class _PostOnlyRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs
    implements CommunityRepository {
  @override
  Future<CommunityPostEntity> getPost(int postId) async => CommunityPostEntity(
    id: _postId,
    writerId: _authorId,
    title: '나랑 경도하자!!!!!',
    content: '본문',
    meetingAt: DateTime(2026, 8, 2, 20, 0),
    latitude: 37.5,
    longitude: 127.0,
    maxParticipants: 10,
    status: CommunityPostStatus.recruiting,
    createdAt: DateTime(2026, 8, 1),
  );
}

/// 상세 조회가 실패하는 상황(네트워크 오류 등)을 흉내낸다 — 두 스텁 다 기본이
/// `getPost` 포함 모든 상세 API에서 UnimplementedError를 던진다.
class _ThrowingPostRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs
    implements CommunityRepository {}

/// 메뉴 → (나가기) → 목록으로 `context.go`하므로 진짜 라우터가 필요하다.
GoRouter _router() => GoRouter(
  initialLocation: '/community/$_postId/chat/menu',
  routes: [
    GoRoute(
      path: '/community',
      builder: (_, _) => const Scaffold(body: Text('목록')),
      routes: [
        GoRoute(
          path: ':postId/chat/menu',
          builder: (_, state) => CommunityChatRoomMenuPage(
            postId: int.parse(state.pathParameters['postId']!),
          ),
        ),
      ],
    ),
  ],
);

Widget _wrap(
  FakeCommunityChatRepository chatRepo, {
  required int currentUserId,
  CommunityRepository? communityRepo,
}) {
  final router = _router();
  addTearDown(router.dispose);
  return ProviderScope(
    overrides: [
      communityChatRepositoryProvider.overrideWithValue(chatRepo),
      communityRepositoryProvider.overrideWithValue(
        communityRepo ?? _PostOnlyRepository(),
      ),
      currentUserIdProvider.overrideWithValue(currentUserId),
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

FakeCommunityChatRepository _repo() => FakeCommunityChatRepository()
  ..members = const [
    CommunityChatMemberEntity(
      userId: _authorId,
      nickname: '경도매우러버',
      isAuthor: true,
    ),
    CommunityChatMemberEntity(userId: 2, nickname: '홍길동그라미', isAuthor: false),
  ];

void main() {
  group('CommunityChatRoomMenuPage', () {
    testWidgets('lists_members_with_author_badge_and_hides_leave_when_author', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_repo(), currentUserId: _authorId));
      await tester.pump(const Duration(milliseconds: 300)); // 상세 목(200ms) 로드
      await tester.pumpAndSettle();

      expect(find.text('참가자 2명'), findsOneWidget);
      expect(find.text('경도매우러버'), findsOneWidget);
      expect(find.text('홍길동그라미'), findsOneWidget);
      expect(find.text('방장'), findsOneWidget);
      expect(find.text('모집글 보기'), findsOneWidget);
      expect(find.text('채팅방 나가기'), findsNothing);
    });

    testWidgets('shows_room_member_count_when_member_list_is_empty', (
      tester,
    ) async {
      final repo = _repo()..members = const [];
      await tester.pumpWidget(_wrap(repo, currentUserId: 2));
      await tester.pump(const Duration(milliseconds: 300)); // 상세 목(200ms) 로드
      await tester.pumpAndSettle();

      expect(find.text('참가자 8명'), findsOneWidget);
    });

    testWidgets('hides_leave_when_member_list_marks_me_as_author', (
      tester,
    ) async {
      final repo = _repo()
        ..members = const [
          CommunityChatMemberEntity(userId: 2, nickname: 'me', isAuthor: true),
        ];
      await tester.pumpWidget(
        _wrap(repo, currentUserId: 2, communityRepo: _ThrowingPostRepository()),
      );
      await tester.pump(const Duration(milliseconds: 300)); // 상세 목(200ms) 로드
      await tester.pumpAndSettle();

      expect(find.text('채팅방 나가기'), findsNothing);
    });

    testWidgets('leaves_room_and_returns_to_list_when_member_confirms', (
      tester,
    ) async {
      final repo = _repo();
      await tester.pumpWidget(_wrap(repo, currentUserId: 2));
      await tester.pump(const Duration(milliseconds: 300)); // 상세 목(200ms) 로드
      await tester.pumpAndSettle();

      await tester.tap(find.text('채팅방 나가기'));
      await tester.pumpAndSettle();
      expect(find.text('채팅방에서 나갈까요?'), findsOneWidget);

      await tester.tap(find.text('채팅방 나가기').last); // 다이얼로그 확인 버튼
      await tester.pumpAndSettle();

      // 화면이 걷히며 provider dispose가 disconnect를 한 번 더 부른다 — 앞 둘만 본다.
      final order = repo.calls
          .where((c) => c == 'leave' || c == 'disconnect')
          .take(2)
          .toList();
      expect(order, ['leave', 'disconnect']);
      expect(find.text('목록'), findsOneWidget);
    });

    testWidgets('keeps_page_and_shows_members_when_member_declines', (
      tester,
    ) async {
      final repo = _repo();
      await tester.pumpWidget(_wrap(repo, currentUserId: 2));
      await tester.pump(const Duration(milliseconds: 300)); // 상세 목(200ms) 로드
      await tester.pumpAndSettle();

      await tester.tap(find.text('채팅방 나가기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('닫기'));
      await tester.pumpAndSettle();

      expect(repo.calls, isNot(contains('leave')));
      expect(find.text('홍길동그라미'), findsOneWidget);
    });
  });
}
