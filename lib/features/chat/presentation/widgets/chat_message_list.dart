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
    super.key,
  });

  final List<ChatMessageDto> messages;
  final int myParticipantId;
  final String myTeam;

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
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
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

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final isMe = message.sender.participantId == widget.myParticipantId;
        return ChatMessageBubble(
          message: message,
          isMe: isMe,
          myTeam: widget.myTeam,
        );
      },
    );
  }
}
