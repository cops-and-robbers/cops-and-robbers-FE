import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_chat_member_entity.freezed.dart';

/// 채팅방 멤버 — BE 이슈에 요청한 `GET /chat/members`의 원소
@freezed
class CommunityChatMemberEntity with _$CommunityChatMemberEntity {
  const factory CommunityChatMemberEntity({
    required int userId,
    required String nickname,
    required bool isAuthor,
  }) = _CommunityChatMemberEntity;
}
