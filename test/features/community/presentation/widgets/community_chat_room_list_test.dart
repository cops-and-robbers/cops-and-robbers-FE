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

  @override
  Future<List<CommunityChatRoomEntity>> getRooms() async {
    getRoomsCalls++;
    return rooms;
  }

  @override
  Stream<CommunityChatEvent> connect(int postId) => const Stream.empty();
  @override
  Future<void> disconnect() async {}
  @override
  Future<List<CommunityChatMemberEntity>> getMembers(int postId) async =>
      const [];
  @override
  Future<String?> getNotice(int postId) => throw UnimplementedError();
  @override
  Future<void> setNotice(int postId, String notice) =>
      throw UnimplementedError();
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
  });
}
