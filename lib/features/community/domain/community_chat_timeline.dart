// lib/features/community/domain/community_chat_timeline.dart
import 'entities/community_chat_message_entity.dart';

/// 채팅방 타임라인 — 최신순 불변 리스트와 그 병합 규칙
///
/// 저장 순서가 최신순인 이유: 서버 페이지가 최신순이고 화면이 reverse ListView라
/// 그대로 쓰면 뒤집을 일이 없다. 실시간 수신은 맨 앞, 이전 페이지는 맨 뒤.
/// 모든 메서드는 새 인스턴스를 돌려준다(원본 불변).
class CommunityChatTimeline {
  const CommunityChatTimeline(this.messages);
  const CommunityChatTimeline.empty() : messages = const [];

  final List<CommunityChatMessageEntity> messages;

  /// 실시간 수신. 내 pending과 키가 같으면 그 자리를 서버 값으로 확정하고,
  /// 같은 id가 이미 있으면 버린다 — 재연결 뒤 첫 페이지를 다시 받아 섞어도 안전하다.
  CommunityChatTimeline receive(CommunityChatMessageEntity incoming) {
    final pendingIndex = messages.indexWhere(
      (m) =>
          m.status != CommunityChatMessageStatus.sent &&
          m.messageKey == incoming.messageKey,
    );
    if (pendingIndex != -1) {
      final next = [...messages];
      next[pendingIndex] = incoming;
      return CommunityChatTimeline(next);
    }
    if (incoming.id != null && messages.any((m) => m.id == incoming.id)) {
      return this;
    }
    return CommunityChatTimeline([incoming, ...messages]);
  }

  /// 이전 페이지를 뒤에 붙인다. 이미 있는 id는 건너뛴다.
  CommunityChatTimeline appendOlder(List<CommunityChatMessageEntity> older) {
    final known = messages.map((m) => m.id).whereType<int>().toSet();
    final fresh = older.where((m) => m.id == null || !known.contains(m.id));
    return CommunityChatTimeline([...messages, ...fresh]);
  }

  /// 재연결 뒤 다시 받은 첫 페이지(최신순)를 섞는다 — 끊긴 동안의 공백을 메운다.
  /// 오래된 것부터 [receive]하면 순서가 최신순으로 유지된다.
  CommunityChatTimeline mergeLatest(List<CommunityChatMessageEntity> latest) {
    return latest.reversed.fold(this, (t, m) => t.receive(m));
  }

  CommunityChatTimeline addPending(CommunityChatMessageEntity m) =>
      CommunityChatTimeline([m, ...messages]);

  CommunityChatTimeline setStatus(
    String messageKey,
    CommunityChatMessageStatus status,
  ) => CommunityChatTimeline([
    for (final m in messages)
      if (m.messageKey == messageKey) m.copyWith(status: status) else m,
  ]);

  /// 연결이 끊기면 확정을 기다리던 것은 전부 실패로 — 탭해서 같은 키로 다시 보낸다.
  CommunityChatTimeline failAllPending() => CommunityChatTimeline([
    for (final m in messages)
      if (m.isPending)
        m.copyWith(status: CommunityChatMessageStatus.failed)
      else
        m,
  ]);
}

/// 시스템 메시지가 인원수에 주는 변화. 서버가 인원수를 실시간으로 주지 않아
/// JOIN/LEAVE/KICK으로 로컬 보정한다. 강퇴도 사람이 줄어드는 사건이다.
/// 이벤트를 전부 열거한다 — 기본값으로 흘리면 새 이벤트가 0으로 조용히 묻혀
/// 헤더 인원수만 어긋난다. 컴파일이 먼저 깨지는 편이 낫다.
int memberDelta(CommunityChatMessageEntity m) => switch (m.body) {
  CommunityChatSystemBody(:final event) => switch (event) {
    CommunityChatSystemEvent.join => 1,
    CommunityChatSystemEvent.leave => -1,
    CommunityChatSystemEvent.kick => -1,
    // 공지 등록·수정·삭제는 사람이 드나든 사건이 아니다.
    CommunityChatSystemEvent.pinRegistered => 0,
    CommunityChatSystemEvent.pinUpdated => 0,
    CommunityChatSystemEvent.pinDeleted => 0,
  },
  _ => 0,
};
