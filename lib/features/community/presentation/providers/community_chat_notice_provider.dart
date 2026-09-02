import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/community_chat_event.dart';
import '../../domain/entities/community_chat_notice_entity.dart';
import 'community_chat_rooms_provider.dart';
import 'community_chat_socket_provider.dart';

part 'community_chat_notice_provider.g.dart';

/// 채팅방 고정 공지 — 화면을 열 때마다 새로 받는다(autoDispose)
///
/// 방마다 하나뿐이고 이력이 없으므로(DEC-0054) 상태는 `있음(엔티티)` 또는
/// `없음(null)` 둘뿐이다. 서버가 없음을 200 + 필드 null로 주는 것을 저장소가
/// null로 접어 준다 — 여기서 404를 다룰 일은 없다.
///
/// 전용 소켓 채널(DEC-0055)이 "바뀌었다"만 알려 오면 내용을 다시 받는다. 그
/// payload에는 작성자 프로필 아이콘도 등록 시각도 없어 그대로 상태에 넣으면
/// 실시간 갱신 때만 아바타가 비기 때문이다.
@riverpod
class CommunityChatNotice extends _$CommunityChatNotice {
  StreamSubscription<CommunityChatEvent>? _sub;
  bool _disposed = false;

  @override
  Future<CommunityChatNoticeEntity?> build(int postId) {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _sub?.cancel();
    });
    _listen();
    return ref.watch(communityChatRepositoryProvider).getNotice(postId);
  }

  /// 등록·수정은 저장한 결과를 그대로 상태로 삼는다 — 서버 응답이 정본이라
  /// 방금 쓴 글을 다시 받아올 이유가 없다.
  Future<void> register(String content) async {
    final saved = await ref
        .read(communityChatRepositoryProvider)
        .registerNotice(postId, content);
    if (_disposed) return;
    state = AsyncData(saved);
  }

  /// 이름이 `update`가 아닌 이유: `AsyncNotifier.update`와 시그니처가 부딪힌다.
  Future<void> edit(String content) async {
    final saved = await ref
        .read(communityChatRepositoryProvider)
        .updateNotice(postId, content);
    if (_disposed) return;
    state = AsyncData(saved);
  }

  Future<void> delete() async {
    await ref.read(communityChatRepositoryProvider).deleteNotice(postId);
    if (_disposed) return;
    state = const AsyncData(null);
  }

  void _listen() {
    _sub?.cancel();
    // 소켓 자체는 로그인 수명이다 — 여기서는 흐르는 이벤트만 듣는다.
    _sub = ref
        .read(communityChatSocketProvider.notifier)
        .events
        .listen(_onEvent);
  }

  void _onEvent(CommunityChatEvent event) {
    // 방 채널은 하나가 아니다 — 다른 방의 공지 변경까지 받아 다시 조회하면
    // 화면과 무관한 요청이 는다.
    if (event is! CommunityChatNoticeChangedEvent) return;
    if (event.postId != postId || _disposed) return;
    unawaited(_refetch());
  }

  Future<void> _refetch() async {
    try {
      final fresh = await ref
          .read(communityChatRepositoryProvider)
          .getNotice(postId);
      if (_disposed) return;
      state = AsyncData(fresh);
    } on AppException catch (e) {
      // 사용자가 시킨 조회가 아니다 — 보던 공지를 그대로 두고 다음 신호를 기다린다.
      debugPrint('[채팅 공지] ⚠️ 실시간 갱신 실패 — 보던 내용 유지: ${e.message}');
    }
  }
}
