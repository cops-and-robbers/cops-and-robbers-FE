import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_chat_message_entity.freezed.dart';

/// 서버 `SYSTEM` 메시지의 `{"event":"JOIN"|"LEAVE"}`
enum CommunityChatSystemEvent { join, leave }

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
    required CommunityChatMessageBody body,
    required DateTime createdAt,
    @Default(CommunityChatMessageStatus.sent) CommunityChatMessageStatus status,
  }) = _CommunityChatMessageEntity;

  /// 말풍선으로 그리는 메시지인가 (TEXT만). 시스템 pill·초대 카드·unknown은 아니다.
  bool get isBubble => body is CommunityChatTextBody;

  bool get isPending => status == CommunityChatMessageStatus.pending;
}
