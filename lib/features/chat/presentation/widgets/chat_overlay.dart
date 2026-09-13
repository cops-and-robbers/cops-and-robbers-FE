import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/chat_constants.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/chat/chat_context_menu.dart';
import '../../../../core/widgets/chat/community_message_input.dart';
import '../../../../core/widgets/toggles/segmented_toggle.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../report/domain/report_target.dart';
import '../../data/models/chat_message_dto.dart';
import '../providers/chat_notification_provider.dart';
import '../providers/chat_provider.dart';
import 'chat_message_list.dart';
import 'chat_preview_card.dart';

/// 지도 버튼으로 여는 채팅. 닫혀 있어도 구독·미읽음·작성 중 입력은 유지한다.
class ChatOverlay extends ConsumerStatefulWidget {
  const ChatOverlay({
    required this.gameId,
    required this.myParticipantId,
    required this.myTeam,
    required this.visible,
    required this.previewInsets,
    required this.onOpen,
    this.isDarkMode = false,
    super.key,
  });

  final int gameId;
  final int myParticipantId;
  final String myTeam;
  final bool visible;
  final EdgeInsets previewInsets;
  final VoidCallback onOpen;
  final bool isDarkMode;

  @override
  ConsumerState<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends ConsumerState<ChatOverlay> {
  int _currentPage = 1;
  final _pageController = PageController();
  final _focusNodes = [FocusNode(), FocusNode()];
  FocusNode get _focusNode => _focusNodes[_currentPage];

  @override
  void initState() {
    super.initState();
    _syncVisibility();
  }

  @override
  void didUpdateWidget(ChatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible) {
      if (!widget.visible) _focusNode.unfocus();
      _syncVisibility();
    }
  }

  void _syncVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(chatNotifierProvider.notifier);
      notifier.setMyParticipantId(widget.myParticipantId);
      notifier.updateSheetExpanded(false);
      notifier.updateCurrentPage(_currentPage);
      notifier.updateSheetExpanded(widget.visible);
      if (widget.visible) notifier.dismissPreview();
    });
  }

  void _selectPage(int page) {
    _onPageChanged(page);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(page == 1 ? 0 : 1);
    }
  }

  void _onPageChanged(int page) {
    if (_currentPage == page) return;
    final hadFocus = _focusNode.hasFocus;
    _focusNode.unfocus();
    setState(() => _currentPage = page);
    ref.read(chatNotifierProvider.notifier).updateCurrentPage(page);
    if (hadFocus && widget.visible) _focusNode.requestFocus();
  }

  void _handleSend(String text, int page) {
    ref
        .read(chatNotifierProvider.notifier)
        .sendMessage(
          gameId: widget.gameId,
          message: text,
          scope: page == 0 ? ChatScope.all : ChatScope.team,
        );
  }

  void _handleMessageLongPress(
    ChatMessageDto message,
    BuildContext bubbleContext,
    bool isMe,
  ) {
    VibrationService.instance().longPress();
    ChatContextMenu.show(
      context: bubbleContext,
      bubble: ChatContextMenuBubble(
        text: message.filteredMessage,
        backgroundColor: widget.isDarkMode
            ? (isMe ? AppColors.green : AppColors.black)
            : (isMe ? AppColors.blueVer2Basic : AppColors.white),
        textStyle: AppTextStyles.paragraph_14.copyWith(
          color: widget.isDarkMode != isMe ? AppColors.white : AppColors.black,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
          bottomLeft: Radius.circular(isMe ? 12.r : 4.r),
          bottomRight: Radius.circular(isMe ? 4.r : 12.r),
        ),
      ),
      copyText: message.message,
      isDarkMode: widget.isDarkMode,
      reportTarget: isMe
          ? null
          : GameChatReportTarget(
              gameId: widget.gameId,
              reportedParticipantId: message.sender.participantId,
              messageContent: message.message,
            ),
      onBlock: isMe
          ? null
          : () => ref
                .read(chatNotifierProvider.notifier)
                .blockUser(message.sender.participantId),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final notifications = ref.watch(chatNotificationEnabledProvider);
    final l10n = AppLocalizations.of(context);
    final preview = chatState.lastPreviewMessage;

    return Positioned.fill(
      child: Stack(
        children: [
          if (!widget.visible && notifications && preview != null)
            Positioned(
              left: widget.previewInsets.left,
              right: widget.previewInsets.right,
              bottom: widget.previewInsets.bottom,
              child: ChatPreviewCard(
                message: preview,
                isDarkMode: widget.isDarkMode,
                onTap: () {
                  _selectPage(preview.scope == ChatScope.team ? 1 : 0);
                  ref.read(chatNotifierProvider.notifier).onPreviewTapped();
                  widget.onOpen();
                },
                onDismissed: () =>
                    ref.read(chatNotifierProvider.notifier).dismissPreview(),
              ),
            ),
          Positioned.fill(
            key: const ValueKey('game-chat-panel'),
            top: MediaQuery.paddingOf(context).top + kToolbarHeight,
            child: Offstage(
              offstage: !widget.visible,
              child: TickerMode(
                enabled: widget.visible,
                child: ColoredBox(
                  color: widget.isDarkMode
                      ? AppColors.black900
                      : AppColors.black100,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: AppPadding.all16,
                          color: widget.isDarkMode
                              ? AppColors.black900
                              : AppColors.white,
                          child: SegmentedToggle(
                            labels: [
                              for (final page in [1, 0])
                                _tabLabel(
                                  page == 1
                                      ? l10n.chatScopeTeamTitle
                                      : l10n.chatScopeAllTitle,
                                  page == 1
                                      ? chatState.unreadTeamCount
                                      : chatState.unreadAllCount,
                                ),
                            ],
                            selectedIndex: _currentPage == 1 ? 0 : 1,
                            onChanged: (index) =>
                                _selectPage(index == 0 ? 1 : 0),
                            isDarkMode: widget.isDarkMode,
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: _focusNode.unfocus,
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) =>
                                  _onPageChanged(index == 0 ? 1 : 0),
                              children: [
                                for (final page in [1, 0])
                                  ChatMessageList(
                                    key: PageStorageKey(
                                      'game-chat-${widget.gameId}-$page',
                                    ),
                                    messages: page == 0
                                        ? chatState.allScopeMessages
                                        : chatState.teamScopeMessages,
                                    myParticipantId: widget.myParticipantId,
                                    myTeam: widget.myTeam,
                                    isDarkMode: widget.isDarkMode,
                                    scope: page == 0
                                        ? ChatScope.all
                                        : ChatScope.team,
                                    onMessageLongPress: _handleMessageLongPress,
                                    blockedParticipantIds:
                                        chatState.blockedParticipantIds,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        for (final page in [0, 1])
                          Offstage(
                            offstage: _currentPage != page,
                            child: CommunityMessageInput(
                              isDarkMode: widget.isDarkMode,
                              hintText:
                                  chatState.connectionState ==
                                      StompConnectionState.connected
                                  ? (page == 1
                                        ? l10n.gameChatTeamInputHint
                                        : l10n.gameChatAllInputHint)
                                  : l10n.chatInputBarConnecting,
                              onSubmit: (text) async => _handleSend(text, page),
                              maxLength: 300,
                              enabled:
                                  chatState.connectionState ==
                                  StompConnectionState.connected,
                              focusNode: _focusNodes[page],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _tabLabel(String title, int unread) =>
      unread == 0 ? title : '$title · ${unread > 99 ? '99+' : unread}';
}
