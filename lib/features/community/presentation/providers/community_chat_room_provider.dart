import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/community_chat_timeline.dart';
import '../../domain/entities/community_chat_event.dart';
import '../../domain/entities/community_chat_message_entity.dart';
import '../../domain/repositories/community_chat_repository.dart';
import 'community_chat_rooms_provider.dart';
import 'community_chat_socket_provider.dart';
import 'community_provider.dart';

part 'community_chat_room_provider.freezed.dart';
part 'community_chat_room_provider.g.dart';

/// 채팅방 화면이 그리는 것 전부
@freezed
class CommunityChatRoomState with _$CommunityChatRoomState {
  const factory CommunityChatRoomState({
    required CommunityChatTimeline timeline,
    @Default(CommunityChatConnectionState.connecting)
    CommunityChatConnectionState connection,

    /// 목록(`GET /chat/rooms`)에서 찾은 인원수. 못 찾으면 null — 헤더가 정원만 그린다.
    int? memberCount,
    int? nextCursor,
    @Default(false) bool hasNext,
    @Default(false) bool loadingOlder,

    /// 방 멤버가 아니라는 소켓 에러(다른 기기에서 나감). 화면이 목록으로 나간다.
    @Default(false) bool evicted,

    /// 가장 최근 소켓 에러 코드. [errorSeq]가 바뀔 때마다 화면이 한 번 알린다.
    String? lastErrorCode,
    @Default(0) int errorSeq,
  }) = _CommunityChatRoomState;
}

/// 채팅방 하나의 상태 — 방 구독·타임라인·인원수·읽음·나가기
///
/// 소켓은 여기서 열지 않는다. 로그인 수명의 `CommunityChatSocket`이 열어 두고,
/// 이 Notifier는 제 방을 **구독**만 한다 — dispose면 구독만 풀린다("보고 있는
/// 방만 구독", DEC-0026 계약 02·03). 재연결·재연결 소진·인증 에러는 소켓
/// Notifier의 일이고, 여기서는 그 결과(연결 상태 전이)만 받아 띠·전송 가드·
/// 끊긴 동안의 공백 메우기를 한다.
@riverpod
class CommunityChatRoomNotifier extends _$CommunityChatRoomNotifier {
  static const pageSize = 30;

  StreamSubscription<CommunityChatEvent>? _sub;
  bool _disposed = false;

  /// 끊겼다가 다시 붙는 중 — 붙으면 첫 페이지를 다시 받아 공백을 메운다.
  bool _dropped = false;

  /// 마지막으로 서버에 보낸 읽음 커서. 같은 값은 다시 보내지 않는다.
  int? _lastReadSent;

  /// 첫 페이지를 받는 동안 도착한 이벤트. 상태가 생기면 순서대로 반영한다.
  final List<CommunityChatEvent> _early = [];

  CommunityChatRepository get _repo =>
      ref.read(communityChatRepositoryProvider);

  @override
  Future<CommunityChatRoomState> build(int postId) async {
    // 재빌드(invalidate·저장소 교체)에도 onDispose가 돌고 인스턴스는 살아남는다 —
    // 지난 구독의 플래그를 들고 가면 새 구독의 이벤트를 전부 무시하게 된다.
    _disposed = false;
    _dropped = false;
    _lastReadSent = null;
    _early.clear();

    final repo = ref.watch(communityChatRepositoryProvider);
    final socket = ref.read(communityChatSocketProvider.notifier);
    // dispose 시점엔 컨테이너가 이미 닫히는 중일 수 있어 ref.read가 실패한다 —
    // build 스코프에서 미리 잡아둔 repo를 그대로 써서 컨테이너를 다시 건드리지 않는다.
    ref.onDispose(() {
      _disposed = true;
      _sub?.cancel();
      repo.unsubscribeRoom(postId);
    });
    repo.subscribeRoom(postId);
    _listen(socket.events);

    final page = await repo.getMessages(postId, size: pageSize);
    final memberCount = await _findMemberCount();

    var next = CommunityChatRoomState(
      timeline: CommunityChatTimeline(page.messages),
      // 소켓은 로그인 때 이미 붙어 있을 수 있다 — 그러면 연결 이벤트가 다시 오지
      // 않으므로 지금 상태를 씨앗으로 쓴다. 안 그러면 입력창이 영영 잠긴다.
      connection: ref.read(communityChatSocketProvider).connection,
      memberCount: memberCount,
      nextCursor: page.nextCursor,
      hasNext: page.hasNext,
    );
    for (final e in _early) {
      next = _apply(next, e);
    }
    final early = [..._early];
    _early.clear();
    // 부수효과는 상태가 자리 잡은 뒤에
    scheduleMicrotask(() {
      if (_disposed) return;
      early.forEach(_sideEffects);
      // 사용자가 방을 실제로 열었다 — REST 성공 여부·dedupe와 무관하게 로컬
      // 배지부터 내린다. 서버 진실은 다음 기준선 조회가 맞춘다(최종 리뷰 M-1).
      if (page.messages.isNotEmpty) {
        ref.read(communityChatRoomsProvider.notifier).clearUnread(postId);
      }
      // 열자마자 보이는 가장 최신 메시지까지 읽음 — 앱이 여기서 죽어도 배지는 내려간다.
      unawaited(_markRead(_newestServerId(next.timeline.messages)));
    });
    return next;
  }

  /// 내 말풍선은 닉네임을 그리지 않으므로 비워 보낸다 — 에코가 서버 값으로 채운다.
  Future<void> send(String text) async {
    final me = ref.read(currentUserIdProvider);
    final trimmed = text.trim();
    if (state.valueOrNull == null || me == null || trimmed.isEmpty) return;

    final pending = CommunityChatMessageEntity(
      messageKey: const Uuid().v4(),
      senderId: me,
      senderNickname: '',
      body: CommunityChatMessageBody.text(trimmed),
      createdAt: ref.read(clockProvider)(),
      status: CommunityChatMessageStatus.pending,
    );
    _update((s) => s.copyWith(timeline: s.timeline.addPending(pending)));
    await _deliver(pending);
  }

  /// 실패한 말풍선을 탭하면 같은 키로 다시 보낸다 — 서버가 같은 키를 두 번 받아도
  /// 에코 매칭은 키 기준이라 화면에 두 번 그려지지 않는다.
  Future<void> retry(String messageKey) async {
    final messages = state.valueOrNull?.timeline.messages;
    if (messages == null) return;
    final i = messages.indexWhere((m) => m.messageKey == messageKey);
    if (i == -1 || messages[i].status != CommunityChatMessageStatus.failed) {
      return;
    }
    _update(
      (s) => s.copyWith(
        timeline: s.timeline.setStatus(
          messageKey,
          CommunityChatMessageStatus.pending,
        ),
      ),
    );
    await _deliver(messages[i]);
  }

  Future<void> _deliver(CommunityChatMessageEntity m) async {
    final body = m.body;
    if (body is! CommunityChatTextBody) return;
    try {
      await _repo.send(postId, messageKey: m.messageKey, text: body.text);
    } on AppException catch (e) {
      debugPrint('[CommunityChatRoom] ❌ 전송 실패: ${e.message}');
      _update(
        (s) => s.copyWith(
          timeline: s.timeline.setStatus(
            m.messageKey,
            CommunityChatMessageStatus.failed,
          ),
        ),
      );
    }
  }

  /// 위로 끝까지 올렸을 때. 실패는 호출자가 알린다(스낵바).
  Future<void> loadOlder() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.loadingOlder) return;

    _update((s) => s.copyWith(loadingOlder: true));
    try {
      final page = await _repo.getMessages(
        postId,
        cursor: current.nextCursor,
        size: pageSize,
      );
      _update(
        (s) => s.copyWith(
          timeline: s.timeline.appendOlder(page.messages),
          nextCursor: page.nextCursor,
          hasNext: page.hasNext,
          loadingOlder: false,
        ),
      );
    } on AppException {
      _update((s) => s.copyWith(loadingOlder: false));
      rethrow;
    }
  }

  /// 나가기. 순서 고정: leave 성공 → 방 구독 해제(UNSUBSCRIBE). 서버는 구독 시점에만
  /// 자격을 보므로 풀지 않으면 나간 방 메시지가 계속 온다. 실패는 호출자가 알린다.
  Future<void> leave() async {
    // await 사이에 저장소 provider가 재계산돼도 같은 인스턴스로 끝낸다.
    final repo = _repo;
    await repo.leave(postId);
    _sub?.cancel();
    repo.unsubscribeRoom(postId);
    ref.invalidate(communityChatRoomsProvider);
  }

  /// 띠의 "다시 연결". 소켓은 로그인 수명이라 소켓 Notifier가 붙인다.
  void reconnectNow() =>
      ref.read(communityChatSocketProvider.notifier).reconnectNow();

  /// 화면을 떠날 때(PopScope `didPop`). 머무는 동안 새 메시지가 왔을 때만 한 번 더
  /// 읽음을 보낸다 — 진입 때 보낸 것과 같으면 요청을 아낀다.
  ///
  /// `await` 뒤에 `ref`를 쓰지 않는다(LSN-0021) — 이 호출은 pop 도중이라 곧
  /// dispose된다. 필요한 것은 전부 `await` 전에 잡는다.
  Future<void> markReadOnExit() async {
    final id = _newestServerId(
      state.valueOrNull?.timeline.messages ?? const [],
    );
    if (id == null || (_lastReadSent != null && id <= _lastReadSent!)) return;
    final repo = _repo;
    final rooms = ref.read(communityChatRoomsProvider.notifier);
    final previous = _lastReadSent;
    _lastReadSent = id;
    try {
      await repo.markRead(postId, id);
    } on AppException catch (e) {
      // 실패한 전송을 성공으로 기억하면 재시도가 dedupe(위 가드)에 막혀 서버
      // 커서가 영영 안 옮겨진다 — 되돌려서 다음 기회가 같은 id로 다시 붙게 한다.
      _lastReadSent = previous;
      // 화면은 이미 떠났다. 로컬 0은 다음 목록 조회가 서버 값으로 되돌린다.
      debugPrint('[CommunityChatRoom] ⚠️ 이탈 읽음 처리 실패: ${e.message}');
      return;
    }
    rooms.clearUnread(postId);
  }

  // ── 소켓 이벤트 ────────────────────────────────────────────────

  void _listen(Stream<CommunityChatEvent> stream) {
    _sub?.cancel();
    _sub = stream.listen(
      _onEvent,
      onError: (Object e) {
        debugPrint('[CommunityChatRoom] ⚠️ 스트림 에러: $e');
        _onEvent(
          const CommunityChatEvent.connection(
            CommunityChatConnectionState.disconnected,
          ),
        );
      },
      onDone: () => _onEvent(
        const CommunityChatEvent.connection(
          CommunityChatConnectionState.disconnected,
        ),
      ),
    );
  }

  void _onEvent(CommunityChatEvent event) {
    if (_disposed) return;
    // 개인 채널은 모든 방의 메시지를 한 구독으로 보낸다 — 제 방 것만 받는다.
    if (event is CommunityChatMessageEvent && event.postId != postId) return;
    final current = state.valueOrNull;
    if (current == null) {
      _early.add(event);
      return;
    }
    state = AsyncData(_apply(current, event));
    _sideEffects(event);
  }

  CommunityChatRoomState _apply(
    CommunityChatRoomState s,
    CommunityChatEvent e,
  ) => switch (e) {
    CommunityChatMessageEvent(:final message) => s.copyWith(
      timeline: s.timeline.receive(message),
      memberCount: s.memberCount == null
          ? null
          : s.memberCount! + memberDelta(message),
      // 내가 강퇴당한 것도 방에서 밀려나는 사건이다 — 화면이 목록으로 나간다.
      evicted: s.evicted || _isKickOfMe(message),
    ),
    CommunityChatConnectionEvent(
      state: CommunityChatConnectionState.connected,
    ) =>
      s.copyWith(connection: CommunityChatConnectionState.connected),
    CommunityChatConnectionEvent(
      state: CommunityChatConnectionState.disconnected,
    ) =>
      s.copyWith(
        connection: CommunityChatConnectionState.disconnected,
        timeline: s.timeline.failAllPending(),
      ),
    CommunityChatConnectionEvent() => s.copyWith(
      connection: CommunityChatConnectionState.connecting,
    ),
    CommunityChatErrorEvent(errorCode: 'NOT_A_CHAT_MEMBER') => s.copyWith(
      evicted: true,
    ),
    CommunityChatErrorEvent(:final errorCode) => s.copyWith(
      lastErrorCode: errorCode,
      errorSeq: s.errorSeq + 1,
    ),
  };

  void _sideEffects(CommunityChatEvent e) {
    switch (e) {
      case CommunityChatConnectionEvent(
        state: CommunityChatConnectionState.connected,
      ):
        if (_dropped) {
          _dropped = false;
          unawaited(_refetchLatest());
        }
      case CommunityChatConnectionEvent(
        state: CommunityChatConnectionState.disconnected,
      ):
        _dropped = true;
      case CommunityChatErrorEvent(errorCode: 'NOT_A_CHAT_MEMBER'):
        // 다른 기기에서 나갔거나 방이 지워졌다 — 구독을 풀어 다시 거절당하지 않는다.
        _evict();
      case CommunityChatMessageEvent(:final message):
        if (_isKickOfMe(message)) {
          // 서버가 강퇴당한 쪽 세션을 끊지 않는다 — 스스로 구독을 풀지 않으면
          // 나간 방의 메시지가 계속 들어온다(전송만 막힌다).
          _evict();
        }
      default:
        break;
    }
  }

  bool _isKickOfMe(CommunityChatMessageEntity m) =>
      m.body ==
          const CommunityChatMessageBody.system(
            CommunityChatSystemEvent.kick,
          ) &&
      m.senderId == ref.read(currentUserIdProvider);

  void _evict() {
    _repo.unsubscribeRoom(postId);
    // leave()와 축을 맞춘다 — 안 하면 밀려난 방이 배지를 단 채 목록에 남고
    // 탭하면 403이 된다(최종 리뷰 I-3).
    ref.invalidate(communityChatRoomsProvider);
  }

  /// 재연결 직후 첫 페이지를 다시 받아 끊긴 동안의 메시지를 메운다.
  Future<void> _refetchLatest() async {
    try {
      final page = await _repo.getMessages(postId, size: pageSize);
      _update(
        (s) => s.copyWith(timeline: s.timeline.mergeLatest(page.messages)),
      );
    } on AppException catch (e) {
      // 다음 실시간 수신으로 이어지므로 화면을 멈추지 않는다.
      debugPrint('[CommunityChatRoom] ⚠️ 재연결 후 재조회 실패: ${e.message}');
    }
  }

  /// 타임라인은 최신순이다. 내 pending 말풍선(id 없음)을 건너뛴 첫 서버 id가 최신.
  static int? _newestServerId(List<CommunityChatMessageEntity> messages) {
    for (final m in messages) {
      if (m.id != null) return m.id;
    }
    return null;
  }

  Future<void> _markRead(int? id) async {
    if (id == null || _disposed) return;
    if (_lastReadSent != null && id <= _lastReadSent!) return;
    final repo = _repo;
    final rooms = ref.read(communityChatRoomsProvider.notifier);
    final previous = _lastReadSent;
    _lastReadSent = id;
    try {
      await repo.markRead(postId, id);
    } on AppException catch (e) {
      // 실패한 전송을 성공으로 기억하면 재시도가 dedupe(위 가드)에 막혀 서버
      // 커서가 영영 안 옮겨진다 — 되돌려서 다음 기회가 같은 id로 다시 붙게 한다.
      _lastReadSent = previous;
      // 실패해도 방은 열려 있어야 한다. 배지는 다음 목록 조회가 서버 값으로 맞춘다.
      debugPrint('[CommunityChatRoom] ⚠️ 읽음 처리 실패: ${e.message}');
      return;
    }
    rooms.clearUnread(postId);
  }

  /// 방금 참여한 방은 캐시된 목록에 없다 — 한 번 새로 받는다. 목록 조회가
  /// 실패해도 방은 열려야 하므로 null로 물러선다.
  Future<int?> _findMemberCount() async {
    try {
      var rooms = await ref.read(communityChatRoomsProvider.future);
      if (!rooms.any((r) => r.postId == postId)) {
        await ref.read(communityChatRoomsProvider.notifier).refresh();
        rooms = await ref.read(communityChatRoomsProvider.future);
      }
      for (final r in rooms) {
        if (r.postId == postId) return r.memberCount;
      }
    } on AppException catch (e) {
      debugPrint('[CommunityChatRoom] ⚠️ 인원수 조회 실패: ${e.message}');
    }
    return null;
  }

  void _update(CommunityChatRoomState Function(CommunityChatRoomState) fn) {
    if (_disposed) return;
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(fn(current));
  }
}
