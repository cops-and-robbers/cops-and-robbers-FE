import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_chat_notice_entity.freezed.dart';

/// 채팅방 상단에 방장이 고정해 두는 공지 한 건
///
/// 방마다 **하나**뿐이고 다시 등록하면 이전 것은 흔적 없이 사라진다(DEC-0054) —
/// 그래서 목록도 이력도 없고, 화면이 다루는 것은 "있다/없다" 둘뿐이다.
/// 없음은 이 엔티티의 `null`로 표현한다(서버는 200 + 필드 null로 준다).
@freezed
class CommunityChatNoticeEntity with _$CommunityChatNoticeEntity {
  const factory CommunityChatNoticeEntity({
    required int id,
    required int writerId,

    /// 등록 시점이 아니라 **조회 시점의 현재 닉네임**이다(멤버 목록과 같은 규칙).
    required String writerNickname,
    required int? writerProfileIcon,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CommunityChatNoticeEntity;
}
