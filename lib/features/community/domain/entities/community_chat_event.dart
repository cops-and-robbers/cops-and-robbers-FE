import 'package:freezed_annotation/freezed_annotation.dart';

import 'community_chat_message_entity.dart';

part 'community_chat_event.freezed.dart';

enum CommunityChatConnectionState { connecting, connected, disconnected }

/// 저장소 `connect()` 스트림으로 오는 것 전부 — 메시지·연결 상태·소켓 에러
///
/// 셋을 한 스트림에 싣는 이유: Notifier가 구독 하나만 들고 있으면 되고, 목이
/// 소켓을 흉내 낼 때도 컨트롤러 하나면 된다.
@freezed
sealed class CommunityChatEvent with _$CommunityChatEvent {
  /// 어느 방의 메시지인지 [postId]로 가른다 — 유저당 알림 채널은 모든 방의
  /// 메시지를 한 구독으로 보내므로 방 Notifier는 제 방 것만 골라 받는다.
  const factory CommunityChatEvent.message(
    int postId,
    CommunityChatMessageEntity message,
  ) = CommunityChatMessageEvent;
  const factory CommunityChatEvent.connection(
    CommunityChatConnectionState state,
  ) = CommunityChatConnectionEvent;

  /// 이 방의 고정 공지가 등록·수정·삭제됐다(DEC-0055의 전용 채널).
  ///
  /// 내용을 싣지 않는 이유: 배너 payload에는 작성자 프로필 아이콘도 등록 시각도
  /// 없다. 반쪽 엔티티를 올리면 실시간 갱신 때만 아바타가 비는 화면이 된다 —
  /// 신호만 나르고 내용은 화면이 REST로 다시 받는다.
  const factory CommunityChatEvent.noticeChanged(int postId) =
      CommunityChatNoticeChangedEvent;

  /// STOMP ERROR 프레임의 `errorCode` (예: `NOT_A_CHAT_MEMBER`)
  const factory CommunityChatEvent.error(String errorCode) =
      CommunityChatErrorEvent;
}
