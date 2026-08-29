import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_navigation_event.freezed.dart';

/// 푸시 알림 탭으로 이동해야 할 목적지 — `DeeplinkEvent`와 같은 역할.
///
/// FCM `data` 페이로드를 의미 있는 sealed event로 normalize한다. 새 푸시
/// 시나리오가 생기면 case만 추가하면 된다.
@freezed
sealed class PushNavigationEvent with _$PushNavigationEvent {
  /// 커뮤니티 댓글·답글 알림 → 게시글 상세.
  const factory PushNavigationEvent.communityPost({required int postId}) =
      CommunityPostPushEvent;

  /// 이동 목적지가 있는 페이로드만 event로 바꾼다. 그 외(게임 이벤트·콘텐츠
  /// 완료 등 이동이 없는 푸시)는 null — 호출자가 무시한다.
  ///
  /// BE `CommunityFcmNotifier`가 보내는 형식:
  /// `{ "type": "COMMENT" | "REPLY", "postId": "<id>" }`. FCM data 값은 항상
  /// 문자열이라 `postId`는 여기서 파싱한다. 파싱이 안 되면 목적지를 모르는
  /// 것이므로 null이다.
  static PushNavigationEvent? fromData(Map<String, dynamic> data) {
    final type = data['type'];
    if (type != 'COMMENT' && type != 'REPLY') return null;
    final postId = int.tryParse('${data['postId'] ?? ''}');
    if (postId == null) return null;
    return PushNavigationEvent.communityPost(postId: postId);
  }
}
