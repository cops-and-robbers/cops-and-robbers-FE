import 'dart:async';

import 'package:cops_and_robbers/core/services/lifecycle/lifecycle_provider.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_event.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_member_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_notice_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_page_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_room_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_chat_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_chat_room_list.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_chat_avatar.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_chat_room_tile.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

CommunityChatRoomEntity _room(
  int id, {
  CommunityChatLastMessageEntity? last,
  int unread = 0,
}) => CommunityChatRoomEntity(
  postId: id,
  title: '방 $id',
  status: CommunityPostStatus.recruiting,
  meetingAt: DateTime(2026, 9, 1),
  memberCount: 5,
  lastMessage: last,
  unreadCount: unread,
);

/// 목록만 돌려주는 가짜 — 나머지는 이 테스트가 쓰지 않는다.
class _RoomsOnlyRepository implements CommunityChatRepository {
  _RoomsOnlyRepository(this.rooms);
  final List<CommunityChatRoomEntity> rooms;
  int getRoomsCalls = 0;

  /// 응답이 늦는 상황 — 다시 받는 동안 화면이 뭘 보여 주는지 보려고 둔다.
  Duration? delay;

  @override
  Future<void> kickMember(int postId, int userId) =>
      throw UnimplementedError('이 테스트는 강퇴를 쓰지 않는다');

  @override
  Future<CommunityChatNoticeEntity?> getNotice(int postId) =>
      throw UnimplementedError('이 테스트는 고정 공지를 쓰지 않는다');

  @override
  Future<CommunityChatNoticeEntity> registerNotice(int postId, String c) =>
      throw UnimplementedError('이 테스트는 고정 공지를 쓰지 않는다');

  @override
  Future<CommunityChatNoticeEntity> updateNotice(int postId, String c) =>
      throw UnimplementedError('이 테스트는 고정 공지를 쓰지 않는다');

  @override
  Future<void> deleteNotice(int postId) =>
      throw UnimplementedError('이 테스트는 고정 공지를 쓰지 않는다');

  @override
  Future<List<CommunityChatRoomEntity>> getRooms() async {
    getRoomsCalls++;
    if (delay != null) await Future<void>.delayed(delay!);
    return rooms;
  }

  StreamController<CommunityChatEvent>? _socket;

  @override
  Stream<CommunityChatEvent> connect(int userId) {
    // 닫히지 않는 스트림이어야 한다 — 닫히면 소켓 Notifier가 끊김으로 보고
    // 재연결 타이머를 돌려 pumpAndSettle이 길어진다.
    _socket?.close();
    final c = StreamController<CommunityChatEvent>.broadcast();
    _socket = c;
    scheduleMicrotask(() {
      if (!c.isClosed) {
        c.add(
          const CommunityChatEvent.connection(
            CommunityChatConnectionState.connected,
          ),
        );
      }
    });
    return c.stream;
  }

  @override
  Future<void> disconnect() async => _socket?.close();

  @override
  void subscribeRoom(int postId) {}

  @override
  void unsubscribeRoom(int postId) {}

  @override
  Future<void> markRead(int postId, int lastReadMessageId) async {}

  @override
  Future<void> setNotification(int postId, {required bool enabled}) async {}

  @override
  Future<CommunityChatMembersEntity> getMembers(int postId) async =>
      const CommunityChatMembersEntity(members: []);
  @override
  Future<CommunityChatPageEntity> getMessages(
    int postId, {
    int? cursor,
    int size = 30,
  }) => throw UnimplementedError('이 테스트는 메시지 조회를 쓰지 않는다');
  @override
  Future<void> join(int postId) => throw UnimplementedError();
  @override
  Future<void> leave(int postId) => throw UnimplementedError();
  @override
  Future<void> send(
    int postId, {
    required String messageKey,
    required String text,
  }) => throw UnimplementedError();

  @override
  bool sendGameInvite(
    int postId, {
    required String messageKey,
    required String inviteCode,
  }) => throw UnimplementedError();
}

/// 탭을 오갈 때 컨테이너는 살아 있어야 한다 — `ProviderScope`를 새로 만들면
/// keepAlive provider까지 새로 만들어져 "다시 받았다"가 거짓으로 참이 된다.
({ProviderContainer container, Widget Function({required bool onTab}) tree})
_tabHarness(CommunityChatRepository repo) {
  final container = ProviderContainer(
    overrides: [
      communityChatRepositoryProvider.overrideWithValue(repo),
      currentUserIdProvider.overrideWithValue(1),
      clockProvider.overrideWithValue(() => DateTime(2026, 8, 24, 20, 0)),
      lifecycleStateProvider.overrideWith(
        (ref) => const Stream<AppLifecycleState>.empty(),
      ),
    ],
  );
  addTearDown(container.dispose);

  Widget tree({required bool onTab}) => UncontrolledProviderScope(
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
        home: Scaffold(
          body: onTab
              ? const CommunityChatRoomList(bottomPadding: 0)
              : const SizedBox.shrink(),
        ),
      ),
    ),
  );

  return (container: container, tree: tree);
}

Widget _wrap(CommunityChatRepository repo, {int? currentUserId}) =>
    ProviderScope(
      overrides: [
        communityChatRepositoryProvider.overrideWithValue(repo),
        currentUserIdProvider.overrideWithValue(currentUserId),
        clockProvider.overrideWithValue(() => DateTime(2026, 8, 24, 20, 0)),
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
          home: const Scaffold(body: CommunityChatRoomList(bottomPadding: 0)),
        ),
      ),
    );

void main() {
  group('CommunityChatRoomList', () {
    testWidgets('lists_rooms_with_preview_and_time_when_logged_in', (
      tester,
    ) async {
      final repo = _RoomsOnlyRepository([
        _room(
          1,
          last: CommunityChatLastMessageEntity(
            id: 1,
            body: const CommunityChatMessageBody.text('도착한 분 계신가요?'),
            createdAt: DateTime(2026, 8, 24, 20, 31),
          ),
        ),
        _room(2),
      ]);
      await tester.pumpWidget(_wrap(repo, currentUserId: 1));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityChatRoomTile), findsNWidgets(2));
      expect(find.text('도착한 분 계신가요?'), findsOneWidget);
      expect(find.text('오후 8:31'), findsOneWidget);
    });

    testWidgets('shows_the_last_senders_profile_icon_on_the_tile', (
      tester,
    ) async {
      // 칸의 얼굴은 마지막으로 말한 사람이다 — 기본 아이콘으로 고정해 두면
      // 방을 열었을 때 보이는 말풍선 얼굴과 어긋난다.
      final repo = _RoomsOnlyRepository([
        _room(
          1,
          last: CommunityChatLastMessageEntity(
            id: 1,
            body: const CommunityChatMessageBody.text('도착한 분 계신가요?'),
            createdAt: DateTime(2026, 8, 24, 20, 31),
            senderProfileIcon: 7,
          ),
        ),
      ]);
      await tester.pumpWidget(_wrap(repo, currentUserId: 1));
      await tester.pumpAndSettle();

      final avatar = tester.widget<CommunityChatAvatar>(
        find.descendant(
          of: find.byType(CommunityChatRoomTile),
          matching: find.byType(CommunityChatAvatar),
        ),
      );
      expect(avatar.iconId, 7);
    });

    testWidgets('falls_back_to_the_default_icon_when_the_room_has_no_talk', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_RoomsOnlyRepository([_room(1)]), currentUserId: 1),
      );
      await tester.pumpAndSettle();

      final avatar = tester.widget<CommunityChatAvatar>(
        find.descendant(
          of: find.byType(CommunityChatRoomTile),
          matching: find.byType(CommunityChatAvatar),
        ),
      );
      expect(avatar.iconId, isNull);
    });

    testWidgets('shows_empty_message_when_no_rooms', (tester) async {
      await tester.pumpWidget(
        _wrap(_RoomsOnlyRepository([]), currentUserId: 1),
      );
      await tester.pumpAndSettle();

      expect(find.text('참여 중인 채팅방이 없어요'), findsOneWidget);
    });

    testWidgets('shows_login_prompt_without_calling_api_when_logged_out', (
      tester,
    ) async {
      final repo = _RoomsOnlyRepository([_room(1)]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.text('로그인하면 내 모임을 볼 수 있어요'), findsOneWidget);
      expect(repo.getRoomsCalls, 0);
    });

    testWidgets('does_not_refetch_when_the_tab_is_reopened', (tester) async {
      // 목록 갱신은 소켓이 한다 — 탭을 오가는 것만으로 요청이 더 나가지 않는다.
      // 첫 진입은 2회(기준선 + 첫 connected 재동기화)까지는 정상이다 — 이
      // 가짜 저장소 구조상 connected는 항상 getRooms() 응답보다 늦게 도착해
      // (provider 테스트의 `resyncs_once_when_the_baseline_was_fetched_before_the_first_connect`와
      // 같은 근거) "다음 connected에서 한 번 맞춘다" 규칙이 첫 진입마다 발동한다.
      // 여기서 확인할 것은 그 이후 — 탭을 오가도 더 늘지 않는다는 점이다.
      final repo = _RoomsOnlyRepository([_room(1)]);
      final h = _tabHarness(repo);
      await tester.pumpWidget(h.tree(onTab: true));
      await tester.pumpAndSettle();
      expect(repo.getRoomsCalls, 2);

      await tester.pumpWidget(h.tree(onTab: false));
      await tester.pumpAndSettle();
      await tester.pumpWidget(h.tree(onTab: true));
      await tester.pumpAndSettle();
      expect(repo.getRoomsCalls, 2);
    });

    testWidgets('shows_the_unread_badge_when_the_count_is_positive', (
      tester,
    ) async {
      final repo = _RoomsOnlyRepository([
        _room(
          1,
          unread: 3,
          last: CommunityChatLastMessageEntity(
            id: 1,
            body: const CommunityChatMessageBody.text('안 읽은 말'),
            createdAt: DateTime(2026, 8, 24, 20, 31),
          ),
        ),
        _room(
          2,
          last: CommunityChatLastMessageEntity(
            id: 2,
            body: const CommunityChatMessageBody.text('읽은 말'),
            createdAt: DateTime(2026, 8, 24, 20, 31),
          ),
        ),
      ]);
      await tester.pumpWidget(_wrap(repo, currentUserId: 1));
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('caps_the_unread_badge_at_99_plus', (tester) async {
      final repo = _RoomsOnlyRepository([
        _room(
          1,
          unread: 120,
          last: CommunityChatLastMessageEntity(
            id: 1,
            body: const CommunityChatMessageBody.text('말'),
            createdAt: DateTime(2026, 8, 24, 20, 31),
          ),
        ),
      ]);
      await tester.pumpWidget(_wrap(repo, currentUserId: 1));
      await tester.pumpAndSettle();

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('keeps_showing_the_cached_list_while_refetching', (
      tester,
    ) async {
      // 당겨서 새로고침 중에도 스피너로 갈아치우면 안 된다 — 목록이 깜빡인다.
      final repo = _RoomsOnlyRepository([
        _room(
          1,
          last: CommunityChatLastMessageEntity(
            id: 1,
            body: const CommunityChatMessageBody.text('도착한 분 계신가요?'),
            createdAt: DateTime(2026, 8, 24, 20, 31),
          ),
        ),
      ]);

      await tester.pumpWidget(_wrap(repo, currentUserId: 1));
      await tester.pumpAndSettle();

      repo.delay = const Duration(milliseconds: 200);
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump();

      // 아직 응답 전인데도 캐시된 칸이 그대로 보인다.
      expect(find.text('도착한 분 계신가요?'), findsOneWidget);

      // 지연 타이머를 흘려 보낸다 — 남겨 두면 트리 정리 때 터진다.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    });
  });
}
