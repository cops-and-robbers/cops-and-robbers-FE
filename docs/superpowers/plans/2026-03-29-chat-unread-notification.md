# Chat Unread Notification UX Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 채팅 시트가 접혀있거나 다른 탭을 보고 있을 때, 새 메시지 도착을 슬라이드-인 프리뷰 카드 + 탭 빨간 점으로 알려주는 기능 구현

**Architecture:** `ChatNotifier`에 읽지 않은 카운트 + UI 가시성 상태를 추가하고, 메시지 수신 시 가시성 조건에 따라 카운트 증가/프리뷰 메시지 설정. `ChatOverlay`가 가시성 변경을 notifier에 통보하고, 프리뷰 카드와 탭 배지를 렌더링.

**Tech Stack:** Flutter, Riverpod, flutter_screenutil, AnimatedSlide/AnimatedOpacity

---

## File Structure

| 파일 | 역할 | 작업 |
|------|------|------|
| `lib/features/chat/presentation/providers/chat_provider.dart` | ChatState + ChatNotifier | 수정: unread 필드, UI 가시성 추적, 읽음 처리 메서드 |
| `lib/features/chat/presentation/widgets/chat_preview_card.dart` | 슬라이드-인 프리뷰 카드 | 신규 |
| `lib/features/chat/presentation/widgets/chat_overlay.dart` | 채팅 오버레이 컨테이너 | 수정: 프리뷰 카드 배치, 탭 빨간 점, 가시성 통보 |

---

### Task 1: ChatState에 읽지 않은 메시지 필드 추가

**Files:**
- Modify: `lib/features/chat/presentation/providers/chat_provider.dart:30-67`

- [ ] **Step 1: ChatState에 unread 필드 3개 추가**

`ChatState` 클래스에 다음 필드를 추가한다:

```dart
class ChatState {
  final List<ChatMessageDto> allScopeMessages;
  final List<ChatMessageDto> teamScopeMessages;
  final StompConnectionState connectionState;
  final String? errorMessage;
  final Set<int> blockedParticipantIds;

  // ── 새로 추가 ──
  /// 전체 채팅 읽지 않은 메시지 수
  final int unreadAllCount;

  /// 팀 채팅 읽지 않은 메시지 수
  final int unreadTeamCount;

  /// 프리뷰 카드에 표시할 최신 메시지 (null이면 프리뷰 숨김)
  final ChatMessageDto? lastPreviewMessage;

  const ChatState({
    this.allScopeMessages = const [],
    this.teamScopeMessages = const [],
    this.connectionState = StompConnectionState.disconnected,
    this.errorMessage,
    this.blockedParticipantIds = const {},
    this.unreadAllCount = 0,
    this.unreadTeamCount = 0,
    this.lastPreviewMessage,
  });

  ChatState copyWith({
    List<ChatMessageDto>? allScopeMessages,
    List<ChatMessageDto>? teamScopeMessages,
    StompConnectionState? connectionState,
    Object? errorMessage = _sentinel,
    Set<int>? blockedParticipantIds,
    int? unreadAllCount,
    int? unreadTeamCount,
    Object? lastPreviewMessage = _sentinel,
  }) {
    return ChatState(
      allScopeMessages: allScopeMessages ?? this.allScopeMessages,
      teamScopeMessages: teamScopeMessages ?? this.teamScopeMessages,
      connectionState: connectionState ?? this.connectionState,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      blockedParticipantIds:
          blockedParticipantIds ?? this.blockedParticipantIds,
      unreadAllCount: unreadAllCount ?? this.unreadAllCount,
      unreadTeamCount: unreadTeamCount ?? this.unreadTeamCount,
      lastPreviewMessage: lastPreviewMessage == _sentinel
          ? this.lastPreviewMessage
          : lastPreviewMessage as ChatMessageDto?,
    );
  }
}
```

`lastPreviewMessage`도 `errorMessage`와 동일한 sentinel 패턴을 사용한다. `copyWith(lastPreviewMessage: null)`로 명시적 null 설정이 가능해야 프리뷰를 숨길 수 있기 때문.

- [ ] **Step 2: 코드 분석 확인**

Run: `flutter analyze lib/features/chat/presentation/providers/chat_provider.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/chat/presentation/providers/chat_provider.dart
git commit -m "feat(chat): ChatState에 unreadAllCount, unreadTeamCount, lastPreviewMessage 필드 추가 #200"
```

---

### Task 2: ChatNotifier에 UI 가시성 추적 + 읽음 처리 로직 추가

**Files:**
- Modify: `lib/features/chat/presentation/providers/chat_provider.dart:75-544`

- [ ] **Step 1: ChatNotifier에 UI 가시성 내부 변수 추가**

`ChatNotifier` 클래스 상단(기존 private 변수 영역)에 추가:

```dart
/// UI 가시성 상태 (ChatOverlay가 통보)
bool _isSheetExpanded = false;
int _currentVisiblePage = 0; // 0 = ALL, 1 = TEAM
int _myParticipantId = 0;
```

- [ ] **Step 2: UI 가시성 통보 메서드 추가**

`blockUser` 메서드 아래에 추가:

```dart
/// ChatOverlay가 시트 펼침/접힘 상태 변경 시 호출
///
/// 시트가 펼쳐지면 현재 보고 있는 탭의 읽지 않은 카운트를 초기화합니다.
void updateSheetExpanded(bool expanded) {
  _isSheetExpanded = expanded;
  if (expanded) {
    _markCurrentPageAsRead();
  }
}

/// ChatOverlay가 탭 스와이프 시 호출
///
/// 이동한 탭의 읽지 않은 카운트를 초기화합니다.
void updateCurrentPage(int page) {
  _currentVisiblePage = page;
  if (_isSheetExpanded) {
    _markCurrentPageAsRead();
  }
}

/// 본인 participantId 설정 (프리뷰 필터링용)
void setMyParticipantId(int pid) {
  _myParticipantId = pid;
}

/// 프리뷰 카드 탭 시 호출
///
/// 해당 스코프 탭으로 전환 + 읽음 처리를 위해 카운트 초기화 + 프리뷰 숨김.
/// 실제 시트 펼침과 탭 전환은 ChatOverlay에서 처리.
void onPreviewTapped() {
  final msg = state.lastPreviewMessage;
  if (msg == null) return;

  if (msg.scope == 'TEAM') {
    state = state.copyWith(unreadTeamCount: 0, lastPreviewMessage: null);
  } else {
    state = state.copyWith(unreadAllCount: 0, lastPreviewMessage: null);
  }
}

/// 현재 보고 있는 페이지의 읽지 않은 카운트를 0으로 초기화
void _markCurrentPageAsRead() {
  if (_currentVisiblePage == 0) {
    if (state.unreadAllCount > 0) {
      state = state.copyWith(unreadAllCount: 0);
    }
  } else {
    if (state.unreadTeamCount > 0) {
      state = state.copyWith(unreadTeamCount: 0);
    }
  }
}
```

- [ ] **Step 3: 메시지 수신 핸들러에 읽지 않은 카운트 증가 로직 추가**

`_setupStreams()` 내 `_messageSub` 리스너를 수정한다. 기존 메시지 추가 로직 뒤에 unread 증가 + 프리뷰 설정을 추가:

```dart
_messageSub = datasource.onMessage.listen((message) {
  // ── 기존: scope별 메시지 추가 ──
  if (message.scope == 'TEAM') {
    final updated = [...state.teamScopeMessages, message];
    final trimmed = updated.length > _maxMessages
        ? updated.sublist(updated.length - _maxMessages)
        : updated;
    state = state.copyWith(teamScopeMessages: trimmed);
  } else {
    final updated = [...state.allScopeMessages, message];
    final trimmed = updated.length > _maxMessages
        ? updated.sublist(updated.length - _maxMessages)
        : updated;
    state = state.copyWith(allScopeMessages: trimmed);
  }

  // ── 새로 추가: 읽지 않은 카운트 증가 + 프리뷰 설정 ──
  _handleUnreadUpdate(message);
});
```

그리고 `_handleUnreadUpdate` 메서드를 추가:

```dart
/// 새 메시지 수신 시 읽지 않은 카운트 증가 + 프리뷰 메시지 설정
void _handleUnreadUpdate(ChatMessageDto message) {
  // 내가 보낸 메시지는 무시
  if (message.sender.participantId == _myParticipantId) return;

  // 차단된 사용자 메시지는 무시
  if (state.blockedParticipantIds.contains(message.sender.participantId)) {
    return;
  }

  final isTeamMessage = message.scope == 'TEAM';
  final isCurrentlyViewing = _isSheetExpanded &&
      (isTeamMessage ? _currentVisiblePage == 1 : _currentVisiblePage == 0);

  // 현재 보고 있는 탭이면 읽음 처리 (카운트 증가 안 함)
  if (isCurrentlyViewing) return;

  // 카운트 증가
  if (isTeamMessage) {
    state = state.copyWith(
      unreadTeamCount: state.unreadTeamCount + 1,
      lastPreviewMessage: message,
    );
  } else {
    // 전체 채팅: 현재 팀 프리뷰가 표시 중이면 전체 채팅 프리뷰로 교체하지 않음
    final currentPreview = state.lastPreviewMessage;
    final shouldUpdatePreview = currentPreview == null ||
        currentPreview.scope != 'TEAM';
    state = state.copyWith(
      unreadAllCount: state.unreadAllCount + 1,
      lastPreviewMessage: shouldUpdatePreview ? message : currentPreview,
    );
  }
}
```

팀 채팅 > 전체 채팅 우선순위: 팀 메시지는 항상 프리뷰를 덮어쓰고, 전체 메시지는 현재 팀 프리뷰가 있으면 덮어쓰지 않는다.

- [ ] **Step 4: 더미 모드 메시지에도 unread 로직 적용**

`_addDummyMessage` 메서드 마지막에 `_handleUnreadUpdate(msg)` 호출 추가:

```dart
void _addDummyMessage({
  required String message,
  required String scope,
  required int participantId,
  required String nickname,
  required String team,
}) {
  final msg = ChatMessageDto(
    id: const Uuid().v4(),
    gameId: _gameId ?? 1,
    sender: ChatSenderDto(
      participantId: participantId,
      nickname: nickname,
      team: team,
    ),
    message: message,
    timestamp: DateTime.now().toIso8601String(),
    scope: scope,
  );

  if (scope == 'TEAM') {
    final updated = [...state.teamScopeMessages, msg];
    final trimmed = updated.length > _maxMessages
        ? updated.sublist(updated.length - _maxMessages)
        : updated;
    state = state.copyWith(teamScopeMessages: trimmed);
  } else {
    final updated = [...state.allScopeMessages, msg];
    final trimmed = updated.length > _maxMessages
        ? updated.sublist(updated.length - _maxMessages)
        : updated;
    state = state.copyWith(allScopeMessages: trimmed);
  }

  // 더미 모드에서도 읽지 않은 카운트 + 프리뷰 동작
  _handleUnreadUpdate(msg);
}
```

- [ ] **Step 5: disconnectChat에서 가시성 상태 초기화**

`disconnectChat()` 메서드에서 `state = const ChatState();` 직전에 추가:

```dart
_isSheetExpanded = false;
_currentVisiblePage = 0;
_myParticipantId = 0;
```

- [ ] **Step 6: 코드 분석 확인**

Run: `flutter analyze lib/features/chat/presentation/providers/chat_provider.dart`
Expected: No errors

- [ ] **Step 7: Commit**

```bash
git add lib/features/chat/presentation/providers/chat_provider.dart
git commit -m "feat(chat): ChatNotifier에 UI 가시성 추적 + 읽지 않은 카운트 증가 + 읽음 처리 로직 추가 #200"
```

---

### Task 3: ChatPreviewCard 위젯 생성

**Files:**
- Create: `lib/features/chat/presentation/widgets/chat_preview_card.dart`

- [ ] **Step 1: ChatPreviewCard 위젯 작성**

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../data/models/chat_message_dto.dart';

/// 새 채팅 메시지 프리뷰 카드
///
/// 입력바 위에 슬라이드-인으로 나타나며 3초 후 자동으로 사라집니다.
/// 탭하면 [onTap] 콜백이 호출됩니다.
class ChatPreviewCard extends StatefulWidget {
  const ChatPreviewCard({
    required this.message,
    required this.isDarkMode,
    required this.onTap,
    required this.onDismissed,
    super.key,
  });

  final ChatMessageDto message;
  final bool isDarkMode;
  final VoidCallback onTap;

  /// 3초 후 자동 퇴장 완료 시 호출
  final VoidCallback onDismissed;

  @override
  State<ChatPreviewCard> createState() => _ChatPreviewCardState();
}

class _ChatPreviewCardState extends State<ChatPreviewCard> {
  bool _visible = false;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    // 다음 프레임에서 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
        _startAutoDismiss();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 메시지가 바뀌면 타이머 리셋 + 다시 보이기
    if (oldWidget.message.id != widget.message.id) {
      _autoDismissTimer?.cancel();
      setState(() => _visible = true);
      _startAutoDismiss();
    }
  }

  void _startAutoDismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
  }

  void _handleTap() {
    _autoDismissTimer?.cancel();
    widget.onTap();
    setState(() => _visible = false);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTeamScope = widget.message.scope == 'TEAM';
    final dark = widget.isDarkMode;

    final bgColor = isTeamScope
        ? (dark ? AppColors.green100 : AppColors.blue100)
        : (dark ? AppColors.black900 : AppColors.black100);
    final borderColor = isTeamScope
        ? (dark ? AppColors.green500 : AppColors.blue500)
        : (dark ? AppColors.black700 : AppColors.black300);
    final nicknameColor = isTeamScope
        ? (dark ? AppColors.green : AppColors.blue)
        : (dark ? AppColors.green : AppColors.blue);
    final messageColor = dark ? AppColors.black200 : AppColors.black800;
    final badgeBg = dark ? AppColors.green : AppColors.blue;
    final badgeText = dark ? AppColors.black : AppColors.white;

    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.5),
      duration: _visible
          ? const Duration(milliseconds: 300)
          : const Duration(milliseconds: 200),
      curve: _visible ? Curves.easeOut : Curves.easeIn,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: _visible
            ? const Duration(milliseconds: 300)
            : const Duration(milliseconds: 200),
        onEnd: () {
          // 페이드아웃 완료 후 dismissed 콜백
          if (!_visible) {
            widget.onDismissed();
          }
        },
        child: GestureDetector(
          onTap: _handleTap,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontal12,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontal12,
              vertical: AppSpacing.vertical8,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor),
              borderRadius: AppRadius.large,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 닉네임 + 스코프 배지
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.message.sender.nickname,
                        style: AppTextStyles.tag_12.copyWith(
                          color: nicknameColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (isTeamScope) ...[
                      SizedBox(width: AppSpacing.horizontal4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: AppRadius.medium,
                        ),
                        child: Text(
                          '팀',
                          style: AppTextStyles.tag_10.copyWith(
                            color: badgeText,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                // 메시지 본문
                Text(
                  widget.message.message,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: messageColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 코드 분석 확인**

Run: `flutter analyze lib/features/chat/presentation/widgets/chat_preview_card.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/chat/presentation/widgets/chat_preview_card.dart
git commit -m "feat(chat): ChatPreviewCard 슬라이드-인 프리뷰 카드 위젯 생성 #200"
```

---

### Task 4: ChatOverlay에 프리뷰 카드 + 탭 빨간 점 통합

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_overlay.dart`

- [ ] **Step 1: import 추가**

파일 상단 import 섹션에 추가:

```dart
import 'chat_preview_card.dart';
```

- [ ] **Step 2: _ChatOverlayState에 initState 수정 — notifier에 가시성 통보 연결**

기존 `initState`를 수정하여 `setMyParticipantId` 호출 추가:

```dart
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
```

- [ ] **Step 3: _onSheetChanged 수정 — 시트 펼침/접힘을 notifier에 통보**

기존 `_onSheetChanged`에서 `_isExpanded` 상태 변경 시 notifier에도 알린다:

```dart
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
```

- [ ] **Step 4: PageView onPageChanged 수정 — 탭 전환을 notifier에 통보**

`build()` 메서드 내 PageView의 `onPageChanged` 콜백을 수정:

```dart
PageView(
  controller: _pageController,
  onPageChanged: (page) {
    setState(() => _currentPage = page);
    // notifier에 현재 페이지 통보
    ref.read(chatNotifierProvider.notifier).updateCurrentPage(page);
  },
  children: [
    // ... 기존 ChatMessageList 2개 그대로 ...
  ],
),
```

- [ ] **Step 5: 프리뷰 카드 탭 핸들러 추가**

`_handleMessageLongPress` 메서드 아래에 추가:

```dart
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
```

- [ ] **Step 6: build() 내 Column에 프리뷰 카드 배치**

`ChatInputBar` 바로 위에 프리뷰 카드를 추가한다. `build()` 메서드의 Column children에서 `ChatInputBar` 위에 삽입:

기존:
```dart
child: Column(
  children: [
    // ... drag handle, expanded content ...
    ChatInputBar(
      onSend: _handleSend,
      enabled: isConnected,
      onFocusGain: _onInputFocused,
      isDarkMode: widget.isDarkMode,
    ),
    SizedBox(height: bottomMargin),
  ],
),
```

변경:
```dart
child: Column(
  children: [
    // ... drag handle, expanded content ...
    // 프리뷰 카드
    if (chatState.lastPreviewMessage != null)
      ChatPreviewCard(
        message: chatState.lastPreviewMessage!,
        isDarkMode: widget.isDarkMode,
        onTap: () => _handlePreviewTap(
          chatState.lastPreviewMessage!,
        ),
        onDismissed: () {
          ref.read(chatNotifierProvider.notifier).state =
              ref.read(chatNotifierProvider).copyWith(
                lastPreviewMessage: null,
              );
        },
      ),
    ChatInputBar(
      onSend: _handleSend,
      enabled: isConnected,
      onFocusGain: _onInputFocused,
      isDarkMode: widget.isDarkMode,
    ),
    SizedBox(height: bottomMargin),
  ],
),
```

**주의:** `onDismissed`에서 notifier의 state에 직접 접근하지 않고 메서드를 통해 처리하는 것이 더 깔끔하다. ChatNotifier에 `dismissPreview()` 메서드를 추가:

```dart
/// 프리뷰 카드 자동 퇴장 완료 시 호출
void dismissPreview() {
  state = state.copyWith(lastPreviewMessage: null);
}
```

그러면 onDismissed는:
```dart
onDismissed: () {
  ref.read(chatNotifierProvider.notifier).dismissPreview();
},
```

- [ ] **Step 7: _buildPageIndicator 수정 — 탭 빨간 점 추가**

`_buildPageIndicator()` 메서드를 수정하여 읽지 않은 메시지가 있는 탭에 빨간 점을 표시:

```dart
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
```

- [ ] **Step 8: 코드 분석 확인**

Run: `flutter analyze lib/features/chat/presentation/widgets/chat_overlay.dart`
Expected: No errors

- [ ] **Step 9: Commit**

```bash
git add lib/features/chat/presentation/widgets/chat_overlay.dart lib/features/chat/presentation/providers/chat_provider.dart
git commit -m "feat(chat): ChatOverlay에 프리뷰 카드 배치 + 탭 빨간 점 + 가시성 통보 연동 #200"
```

---

### Task 5: 더미 모드로 전체 기능 검증

**Files:**
- No file changes, manual testing only

- [ ] **Step 1: 코드 생성 실행**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: 빌드 성공 (chat_provider.g.dart 재생성)

- [ ] **Step 2: 전체 분석 실행**

Run: `flutter analyze`
Expected: No errors in chat feature files

- [ ] **Step 3: 더미 모드로 앱 실행하여 수동 검증**

검증 시나리오:
1. 게임 화면 진입 → 채팅 시트 접힌 상태에서 더미 메시지 수신 → **프리뷰 카드가 입력바 위에 슬라이드-인**되는지 확인
2. 프리뷰 카드가 **3초 후 자동으로 사라지는지** 확인
3. 프리뷰 카드 **탭 시 시트가 펼쳐지고 해당 탭으로 이동**하는지 확인
4. 시트 펼친 상태에서 전체 채팅 탭 보는 중 팀 메시지 수신 → **팀 탭 dot에 빨간 점** 표시되는지 확인
5. 팀 탭으로 스와이프 → **빨간 점 사라지는지** 확인
6. 시트 접기 → 다시 펼치기 → **카운트가 초기화되는지** 확인
7. 연속 메시지 수신 → **프리뷰가 새 메시지로 교체되는지** 확인
8. 다크모드(ROBBER팀) → **색상이 초록 계열로 변경되는지** 확인

- [ ] **Step 4: 최종 Commit (필요 시)**

수동 검증 중 발견된 소소한 이슈 수정 후 커밋.

```bash
git add -u
git commit -m "fix(chat): 읽지 않은 메시지 알림 UX 수동 검증 후 미세 조정 #200"
```
