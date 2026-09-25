import 'package:freezed_annotation/freezed_annotation.dart';

import '../../constants/chat_constants.dart';

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

  /// 커뮤니티 채팅 메시지·게임 초대·고정 채팅 알림 → 그 글의 채팅방.
  const factory PushNavigationEvent.communityChat({required int postId}) =
      CommunityChatPushEvent;

  const factory PushNavigationEvent.gameChat({
    required int gameId,
    required String scope,
  }) = GameChatPushEvent;

  /// BE `CommunityChatFcmNotifier`가 보내는 채팅방 알림 type — 메시지(`TEXT`·
  /// `GAME_INVITE`)와 고정 채팅 변경(`PIN_*`) 모두 `postId`만 싣는다(채팅방은
  /// 글당 하나). 이름이 일반적이라 인게임 시스템 이벤트(`ARREST` 등)와 겹치지
  /// 않는지 새 type이 생길 때마다 확인한다.
  static const _communityChatTypes = {
    'TEXT',
    'GAME_INVITE',
    'PIN_REGISTERED',
    'PIN_UPDATED',
    'PIN_DELETED',
  };

  /// 이동 목적지가 있는 페이로드만 event로 바꾼다. 그 외(게임 이벤트·콘텐츠
  /// 완료 등 이동이 없는 푸시)는 null — 호출자가 무시한다.
  ///
  /// BE `CommunityFcmNotifier`가 보내는 형식:
  /// `{ "type": "COMMENT" | "REPLY", "postId": "<id>" }`. FCM data 값은 항상
  /// 문자열이라 `postId`는 여기서 파싱한다. 파싱이 안 되면 목적지를 모르는
  /// 것이므로 null이다.
  static PushNavigationEvent? fromData(Map<String, dynamic> data) {
    final type = data['type'];
    if (type == 'CHAT') {
      final gameId = int.tryParse('${data['gameId'] ?? ''}');
      final scope = data['scope'];
      if (gameId == null ||
          gameId <= 0 ||
          (scope != ChatScope.all && scope != ChatScope.team)) {
        return null;
      }
      return PushNavigationEvent.gameChat(
        gameId: gameId,
        scope: scope as String,
      );
    }
    final isPostPush = type == 'COMMENT' || type == 'REPLY';
    if (!isPostPush && !_communityChatTypes.contains(type)) return null;
    final postId = int.tryParse('${data['postId'] ?? ''}');
    if (postId == null) return null;
    return isPostPush
        ? PushNavigationEvent.communityPost(postId: postId)
        : PushNavigationEvent.communityChat(postId: postId);
  }
}
