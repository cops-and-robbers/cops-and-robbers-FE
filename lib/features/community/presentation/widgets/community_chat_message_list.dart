import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/content_filter/profanity_filter.dart';
import '../../../../core/widgets/chat/chat_bubble.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/community_chat_message_grouping.dart';
import '../../domain/entities/community_chat_message_entity.dart';
import '../community_chat_time_format.dart';
import '../providers/community_chat_room_provider.dart';
import 'community_chat_avatar.dart';
import 'community_chat_invite_card.dart';
import 'community_chat_system_pill.dart';

/// 채팅방 본문 — 최신순 타임라인을 reverse 목록으로 그린다
///
/// 타입별로 다른 위젯을 고른다: TEXT 말풍선 / SYSTEM pill / GAME_INVITE 카드 /
/// unknown은 숨김. 그룹핑(닉네임·시각)은 숨긴 것을 뺀 목록 기준이다.
/// 위로 끝까지 올리면(reverse라 maxScrollExtent 쪽) 이전 페이지를 요청한다.
class CommunityChatMessageList extends StatefulWidget {
  const CommunityChatMessageList({
    required this.state,
    required this.myUserId,
    required this.roomTitle,
    required this.onLoadOlder,
    required this.onRetry,
    required this.onJoinInvite,
    super.key,
  });

  final CommunityChatRoomState state;
  final int? myUserId;
  final String roomTitle;
  final VoidCallback onLoadOlder;
  final void Function(String messageKey) onRetry;
  final void Function(String inviteCode) onJoinInvite;

  @override
  State<CommunityChatMessageList> createState() =>
      _CommunityChatMessageListState();
}

class _CommunityChatMessageListState extends State<CommunityChatMessageList> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    // reverse: true — 위 끝이 maxScrollExtent
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200.h) {
      widget.onLoadOlder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final visible = widget.state.timeline.messages
        .where((m) => m.body is! CommunityChatUnknownBody)
        .toList();
    final loadingOlder = widget.state.loadingOlder;

    return ListView.builder(
      controller: _scroll,
      reverse: true,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical8),
      itemCount: visible.length + (loadingOlder ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == visible.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical12),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final m = visible[index];
        // 같은 발신자 묶음 안(연속)이면 6, 발신자가 바뀌거나 시스템/초대 이벤트가
        // 끼면(groupFlagsAt이 항상 boundary로 판정) 18 — 각 위젯 자체 여백을 뺀
        // 나머지를 이 top padding으로 채운다.
        final flags = groupFlagsAt(visible, index);
        return switch (m.body) {
          CommunityChatTextBody(:final text) => _buildBubble(
            l10n,
            m,
            text,
            flags,
          ),
          CommunityChatSystemBody(:final event) => Padding(
            padding: EdgeInsets.only(top: 12.h), // pill 자체 margin 6 + 12 = 18
            child: CommunityChatSystemPill(
              // 이벤트를 전부 열거한다 — 삼항으로 두면 새 이벤트가 조용히
              // "나갔어요"로 흘러간다(KICK이 추가됐을 때 실제로 그랬다).
              text: switch (event) {
                CommunityChatSystemEvent.join => l10n.communityChatSystemJoined(
                  m.senderNickname,
                ),
                CommunityChatSystemEvent.leave => l10n.communityChatSystemLeft(
                  m.senderNickname,
                ),
                CommunityChatSystemEvent.kick => l10n.communityChatSystemKicked(
                  m.senderNickname,
                ),
              },
            ),
          ),
          CommunityChatGameInviteBody(:final inviteCode) => _buildInvite(
            l10n,
            m,
            inviteCode,
            flags,
          ),
          CommunityChatUnknownBody() => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildBubble(
    AppLocalizations l10n,
    CommunityChatMessageEntity m,
    String text,
    ChatGroupFlags flags,
  ) {
    final isMe = m.senderId == widget.myUserId;
    // ChatBubble 자체 top padding(묶음 시작 8 / 연속 2)에 더해 최종 간격을
    // 묶음 시작(다른 사람·이벤트 경계) 18, 같은 사람 연속 6으로 맞춘다.
    final groupGap = flags.showNickname ? 10.h : 4.h;
    final bubble = ChatBubble(
      text: ProfanityFilter.filter(text),
      isMe: isMe,
      // 내 말풍선은 닉네임·아바타를 그리지 않는다(시안).
      nickname: isMe ? null : m.senderNickname,
      timeLabel: formatChatTime(l10n, m.createdAt),
      showNickname: flags.showNickname,
      showTime: flags.showTime && m.status == CommunityChatMessageStatus.sent,
      bubbleColor: isMe ? AppColors.blueVer2Basic : AppColors.white,
      textStyle: AppTextStyles.chatroom_text_14.copyWith(
        color: isMe ? AppColors.white : AppColors.black,
      ),
      nicknameStyle: AppTextStyles.tag_12.copyWith(color: AppColors.black700),
      timeStyle: AppTextStyles.tag_12.copyWith(color: AppColors.black300),
      avatar: isMe ? null : CommunityChatAvatar(iconId: m.senderProfileIcon),
      // 상대 쪽 꼬리는 좌상단 0, 내 쪽은 우상단 0 — 나머지 모서리는 10.
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isMe ? 10.r : 0),
        topRight: Radius.circular(isMe ? 0 : 10.r),
        bottomLeft: Radius.circular(10.r),
        bottomRight: Radius.circular(10.r),
      ),
    );

    final content = switch (m.status) {
      CommunityChatMessageStatus.sent => bubble,
      // 확정 전엔 흐리게 — 에코가 오면 원래 색으로 돌아온다.
      CommunityChatMessageStatus.pending => Opacity(
        opacity: 0.6,
        child: bubble,
      ),
      CommunityChatMessageStatus.failed => GestureDetector(
        onTap: () => widget.onRetry(m.messageKey),
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            bubble,
            Padding(
              padding: EdgeInsets.only(right: AppSpacing.horizontal24),
              child: Text(
                l10n.communityChatSendFailed,
                style: AppTextStyles.tag_10.copyWith(color: AppColors.red),
              ),
            ),
          ],
        ),
      ),
    };

    return Padding(
      padding: EdgeInsets.only(top: groupGap),
      child: content,
    );
  }

  /// 게임 초대 — 텍스트 말풍선과 같은 [ChatBubble]에 [CommunityChatInviteCard]를 꽂는다.
  Widget _buildInvite(
    AppLocalizations l10n,
    CommunityChatMessageEntity m,
    String inviteCode,
    ChatGroupFlags flags,
  ) {
    final isMe = m.senderId == widget.myUserId;
    final bubble = ChatBubble(
      isMe: isMe,
      nickname: isMe ? null : m.senderNickname,
      timeLabel: formatChatTime(l10n, m.createdAt),
      showNickname: flags.showNickname,
      showTime: flags.showTime,
      bubbleColor: AppColors.white,
      nicknameStyle: AppTextStyles.tag_12.copyWith(color: AppColors.black700),
      timeStyle: AppTextStyles.tag_12.copyWith(color: AppColors.black300),
      avatar: isMe ? null : CommunityChatAvatar(iconId: m.senderProfileIcon),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isMe ? 10.r : 0),
        topRight: Radius.circular(isMe ? 0 : 10.r),
        bottomLeft: Radius.circular(10.r),
        bottomRight: Radius.circular(10.r),
      ),
      child: CommunityChatInviteCard(
        nickname: m.senderNickname,
        roomTitle: widget.roomTitle,
        inviteCode: inviteCode,
        onJoin: () => widget.onJoinInvite(inviteCode),
      ),
    );
    final groupGap = flags.showNickname ? 10.h : 4.h;
    return Padding(
      padding: EdgeInsets.only(top: groupGap),
      child: bubble,
    );
  }
}
