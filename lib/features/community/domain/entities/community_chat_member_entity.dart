import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_chat_member_entity.freezed.dart';

/// 채팅방 멤버 — BE 이슈에 요청한 `GET /chat/members`의 원소
@freezed
class CommunityChatMemberEntity with _$CommunityChatMemberEntity {
  const factory CommunityChatMemberEntity({
    required int userId,
    required String nickname,

    /// 프로필 아이콘 번호. 탈퇴한 멤버는 서버가 기본값을 채워 준다 (DEC-0041).
    int? profileIcon,
    required bool isAuthor,
  }) = _CommunityChatMemberEntity;
}
