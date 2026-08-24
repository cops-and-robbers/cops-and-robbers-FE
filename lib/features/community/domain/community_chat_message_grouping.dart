// lib/features/community/domain/community_chat_message_grouping.dart
import 'entities/community_chat_message_entity.dart';

typedef ChatGroupFlags = ({bool showNickname, bool showTime});

/// 최신순 리스트의 [index] 메시지가 닉네임·시각을 그릴지 판정한다.
///
/// 같은 발신자 말풍선이 연달아 오면 닉네임은 묶음의 첫 줄(화면상 위 = index+1 쪽이
/// 다른 발신자)에만, 시각은 묶음의 마지막 줄(화면상 아래 = index-1 쪽이 다른
/// 발신자이거나 분이 바뀜)에만 그린다. 시스템·초대·unknown은 말풍선이 아니라
/// 묶음을 끊는다. 게임 채팅(`chat_message_list.dart`)과 같은 규칙에 "분 변화"만 더했다.
ChatGroupFlags groupFlagsAt(
  List<CommunityChatMessageEntity> newestFirst,
  int index,
) {
  final m = newestFirst[index];
  final older = index + 1 < newestFirst.length ? newestFirst[index + 1] : null;
  final newer = index > 0 ? newestFirst[index - 1] : null;

  bool sameSender(CommunityChatMessageEntity a, CommunityChatMessageEntity b) =>
      a.isBubble && b.isBubble && a.senderId == b.senderId;
  bool sameMinute(CommunityChatMessageEntity a, CommunityChatMessageEntity b) =>
      a.createdAt.hour == b.createdAt.hour &&
      a.createdAt.minute == b.createdAt.minute;

  return (
    showNickname: older == null || !sameSender(older, m),
    showTime: newer == null || !sameSender(m, newer) || !sameMinute(m, newer),
  );
}
