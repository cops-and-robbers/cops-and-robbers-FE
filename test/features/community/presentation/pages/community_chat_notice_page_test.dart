import 'package:cops_and_robbers/core/services/lifecycle/lifecycle_provider.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_notice_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_chat_notice_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_menu_button.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_chat_fakes.dart';
import '../../community_fakes.dart';

const _postId = 42;
const _hostId = 7;
const _memberId = 1;

final _notice = CommunityChatNoticeEntity(
  id: 9,
  writerId: _hostId,
  writerNickname: '경도매우러버',
  writerProfileIcon: 3,
  content: '경도 마치고 뒷풀이가 있습니다!',
  createdAt: DateTime(2026, 9, 19, 13, 24),
  updatedAt: DateTime(2026, 9, 19, 13, 24),
);

CommunityPostEntity _post() => CommunityPostEntity(
  id: _postId,
  writerId: _hostId,
  title: '나랑 경도하자!!!!!',
  content: '본문',
  meetingAt: DateTime(2026, 9, 19, 20, 0),
  latitude: 37.5,
  longitude: 127.0,
  maxParticipants: 10,
  status: CommunityPostStatus.recruiting,
  createdAt: DateTime(2026, 9, 1),
  likeCount: 0,
  isLiked: false,
  scrapCount: 0,
  isScrapped: false,
);

class _PostOnlyRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs
    implements CommunityRepository {
  @override
  Future<CommunityPostEntity> getPost(int postId) async => _post();
}

Widget _wrap(FakeCommunityChatRepository chatRepo, {required int? viewerId}) =>
    ProviderScope(
      overrides: [
        communityChatRepositoryProvider.overrideWithValue(chatRepo),
        communityRepositoryProvider.overrideWithValue(_PostOnlyRepository()),
        currentUserIdProvider.overrideWithValue(viewerId),
        lifecycleStateProvider.overrideWith(
          (ref) => const Stream<AppLifecycleState>.empty(),
        ),
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
          home: const CommunityChatNoticePage(postId: _postId),
        ),
      ),
    );

void main() {
  group('CommunityChatNoticePage', () {
    testWidgets('shows_writer_and_content_when_notice_exists', (tester) async {
      final repo = FakeCommunityChatRepository()..notice = _notice;

      await tester.pumpWidget(_wrap(repo, viewerId: _memberId));
      await tester.pumpAndSettle();

      expect(find.text('경도매우러버'), findsOneWidget);
      expect(find.text('경도 마치고 뒷풀이가 있습니다!'), findsOneWidget);
      // 댓글 목록과 같은 형식을 쓴다 — 새 포맷을 만들지 않는다.
      expect(find.text('09/19 13:24'), findsOneWidget);
    });

    testWidgets('hides_every_edit_entry_point_when_viewer_is_not_the_host', (
      tester,
    ) async {
      // 서버도 403으로 막지만, 눌러 놓고 거절당하는 화면을 보여줄 이유가 없다.
      final repo = FakeCommunityChatRepository()..notice = _notice;

      await tester.pumpWidget(_wrap(repo, viewerId: _memberId));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityMenuButton), findsNothing);
      expect(find.byTooltip('공지글 작성'), findsNothing);
    });

    testWidgets('hides_every_edit_entry_point_while_the_viewer_is_unknown', (
      tester,
    ) async {
      // 로그인 상태가 확정되기 전에는 방장이 아닌 쪽으로 본다 — 잠깐 보였다가
      // 사라지는 편집 버튼은 눌러 놓고 403을 받는 길이다.
      final repo = FakeCommunityChatRepository()..notice = _notice;

      await tester.pumpWidget(_wrap(repo, viewerId: null));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityMenuButton), findsNothing);
      expect(find.byTooltip('공지글 작성'), findsNothing);
    });

    testWidgets('offers_edit_and_delete_when_viewer_is_the_host', (
      tester,
    ) async {
      final repo = FakeCommunityChatRepository()..notice = _notice;

      await tester.pumpWidget(_wrap(repo, viewerId: _hostId));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityMenuButton), findsOneWidget);
      await tester.tap(find.byType(CommunityMenuButton));
      await tester.pumpAndSettle();

      expect(find.text('수정하기'), findsOneWidget);
      expect(find.text('삭제하기'), findsOneWidget);
    });

    testWidgets('tells_the_host_to_write_one_when_room_has_no_notice', (
      tester,
    ) async {
      final repo = FakeCommunityChatRepository();

      await tester.pumpWidget(_wrap(repo, viewerId: _hostId));
      await tester.pumpAndSettle();

      expect(find.text('공지를 등록해 모임 소식을 전해 보세요'), findsOneWidget);
      // 쓸 것이 없으니 더보기 메뉴도 없다 — 수정·삭제할 대상이 없다.
      expect(find.byType(CommunityMenuButton), findsNothing);
    });

    testWidgets('tells_the_member_there_is_none_when_room_has_no_notice', (
      tester,
    ) async {
      final repo = FakeCommunityChatRepository();

      await tester.pumpWidget(_wrap(repo, viewerId: _memberId));
      await tester.pumpAndSettle();

      expect(find.text('등록된 공지가 없어요'), findsOneWidget);
    });
  });
}
