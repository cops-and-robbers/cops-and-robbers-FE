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

/// 멤버 목록 응답 전체 — 멤버들과, 요청자 본인의 이 방 알림 수신 여부
///
/// `notificationEnabled`가 멤버별이 아니라 응답 최상위에 하나뿐이라 목록과 같이
/// 묶는다. 사이드바가 토글의 초기 상태를 여기서 받는다.
@freezed
class CommunityChatMembersEntity with _$CommunityChatMembersEntity {
  const factory CommunityChatMembersEntity({
    @Default(true) bool notificationEnabled,
    required List<CommunityChatMemberEntity> members,
  }) = _CommunityChatMembersEntity;
}
