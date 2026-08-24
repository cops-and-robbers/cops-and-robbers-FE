import 'dart:async';

import 'package:cops_and_robbers/features/community/domain/entities/community_chat_event.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_member_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_page_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_room_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_chat_repository.dart';

/// 소켓을 손으로 조종하는 가짜 저장소 — 시스템 경계(서버)만 가짜다.
class FakeCommunityChatRepository implements CommunityChatRepository {
  final calls = <String>[];
  StreamController<CommunityChatEvent>? controller;

  /// true면 연결 직후 끊김을 보낸다 — 재연결 정책 검증용
  bool connectEmitsDisconnected = false;
  List<CommunityChatMessageEntity> firstPage = [];
  List<CommunityChatMessageEntity> olderPage = [];

  void emit(CommunityChatEvent e) => controller!.add(e);

  @override
  Stream<CommunityChatEvent> connect(int postId) {
    calls.add('connect');
    controller?.close();
    final c = StreamController<CommunityChatEvent>.broadcast();
    controller = c;
    scheduleMicrotask(() {
      if (c.isClosed) return;
      c.add(
        CommunityChatEvent.connection(
          connectEmitsDisconnected
              ? CommunityChatConnectionState.disconnected
              : CommunityChatConnectionState.connected,
        ),
      );
    });
    return c.stream;
  }

  @override
  Future<CommunityChatPageEntity> getMessages(
    int postId, {
    int? cursor,
    int size = 30,
  }) async {
    if (cursor == null) {
      return CommunityChatPageEntity(
        messages: firstPage,
        nextCursor: olderPage.isEmpty ? null : olderPage.first.id,
        hasNext: olderPage.isNotEmpty,
      );
    }
    return CommunityChatPageEntity(
      messages: olderPage,
      nextCursor: null,
      hasNext: false,
    );
  }

  /// 내 채팅방 목록. 기본값은 42번 방 하나(인원 8).
  List<CommunityChatRoomEntity> rooms = [
    CommunityChatRoomEntity(
      postId: 42,
      title: '방',
      status: CommunityPostStatus.recruiting,
      meetingAt: DateTime(2026, 9, 1),
      memberCount: 8,
    ),
  ];
  List<CommunityChatMemberEntity> members = const [];
  String? notice;

  @override
  Future<List<CommunityChatRoomEntity>> getRooms() async => rooms;

  @override
  Future<List<CommunityChatMemberEntity>> getMembers(int postId) async =>
      members;

  @override
  Future<String?> getNotice(int postId) async => notice;

  @override
  Future<void> setNotice(int postId, String notice) async {
    calls.add('setNotice:$notice');
    this.notice = notice;
  }

  @override
  Future<void> join(int postId) async => calls.add('join');

  @override
  Future<void> leave(int postId) async => calls.add('leave');

  @override
  Future<void> send(
    int postId, {
    required String messageKey,
    required String text,
  }) async => calls.add('send:$messageKey');

  @override
  Future<void> disconnect() async {
    calls.add('disconnect');
    await controller?.close();
  }
}
