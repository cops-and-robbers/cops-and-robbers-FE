# Chat Profanity Filter 구조 통합 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 채팅 메시지를 표시하는 모든 곳에서 욕설 필터링이 누락 없이 일관되게 적용되도록 Extension 기반 공통 구조로 통합

**Architecture:** `ChatMessageDto`에 `ChatMessageFiltered` extension을 추가하여 `filteredMessage` getter를 제공. 기존 소비자(버블, 컨텍스트 메뉴)에서 `ProfanityFilter` 직접 호출을 제거하고, 신규 소비자(프리뷰 카드)에도 동일하게 적용.

**Tech Stack:** Flutter, Dart Extension

---

## File Structure

| 파일 | 역할 | 작업 |
|------|------|------|
| `lib/features/chat/data/models/chat_message_dto.dart` | 메시지 DTO + Extensions | 수정: `ChatMessageFiltered` extension 추가 |
| `lib/features/chat/presentation/widgets/chat_message_bubble.dart` | 메시지 버블 위젯 | 수정: `_filteredMessage` getter 제거, extension 사용 |
| `lib/features/chat/presentation/widgets/chat_context_menu.dart` | 컨텍스트 메뉴 위젯 | 수정: `ProfanityFilter.filter()` 직접 호출 제거, extension 사용 |
| `lib/features/chat/presentation/widgets/chat_preview_card.dart` | 프리뷰 카드 위젯 | 수정: `widget.message.message` → `widget.message.filteredMessage` |

---

### Task 1: ChatMessageFiltered Extension 추가

**Files:**
- Modify: `lib/features/chat/data/models/chat_message_dto.dart`

- [ ] **Step 1: chat_message_dto.dart에 ProfanityFilter import + Extension 추가**

파일 상단 import 섹션에 추가:

```dart
import '../../../core/services/content_filter/profanity_filter.dart';
```

주의: 이 import 경로는 `lib/features/chat/data/models/` 기준으로 `lib/core/services/content_filter/`에 접근해야 하므로 `../../../../core/services/content_filter/profanity_filter.dart`가 맞다.

파일 하단, 기존 `ChatSenderDto` 클래스 아래에 추가:

```dart
/// 채팅 메시지 비속어 필터링 확장
///
/// [ProfanityFilter]를 통해 마스킹된 메시지 텍스트를 제공합니다.
/// 원본 [message] 필드는 보존됩니다.
extension ChatMessageFiltered on ChatMessageDto {
  /// 욕설/금칙어가 마스킹된 메시지 텍스트
  String get filteredMessage => ProfanityFilter.filter(message);
}
```

- [ ] **Step 2: 코드 분석 확인**

Run: `flutter analyze lib/features/chat/data/models/chat_message_dto.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/chat/data/models/chat_message_dto.dart
git commit -m "feat(chat): ChatMessageFiltered extension 추가 — filteredMessage getter 제공 #200"
```

---

### Task 2: 기존 소비자 마이그레이션 + 프리뷰 카드 적용

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_message_bubble.dart:48`
- Modify: `lib/features/chat/presentation/widgets/chat_context_menu.dart:199`
- Modify: `lib/features/chat/presentation/widgets/chat_preview_card.dart:154`

- [ ] **Step 1: chat_message_bubble.dart — `_filteredMessage` getter 제거, extension 사용**

현재 코드 (line 48):
```dart
String get _filteredMessage => ProfanityFilter.filter(message.message);
```

이 getter를 제거한다. 그리고 파일 내에서 `_filteredMessage`를 사용하는 모든 곳을 `message.filteredMessage`로 교체한다.

또한 `ProfanityFilter` import를 제거한다:
```dart
import '../../../../core/services/content_filter/profanity_filter.dart';
```

이 import를 삭제. (`filteredMessage`는 `ChatMessageDto`의 extension이므로 `chat_message_dto.dart` import에서 자동으로 사용 가능)

- [ ] **Step 2: chat_context_menu.dart — `ProfanityFilter.filter()` 직접 호출 제거**

현재 코드 (line 199):
```dart
final filteredMessage = ProfanityFilter.filter(widget.message.message);
```

변경:
```dart
final filteredMessage = widget.message.filteredMessage;
```

또한 `ProfanityFilter` import를 제거한다:
```dart
import '../../../../core/services/content_filter/profanity_filter.dart';
```

이 import를 삭제.

- [ ] **Step 3: chat_preview_card.dart — filteredMessage 적용**

현재 코드 (line 154):
```dart
text: widget.message.message,
```

변경:
```dart
text: widget.message.filteredMessage,
```

`chat_message_dto.dart`는 이미 import되어 있으므로 추가 import 불필요.

- [ ] **Step 4: 코드 분석 확인**

Run: `flutter analyze lib/features/chat/presentation/widgets/`
Expected: No errors. `ProfanityFilter` import가 제거된 파일에서 unused import 경고가 없어야 함.

- [ ] **Step 5: Commit**

```bash
git add lib/features/chat/presentation/widgets/chat_message_bubble.dart lib/features/chat/presentation/widgets/chat_context_menu.dart lib/features/chat/presentation/widgets/chat_preview_card.dart
git commit -m "refactor(chat): ProfanityFilter 직접 호출을 ChatMessageFiltered extension으로 통일 #200"
```
