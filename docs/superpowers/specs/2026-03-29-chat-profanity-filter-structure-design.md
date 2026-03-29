# Chat Profanity Filter 구조 통합 설계

## 개요

채팅 메시지를 표시하는 모든 곳(버블, 프리뷰 카드, 컨텍스트 메뉴)에서 욕설 필터링이 일관되게 적용되도록, 공통 Extension을 통해 필터링된 텍스트를 제공하는 구조로 통합한다.

**배경:** 현재 `ProfanityFilter.filter()`가 `ChatMessageBubble`과 `ChatContextMenu`에만 개별 호출되어 있고, 새로 추가된 `ChatPreviewCard`에는 미적용. 표시 지점마다 직접 호출하는 방식은 누락이 발생하기 쉬움.

**목표:** App Store 심사 가이드라인 1.2(UGC) 준수 — 사용자에게 보이는 모든 채팅 텍스트에 필터링 보장.

---

## 설계

### 1. ChatMessageFiltered Extension 추가

`chat_message_dto.dart`에 기존 `ChatMessageTimestamp` extension과 동일한 패턴으로 추가:

```dart
extension ChatMessageFiltered on ChatMessageDto {
  /// 욕설/금칙어가 마스킹된 메시지 텍스트
  String get filteredMessage => ProfanityFilter.filter(message);
}
```

- 원본 `message` 필드는 보존 (신고 시 원본 필요)
- 표시 시점에서 필터링 (금칙어 목록 변경 시 자동 반영)
- DTO freezed 모델 변경 없음

### 2. 소비자 통일

| 파일 | 현재 | 변경 후 |
|------|------|---------|
| `chat_message_bubble.dart` | `_filteredMessage` getter에서 `ProfanityFilter.filter()` 직접 호출 | `message.filteredMessage` 사용, getter 제거 |
| `chat_context_menu.dart` | `ProfanityFilter.filter()` 직접 호출 | `message.filteredMessage` 사용 |
| `chat_preview_card.dart` | `widget.message.message` (필터링 없음) | `widget.message.filteredMessage` 사용 |

### 3. 변경하지 않는 것

- `ProfanityFilter` 클래스 (`lib/core/services/content_filter/profanity_filter.dart`) — 그대로 유지
- `ChatMessageDto` freezed 모델 — 변경 없음
- `ChatNotifier` — 변경 없음
- `ChatMessageList` — 변경 없음 (여기는 메시지 텍스트를 직접 표시하지 않음)

---

## 구현 범위

### 수정 파일

| 파일 | 변경 내용 |
|------|----------|
| `lib/features/chat/data/models/chat_message_dto.dart` | `ChatMessageFiltered` extension 추가 |
| `lib/features/chat/presentation/widgets/chat_message_bubble.dart` | `_filteredMessage` getter 제거, `message.filteredMessage` 사용 |
| `lib/features/chat/presentation/widgets/chat_context_menu.dart` | `ProfanityFilter.filter()` 직접 호출 → `message.filteredMessage` 사용 |
| `lib/features/chat/presentation/widgets/chat_preview_card.dart` | `widget.message.message` → `widget.message.filteredMessage` 사용 |

### 신규 파일

없음

### 향후 확장 포인트

- 서버 동적 금칙어 목록: `ProfanityFilter` 내부만 수정하면 모든 소비자에 자동 반영
- 정규식 우회 방지: 동일하게 `ProfanityFilter` 내부 로직만 수정
