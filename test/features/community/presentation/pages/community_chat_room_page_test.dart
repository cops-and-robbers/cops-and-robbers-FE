import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/services/lifecycle/lifecycle_provider.dart';
import 'package:cops_and_robbers/core/widgets/chat/chat_bubble.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_chat_room_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_comment_entity.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_comment_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_chat_invite_card.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_chat_system_pill.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_message_input.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_chat_fakes.dart';
import '../../community_fakes.dart';

const _postId = 42;

CommunityPostEntity _post() => CommunityPostEntity(
  id: _postId,
  writerId: 7,
  title: '나랑 경도하자!!!!!',
  content: '본문',
  meetingAt: DateTime(2026, 8, 2, 20, 0),
  latitude: 37.5,
  longitude: 127.0,
  maxParticipants: 10,
  status: CommunityPostStatus.recruiting,
  createdAt: DateTime(2026, 8, 1),
  likeCount: 0,
  isLiked: false,
  scrapCount: 0,
  isScrapped: false,
);

/// 상세 조회만 돌려주는 가짜 — 채팅방 상단 카드가 쓴다.
class _PostOnlyRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs
    implements CommunityRepository {
  @override
  Future<CommunityPostEntity> getPost(int postId) async => _post();
}

CommunityChatMessageEntity _text(int id, int sender, String text) =>
    CommunityChatMessageEntity(
      id: id,
      messageKey: 'k$id',
      senderId: sender,
      senderNickname: sender == 7 ? '경도매우러버' : '나',
      body: CommunityChatMessageBody.text(text),
      createdAt: DateTime(2026, 8, 24, 17, 34),
    );

/// 이 화면은 댓글을 그리지 않는다 — 상세 provider가 부르기만 하므로 빈 목록이면 된다.
class _NoCommentsRepository implements CommunityCommentRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();

  @override
  Future<List<CommunityCommentEntity>> getComments(int postId) async =>
      const [];
}

Widget _wrap(FakeCommunityChatRepository chatRepo) => ProviderScope(
  overrides: [
    communityChatRepositoryProvider.overrideWithValue(chatRepo),
    communityRepositoryProvider.overrideWithValue(_PostOnlyRepository()),
    // 이 화면은 글 제목을 상세 provider에서 가져오는데, 그 provider가 댓글도
    // 함께 부른다. 덮지 않으면 Retrofit이 실제 Dio를 타고 상세가 통째로 실패한다.
    communityCommentRepositoryProvider.overrideWithValue(
      _NoCommentsRepository(),
    ),
    currentUserIdProvider.overrideWithValue(1),
    clockProvider.overrideWithValue(() => DateTime(2026, 8, 24, 17, 40)),
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
      home: const CommunityChatRoomPage(postId: _postId),
    ),
  ),
);

/// pending 말풍선은 0.6 투명도로 흐리게 그린다 — 그 래퍼만 센다.
final Finder _pendingBubble = find.byWidgetPredicate(
  (w) => w is Opacity && w.opacity == 0.6,
);

/// 입력 바 안의 유일한 아이콘이 전송 버튼이다. 키보드 오른쪽 아래 키는 개행이라
/// 전송 경로는 이 아이콘 탭뿐이다.
final Finder _sendButton = find.descendant(
  of: find.byType(CommunityMessageInput),
  matching: find.byType(SvgPicture),
);

void main() {
  group('CommunityChatRoomPage', () {
    testWidgets(
      'renders_title_meeting_card_bubbles_pill_and_invite_when_loaded',
      (tester) async {
        // 초대 카드가 커서 기본 뷰포트로는 목록 위쪽(과거 메시지)이 화면 밖으로
        // 밀린다 — 스크롤 없이 전부 검증하도록 세로로 넉넉하게 잡는다.
        tester.view.physicalSize = const Size(1125, 4000);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);
        final repo = FakeCommunityChatRepository()
          ..firstPage = [
            CommunityChatMessageEntity(
              id: 4,
              messageKey: 'k4',
              senderId: 2,
              senderNickname: '홍길동그라미',
              body: const CommunityChatMessageBody.gameInvite('ABC123'),
              createdAt: DateTime(2026, 8, 24, 17, 36),
            ),
            _text(3, 1, '넵 알겠습니다!'),
            _text(2, 7, '안녕하세요~ 공지 확인해주세요!'),
            CommunityChatMessageEntity(
              id: 1,
              messageKey: 'k1',
              senderId: 3,
              senderNickname: '도둑쥐',
              body: const CommunityChatMessageBody.system(
                CommunityChatSystemEvent.join,
              ),
              createdAt: DateTime(2026, 8, 24, 17, 30),
            ),
          ];
        await tester.pumpWidget(_wrap(repo));
        await tester.pump(const Duration(milliseconds: 300)); // 상세 목(200ms) 로드
        await tester.pumpAndSettle();

        expect(find.text('나랑 경도하자!!!!!'), findsOneWidget);
        expect(find.text('현재 인원 8/10명'), findsOneWidget);
        expect(find.text('도둑쥐님이 참여했어요'), findsOneWidget);
        expect(find.byType(CommunityChatSystemPill), findsOneWidget);
        expect(find.byType(CommunityChatInviteCard), findsOneWidget);
        expect(find.text('경도매우러버'), findsOneWidget);
        // 말풍선 셋 — 내 것 하나(파랑), 상대 텍스트 하나 + 초대 카드 하나(흰색)
        expect(find.byType(ChatBubble), findsNWidgets(3));
        final mine = tester.widget<ChatBubble>(
          find.byWidgetPredicate((w) => w is ChatBubble && w.isMe),
        );
        expect(mine.bubbleColor, AppColors.blueVer2Basic);
        final theirs = tester.widget<ChatBubble>(
          find.ancestor(
            of: find.text('안녕하세요~ 공지 확인해주세요!'),
            matching: find.byType(ChatBubble),
          ),
        );
        expect(theirs.bubbleColor, AppColors.white);
        // 초대 카드도 같은 말풍선(흰색, 아바타 있는 상대 쪽)에 담긴다.
        final inviteBubble = tester.widget<ChatBubble>(
          find.ancestor(
            of: find.byType(CommunityChatInviteCard),
            matching: find.byType(ChatBubble),
          ),
        );
        expect(inviteBubble.isMe, isFalse);
        expect(inviteBubble.bubbleColor, AppColors.white);
      },
    );

    testWidgets('shows_pending_bubble_then_confirms_when_echo_arrives', (
      tester,
    ) async {
      final repo = FakeCommunityChatRepository();
      await tester.pumpWidget(_wrap(repo));
      await tester.pump(const Duration(milliseconds: 300)); // 상세 목(200ms) 로드
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '곧 봬요');
      // 입력이 생겨야 전송 버튼이 살아난다 — 그 리빌드를 한 프레임 기다린다.
      await tester.pump();
      await tester.tap(_sendButton);
      await tester.pump();

      expect(find.text('곧 봬요'), findsOneWidget);
      expect(_pendingBubble, findsOneWidget); // pending 흐림
      final key = repo.calls
          .firstWhere((c) => c.startsWith('send:'))
          .substring(5);

      repo.emitMessage(
        CommunityChatMessageEntity(
          id: 99,
          messageKey: key,
          senderId: 1,
          senderNickname: '나',
          body: const CommunityChatMessageBody.text('곧 봬요'),
          createdAt: DateTime(2026, 8, 24, 17, 41),
        ),
      );
      // 브로드캐스트 스트림 전달(마이크로태스크) 뒤 리빌드까지 기다린다
      await tester.pumpAndSettle();

      expect(_pendingBubble, findsNothing);
      expect(find.text('오후 5:41'), findsOneWidget);
    });

    testWidgets('shows_notice_pill_when_host_registers_a_pin', (tester) async {
      // 공지는 이력을 남기지 않는다(DEC-0054) — 대화창의 이 자국이 "언제
      // 바뀌었나"의 유일한 기록이다. 모르는 이벤트로 접히면 아무것도 안 남는다.
      final repo = FakeCommunityChatRepository();
      await tester.pumpWidget(_wrap(repo));
      await tester.pump(const Duration(milliseconds: 300)); // 상세 목(200ms) 로드
      await tester.pumpAndSettle();

      repo.emitMessage(
        CommunityChatMessageEntity(
          id: 101,
          messageKey: 'pin-1',
          senderId: 7,
          senderNickname: '경도매우러버',
          body: const CommunityChatMessageBody.system(
            CommunityChatSystemEvent.pinRegistered,
          ),
          createdAt: DateTime(2026, 8, 24, 17, 45),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('경도매우러버님이 공지를 등록했어요'), findsOneWidget);
      expect(find.byType(CommunityChatSystemPill), findsOneWidget);
    });

    testWidgets('shows_reconnect_banner_when_connection_is_exhausted', (
      tester,
    ) async {
      final repo = FakeCommunityChatRepository()
        ..connectEmitsDisconnected = true;
      await tester.pumpWidget(_wrap(repo));
      await tester.pump(const Duration(milliseconds: 300)); // 상세 목(200ms) 로드
      await tester.pumpAndSettle();
      // 백오프 1+2+4+8+10초를 지나면 포기한다
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();

      expect(find.text('연결이 끊겼어요'), findsOneWidget);
      expect(find.text('다시 연결'), findsOneWidget);
    });

    testWidgets('sends_the_read_receipt_when_the_page_is_popped', (
      tester,
    ) async {
      final repo = FakeCommunityChatRepository()
        ..firstPage = [_text(3, 7, '먼저 온 말')];
      await tester.pumpWidget(_wrap(repo));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      // 머무는 동안 하나 더 왔다 — 떠날 때 그 id로 한 번 더 보낸다
      repo.emitMessage(_text(4, 7, '나중 말'));
      await tester.pumpAndSettle();

      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(repo.calls.where((x) => x.startsWith('markRead:')), [
        'markRead:$_postId:3',
        'markRead:$_postId:4',
      ]);
    });
  });
}
