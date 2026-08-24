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

    /// 방장이 붙여 둔 공지사항. 없으면 null.
    String? notice,
    int? nextCursor,
    @Default(false) bool hasNext,
    @Default(false) bool loadingOlder,

    /// 자동 재연결 5회 실패 — 띠에 "다시 연결" 버튼을 준다.
    @Default(false) bool reconnectExhausted,

    /// 방 멤버가 아니라는 소켓 에러(다른 기기에서 나감). 화면이 목록으로 나간다.
    @Default(false) bool evicted,

    /// 가장 최근 소켓 에러 코드. [errorSeq]가 바뀔 때마다 화면이 한 번 알린다.
    String? lastErrorCode,
    @Default(0) int errorSeq,
  }) = _CommunityChatRoomState;
}

/// 채팅방 하나의 상태 — 소켓 수명·타임라인·인원수·재연결·나가기
///
/// 화면 수명 소켓(spec 2절): provider가 살아 있는 동안만 연결한다. dispose면
/// 방을 나가지 않아도 끊는다 — "보고 있는 방만 구독". 재연결 정책은 게임
/// `ChatNotifier`를 그대로 옮겼다(1·2·4·8·10초, 5회). 토큰은 저장소 impl이
/// 연결 때마다 직접 얻으므로 여기서는 다시 `connect`만 부른다.
@riverpod
class CommunityChatRoomNotifier extends _$CommunityChatRoomNotifier {
  static const pageSize = 30;
  static const maxReconnectRetries = 5;

  StreamSubscription<CommunityChatEvent>? _sub;
  Timer? _reconnectTimer;
  int _reconnectCount = 0;
  bool _leaving = false;
  bool _disposed = false;

  /// 끊겼다가 다시 붙는 중 — 붙으면 첫 페이지를 다시 받아 공백을 메운다.
  bool _resumeAfterDrop = false;

  /// 첫 페이지를 받는 동안 도착한 이벤트. 상태가 생기면 순서대로 반영한다.
  final List<CommunityChatEvent> _early = [];

  CommunityChatRepository get _repo =>
      ref.read(communityChatRepositoryProvider);

  @override
  Future<CommunityChatRoomState> build(int postId) async {
    // 재빌드(invalidate·저장소 교체)에도 onDispose가 돌고 인스턴스는 살아남는다 —
    // 지난 연결의 플래그를 들고 가면 새 연결의 이벤트를 전부 무시하게 된다.
    _disposed = false;
    _leaving = false;
    _reconnectCount = 0;
    _resumeAfterDrop = false;
    _reconnectTimer?.cancel();
    _early.clear();

    final repo = ref.watch(communityChatRepositoryProvider);
    // dispose 시점엔 컨테이너가 이미 닫히는 중일 수 있어 ref.read가 실패한다 —
    // build 스코프에서 미리 잡아둔 repo를 그대로 써서 컨테이너를 다시 건드리지 않는다.
    ref.onDispose(() {
      _disposed = true;
      _reconnectTimer?.cancel();
      _sub?.cancel();
      unawaited(repo.disconnect());
    });
    _listen(repo.connect(postId));

    final page = await repo.getMessages(postId, size: pageSize);
    final memberCount = await _findMemberCount();
    final notice = await repo.getNotice(postId);

    var next = CommunityChatRoomState(
      timeline: CommunityChatTimeline(page.messages),
      memberCount: memberCount,
      notice: notice,
      nextCursor: page.nextCursor,
      hasNext: page.hasNext,
    );
    for (final e in _early) {
      next = _apply(next, e);
    }
    final early = [..._early];
    _early.clear();
    // 부수효과(재연결 예약 등)는 상태가 자리 잡은 뒤에
    scheduleMicrotask(() {
      if (_disposed) return;
      early.forEach(_sideEffects);
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

  /// 공지사항 등록/수정. 방장만 부른다(화면이 막는다). 실패는 호출자가 알린다.
  Future<void> updateNotice(String notice) async {
    final trimmed = notice.trim();
    await _repo.setNotice(postId, trimmed);
    _update((s) => s.copyWith(notice: trimmed));
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

  /// 나가기. 순서 고정: leave 성공 → disconnect(UNSUBSCRIBE). 서버는 구독 시점에만
  /// 자격을 보므로 끊지 않으면 나간 방 메시지가 계속 온다. 실패는 호출자가 알린다.
  Future<void> leave() async {
    // await 사이에 저장소 provider가 재계산돼도 같은 인스턴스로 끝낸다.
    final repo = _repo;
    _leaving = true;
    _reconnectTimer?.cancel();
    try {
      await repo.leave(postId);
    } catch (_) {
      _leaving = false;
      rethrow;
    }
    // cancel()은 구독 해제를 즉시 반영한다 — 반환 Future는 onCancel 콜백이 없어
    // 정리 완료 신호일 뿐이라 기다리지 않는다(awaiting은 스트림 컨트롤러 내부의
    // 실제 이벤트 루프 스케줄링에 걸려 fakeAsync의 마이크로태스크 플러시로 진행되지 않는다).
    _sub?.cancel();
    await repo.disconnect();
    ref.invalidate(communityChatRoomsProvider);
  }

  /// 띠의 "다시 연결"과 앱 resume. 이미 붙어 있으면 아무것도 안 한다.
  void reconnectNow() {
    if (_disposed || _leaving) return;
    if (state.valueOrNull?.connection ==
        CommunityChatConnectionState.connected) {
      return;
    }
    _reconnectTimer?.cancel();
    _reconnectCount = 0;
    _resumeAfterDrop = true;
    _update((s) => s.copyWith(reconnectExhausted: false));
    _attemptReconnect();
  }

  /// 1·2·4·8초, 최대 10초 — 게임 `ChatNotifier`와 같은 정책
  static Duration backoffDelay(int attempt) =>
      Duration(seconds: (1 << (attempt - 1)).clamp(1, 10));

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
      // 서버 쪽 구현이 끊김 이벤트 없이 스트림만 닫아도 끊긴 것으로 본다 — 안
      // 그러면 화면이 "연결됨"으로 굳는다.
      onDone: () => _onEvent(
        const CommunityChatEvent.connection(
          CommunityChatConnectionState.disconnected,
        ),
      ),
    );
  }

  void _onEvent(CommunityChatEvent event) {
    if (_disposed) return;
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
    ),
    CommunityChatConnectionEvent(
      state: CommunityChatConnectionState.connected,
    ) =>
      s.copyWith(
        connection: CommunityChatConnectionState.connected,
        reconnectExhausted: false,
      ),
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
        _reconnectCount = 0;
        if (_resumeAfterDrop) {
          _resumeAfterDrop = false;
          unawaited(_refetchLatest());
        }
      case CommunityChatConnectionEvent(
        state: CommunityChatConnectionState.disconnected,
      ):
        if (!_leaving) _scheduleReconnect();
      case CommunityChatErrorEvent(errorCode: 'NOT_A_CHAT_MEMBER'):
        // 다른 기기에서 나간 방이다 — 다시 붙어봐야 또 거절된다.
        _leaving = true;
        _reconnectTimer?.cancel();
        unawaited(_repo.disconnect());
      default:
        break;
    }
  }

  void _scheduleReconnect() {
    if (_reconnectCount >= maxReconnectRetries) {
      _update((s) => s.copyWith(reconnectExhausted: true));
      return;
    }
    _reconnectCount++;
    _resumeAfterDrop = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(backoffDelay(_reconnectCount), _attemptReconnect);
  }

  void _attemptReconnect() {
    if (_disposed || _leaving) return;
    _update(
      (s) => s.copyWith(connection: CommunityChatConnectionState.connecting),
    );
    _listen(_repo.connect(postId));
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
