import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../data/models/chat_message_dto.dart';
import 'chat_message_bubble.dart';

/// 채팅 메시지 목록 위젯
///
/// 채팅 메시지들을 스크롤 가능한 리스트로 표시합니다.
/// 새 메시지가 추가되면 자동으로 하단으로 스크롤됩니다.
class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    required this.messages,
    required this.myParticipantId,
    required this.myTeam,
    this.isDarkMode = false,
    this.onOverscrollDown,
    super.key,
  });

  final List<ChatMessageDto> messages;
  final int myParticipantId;
  final String myTeam;

  /// 다크 모드 여부
  final bool isDarkMode;

  /// 리스트 끝에서 아래로 overscroll 시 콜백 (바텀시트 닫기용)
  final VoidCallback? onOverscrollDown;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottomIfNear();
      });
    }
  }

  /// 사용자가 하단 근처에 있을 때만 최신 메시지로 부드럽게 이동
  void _scrollToBottomIfNear() {
    if (!_scrollController.hasClients) return;
    final pixels = _scrollController.position.pixels;
    if (pixels > 100) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return Center(
        child: Text(
          '채팅을 시작해보세요',
          style: AppTextStyles.tag_12.copyWith(color: AppColors.black400),
        ),
      );
    }

    return NotificationListener<OverscrollNotification>(
      onNotification: (notification) {
        // reverse: true에서 아래로 스와이프 시 overscroll < 0
        if (notification.overscroll < 0 && widget.onOverscrollDown != null) {
          widget.onOverscrollDown!();
          return true;
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: widget.messages.length,
        itemBuilder: (context, index) {
          final message = widget.messages[widget.messages.length - 1 - index];
          final isMe = message.sender.participantId == widget.myParticipantId;
          return ChatMessageBubble(
            message: message,
            isMe: isMe,
            myTeam: widget.myTeam,
            isDarkMode: widget.isDarkMode,
          );
        },
      ),
    );
  }
}
