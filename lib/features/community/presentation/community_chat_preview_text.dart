import '../../../core/services/content_filter/profanity_filter.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/community_chat_message_entity.dart';
import '../domain/entities/community_chat_room_entity.dart';

/// 내 채팅방 목록의 마지막 메시지 한 줄
///
/// 시스템 메시지는 본문에 이름이 없다(서버가 닉네임을 저장하지 않는다 — DOC-0037).
/// 목록 응답의 `senderNickname`은 BE 이슈로 요청한 필드라 없을 수 있어, 없으면
/// 이름 없는 일반 문구로 물러선다.
String chatPreviewText(
  AppLocalizations l10n,
  CommunityChatLastMessageEntity last,
) {
  final nickname = last.senderNickname;
  return switch (last.body) {
    CommunityChatTextBody(:final text) => ProfanityFilter.filter(text),
    CommunityChatSystemBody(event: CommunityChatSystemEvent.join) =>
      nickname == null
          ? l10n.communityChatPreviewJoined
          : l10n.communityChatSystemJoined(nickname),
    CommunityChatSystemBody() =>
      nickname == null
          ? l10n.communityChatPreviewLeft
          : l10n.communityChatSystemLeft(nickname),
    CommunityChatGameInviteBody() => l10n.communityChatPreviewInvite,
    CommunityChatUnknownBody() => l10n.communityChatPreviewUnsupported,
  };
}
