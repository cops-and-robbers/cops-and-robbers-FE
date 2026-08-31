import 'package:freezed_annotation/freezed_annotation.dart';

import 'community_chat_message_entity.dart';
import 'community_post_status.dart';

part 'community_chat_room_entity.freezed.dart';

/// 내 채팅방 목록의 마지막 메시지. 대화가 없는 방은 엔티티 자체가 null이다.
///
/// [senderNickname]은 BE 이슈(`.issues/20260824_BE요청_…`)에 요청한 필드라 서버가
/// 아직 안 줄 수 있다 — null이면 미리보기가 타입별 일반 문구로 물러선다.
@freezed
class CommunityChatLastMessageEntity with _$CommunityChatLastMessageEntity {
  const factory CommunityChatLastMessageEntity({
    required int id,
    required CommunityChatMessageBody body,
    required DateTime createdAt,
    String? senderNickname,
    int? senderProfileIcon,
  }) = _CommunityChatLastMessageEntity;
}

/// 내가 참여 중인 채팅방 한 칸 (`GET /chat/rooms` 원소)
@freezed
class CommunityChatRoomEntity with _$CommunityChatRoomEntity {
  const factory CommunityChatRoomEntity({
    required int postId,
    required String title,
    required CommunityPostStatus status,
    required DateTime meetingAt,
    required int memberCount,
    CommunityChatLastMessageEntity? lastMessage,

    /// 안 읽은 개수. 서버 기준선에 소켓 이벤트로 +1 한다(DEC-0044).
    @Default(0) int unreadCount,
  }) = _CommunityChatRoomEntity;
}
