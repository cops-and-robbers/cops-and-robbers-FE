# Chat Unread Notification UX Design

## 개요

채팅 시트가 접혀있거나 다른 탭을 보고 있을 때, 새 메시지가 왔는지 시각적으로 알 수 없는 문제를 해결한다.

**접근 방식:** 입력바 위 슬라이드-인 프리뷰 카드 + 탭 dot 읽지 않은 배지

---

## 1. 읽지 않은 메시지 추적 (State)

### ChatState 추가 필드

```dart
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    // ... 기존 필드 ...
    @Default(0) int unreadAllCount,
    @Default(0) int unreadTeamCount,
    ChatMessageDto? lastPreviewMessage,
  }) = _ChatState;
}
```

### 읽음 처리 기준

| 시트 상태 | 현재 탭 | 동작 |
|----------|---------|------|
| 접혀있음 | - | 프리뷰 카드 슬라이드-인 + 해당 스코프 카운트 증가 |
| 펼쳐짐 | 같은 탭 | 아무것도 안 함 (바로 읽힘) |
| 펼쳐짐 | 다른 탭 | 탭 dot에 빨간 점 + 해당 스코프 카운트 증가 |

### 읽음 처리 시점

- 시트 펼침 → 현재 보고 있는 탭의 카운트 0으로 초기화
- 탭 스와이프 → 이동한 탭의 카운트 0으로 초기화
- 프리뷰 카드 탭 → 해당 스코프 탭으로 이동 + 카운트 초기화

---

## 2. 프리뷰 카드 (슬라이드-인 알림)

### 표시 조건

- 채팅 시트가 접혀있을 때 새 메시지 도착
- 시트가 펼쳐져 있지만 다른 탭에 메시지가 온 경우
- 내가 보낸 메시지는 프리뷰 안 뜸
- 시스템 메시지는 프리뷰 표시함
- 차단된 사용자의 메시지는 프리뷰 안 뜸

### 카드 레이아웃

```
┌──────────────────────────┐
│ 닉네임 [팀]               │  ← 닉네임 + 스코프 배지 (팀이면 표시, 전체면 없음)
│ 메시지 본문 한 줄...       │  ← 1줄, overflow ellipsis
└──────────────────────────┘
```

### 위치

- `ChatOverlay` 내부, 입력바(`ChatInputBar`) 바로 위
- 좌우 12px 마진 (`AppSpacing` 사용)

### 스타일

**라이트 모드 (POLICE):**
- 팀 채팅 프리뷰: 배경 `AppColors.blue100`, 테두리 `AppColors.blue500`
- 전체 채팅 프리뷰: 배경 `AppColors.black100`, 테두리 `AppColors.black300`
- 닉네임: `AppTextStyles.tag_12`, 색상 `AppColors.blue`
- 배지 [팀]: `AppTextStyles.tag_10`, 배경 `AppColors.blue`, 텍스트 `AppColors.white`
- 메시지: `AppTextStyles.paragraph_14`, 색상 `AppColors.black800`

**다크 모드 (ROBBER):**
- 팀 채팅 프리뷰: 배경 `AppColors.green100`, 테두리 `AppColors.green500`
- 전체 채팅 프리뷰: 배경 `AppColors.black900`, 테두리 `AppColors.black700`
- 닉네임: `AppTextStyles.tag_12`, 색상 `AppColors.green`
- 배지 [팀]: `AppTextStyles.tag_10`, 배경 `AppColors.green`, 텍스트 `AppColors.black`
- 메시지: `AppTextStyles.paragraph_14`, 색상 `AppColors.black200`

### 애니메이션

- 등장: 아래→위 슬라이드 + 페이드인 (300ms, Curves.easeOut)
- 퇴장: 위→아래 슬라이드 + 페이드아웃 (200ms, Curves.easeIn)
- 3초 후 자동 퇴장

### 상호작용

- 연속 메시지: 기존 프리뷰를 새 메시지로 교체 (타이머 리셋 3초)
- 프리뷰 탭: 해당 스코프 탭으로 시트 펼침 + 읽음 처리
- 입력 중(포커스)에도 프리뷰 표시 (입력바 위에 뜨므로 방해 없음)

### 우선순위

- 팀 채팅 > 전체 채팅 (동시 도착 시 팀 채팅 프리뷰 표시)

---

## 3. 탭 읽지 않은 배지 (Tab Unread Dot)

### 표시 조건

- 채팅 시트가 펼쳐져 있을 때, 현재 안 보고 있는 탭에 읽지 않은 메시지가 있으면 표시

### 스타일

- 기존 탭 indicator dot 우상단에 작은 빨간 점
- 색상: `AppColors.red`
- 크기: 5px 원형
- 숫자 배지 없이 dot만

### 해제

- 해당 탭으로 스와이프하면 빨간 점 사라짐 + 카운트 초기화

---

## 4. 구현 범위

### 수정 파일

| 파일 | 변경 내용 |
|------|----------|
| `chat_provider.dart` | `ChatState`에 unread 필드 추가, 읽음 처리 메서드 추가 |
| `chat_overlay.dart` | 프리뷰 카드 배치, 탭 dot 빨간 점, 시트 상태 추적 |

### 신규 파일

| 파일 | 설명 |
|------|------|
| `chat_preview_card.dart` | 슬라이드-인 프리뷰 카드 위젯 (애니메이션 포함) |

### 변경하지 않는 것

- `ChatStompDatasource` — 데이터소스 계층은 변경 없음
- `ChatMessageDto` — 모델 변경 없음
- 서버 API — 클라이언트 전용 기능, 서버 변경 없음
