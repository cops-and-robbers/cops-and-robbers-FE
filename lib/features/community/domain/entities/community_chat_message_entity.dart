import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_chat_message_entity.freezed.dart';

/// 서버 `SYSTEM` 메시지의 `{"event":"JOIN"|"LEAVE"|"KICK"}`
///
/// [kick]은 방장이 내보낸 경우다. 서버가 강퇴당한 쪽 소켓 세션을 끊지 않으므로
/// (Swagger 명시) 본인이 이 메시지를 보고 스스로 구독을 해제해야 한다 — 안 하면
/// 나간 방의 메시지가 계속 들어온다.
enum CommunityChatSystemEvent { join, leave, kick }

/// 내가 보낸 메시지의 확정 상태. 서버·남이 보낸 것은 항상 [sent]다.
enum CommunityChatMessageStatus { pending, sent, failed }

/// 메시지 본문 — 와이어 `messageType`에 따라 `message`를 다르게 읽은 결과
///
/// [unknown]은 앱이 모르는 타입이다. 파싱 실패로 화면이 통째로 에러가 되지 않게
/// 접어 두고 화면에서는 숨긴다 — `ENDED` 상태가 추가됐을 때 목록이 통째로 깨진
/// 전례가 있다(`community_wire.dart`).
@freezed
sealed class CommunityChatMessageBody with _$CommunityChatMessageBody {
  const factory CommunityChatMessageBody.text(String text) =
      CommunityChatTextBody;
  const factory CommunityChatMessageBody.system(
    CommunityChatSystemEvent event,
  ) = CommunityChatSystemBody;
  const factory CommunityChatMessageBody.gameInvite(String inviteCode) =
      CommunityChatGameInviteBody;
  const factory CommunityChatMessageBody.unknown() = CommunityChatUnknownBody;
}

/// 채팅 메시지 한 건
///
/// [id]는 서버가 저장 후 발급한다 — 내가 방금 보낸 [CommunityChatMessageStatus.pending]
/// 메시지는 아직 null이고, 에코가 같은 [messageKey]로 돌아오면 채워진다.
/// [senderNickname]은 조회 시점의 현재 닉네임이다(탈퇴자만 발신 당시 닉네임).
@freezed
class CommunityChatMessageEntity with _$CommunityChatMessageEntity {
  const CommunityChatMessageEntity._();

  const factory CommunityChatMessageEntity({
    int? id,
    required String messageKey,
    required int senderId,
    required String senderNickname,

    /// 프로필 아이콘 번호. 서버가 안 줬으면 null — 화면이 기본 아이콘을 쓴다.
    int? senderProfileIcon,
    required CommunityChatMessageBody body,
    required DateTime createdAt,
    @Default(CommunityChatMessageStatus.sent) CommunityChatMessageStatus status,

    /// 와이어 `messageType == 'SYSTEM'`. 본문 타입으로 판정하지 않는 이유: 파서는
    /// 모르는 시스템 이벤트를 `unknown` 본문으로 접는데, 서버의 안 읽은 개수 집계는
    /// `messageType`으로만 제외한다 — 본문으로 세면 그 경우 숫자가 어긋난다.
    @Default(false) bool isSystem,
  }) = _CommunityChatMessageEntity;

  /// 말풍선으로 그리는 메시지인가 (TEXT만). 시스템 pill·초대 카드·unknown은 아니다.
  bool get isBubble => body is CommunityChatTextBody;

  bool get isPending => status == CommunityChatMessageStatus.pending;

  /// 안 읽은 개수에 세는 메시지인가 — 서버 집계 규칙의 절반, 와이어 타입
  /// (`messageType != SYSTEM`) 하나만 본다. 나머지 절반(`senderId != 나`)은
  /// 내 id를 아는 목록 Notifier가 판정한다(최종 리뷰 M-3).
  bool get countsAsUnread => !isSystem;
}
