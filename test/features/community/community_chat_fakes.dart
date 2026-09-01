import 'dart:async';

import 'package:cops_and_robbers/features/community/domain/entities/community_chat_event.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_member_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_message_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_page_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_room_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_chat_repository.dart';

/// 소켓을 손으로 조종하는 가짜 저장소 — 시스템 경계(서버)만 가짜다.
///
/// 소켓은 로그인 시점에 하나 열린다(`connect(userId)`). 방은 `subscribeRoom`으로
/// 드나들고, 메시지는 [emitMessage]로 흘려 넣는다(기본 42번 방).
class FakeCommunityChatRepository implements CommunityChatRepository {
  final calls = <String>[];
  StreamController<CommunityChatEvent>? controller;

  /// true면 연결 직후 끊김을 보낸다 — 재연결 정책 검증용
  bool connectEmitsDisconnected = false;

  /// true면 connect가 스트림만 주고 아무 이벤트도 안 낸다 — connecting 고착
  /// 워치독 검증용. controller는 그대로 만드니 emit 헬퍼는 계속 쓸 수 있다.
  bool connectEmitsNothing = false;
  List<CommunityChatMessageEntity> firstPage = [];
  List<CommunityChatMessageEntity> olderPage = [];

  /// 던지면 markRead / setNotification이 실패한다
  Object? markReadError;
  Object? setNotificationError;

  /// non-null이면 getRooms가 반환 전에 이 future를 기다린다 — 로드 중 타이밍 검증용
  Future<void>? roomsGate;

  void emit(CommunityChatEvent e) => controller!.add(e);

  void emitMessage(CommunityChatMessageEntity m, {int postId = 42}) =>
      emit(CommunityChatEvent.message(postId, m));

  @override
  Stream<CommunityChatEvent> connect(int userId) {
    calls.add('connect:$userId');
    controller?.close();
    final c = StreamController<CommunityChatEvent>.broadcast();
    controller = c;
    if (!connectEmitsNothing) {
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
    }
    return c.stream;
  }

  @override
  Future<void> disconnect() async {
    calls.add('disconnect');
    await controller?.close();
  }

  @override
  void subscribeRoom(int postId) => calls.add('subscribeRoom:$postId');

  @override
  void unsubscribeRoom(int postId) => calls.add('unsubscribeRoom:$postId');

  @override
  Future<CommunityChatPageEntity> getMessages(
    int postId, {
    int? cursor,
    int size = 30,
  }) async {
    calls.add('getMessages');
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
  CommunityChatMembersEntity members = const CommunityChatMembersEntity(
    members: [],
  );

  @override
  Future<List<CommunityChatRoomEntity>> getRooms() async {
    calls.add('getRooms');
    if (roomsGate != null) await roomsGate;
    return rooms;
  }

  @override
  Future<CommunityChatMembersEntity> getMembers(int postId) async => members;

  @override
  Future<void> join(int postId) async => calls.add('join');

  @override
  Future<void> leave(int postId) async => calls.add('leave');

  @override
  Future<void> markRead(int postId, int lastReadMessageId) async {
    calls.add('markRead:$postId:$lastReadMessageId');
    if (markReadError != null) throw markReadError!;
  }

  @override
  Future<void> setNotification(int postId, {required bool enabled}) async {
    calls.add('setNotification:$postId:$enabled');
    if (setNotificationError != null) throw setNotificationError!;
  }

  @override
  Future<void> send(
    int postId, {
    required String messageKey,
    required String text,
  }) async => calls.add('send:$messageKey');

  @override
  bool sendGameInvite(
    int postId, {
    required String messageKey,
    required String inviteCode,
  }) {
    calls.add('sendGameInvite:$postId:$inviteCode');
    return true;
  }
}
