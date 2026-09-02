import 'package:freezed_annotation/freezed_annotation.dart';

import 'community_chat_message_entity.dart';

part 'community_chat_page_entity.freezed.dart';

/// 이전 대화 한 페이지 (`GET /chat/messages`)
///
/// [messages]는 최신순이다. [hasNext]가 true일 때만 [nextCursor]로 다음을 받는다.
@freezed
class CommunityChatPageEntity with _$CommunityChatPageEntity {
  const factory CommunityChatPageEntity({
    required List<CommunityChatMessageEntity> messages,
    required int? nextCursor,
    required bool hasNext,
  }) = _CommunityChatPageEntity;
}
