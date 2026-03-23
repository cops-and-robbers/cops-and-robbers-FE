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
/// 카카오톡 스타일 그룹핑: 같은 발신자 + 같은 분(minute) 기준.
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

  /// 두 메시지가 같은 그룹인지 판별 (같은 sender + 같은 분)
  bool _isSameGroup(ChatMessageDto a, ChatMessageDto b) {
    if (a.sender.participantId != b.sender.participantId) return false;
    final dtA = _parseTimestamp(a.timestamp);
    final dtB = _parseTimestamp(b.timestamp);
    if (dtA == null || dtB == null) return false;
    return dtA.year == dtB.year &&
        dtA.month == dtB.month &&
        dtA.day == dtB.day &&
        dtA.hour == dtB.hour &&
        dtA.minute == dtB.minute;
  }

  /// 두 메시지의 날짜가 다른지 판별
  bool _isDifferentDate(ChatMessageDto a, ChatMessageDto b) {
    final dtA = _parseTimestamp(a.timestamp);
    final dtB = _parseTimestamp(b.timestamp);
    if (dtA == null || dtB == null) return false;
    return dtA.year != dtB.year || dtA.month != dtB.month || dtA.day != dtB.day;
  }

  DateTime? _parseTimestamp(String timestamp) {
    try {
      final normalized = timestamp.replaceFirstMapped(
        RegExp(r'(\.\d{1,6})\d*'),
        (m) => m.group(1)!,
      );
      return DateTime.parse(normalized).add(const Duration(hours: 9));
    } catch (_) {
      return null;
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
          final msgIndex = widget.messages.length - 1 - index;
          final message = widget.messages[msgIndex];
          final isMe = message.sender.participantId == widget.myParticipantId;

          final prevMessage = msgIndex > 0
              ? widget.messages[msgIndex - 1]
              : null;
          final nextMessage = msgIndex < widget.messages.length - 1
              ? widget.messages[msgIndex + 1]
              : null;

          // 그룹 첫 메시지: 닉네임 표시
          final showNickname =
              prevMessage == null || !_isSameGroup(prevMessage, message);

          // 그룹 마지막 메시지: 시간 표시
          final showTime =
              nextMessage == null || !_isSameGroup(message, nextMessage);

          // 날짜 구분선: 이전 메시지와 날짜가 다르면 표시
          final showDateDivider =
              prevMessage == null || _isDifferentDate(prevMessage, message);

          return Column(
            children: [
              if (showDateDivider) _buildDateDivider(message.timestamp),
              ChatMessageBubble(
                message: message,
                isMe: isMe,
                myTeam: widget.myTeam,
                showNickname: showNickname,
                showTime: showTime,
                isDarkMode: widget.isDarkMode,
              ),
            ],
          );
        },
      ),
    );
  }

  /// 날짜 구분선 위젯
  Widget _buildDateDivider(String timestamp) {
    final dt = _parseTimestamp(timestamp);
    if (dt == null) return const SizedBox.shrink();

    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dt.weekday - 1];
    final label = '${dt.year}년 ${dt.month}월 ${dt.day}일 $weekday요일';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: widget.isDarkMode
                  ? AppColors.black800
                  : AppColors.black200,
              height: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              label,
              style: AppTextStyles.tag_12.copyWith(color: AppColors.black400),
            ),
          ),
          Expanded(
            child: Divider(
              color: widget.isDarkMode
                  ? AppColors.black800
                  : AppColors.black200,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
