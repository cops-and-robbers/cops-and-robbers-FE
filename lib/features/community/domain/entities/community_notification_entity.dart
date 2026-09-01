import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_notification_entity.freezed.dart';

/// 커뮤니티 알림 종류 — 서버 와이어 포맷 비의존 (순수 도메인 타입)
///
/// 서버는 `COMMENT`(내 글 댓글)·`REPLY`(답글) 둘만 보낸다. 시안에 있던
/// "추천 게시글"은 서버 스펙에 없다(DEC-0042 열린 질문) — 별도 값을 만들지 않고
/// 필요해지면 그때 추가한다.
enum CommunityNotificationType { comment, reply }

/// 커뮤니티 알림 한 건
///
/// 알림함 목록의 항목이다. [read]는 알림마다 저장된 값이 아니라 유저당 읽음
/// 커서로 판정한 결과라 개별 갱신은 불가능하다(DEC-0038) — 서버가 내려준 값을
/// 그대로 보여주기만 한다.
@freezed
class CommunityNotificationEntity with _$CommunityNotificationEntity {
  const factory CommunityNotificationEntity({
    required int id,
    required CommunityNotificationType type,
    required int communityPostId,
    required String postTitle,
    required String content,
    required bool read,
    required DateTime createdAt,
  }) = _CommunityNotificationEntity;
}

/// 알림함 목록 한 장 (커서 페이지네이션)
///
/// 커서는 스크랩 목록과 같은 형태(정수, [CommunityScrapPageEntity] 참고)다.
@freezed
class CommunityNotificationPageEntity with _$CommunityNotificationPageEntity {
  const factory CommunityNotificationPageEntity({
    required List<CommunityNotificationEntity> items,
    required int? nextCursor,
    required bool hasNext,
  }) = _CommunityNotificationPageEntity;
}
