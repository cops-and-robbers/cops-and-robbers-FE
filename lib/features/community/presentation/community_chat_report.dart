import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/services/content_filter/profanity_filter.dart';
import '../../../core/services/vibration_service.dart';
import '../../../core/widgets/chat/chat_context_menu.dart';
import '../../report/domain/report_target.dart';
import '../domain/entities/community_chat_message_entity.dart';

/// 이 말풍선을 신고할 수 있는가 — 서버가 거절할 것을 화면이 미리 막는다.
///
/// 넷 다 걸러야 한다:
/// - **내 메시지**: 서버가 400(`SELF_REPORT`)으로 막는다.
/// - **아직 전송 중**: 서버 id가 없다. 앱이 만든 `messageKey`를 대신 보내면
///   서버가 못 찾는다(404 `CHAT_MESSAGE_NOT_FOUND`).
/// - **시스템 메시지·초대 카드**: 사람이 쓴 글이 아니라 신고할 대상이 없다.
/// - **비로그인**: 내 메시지인지 가릴 수 없고 신고 자체가 401이다.
bool canReportChatMessage(
  CommunityChatMessageEntity message, {
  required int? myUserId,
}) {
  if (myUserId == null) return false;
  if (message.senderId == myUserId) return false;
  if (message.id == null) return false;
  return message.body is CommunityChatTextBody;
}

/// 모집글 채팅 말풍선을 길게 눌렀을 때 — 인게임과 **같은** 메뉴를 연다
///
/// 신고 진입 UI를 따로 만들지 않는다. 차단은 넘기지 않아 항목이 빠진다 —
/// 커뮤니티에는 차단 기능이 없다.
Future<void> showCommunityChatMessageMenu({
  required BuildContext context,
  required CommunityChatMessageEntity message,
  required int? myUserId,
  required bool isMe,
}) {
  final body = message.body;
  // 텍스트 말풍선에서만 롱프레스가 걸린다 — 시스템 pill·초대 카드는 대상이 아니다.
  if (body is! CommunityChatTextBody) return Future.value();

  // 화면에 보이는 대로 복사한다 — 필터가 가린 말을 클립보드로 흘리지 않는다.
  final shown = ProfanityFilter.filter(body.text);
  VibrationService.instance().longPress();

  return ChatContextMenu.show(
    context: context,
    bubble: ChatContextMenuBubble(
      text: shown,
      backgroundColor: isMe ? AppColors.blueVer2Basic : AppColors.white,
      textStyle: AppTextStyles.chatroom_text_14.copyWith(
        color: isMe ? AppColors.white : AppColors.black,
      ),
      // 채팅방 말풍선과 같은 모서리 — 상대는 좌상단 0, 나는 우상단 0.
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isMe ? 10.r : 0),
        topRight: Radius.circular(isMe ? 0 : 10.r),
        bottomLeft: Radius.circular(10.r),
        bottomRight: Radius.circular(10.r),
      ),
    ),
    copyText: shown,
    reportTarget: canReportChatMessage(message, myUserId: myUserId)
        ? CommunityChatReportTarget(message.id!)
        : null,
  );
}
