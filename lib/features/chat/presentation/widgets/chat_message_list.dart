import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
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
    this.onMessageLongPress,
    this.blockedParticipantIds = const {},
    super.key,
  });

  final List<ChatMessageDto> messages;
  final int myParticipantId;
  final String myTeam;

  /// 다크 모드 여부
  final bool isDarkMode;

  /// 리스트 끝에서 아래로 overscroll 시 콜백 (바텀시트 닫기용)
  final VoidCallback? onOverscrollDown;

  /// 메시지 롱프레스 콜백 (메시지, BuildContext, isMe 전달)
  final void Function(ChatMessageDto message, BuildContext context, bool isMe)?
  onMessageLongPress;

  /// 차단된 유저 ID 목록 (해당 유저 메시지 숨김)
  final Set<int> blockedParticipantIds;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  /// 스크롤 하단 이동 FAB 표시 여부 (위로 200px 이상 스크롤 시 true)
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

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

  /// 스크롤 위치에 따라 FAB 표시 여부 갱신
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // reverse: true → pixels 0 = 최하단, 위로 스크롤하면 pixels 증가
    final shouldShow = _scrollController.position.pixels > 200;
    if (shouldShow != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = shouldShow;
      });
    }
  }

  /// 최신 메시지(최하단)로 스크롤 이동
  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// 두 메시지가 같은 그룹인지 판별 (같은 sender + 같은 분)
  bool _isSameGroup(ChatMessageDto a, ChatMessageDto b) {
    if (a.sender.participantId != b.sender.participantId) return false;
    final dtA = a.kstDateTime;
    final dtB = b.kstDateTime;
    if (dtA == null || dtB == null) return false;
    return dtA.year == dtB.year &&
        dtA.month == dtB.month &&
        dtA.day == dtB.day &&
        dtA.hour == dtB.hour &&
        dtA.minute == dtB.minute;
  }

  /// 두 메시지의 날짜가 다른지 판별
  bool _isDifferentDate(ChatMessageDto a, ChatMessageDto b) {
    final dtA = a.kstDateTime;
    final dtB = b.kstDateTime;
    if (dtA == null || dtB == null) return false;
    return dtA.year != dtB.year || dtA.month != dtB.month || dtA.day != dtB.day;
  }

  @override
  void dispose() {
    // 메모리 누수 방지: dispose 전에 리스너 먼저 제거
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 차단된 유저 메시지 필터링
    final filteredMessages = widget.blockedParticipantIds.isEmpty
        ? widget.messages
        : widget.messages
              .where(
                (m) => !widget.blockedParticipantIds.contains(
                  m.sender.participantId,
                ),
              )
              .toList();

    if (filteredMessages.isEmpty) {
      return Center(
        child: Text(
          '채팅을 시작해보세요',
          style: AppTextStyles.tag_12.copyWith(color: AppColors.black400),
        ),
      );
    }

    return Stack(
      children: [
        NotificationListener<OverscrollNotification>(
          onNotification: (notification) {
            // reverse: true에서 아래로 스와이프 시 overscroll < 0
            if (notification.overscroll < 0 &&
                widget.onOverscrollDown != null) {
              widget.onOverscrollDown!();
              return true;
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical8),
            itemCount: filteredMessages.length,
            itemBuilder: (context, index) {
              final msgIndex = filteredMessages.length - 1 - index;
              final message = filteredMessages[msgIndex];
              final isMe =
                  message.sender.participantId == widget.myParticipantId;

              final prevMessage = msgIndex > 0
                  ? filteredMessages[msgIndex - 1]
                  : null;
              final nextMessage = msgIndex < filteredMessages.length - 1
                  ? filteredMessages[msgIndex + 1]
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
                  if (showDateDivider) _buildDateDivider(message.kstDateTime),
                  ChatMessageBubble(
                    message: message,
                    isMe: isMe,
                    myTeam: widget.myTeam,
                    showNickname: showNickname,
                    showTime: showTime,
                    isDarkMode: widget.isDarkMode,
                    onLongPress: widget.onMessageLongPress != null
                        ? (bubbleContext) => widget.onMessageLongPress!(
                            message,
                            bubbleContext,
                            isMe,
                          )
                        : null,
                  ),
                ],
              );
            },
          ),
        ),
        // 스크롤 하단 이동 FAB — 채팅 입력바 위 32, 우측 24
        if (_showScrollToBottom)
          Positioned(
            right: 24.w,
            bottom: 8.h,
            child: Semantics(
              label: '최신 메시지로 이동',
              button: true,
              child: GestureDetector(
                onTap: _scrollToBottom,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? AppColors.black
                        : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isDarkMode
                          ? AppColors.black800
                          : AppColors.black200,
                    ),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: 3 * math.pi / 2,
                      child: SvgPicture.asset(
                        'assets/icons/icon_previous.svg',
                        width: 24.w,
                        height: 24.w,
                        colorFilter: ColorFilter.mode(
                          widget.isDarkMode
                              ? AppColors.black400
                              : AppColors.black600,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 날짜 구분선 위젯
  Widget _buildDateDivider(DateTime? dt) {
    if (dt == null) return const SizedBox.shrink();

    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dt.weekday - 1];
    final label = '${dt.year}년 ${dt.month}월 ${dt.day}일 $weekday요일';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical12),
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
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal12),
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
