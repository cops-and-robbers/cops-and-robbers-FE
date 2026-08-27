import 'dart:async';

import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_event.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_member_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
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

CommunityChatRoomEntity _room(int id, {CommunityChatLastMessageEntity? last}) =>
    CommunityChatRoomEntity(
      postId: id,
      title: '방 $id',
      status: CommunityPostStatus.recruiting,
      meetingAt: DateTime(2026, 9, 1),
      memberCount: 5,
      lastMessage: last,
    );

/// 목록만 돌려주는 가짜 — 나머지는 이 테스트가 쓰지 않는다.
class _RoomsOnlyRepository implements CommunityChatRepository {
  _RoomsOnlyRepository(this.rooms);
  final List<CommunityChatRoomEntity> rooms;
  int getRoomsCalls = 0;

  /// 응답이 늦는 상황 — 다시 받는 동안 화면이 뭘 보여 주는지 보려고 둔다.
  Duration? delay;

  @override
  Future<List<CommunityChatRoomEntity>> getRooms() async {
    getRoomsCalls++;
    if (delay != null) await Future<void>.delayed(delay!);
    return rooms;
  }

  @override
  Stream<CommunityChatEvent> connect(int postId) => const Stream.empty();
  @override
  Future<void> disconnect(int postId) async {}
  @override
  Future<List<CommunityChatMemberEntity>> getMembers(int postId) async =>
      const [];
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
}

/// 탭을 오갈 때 컨테이너는 살아 있어야 한다 — `ProviderScope`를 새로 만들면
/// keepAlive provider까지 새로 만들어져 "다시 받았다"가 거짓으로 참이 된다.
({
  ProviderContainer container,
  Widget Function({required bool onTab}) tree,
  void Function(Duration) advance,
})
_tabHarness(CommunityChatRepository repo) {
  var now = DateTime(2026, 8, 24, 20, 0);
  final container = ProviderContainer(
    overrides: [
      communityChatRepositoryProvider.overrideWithValue(repo),
      currentUserIdProvider.overrideWithValue(1),
      clockProvider.overrideWithValue(() => now),
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

  return (
    container: container,
    tree: tree,
    advance: (Duration d) => now = now.add(d),
  );
}

Widget _wrap(CommunityChatRepository repo, {int? currentUserId}) =>
    ProviderScope(
      overrides: [
        communityChatRepositoryProvider.overrideWithValue(repo),
        currentUserIdProvider.overrideWithValue(currentUserId),
        clockProvider.overrideWithValue(() => DateTime(2026, 8, 24, 20, 0)),
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

    testWidgets('refetches_when_the_tab_is_reopened_after_the_stale_window', (
      tester,
    ) async {
      // 목록은 keepAlive라 방에서 대화하고 나와도 미리보기가 그대로다. 서버가
      // 새 메시지를 알려 줄 채널이 없어 돌아오는 순간이 유일한 기회다.
      final repo = _RoomsOnlyRepository([_room(1)]);
      final h = _tabHarness(repo);

      await tester.pumpWidget(h.tree(onTab: true));
      await tester.pumpAndSettle();
      expect(repo.getRoomsCalls, 1);

      // 다른 스코프를 고르면 이 위젯이 통째로 빠졌다가 돌아온다.
      await tester.pumpWidget(h.tree(onTab: false));
      await tester.pumpAndSettle();
      h.advance(const Duration(minutes: 4));
      await tester.pumpWidget(h.tree(onTab: true));
      await tester.pumpAndSettle();

      expect(repo.getRoomsCalls, 2);
    });

    testWidgets('does_not_refetch_when_the_tab_is_reopened_right_away', (
      tester,
    ) async {
      // 토글을 빠르게 오갈 때마다 다시 받으면 요청만 늘고 화면은 그대로다.
      final repo = _RoomsOnlyRepository([_room(1)]);
      final h = _tabHarness(repo);

      await tester.pumpWidget(h.tree(onTab: true));
      await tester.pumpAndSettle();
      await tester.pumpWidget(h.tree(onTab: false));
      await tester.pumpAndSettle();
      await tester.pumpWidget(h.tree(onTab: true));
      await tester.pumpAndSettle();

      expect(repo.getRoomsCalls, 1);
    });

    testWidgets('keeps_showing_the_cached_list_while_refetching', (
      tester,
    ) async {
      // 다시 받는 동안 스피너로 갈아치우면 탭을 옮길 때마다 화면이 깜빡인다.
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

      final h = _tabHarness(repo);
      await tester.pumpWidget(h.tree(onTab: true));
      await tester.pumpAndSettle();
      await tester.pumpWidget(h.tree(onTab: false));
      await tester.pumpAndSettle();

      h.advance(const Duration(minutes: 4));
      repo.delay = const Duration(milliseconds: 200);
      await tester.pumpWidget(h.tree(onTab: true));
      await tester.pump();

      // 아직 응답 전인데도 캐시된 칸이 그대로 보인다.
      expect(find.text('도착한 분 계신가요?'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // 지연 타이머를 흘려 보낸다 — 남겨 두면 트리 정리 때 터진다.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    });
  });
}
