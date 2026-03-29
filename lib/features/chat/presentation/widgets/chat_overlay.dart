import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../data/models/chat_message_dto.dart';
import '../providers/chat_provider.dart';
import 'chat_context_menu.dart';
import 'chat_input_bar.dart';
import 'chat_message_list.dart';
import 'chat_preview_card.dart';

/// 채팅 오버레이 위젯
///
/// 게임 화면 하단에 표시되는 채팅 UI입니다.
/// DraggableScrollableSheet로 드래그하여 높이 조절 가능하고,
/// PageView로 전체 채팅 ↔ 팀 채팅을 스와이프 전환합니다.
/// 입력바는 항상 화면 하단 고정 위치에 표시됩니다.
class ChatOverlay extends ConsumerStatefulWidget {
  const ChatOverlay({
    required this.gameId,
    required this.myParticipantId,
    required this.myTeam,
    this.isDarkMode = false,
    super.key,
  });

  final int gameId;
  final int myParticipantId;
  final String myTeam;

  /// 다크 모드 여부 (도둑팀)
  final bool isDarkMode;

  @override
  ConsumerState<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends ConsumerState<ChatOverlay> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _isExpanded = false;
  double _sheetSize = 0;
  double _prevKeyboardHeight = 0;

  static const double _snap50 = 0.5;
  static const double _snap75 = 0.75;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
    // notifier에 본인 participantId 전달 (프리뷰 필터링용)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).setMyParticipantId(
        widget.myParticipantId,
      );
    });
  }

  double _minSize = 0.18;
  double _expandedThreshold = 0.25;

  void _onSheetChanged() {
    final size = _sheetController.size;
    _sheetSize = size;
    final expanded = size > _expandedThreshold;
    if (expanded != _isExpanded) {
      setState(() {
        _isExpanded = expanded;
      });
      // notifier에 시트 상태 통보
      ref.read(chatNotifierProvider.notifier).updateSheetExpanded(expanded);
      if (expanded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(_currentPage);
          }
        });
      } else {
        FocusScope.of(context).unfocus();
      }
    }
  }

  void _handleSend(String message) {
    final scope = _currentPage == 0 ? 'ALL' : 'TEAM';
    ref
        .read(chatNotifierProvider.notifier)
        .sendMessage(gameId: widget.gameId, message: message, scope: scope);
  }

  void _onInputFocused() {
    if (_sheetController.isAttached && _sheetController.size < _snap50) {
      _sheetController.animateTo(
        _snap50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleMessageLongPress(
    ChatMessageDto message,
    BuildContext bubbleContext,
    bool isMe,
  ) {
    ChatContextMenu.show(
      context: bubbleContext,
      message: message,
      isMe: isMe,
      isDarkMode: widget.isDarkMode,
      onBlock: (participantId) {
        ref.read(chatNotifierProvider.notifier).blockUser(participantId);
      },
    );
  }

  void _handlePreviewTap(ChatMessageDto message) {
    final notifier = ref.read(chatNotifierProvider.notifier);
    notifier.onPreviewTapped();

    // 해당 스코프 탭으로 이동
    final targetPage = message.scope == 'TEAM' ? 1 : 0;
    setState(() => _currentPage = targetPage);

    // 시트 펼치기
    if (_sheetController.isAttached && _sheetController.size < _snap50) {
      _sheetController.animateTo(
        _snap50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    // 탭 이동
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    notifier.updateCurrentPage(targetPage);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final isConnected =
        chatState.connectionState == StompConnectionState.connected;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;
    final isKeyboardClosing =
        _prevKeyboardHeight > 0 && keyboardHeight < _prevKeyboardHeight;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final safeBottomMargin = (bottomPadding > 0 ? bottomPadding : 37.h) + 12.h;
    final bottomMargin = (isKeyboardOpen && !isKeyboardClosing)
        ? keyboardHeight
        : safeBottomMargin;
    final collapsedHeight = 20.h + 8.h + 64.h + safeBottomMargin;
    final expandedMinHeight = 20.h + 42.h + 18.h + 64.h + safeBottomMargin;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        _minSize = (collapsedHeight / availableHeight).clamp(0.1, 0.25);
        _expandedThreshold = (expandedMinHeight / availableHeight).clamp(
          0.15,
          0.35,
        );

        _prevKeyboardHeight = keyboardHeight;

        // 키보드 열림: 시트 75% 고정, 닫힘: 기본 minSize
        final effectiveMinSize = isKeyboardOpen ? _snap75 : _minSize;

        return Stack(
          children: [
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: effectiveMinSize,
              minChildSize: effectiveMinSize,
              maxChildSize: _snap75,
              snap: true,
              snapSizes: const [_snap50, _snap75],
              builder: (context, scrollController) {
                return Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? AppColors.black900
                        : AppColors.black100,
                    borderRadius: BorderRadius.only(
                      topLeft: AppRadius.xl20.topLeft,
                      topRight: AppRadius.xl20.topRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, -2),
                        blurRadius: 10,
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        child: _buildDragHandle(),
                      ),
                      if (_isExpanded)
                        Expanded(
                          child: Column(
                            children: [
                              _buildTitle(),
                              Expanded(
                                child: PageView(
                                  controller: _pageController,
                                  onPageChanged: (page) {
                                    setState(() => _currentPage = page);
                                    // notifier에 현재 페이지 통보
                                    ref.read(chatNotifierProvider.notifier).updateCurrentPage(page);
                                  },
                                  children: [
                                    ChatMessageList(
                                      messages: chatState.allScopeMessages,
                                      myParticipantId: widget.myParticipantId,
                                      myTeam: widget.myTeam,
                                      isDarkMode: widget.isDarkMode,
                                      onMessageLongPress:
                                          _handleMessageLongPress,
                                      blockedParticipantIds:
                                          chatState.blockedParticipantIds,
                                    ),
                                    ChatMessageList(
                                      messages: chatState.teamScopeMessages,
                                      myParticipantId: widget.myParticipantId,
                                      myTeam: widget.myTeam,
                                      isDarkMode: widget.isDarkMode,
                                      onMessageLongPress:
                                          _handleMessageLongPress,
                                      blockedParticipantIds:
                                          chatState.blockedParticipantIds,
                                    ),
                                  ],
                                ),
                              ),
                              _buildPageIndicator(),
                            ],
                          ),
                        )
                      else
                        const Expanded(child: SizedBox.shrink()),
                      ChatInputBar(
                        onSend: _handleSend,
                        enabled: isConnected,
                        onFocusGain: _onInputFocused,
                        isDarkMode: widget.isDarkMode,
                        unreadAllCount: chatState.unreadAllCount,
                        unreadTeamCount: chatState.unreadTeamCount,
                      ),
                      SizedBox(height: bottomMargin),
                    ],
                  ),
                );
              },
            ),
            // 프리뷰 카드: DraggableScrollableSheet 바깥에 배치 (clip 방지)
            if (chatState.lastPreviewMessage != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomMargin + 64.h + 4.h,
                child: ChatPreviewCard(
                  message: chatState.lastPreviewMessage!,
                  isDarkMode: widget.isDarkMode,
                  onTap: () => _handlePreviewTap(
                    chatState.lastPreviewMessage!,
                  ),
                  onDismissed: () {
                    ref.read(chatNotifierProvider.notifier).dismissPreview();
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!_sheetController.isAttached) return;
        final target = _sheetSize > _minSize + 0.01 ? _minSize : _snap50;
        _sheetController.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      child: Padding(
        padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
        child: Center(
          child: Container(
            width: 48.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? AppColors.black600
                  : AppColors.black200,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final title = _currentPage == 0 ? '전체 채팅' : '팀 채팅';
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.horizontal24,
        right: AppSpacing.horizontal24,
        top: AppSpacing.vertical16,
        bottom: AppSpacing.vertical8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: widget.isDarkMode
              ? AppTextStyles.robberSubHeading.copyWith(color: AppColors.white)
              : AppTextStyles.subHeading_18.copyWith(color: AppColors.black),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    final chatState = ref.watch(chatNotifierProvider);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(2, (index) {
          final isActive = index == _currentPage;
          final hasUnread = index == 0
              ? chatState.unreadAllCount > 0
              : chatState.unreadTeamCount > 0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  color: isActive
                      ? (widget.isDarkMode
                            ? AppColors.green
                            : AppColors.blue)
                      : (widget.isDarkMode
                            ? AppColors.black600
                            : AppColors.black200),
                  shape: BoxShape.circle,
                ),
              ),
              // 읽지 않은 메시지 빨간 점
              if (hasUnread && !isActive)
                Positioned(
                  top: -2.h,
                  right: 0,
                  child: Container(
                    width: 5.w,
                    height: 5.w,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
