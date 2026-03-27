# 채팅 신고/차단/콘텐츠 필터링 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 채팅 메시지 롱프레스 시 컨텍스트 메뉴(복사/신고/차단)를 표시하고, 신고 플로우(카테고리 선택 → 확인 다이얼로그 → API 호출 → 스낵바), 유저 차단(세션 내 메시지 숨김), 비속어 필터링을 구현한다.

**Architecture:** ChatMessageBubble에 롱프레스 핸들러를 추가하고, `showGeneralDialog`로 풀스크린 오버레이(black 0.4) 위에 메시지 + 컨텍스트 메뉴를 표시한다. 차단된 유저 목록은 ChatState에 `Set<int>`로 관리하며, 비속어 필터는 순수 유틸리티 함수로 메시지 표시 시점에 적용한다.

**Tech Stack:** Flutter, Riverpod, showGeneralDialog, Clipboard, AppDialog, AppSnackbar

---

## File Structure

| 파일 | 역할 | 액션 |
|------|------|------|
| `lib/features/chat/domain/constants/report_categories.dart` | 신고 카테고리 enum | Create |
| `lib/features/chat/presentation/widgets/chat_context_menu.dart` | 롱프레스 컨텍스트 메뉴 오버레이 (복사/신고/차단 + 신고 카테고리 선택) | Create |
| `lib/core/services/content_filter/profanity_filter.dart` | 비속어 필터링 유틸리티 | Create |
| `lib/features/chat/presentation/widgets/chat_message_bubble.dart` | 롱프레스 핸들러 + 콘텐츠 필터 적용 | Modify |
| `lib/features/chat/presentation/widgets/chat_message_list.dart` | 롱프레스 콜백 전달 + 차단 유저 필터링 | Modify |
| `lib/features/chat/presentation/providers/chat_provider.dart` | 차단 유저 관리 (blockedParticipantIds) | Modify |
| `lib/features/chat/presentation/widgets/chat_overlay.dart` | ChatMessageList에 콜백 전달 | Modify |

---

### Task 1: 신고 카테고리 상수 정의

**Files:**
- Create: `lib/features/chat/domain/constants/report_categories.dart`

- [ ] **Step 1: 신고 카테고리 enum 작성**

```dart
/// 채팅 신고 카테고리
enum ReportCategory {
  bait('낚시/놀람/도배'),
  abuse('욕설/비하'),
  impersonation('사칭/사기'),
  spam('광고/스팸'),
  exploit('부정 행위/버그 악용'),
  teamSabotage('팀 사기 저하'),
  other('기타(직접 작성)');

  const ReportCategory(this.label);

  /// UI에 표시할 한글 라벨
  final String label;
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/chat/domain/constants/report_categories.dart
git commit -m "feat(chat): 신고 카테고리 enum 추가"
```

---

### Task 2: 채팅 컨텍스트 메뉴 오버레이 위젯

**Files:**
- Create: `lib/features/chat/presentation/widgets/chat_context_menu.dart`

이 위젯은 두 가지 화면을 StatefulWidget으로 관리한다:
1. **액션 메뉴** (복사하기, 신고하기, 차단하기)
2. **신고 카테고리 선택** (신고하기 탭 시 전환)

- [ ] **Step 1: ChatContextMenu 클래스 + show 정적 메서드 작성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../data/models/chat_message_dto.dart';
import '../../domain/constants/report_categories.dart';

/// 채팅 메시지 롱프레스 컨텍스트 메뉴
///
/// 풀스크린 오버레이(black 0.4)로 배경을 덮고,
/// 선택된 메시지와 액션 메뉴를 오버레이 위에 표시합니다.
class ChatContextMenu {
  ChatContextMenu._();

  /// 컨텍스트 메뉴 표시
  ///
  /// [context] 메시지 버블의 BuildContext (위치 계산용)
  /// [message] 롱프레스된 채팅 메시지
  /// [messageWidget] 메시지 버블 위젯 (오버레이에 복제 표시)
  /// [isMe] 본인 메시지 여부 (true면 복사만 표시)
  /// [onBlock] 차단 콜백 (participantId 전달)
  static Future<void> show({
    required BuildContext context,
    required ChatMessageDto message,
    required Widget messageWidget,
    required bool isMe,
    required void Function(int participantId) onBlock,
  }) {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final messageRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      size.dx,
      size.dy,
    );

    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, __) {
        return _ChatContextMenuOverlay(
          message: message,
          messageRect: messageRect,
          messageWidget: messageWidget,
          isMe: isMe,
          onDismiss: () => Navigator.of(dialogContext).pop(),
          onBlock: onBlock,
        );
      },
    );
  }
}
```

- [ ] **Step 2: _ChatContextMenuOverlay StatefulWidget 작성**

오버레이 내부에서 `_MenuMode` enum으로 액션 메뉴 ↔ 신고 카테고리를 전환한다.

```dart
enum _MenuMode { actions, reportCategories }

class _ChatContextMenuOverlay extends StatefulWidget {
  const _ChatContextMenuOverlay({
    required this.message,
    required this.messageRect,
    required this.messageWidget,
    required this.isMe,
    required this.onDismiss,
    required this.onBlock,
  });

  final ChatMessageDto message;
  final Rect messageRect;
  final Widget messageWidget;
  final bool isMe;
  final VoidCallback onDismiss;
  final void Function(int participantId) onBlock;

  @override
  State<_ChatContextMenuOverlay> createState() =>
      _ChatContextMenuOverlayState();
}

class _ChatContextMenuOverlayState extends State<_ChatContextMenuOverlay> {
  _MenuMode _mode = _MenuMode.actions;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    // 메뉴 크기 계산
    final menuWidth = 204.w;
    final menuHeight = _mode == _MenuMode.actions
        ? (widget.isMe ? _singleItemHeight : _actionMenuHeight)
        : _categoryMenuHeight;

    // 메뉴 위치: 메시지 아래, 메시지 왼쪽 정렬
    // 화면 밖으로 나가지 않도록 clamp
    final menuLeft = widget.messageRect.left.clamp(
      16.w,
      screenSize.width - menuWidth - 16.w,
    );

    // 메시지 아래에 공간이 충분하면 아래에, 아니면 위에 표시
    final spaceBelow =
        screenSize.height - widget.messageRect.bottom - 16.h;
    final menuTop = spaceBelow >= menuHeight
        ? widget.messageRect.bottom + 8.h
        : widget.messageRect.top - menuHeight - 8.h;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // 어두운 배경 (탭하면 닫기)
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              color: AppColors.black.withValues(alpha: 0.4),
            ),
          ),

          // 원래 위치의 메시지 버블
          Positioned(
            left: widget.messageRect.left,
            top: widget.messageRect.top,
            width: widget.messageRect.width,
            child: widget.messageWidget,
          ),

          // 컨텍스트 메뉴
          Positioned(
            left: menuLeft,
            top: menuTop.clamp(16.h, screenSize.height - menuHeight - 16.h),
            child: _mode == _MenuMode.actions
                ? _buildActionMenu()
                : _buildCategoryMenu(),
          ),
        ],
      ),
    );
  }

  // ... (아래 step에서 계속)
}
```

- [ ] **Step 3: _buildActionMenu 메서드 작성**

메뉴 항목: 복사하기, 신고하기(빨간색), 차단하기. 본인 메시지면 복사만 표시.
메뉴 스펙: width 204.w, radius 16.r, white 배경.

```dart
  static final _singleItemHeight = 52.h;  // 복사만 (본인 메시지)
  static final _actionMenuHeight = 156.h; // 3개 항목
  static final _categoryMenuHeight = 380.h; // 카테고리 7개 + 타이틀

  Widget _buildActionMenu() {
    return Container(
      width: 204.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 12,
            color: AppColors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 복사하기
          _buildMenuItem(
            icon: 'assets/icons/icon_copy.svg',
            label: '복사하기',
            onTap: _handleCopy,
          ),
          if (!widget.isMe) ...[
            Divider(height: 1, color: AppColors.black100, indent: 16.w, endIndent: 16.w),
            // 신고하기
            _buildMenuItem(
              icon: 'assets/icons/icon_siren.svg',
              label: '신고하기',
              labelColor: AppColors.red,
              iconColor: AppColors.red,
              onTap: () => setState(() => _mode = _MenuMode.reportCategories),
            ),
            Divider(height: 1, color: AppColors.black100, indent: 16.w, endIndent: 16.w),
            // 차단하기
            _buildMenuItem(
              icon: 'assets/icons/icon_block.svg',
              label: '차단하기',
              onTap: _handleBlock,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
    Color? labelColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 20.w,
              height: 20.w,
              colorFilter: ColorFilter.mode(
                iconColor ?? AppColors.black900,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              label,
              style: AppTextStyles.label_16.copyWith(
                color: labelColor ?? AppColors.black900,
              ),
            ),
          ],
        ),
      ),
    );
  }
```

- [ ] **Step 4: _buildCategoryMenu 메서드 작성**

신고 유형 선택 메뉴. 타이틀 "신고 유형 선택" + 7개 카테고리.

```dart
  Widget _buildCategoryMenu() {
    return Container(
      width: 204.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 12,
            color: AppColors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              '신고 유형 선택',
              style: AppTextStyles.label_16.copyWith(
                color: AppColors.black900,
              ),
            ),
          ),
          // 카테고리 목록
          ...ReportCategory.values.map((category) {
            final isLast = category == ReportCategory.values.last;
            return Column(
              children: [
                Divider(height: 1, color: AppColors.black100, indent: 16.w, endIndent: 16.w),
                InkWell(
                  onTap: () => _handleReportCategorySelected(category),
                  borderRadius: isLast
                      ? BorderRadius.only(
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r),
                        )
                      : BorderRadius.zero,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        category.label,
                        style: AppTextStyles.label16Medium.copyWith(
                          color: AppColors.black900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
```

- [ ] **Step 5: 액션 핸들러 메서드 작성 (복사, 차단, 신고)**

```dart
  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: widget.message.message));
    widget.onDismiss();
    if (mounted) {
      AppSnackbar.show(
        context,
        message: '메시지가 복사되었어요',
        iconPath: 'assets/icons/icon_copy.svg',
      );
    }
  }

  void _handleBlock() {
    widget.onDismiss();
    widget.onBlock(widget.message.sender.participantId);
    if (mounted) {
      AppSnackbar.show(
        context,
        message: '해당 유저를 차단했어요',
        iconPath: 'assets/icons/icon_block.svg',
      );
    }
  }

  void _handleReportCategorySelected(ReportCategory category) {
    widget.onDismiss();

    // 확인 다이얼로그 표시
    AppDialog.show(
      context: context,
      title: '해당 유저를 신고할까요?',
      cancelText: '취소',
      confirmText: '신고하기',
      isDestructive: true,
      customContent: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTextStyles.paragraph_14.copyWith(
            color: AppColors.black600,
          ),
          children: [
            const TextSpan(text: '선택한 신고 사유: '),
            TextSpan(
              text: category.label,
              style: AppTextStyles.paragraph14Semibold.copyWith(
                color: AppColors.red,
              ),
            ),
            const TextSpan(text: '\n신고된 내용은 검토 후 조치할게요'),
          ],
        ),
      ),
      onConfirm: () {
        // TODO: 신고 API 호출
        // await ref.read(reportUsecaseProvider).execute(
        //   participantId: widget.message.sender.participantId,
        //   gameId: widget.message.gameId,
        //   messageId: widget.message.id,
        //   category: category,
        // );
        AppSnackbar.show(
          context,
          message: '신고가 접수되었어요',
        );
      },
    );
  }
```

- [ ] **Step 6: Commit**

```bash
git add lib/features/chat/presentation/widgets/chat_context_menu.dart
git commit -m "feat(chat): 채팅 컨텍스트 메뉴 오버레이 위젯 구현"
```

---

### Task 3: ChatMessageBubble에 롱프레스 핸들러 추가

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_message_bubble.dart`

- [ ] **Step 1: onLongPress 콜백 파라미터 추가**

`ChatMessageBubble`에 `onLongPress` 콜백을 추가한다. 시스템 메시지에는 롱프레스를 적용하지 않는다.

```dart
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    required this.isMe,
    required this.myTeam,
    this.showNickname = true,
    this.showTime = true,
    this.isDarkMode = false,
    this.onLongPress,  // 추가
    super.key,
  });

  // ... 기존 필드 ...

  /// 메시지 롱프레스 콜백
  final VoidCallback? onLongPress;
```

- [ ] **Step 2: build 메서드에 GestureDetector 래핑**

시스템 메시지가 아닌 경우에만 GestureDetector를 감싼다.

기존 `build` 메서드의 반환부를 수정:

```dart
  @override
  Widget build(BuildContext context) {
    if (_isSystemMessage) {
      return _buildSystemMessage();
    }

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.only(
          left: isMe ? 16.w : 24.w,
          right: isMe ? 24.w : 16.w,
          top: showNickname ? 8.h : 2.h,
          bottom: 2.h,
        ),
        child: isMe ? _buildMyMessage() : _buildOtherMessage(),
      ),
    );
  }
```

기존 Padding 위에 GestureDetector를 추가하는 것이므로, 기존 Padding을 GestureDetector의 child로 이동한다.

- [ ] **Step 3: Commit**

```bash
git add lib/features/chat/presentation/widgets/chat_message_bubble.dart
git commit -m "feat(chat): ChatMessageBubble에 onLongPress 콜백 추가"
```

---

### Task 4: ChatMessageList에 롱프레스 콜백 전달 + 차단 필터링

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_message_list.dart`

- [ ] **Step 1: 콜백 파라미터 + blockedIds 추가**

```dart
class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    required this.messages,
    required this.myParticipantId,
    required this.myTeam,
    this.isDarkMode = false,
    this.onOverscrollDown,
    this.onMessageLongPress,  // 추가
    this.blockedParticipantIds = const {},  // 추가
    super.key,
  });

  // ... 기존 필드 ...

  /// 메시지 롱프레스 콜백 (메시지, BuildContext, isMe 전달)
  final void Function(ChatMessageDto message, BuildContext context, bool isMe)? onMessageLongPress;

  /// 차단된 유저 ID 목록 (해당 유저 메시지 숨김)
  final Set<int> blockedParticipantIds;
```

- [ ] **Step 2: 메시지 필터링 + 롱프레스 콜백 연결**

`build` 메서드에서 차단된 유저 메시지를 필터링하고, ChatMessageBubble에 `onLongPress`를 전달한다.

```dart
  @override
  Widget build(BuildContext context) {
    // 차단된 유저 메시지 필터링
    final filteredMessages = widget.blockedParticipantIds.isEmpty
        ? widget.messages
        : widget.messages
              .where((m) => !widget.blockedParticipantIds.contains(
                    m.sender.participantId,
                  ))
              .toList();

    if (filteredMessages.isEmpty) {
      return Center(
        child: Text(
          '채팅을 시작해보세요',
          style: AppTextStyles.tag_12.copyWith(color: AppColors.black400),
        ),
      );
    }

    return NotificationListener<OverscrollNotification>(
      // ... 기존 코드 ...
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: filteredMessages.length,
        itemBuilder: (context, index) {
          final msgIndex = filteredMessages.length - 1 - index;
          final message = filteredMessages[msgIndex];
          final isMe = message.sender.participantId == widget.myParticipantId;

          final prevMessage = msgIndex > 0
              ? filteredMessages[msgIndex - 1]
              : null;
          final nextMessage = msgIndex < filteredMessages.length - 1
              ? filteredMessages[msgIndex + 1]
              : null;

          final showNickname =
              prevMessage == null || !_isSameGroup(prevMessage, message);
          final showTime =
              nextMessage == null || !_isSameGroup(message, nextMessage);
          final showDateDivider =
              prevMessage == null || _isDifferentDate(prevMessage, message);

          return Column(
            children: [
              if (showDateDivider) _buildDateDivider(message.kstDateTime),
              Builder(
                builder: (bubbleContext) {
                  return ChatMessageBubble(
                    message: message,
                    isMe: isMe,
                    myTeam: widget.myTeam,
                    showNickname: showNickname,
                    showTime: showTime,
                    isDarkMode: widget.isDarkMode,
                    onLongPress: widget.onMessageLongPress != null
                        ? () => widget.onMessageLongPress!(
                              message,
                              bubbleContext,
                              isMe,
                            )
                        : null,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
```

`didUpdateWidget`도 `filteredMessages`를 사용하도록 변경하지 않아도 된다 — `widget.messages.length` 비교는 원본 기준이 맞다 (새 메시지 도착 감지 목적).

- [ ] **Step 3: Commit**

```bash
git add lib/features/chat/presentation/widgets/chat_message_list.dart
git commit -m "feat(chat): ChatMessageList에 롱프레스 콜백 및 차단 필터링 추가"
```

---

### Task 5: ChatProvider에 차단 기능 추가

**Files:**
- Modify: `lib/features/chat/presentation/providers/chat_provider.dart`

- [ ] **Step 1: ChatState에 blockedParticipantIds 필드 추가**

```dart
class ChatState {
  final List<ChatMessageDto> allScopeMessages;
  final List<ChatMessageDto> teamScopeMessages;
  final StompConnectionState connectionState;
  final String? errorMessage;
  final Set<int> blockedParticipantIds;  // 추가

  const ChatState({
    this.allScopeMessages = const [],
    this.teamScopeMessages = const [],
    this.connectionState = StompConnectionState.disconnected,
    this.errorMessage,
    this.blockedParticipantIds = const {},  // 추가
  });

  ChatState copyWith({
    List<ChatMessageDto>? allScopeMessages,
    List<ChatMessageDto>? teamScopeMessages,
    StompConnectionState? connectionState,
    Object? errorMessage = _sentinel,
    Set<int>? blockedParticipantIds,  // 추가
  }) {
    return ChatState(
      allScopeMessages: allScopeMessages ?? this.allScopeMessages,
      teamScopeMessages: teamScopeMessages ?? this.teamScopeMessages,
      connectionState: connectionState ?? this.connectionState,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      blockedParticipantIds:
          blockedParticipantIds ?? this.blockedParticipantIds,  // 추가
    );
  }
}
```

- [ ] **Step 2: ChatNotifier에 blockUser 메서드 추가**

```dart
  /// 유저 차단 (현재 게임 세션 동안만 유지)
  ///
  /// 차단된 유저의 메시지는 ChatMessageList에서 필터링됩니다.
  void blockUser(int participantId) {
    state = state.copyWith(
      blockedParticipantIds: {...state.blockedParticipantIds, participantId},
    );
  }
```

`disconnectChat()`에서 `state = const ChatState()`로 초기화되므로, 게임 종료 시 차단 목록도 자동 초기화된다.

- [ ] **Step 3: Commit**

```bash
git add lib/features/chat/presentation/providers/chat_provider.dart
git commit -m "feat(chat): ChatState에 유저 차단 기능 추가"
```

---

### Task 6: ChatOverlay에서 컨텍스트 메뉴 연결

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_overlay.dart`

- [ ] **Step 1: import 추가 + 롱프레스 핸들러 메서드 작성**

```dart
import 'chat_context_menu.dart';
```

`_ChatOverlayState`에 핸들러 메서드 추가:

```dart
  void _handleMessageLongPress(
    ChatMessageDto message,
    BuildContext bubbleContext,
    bool isMe,
  ) {
    ChatContextMenu.show(
      context: bubbleContext,
      message: message,
      messageWidget: ChatMessageBubble(
        message: message,
        isMe: isMe,
        myTeam: widget.myTeam,
        showNickname: false,
        showTime: false,
        isDarkMode: widget.isDarkMode,
      ),
      isMe: isMe,
      onBlock: (participantId) {
        ref.read(chatNotifierProvider.notifier).blockUser(participantId);
      },
    );
  }
```

- [ ] **Step 2: ChatMessageList에 콜백 + blockedIds 전달**

기존 `ChatMessageList` 위젯 2개(allScope, teamScope)에 파라미터 추가:

```dart
  // build 메서드 내 PageView children에서:
  ChatMessageList(
    messages: chatState.allScopeMessages,
    myParticipantId: widget.myParticipantId,
    myTeam: widget.myTeam,
    isDarkMode: widget.isDarkMode,
    onMessageLongPress: _handleMessageLongPress,
    blockedParticipantIds: chatState.blockedParticipantIds,
  ),
  ChatMessageList(
    messages: chatState.teamScopeMessages,
    myParticipantId: widget.myParticipantId,
    myTeam: widget.myTeam,
    isDarkMode: widget.isDarkMode,
    onMessageLongPress: _handleMessageLongPress,
    blockedParticipantIds: chatState.blockedParticipantIds,
  ),
```

- [ ] **Step 3: import chat_message_bubble.dart 추가**

`_handleMessageLongPress`에서 `ChatMessageBubble`을 직접 생성하므로 import 필요:

```dart
import 'chat_message_bubble.dart';
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/chat/presentation/widgets/chat_overlay.dart
git commit -m "feat(chat): ChatOverlay에 컨텍스트 메뉴 연결"
```

---

### Task 7: 비속어 필터링 서비스

**Files:**
- Create: `lib/core/services/content_filter/profanity_filter.dart`
- Modify: `lib/features/chat/presentation/widgets/chat_message_bubble.dart`

- [ ] **Step 1: ProfanityFilter 유틸리티 클래스 작성**

```dart
/// 채팅 메시지 비속어 필터링 유틸리티
///
/// 부적절한 단어를 감지하고 마스킹 처리합니다.
/// 필터링 단어 목록은 추후 서버에서 동적으로 받아올 수 있습니다.
class ProfanityFilter {
  ProfanityFilter._();

  /// 필터링 대상 단어 목록
  ///
  /// TODO: 서버에서 필터링 단어 목록을 동적으로 로드하는 기능 추가
  static const List<String> _blockedWords = [
    // 욕설/비하
    '시발', '씨발', 'ㅅㅂ', 'ㅆㅂ', '씹', '병신', 'ㅂㅅ',
    '지랄', 'ㅈㄹ', '개새끼', '새끼', 'ㅅㅋ',
    '꺼져', '닥쳐', '죽어',
    // 비하/차별
    '장애인', '찐따', '쪼다',
    // 스팸 키워드
    '돈벌기', '부업추천', '카톡추가',
  ];

  /// 메시지에서 비속어를 '***'로 마스킹
  ///
  /// [message] 원본 메시지
  /// Returns 필터링된 메시지
  static String filter(String message) {
    var filtered = message;
    for (final word in _blockedWords) {
      if (filtered.contains(word)) {
        filtered = filtered.replaceAll(word, '***');
      }
    }
    return filtered;
  }
}
```

- [ ] **Step 2: ChatMessageBubble에 필터 적용**

`chat_message_bubble.dart`에서 메시지 텍스트 표시 시 `ProfanityFilter.filter()` 적용.

import 추가:
```dart
import '../../../../core/services/content_filter/profanity_filter.dart';
```

`_buildMyMessage()`, `_buildOtherMessage()` 내부의 `message.message` 사용 부분을 필터링된 텍스트로 교체.

클래스에 getter 추가:
```dart
  String get _filteredMessage => ProfanityFilter.filter(message.message);
```

그리고 `_buildMyMessage()`, `_buildOtherMessage()`의 Text 위젯에서 `message.message` → `_filteredMessage`로 변경:

```dart
  // _buildMyMessage 내부
  child: Text(
    _filteredMessage,  // message.message → _filteredMessage
    style: AppTextStyles.paragraph_14.copyWith(
      color: isDarkMode ? AppColors.white : AppColors.black900,
    ),
  ),

  // _buildOtherMessage 내부
  child: Text(
    _filteredMessage,  // message.message → _filteredMessage
    style: AppTextStyles.paragraph_14.copyWith(
      color: isDarkMode ? AppColors.white : AppColors.black900,
    ),
  ),
```

시스템 메시지(`_buildSystemMessage`)에는 필터를 적용하지 않는다.

- [ ] **Step 3: Commit**

```bash
git add lib/core/services/content_filter/profanity_filter.dart
git add lib/features/chat/presentation/widgets/chat_message_bubble.dart
git commit -m "feat(chat): 비속어 필터링 서비스 구현 및 메시지 버블에 적용"
```

---

### Task 8: 빌드 확인 + 최종 검증

- [ ] **Step 1: build_runner 실행**

```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers
flutter pub run build_runner build --delete-conflicting-outputs
```

ChatState의 변경은 코드 생성 대상이 아니지만(freezed 아님), ChatNotifier는 `@riverpod`이므로 `.g.dart` 재생성이 필요할 수 있다. 실제로 `ChatState`는 일반 클래스이고 `ChatNotifier`의 `build()` 시그니처는 변경되지 않으므로 재생성이 불필요할 수 있으나, 안전을 위해 실행한다.

Expected: BUILD SUCCESSFUL

- [ ] **Step 2: flutter analyze 실행**

```bash
flutter analyze
```

Expected: No issues found

- [ ] **Step 3: 최종 Commit**

lint 이슈가 있으면 수정 후 커밋:

```bash
git add -A
git commit -m "fix(chat): lint 이슈 수정"
```

---

## TODO (API 미구현 — 서버 연동 시 처리)

1. **신고 API**: `POST /api/reports` — `{ participantId, gameId, messageId, category }`
   - `chat_context_menu.dart`의 `_handleReportCategorySelected` 내부 TODO 주석 참조
   - `lib/features/chat/data/datasources/` 에 `ReportRemoteDataSource` 추가
   - `lib/features/chat/domain/usecases/` 에 `ReportUserUsecase` 추가
   - `lib/features/chat/data/repositories/` 에 `ReportRepositoryImpl` 추가

2. **차단 API** (선택): 현재는 클라이언트 사이드 세션 내 차단. 서버 사이드 영구 차단이 필요하면 API 연동 추가.

3. **비속어 목록 서버 동기화**: `ProfanityFilter._blockedWords`를 서버에서 동적으로 로드하는 기능.
