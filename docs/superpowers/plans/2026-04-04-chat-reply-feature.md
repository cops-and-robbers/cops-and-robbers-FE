# 채팅 답장(Reply) 기능 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 채팅 메시지에 답장(Reply) 기능을 추가한다. 롱프레스 컨텍스트 메뉴에서 답장을 선택하면 인용 프리뷰가 표시되고, 전송 시 2단 합체 버블로 렌더링된다. 인용 헤더를 탭하면 원본 메시지로 스크롤 이동한다.

**Architecture:** 메시지 텍스트에 `@reply{messageId|닉네임|원본메시지}답장내용` 마크업을 삽입하는 프론트 전용 방식. 백엔드는 일반 텍스트로 처리하고, 프론트에서 마크업을 파싱하여 2단 버블을 렌더링한다. `ChatOverlay`가 `_replyingTo` 로컬 상태를 관리하고, `ChatMessageBubble`이 마크업을 파싱하여 인용 헤더 + 답장 본문을 표시한다.

**Tech Stack:** Flutter, flutter_screenutil, flutter_svg

---

## File Map

| 작업 | 파일 | 책임 |
|------|------|------|
| 생성 | `lib/features/chat/domain/utils/reply_markup_parser.dart` | 답장 마크업 파싱/조합 유틸리티 |
| 생성 | `lib/features/chat/presentation/widgets/reply_preview_bar.dart` | 입력바 위 인용 프리뷰 바 위젯 |
| 수정 | `lib/features/chat/presentation/widgets/chat_context_menu.dart` | "답장" 메뉴 항목 추가 |
| 수정 | `lib/features/chat/presentation/widgets/chat_overlay.dart` | 답장 상태 관리 + 프리뷰 바 배치 + 마크업 포함 전송 |
| 수정 | `lib/features/chat/presentation/widgets/chat_message_bubble.dart` | 2단 답장 버블 렌더링 |
| 수정 | `lib/features/chat/presentation/widgets/chat_message_list.dart` | GlobalObjectKey + 원본 스크롤 이동 |

---

## 마크업 포맷 정의

```
@reply{messageId|닉네임|원본메시지텍스트}실제 답장 내용
```

- `messageId`: 원본 메시지의 `ChatMessageDto.id` (UUID)
- `닉네임`: 원본 발신자 닉네임
- `원본메시지텍스트`: 원본 메시지 전문 (줄바꿈은 공백으로 치환, `|`와 `}`는 이스케이프)
- `}` 이후: 실제 답장 텍스트

파싱 결과 모델:

```dart
class ReplyData {
  final String originalMessageId;
  final String originalNickname;
  final String originalText;
  final String replyText;
}
```

---

### Task 1: 답장 마크업 파싱/조합 유틸리티 생성

**Files:**
- Create: `lib/features/chat/domain/utils/reply_markup_parser.dart`

- [ ] **Step 1: ReplyData 클래스 + ReplyMarkupParser 작성**

```dart
/// 답장 마크업 파싱 결과
class ReplyData {
  const ReplyData({
    required this.originalMessageId,
    required this.originalNickname,
    required this.originalText,
    required this.replyText,
  });

  final String originalMessageId;
  final String originalNickname;
  final String originalText;
  final String replyText;
}

/// 답장 마크업 파싱 및 조합 유틸리티
///
/// 포맷: `@reply{messageId|닉네임|원본메시지}답장내용`
/// 서버에는 일반 텍스트로 전송되고, 프론트에서 파싱하여 2단 버블을 렌더링한다.
class ReplyMarkupParser {
  ReplyMarkupParser._();

  static final _replyRegex = RegExp(r'^@reply\{([^|]+)\|([^|]+)\|(.+?)\}(.+)$', dotAll: true);

  /// 메시지 텍스트에서 답장 마크업을 파싱한다.
  /// 답장 마크업이 없으면 null을 반환한다.
  static ReplyData? parse(String message) {
    final match = _replyRegex.firstMatch(message);
    if (match == null) return null;
    return ReplyData(
      originalMessageId: match.group(1)!,
      originalNickname: _unescape(match.group(2)!),
      originalText: _unescape(match.group(3)!),
      replyText: match.group(4)!,
    );
  }

  /// 답장 마크업을 조합한다.
  static String compose({
    required String originalMessageId,
    required String originalNickname,
    required String originalText,
    required String replyText,
  }) {
    final safeNickname = _escape(originalNickname);
    // 줄바꿈 → 공백 치환
    final safeText = _escape(originalText.replaceAll('\n', ' '));
    return '@reply{$originalMessageId|$safeNickname|$safeText}$replyText';
  }

  /// 메시지가 답장 마크업인지 빠르게 확인
  static bool isReply(String message) => message.startsWith('@reply{');

  /// 마크업 특수문자 이스케이프: | → \\|, } → \\}
  static String _escape(String text) =>
      text.replaceAll(r'\', r'\\').replaceAll('|', r'\|').replaceAll('}', r'\}');

  /// 이스케이프 복원
  static String _unescape(String text) =>
      text.replaceAll(r'\|', '|').replaceAll(r'\}', '}').replaceAll(r'\\', r'\');
}
```

- [ ] **Step 2: 빌드 확인**

```bash
flutter analyze lib/features/chat/domain/utils/reply_markup_parser.dart
```

Expected: No issues found!

- [ ] **Step 3: 커밋**

```bash
git add lib/features/chat/domain/utils/reply_markup_parser.dart
git commit -m "feat: 답장 마크업 파싱/조합 유틸리티 추가 #214"
```

---

### Task 2: ChatContextMenu에 "답장" 메뉴 항목 추가

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_context_menu.dart`

- [ ] **Step 1: ChatContextMenu에 onReply 콜백 추가**

`ChatContextMenu._()` 생성자와 `show()` 정적 메서드에 `onReply` 콜백을 추가한다.

생성자 파라미터에 추가 (기존 `onBlock` 아래):
```dart
final VoidCallback? onReply;
```

`show()` 메서드 시그니처에 추가 (기존 `onBlock` 파라미터 아래):
```dart
VoidCallback? onReply,
```

`show()` 내부 `ChatContextMenu._()` 생성 부에 전달:
```dart
onReply: onReply,
```

- [ ] **Step 2: _ActionMenu에 "답장" 메뉴 아이템 추가**

`_ActionMenu` 위젯에 `onReply` 콜백 추가:
```dart
final VoidCallback? onReply;
```

`_ActionMenu.build()` 내부, "복사하기" 항목 다음에 "답장" 항목을 추가한다. `!isMe` 조건 블록 앞에 삽입:

```dart
if (onReply != null) ...[
  _MenuDivider(isDarkMode: isDarkMode),
  _MenuItem(
    iconPath: 'assets/icons/icon_reply.svg',
    label: '답장',
    textColor: isDarkMode ? AppColors.white : AppColors.black,
    iconColor: isDarkMode ? AppColors.black200 : AppColors.black800,
    isDarkMode: isDarkMode,
    onTap: onReply!,
  ),
],
```

> **아이콘 에셋**: `assets/icons/icon_reply.svg`가 없으면 기존 에셋 중 적절한 것을 사용하거나, 추후 디자인팀에서 제공받을 때까지 `icon_arrow.svg`를 180도 회전 사용. 에셋 존재 여부를 먼저 확인할 것.

- [ ] **Step 3: _ChatContextMenuState에 _onReply 핸들러 추가**

`_onCopy()` 메서드 아래에 추가:

```dart
void _onReply() {
  _dismiss();
  widget.onReply?.call();
}
```

- [ ] **Step 4: _ActionMenu 생성 시 onReply 전달**

`build()` 내부 `_ActionMenu(...)` 생성 부에 추가:
```dart
onReply: _onReply,
```

- [ ] **Step 5: 빌드 확인**

```bash
flutter analyze lib/features/chat/presentation/widgets/chat_context_menu.dart
```

- [ ] **Step 6: 커밋**

```bash
git add lib/features/chat/presentation/widgets/chat_context_menu.dart
git commit -m "feat: 컨텍스트 메뉴에 답장 옵션 추가 #214"
```

---

### Task 3: 인용 프리뷰 바 위젯 생성

**Files:**
- Create: `lib/features/chat/presentation/widgets/reply_preview_bar.dart`

- [ ] **Step 1: ReplyPreviewBar 위젯 작성**

입력바 바로 위에 표시되는 인용 프리뷰. 왼쪽 accent 바 + 닉네임(볼드) + 원본 메시지(1줄 truncate) + X 닫기 버튼.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 답장 인용 프리뷰 바
///
/// 답장 모드 진입 시 ChatInputBar 위에 표시된다.
/// 원본 발신자 닉네임 + 메시지 미리보기 + 닫기(X) 버튼으로 구성.
class ReplyPreviewBar extends StatelessWidget {
  const ReplyPreviewBar({
    required this.nickname,
    required this.message,
    required this.onCancel,
    this.isDarkMode = false,
    super.key,
  });

  final String nickname;
  final String message;
  final VoidCallback onCancel;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal20,
        vertical: AppSpacing.vertical8,
      ),
      color: isDarkMode ? AppColors.black900 : AppColors.black100,
      child: Row(
        children: [
          // 왼쪽 accent 세로 바 (파랑/초록)
          Container(
            width: 3.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.green : AppColors.blue,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: AppSpacing.horizontal8),
          // 닉네임 + 메시지
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nickname,
                  style: AppTextStyles.paragraph14Semibold.copyWith(
                    color: isDarkMode ? AppColors.green : AppColors.blue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  message,
                  style: AppTextStyles.tag_12.copyWith(
                    color: isDarkMode ? AppColors.black400 : AppColors.black600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.horizontal8),
          // X 닫기 버튼
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: SvgPicture.asset(
                'assets/icons/icon_close.svg',
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(
                  isDarkMode ? AppColors.black400 : AppColors.black600,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

> **아이콘 에셋**: `assets/icons/icon_close.svg` 존재 여부를 확인할 것. 없으면 `Icons.close`를 `Icon` 위젯으로 대체.

- [ ] **Step 2: 빌드 확인**

```bash
flutter analyze lib/features/chat/presentation/widgets/reply_preview_bar.dart
```

- [ ] **Step 3: 커밋**

```bash
git add lib/features/chat/presentation/widgets/reply_preview_bar.dart
git commit -m "feat: 답장 인용 프리뷰 바 위젯 추가 #214"
```

---

### Task 4: ChatOverlay에 답장 상태 관리 + 전송 로직 연결

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_overlay.dart`

- [ ] **Step 1: import 추가**

파일 상단에 추가:
```dart
import '../../domain/utils/reply_markup_parser.dart';
import 'reply_preview_bar.dart';
```

- [ ] **Step 2: _ChatOverlayState에 답장 상태 변수 추가**

`_ChatOverlayState` 클래스 내부, 기존 상태 변수 영역에 추가:
```dart
/// 답장 대상 메시지 (null이면 답장 모드 아님)
ChatMessageDto? _replyingTo;
```

- [ ] **Step 3: 답장 모드 진입/취소 메서드 추가**

```dart
/// 답장 모드 진입: 컨텍스트 메뉴에서 답장 선택 시 호출
void _startReply(ChatMessageDto message) {
  setState(() => _replyingTo = message);
}

/// 답장 모드 취소: 프리뷰 바 X 버튼 또는 전송 후 호출
void _cancelReply() {
  setState(() => _replyingTo = null);
}
```

- [ ] **Step 4: _handleSend 수정 — 답장 마크업 포함**

기존 `_handleSend(String message)` 메서드를 수정한다:

```dart
void _handleSend(String message) {
  final scope = _currentPage == 0 ? ChatScope.all : ChatScope.team;

  // 답장 모드일 경우 마크업으로 감싸기
  final replyTarget = _replyingTo;
  final actualMessage = replyTarget != null
      ? ReplyMarkupParser.compose(
          originalMessageId: replyTarget.id,
          originalNickname: replyTarget.sender.nickname,
          originalText: replyTarget.filteredMessage,
          replyText: message,
        )
      : message;

  ref
      .read(chatNotifierProvider.notifier)
      .sendMessage(gameId: widget.gameId, message: actualMessage, scope: scope);

  // 답장 모드 해제
  if (replyTarget != null) _cancelReply();
}
```

- [ ] **Step 5: _handleMessageLongPress에 onReply 콜백 연결**

기존 `_handleMessageLongPress` 메서드의 `ChatContextMenu.show()` 호출부에 `onReply` 파라미터를 추가한다:

```dart
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
    onReply: () => _startReply(message),
  );
}
```

- [ ] **Step 6: build() 내 ChatInputBar 위에 ReplyPreviewBar 배치**

ChatOverlay의 `build()` 내부, `ChatInputBar` 위젯 바로 위에 조건부로 `ReplyPreviewBar`를 추가한다:

```dart
// 답장 프리뷰 바 (답장 모드일 때만 표시)
if (_replyingTo != null)
  ReplyPreviewBar(
    nickname: _replyingTo!.sender.nickname,
    message: _replyingTo!.filteredMessage,
    onCancel: _cancelReply,
    isDarkMode: widget.isDarkMode,
  ),
ChatInputBar(
  onSend: _handleSend,
  // ... 기존 파라미터 그대로 ...
),
```

- [ ] **Step 7: 빌드 확인**

```bash
flutter analyze lib/features/chat/presentation/widgets/chat_overlay.dart
```

- [ ] **Step 8: 커밋**

```bash
git add lib/features/chat/presentation/widgets/chat_overlay.dart
git commit -m "feat: ChatOverlay 답장 상태 관리 + 마크업 전송 연결 #214"
```

---

### Task 5: ChatMessageBubble 2단 답장 버블 렌더링

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_message_bubble.dart`

- [ ] **Step 1: import 추가**

```dart
import '../../domain/utils/reply_markup_parser.dart';
```

- [ ] **Step 2: _replyData getter 추가**

`_roleIconPath` getter 아래에 추가:

```dart
/// 답장 마크업 파싱 결과 (일반 메시지는 null)
ReplyData? get _replyData => ReplyMarkupParser.parse(message.message);
```

- [ ] **Step 3: 인용 헤더 + 답장 본문 합체 버블 빌드 메서드 추가**

`_buildOtherMessage()` 메서드 아래에 추가:

```dart
/// 답장 인용 헤더 위젯 (버블 상단)
///
/// accent 세로 바 + 원본 닉네임 + 원본 메시지 1줄.
/// 탭하면 원본 메시지로 스크롤 이동한다.
Widget _buildReplyQuoteHeader(ReplyData replyData) {
  return GestureDetector(
    onTap: onReplyQuoteTap != null
        ? () => onReplyQuoteTap!(replyData.originalMessageId)
        : null,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal12,
        vertical: AppSpacing.vertical8,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.black900 : AppColors.black100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // accent 세로 바
          Container(
            width: 2.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.green : AppColors.blue,
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
          SizedBox(width: AppSpacing.horizontal8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  replyData.originalNickname,
                  style: AppTextStyles.tag_12.copyWith(
                    color: isDarkMode ? AppColors.green : AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  replyData.originalText,
                  style: AppTextStyles.tag_12.copyWith(
                    color: isDarkMode ? AppColors.black400 : AppColors.black600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// 답장 버블: 인용 헤더(상단) + 답장 본문(하단) 합체
Widget _buildReplyBubble({
  required ReplyData replyData,
  required bool alignEnd,
}) {
  final replyText = ProfanityFilter.filter(replyData.replyText);
  final bottomLeft = alignEnd ? Radius.circular(12.r) : Radius.circular(4.r);
  final bottomRight = alignEnd ? Radius.circular(4.r) : Radius.circular(12.r);

  return Container(
    constraints: BoxConstraints(maxWidth: 240.w),
    decoration: BoxDecoration(
      color: isDarkMode ? AppColors.black : AppColors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12.r),
        topRight: Radius.circular(12.r),
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 인용 헤더
        _buildReplyQuoteHeader(replyData),
        // 답장 본문
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontal12,
            vertical: AppSpacing.vertical8,
          ),
          child: Text(
            replyText,
            style: AppTextStyles.paragraph_14.copyWith(
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          ),
        ),
      ],
    ),
  );
}
```

> **주의**: `ProfanityFilter` import가 필요하다: `import '../../../../core/services/content_filter/profanity_filter.dart';`

- [ ] **Step 4: onReplyQuoteTap 콜백 파라미터 추가**

`ChatMessageBubble` 생성자에 추가:
```dart
this.onReplyQuoteTap,
```

필드 선언:
```dart
/// 인용 헤더 탭 콜백 (원본 메시지 ID 전달)
final void Function(String originalMessageId)? onReplyQuoteTap;
```

- [ ] **Step 5: _buildMyMessage / _buildOtherMessage에서 답장 버블 분기 처리**

`_buildMyMessage()` 메서드에서 기존 `Builder > GestureDetector > Container` (메시지 버블 부분)를 답장 여부에 따라 분기한다.

`_buildMyMessage()` 상단에 로컬 변수 추가 (`roleIconPath` 선언 아래):
```dart
final replyData = _replyData;
```

기존 `Flexible(child: Builder(...Container...))` 부분을 조건 분기:
```dart
Flexible(
  child: replyData != null
      ? _buildReplyBubble(replyData: replyData, alignEnd: true)
      : Builder(
          builder: (bubbleCtx) => GestureDetector(
            // ... 기존 일반 버블 코드 그대로 ...
          ),
        ),
),
```

`_buildOtherMessage()`에도 동일 패턴 적용 (`alignEnd: false`):
```dart
final replyData = _replyData;
// ...
Flexible(
  child: replyData != null
      ? _buildReplyBubble(replyData: replyData, alignEnd: false)
      : Builder(
          builder: (bubbleCtx) => GestureDetector(
            // ... 기존 일반 버블 코드 그대로 ...
          ),
        ),
),
```

- [ ] **Step 6: filteredMessage getter에서 답장 본문만 표시 처리**

`ChatMessageFiltered` extension의 `filteredMessage`는 전체 메시지를 필터링한다. 답장 버블에서는 `_buildReplyBubble` 내부에서 `replyData.replyText`만 별도로 필터링하므로 extension 수정은 불필요하다.

단, 시스템 메시지 파서 `_parseSystemMessageSpans`에서 답장 마크업이 잘못 파싱되지 않도록 확인: 시스템 메시지는 `_isSystemMessage` 가드에 의해 `_buildSystemMessage`로 분기되므로 안전하다.

- [ ] **Step 7: 빌드 확인**

```bash
flutter analyze lib/features/chat/presentation/widgets/chat_message_bubble.dart
```

- [ ] **Step 8: 커밋**

```bash
git add lib/features/chat/presentation/widgets/chat_message_bubble.dart
git commit -m "feat: 2단 답장 합체 버블 렌더링 #214"
```

---

### Task 6: 원본 메시지로 스크롤 이동 + 하이라이트

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_message_list.dart`
- Modify: `lib/features/chat/presentation/widgets/chat_overlay.dart`

- [ ] **Step 1: ChatMessageList에 onReplyQuoteTap 콜백 파라미터 추가**

`ChatMessageList` 생성자에 추가:
```dart
this.onReplyQuoteTap,
```

필드:
```dart
/// 답장 인용 헤더 탭 시 원본 메시지 ID 전달
final void Function(String originalMessageId)? onReplyQuoteTap;
```

- [ ] **Step 2: ChatMessageBubble에 onReplyQuoteTap 전달**

`itemBuilder` 내부 `ChatMessageBubble(...)` 생성 시 추가:
```dart
onReplyQuoteTap: widget.onReplyQuoteTap,
```

- [ ] **Step 3: ListView.builder의 각 아이템에 GlobalObjectKey 부여**

`itemBuilder` 내부, `return Column(...)` 을 `KeyedSubtree`로 감싼다:

```dart
return KeyedSubtree(
  key: GlobalObjectKey('chat_msg_${message.id}'),
  child: Column(
    children: [
      if (showDateDivider) _buildDateDivider(message.kstDateTime),
      ChatMessageBubble(
        // ... 기존 파라미터 그대로 ...
      ),
    ],
  ),
);
```

- [ ] **Step 4: _ChatMessageListState에 scrollToMessage 메서드 추가**

`_scrollToBottom()` 아래에 추가:

```dart
/// 특정 메시지 ID 위치로 스크롤 이동 + 하이라이트
void scrollToMessage(String messageId) {
  final key = GlobalObjectKey('chat_msg_$messageId');
  final context = key.currentContext;
  if (context == null) {
    // 메시지가 캐시 범위 밖 — 토스트 등으로 안내
    return;
  }
  Scrollable.ensureVisible(
    context,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
    alignment: 0.3,
  );
}
```

- [ ] **Step 5: ChatOverlay에서 onReplyQuoteTap 콜백 연결**

ChatOverlay의 각 `ChatMessageList(...)` 생성 시 `onReplyQuoteTap` 파라미터를 추가한다:

```dart
onReplyQuoteTap: (messageId) {
  // 현재 보이는 페이지의 ChatMessageList의 scrollToMessage 호출 필요
  // GlobalKey로 ChatMessageListState에 접근
},
```

이를 위해 `_ChatOverlayState`에 두 개의 `GlobalKey<_ChatMessageListState>`를 추가한다:

```dart
final _allChatListKey = GlobalKey<_ChatMessageListState>();
final _teamChatListKey = GlobalKey<_ChatMessageListState>();
```

> **주의**: `_ChatMessageListState`는 private이므로 접근 불가. 대신 public 방식으로 노출한다.

**대안 접근**: `ChatMessageList`의 State 클래스명을 public으로 변경하지 않고, `ChatMessageList`에 static 메서드 또는 `ChatMessageList` 자체에서 콜백을 처리하는 방식을 사용한다.

**실제 구현 방식**: `ChatMessageList`에 `scrollToMessageId` 필드를 추가하고, `didUpdateWidget`에서 변경 감지 시 스크롤 실행:

```dart
// ChatMessageList 생성자에 추가
this.scrollToMessageId,

// 필드
final String? scrollToMessageId;
```

`_ChatMessageListState.didUpdateWidget`에 추가:
```dart
// 답장 인용 탭 → 원본 메시지로 스크롤 이동
if (widget.scrollToMessageId != null &&
    widget.scrollToMessageId != oldWidget.scrollToMessageId) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    scrollToMessage(widget.scrollToMessageId!);
  });
}
```

ChatOverlay에서는:
```dart
/// 스크롤 이동 대상 메시지 ID (답장 인용 탭 시 설정, 이동 후 null로 리셋)
String? _scrollToMessageId;

void _handleReplyQuoteTap(String messageId) {
  setState(() => _scrollToMessageId = messageId);
  // 다음 프레임에서 리셋 (한 번만 트리거)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) setState(() => _scrollToMessageId = null);
  });
}
```

각 `ChatMessageList(...)` 에 전달:
```dart
scrollToMessageId: _scrollToMessageId,
onReplyQuoteTap: _handleReplyQuoteTap,
```

- [ ] **Step 6: 빌드 확인**

```bash
flutter analyze lib/features/chat/presentation/widgets/chat_message_list.dart
flutter analyze lib/features/chat/presentation/widgets/chat_overlay.dart
```

- [ ] **Step 7: 커밋**

```bash
git add lib/features/chat/presentation/widgets/chat_message_list.dart lib/features/chat/presentation/widgets/chat_overlay.dart
git commit -m "feat: 답장 인용 탭 시 원본 메시지로 스크롤 이동 #214"
```

---

## 동작 시나리오

1. **답장 시작**: 메시지 롱프레스 → 컨텍스트 메뉴 → "답장" 탭
2. **프리뷰 표시**: 입력바 위에 인용 프리뷰 바 등장 (accent 바 + 닉네임 + 원본 1줄 + X)
3. **전송**: 메시지 입력 후 전송 → `@reply{id|nick|orig}reply` 마크업으로 STOMP 전송
4. **버블 렌더링**: 수신 측에서 마크업 파싱 → 2단 합체 버블 (인용 헤더 + 답장 본문)
5. **원본 이동**: 인용 헤더 탭 → `Scrollable.ensureVisible`로 원본 위치 스크롤
6. **Edge case**: 원본이 200개 메시지 밖으로 밀려남 → `currentContext == null` → 무시 (추후 토스트 추가 가능)

## 사용자 확인 사항

- 답장 트리거: 롱프레스 메뉴만 사용 (스와이프는 이번 스코프 밖)
- `icon_reply.svg`, `icon_close.svg` 에셋 존재 여부 확인
- 인용 프리뷰 바 / 2단 버블 디자인 가시성 확인
- 인용 헤더의 accent 바 색상 (라이트: blue, 다크: green) 확인
