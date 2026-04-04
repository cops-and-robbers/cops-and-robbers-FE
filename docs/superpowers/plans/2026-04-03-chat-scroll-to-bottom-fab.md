# 채팅 스크롤 하단 이동 플로팅 버튼 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 채팅 메시지 리스트를 위로 스크롤했을 때 최신 메시지(하단)로 바로 이동하는 플로팅 버튼을 표시한다.

**Architecture:** `ChatMessageList`는 `reverse: true` ListView를 사용하므로 `pixels == 0`이 최하단(최신)이고, 위로 스크롤하면 pixels가 증가한다. ScrollController에 리스너를 달아 `pixels > 200` 이면 FAB를 표시하고, 탭하면 `animateTo(0)`으로 최하단 이동한다. `Stack`으로 ListView 위에 FAB를 겹쳐 배치한다.

**Tech Stack:** Flutter, flutter_screenutil

---

## File Map

| 작업 | 파일 | 책임 |
|------|------|------|
| 수정 | `lib/features/chat/presentation/widgets/chat_message_list.dart` | 스크롤 감지 + FAB 표시 |

## 기존 리소스 (수정 없이 재사용)

- `_scrollController` — 이미 `_ChatMessageListState`에 존재
- `_scrollToBottomIfNear()` — 이미 존재하는 하단 이동 메서드 (threshold 100)
- `AppColors`, `AppSpacing` — 기존 디자인 상수
- `reverse: true` ListView — pixels 0 = 최하단

---

### Task 1: 스크롤 위치 감지 상태 추가 및 리스너 등록

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_message_list.dart`

- [ ] **Step 1: `_showScrollToBottom` 상태 변수 추가**

`_ChatMessageListState` 클래스에 상태 변수를 추가한다. `_scrollController` 선언 바로 아래에 삽입:

```dart
/// 스크롤 하단 이동 FAB 표시 여부 (위로 200px 이상 스크롤 시 true)
bool _showScrollToBottom = false;
```

- [ ] **Step 2: 스크롤 리스너 등록**

`initState()`에서 `_scrollController`에 리스너를 추가한다. 기존 `initState()` 내용 마지막에 추가:

```dart
_scrollController.addListener(_onScroll);
```

- [ ] **Step 3: `_onScroll` 콜백 메서드 추가**

`_scrollToBottomIfNear()` 메서드 아래에 추가:

```dart
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
```

---

### Task 2: ListView를 Stack으로 감싸고 FAB 추가

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_message_list.dart`

- [ ] **Step 1: `_scrollToBottom` 메서드 추가**

`_onScroll()` 아래에 FAB 탭 시 호출할 메서드를 추가:

```dart
/// 최신 메시지(최하단)로 스크롤 이동
void _scrollToBottom() {
  _scrollController.animateTo(
    0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
}
```

- [ ] **Step 2: build 메서드에서 기존 `NotificationListener` 를 `Stack`으로 감싸기**

현재 `build()` 메서드는 `NotificationListener<OverscrollNotification>` 을 최상위로 반환한다. 이를 `Stack`으로 감싸고, FAB를 두 번째 자식으로 추가한다:

```dart
@override
Widget build(BuildContext context) {
  final filteredMessages = widget.messages
      .where((m) => !widget.blockedParticipantIds.contains(m.sender.participantId))
      .toList();

  return Stack(
    children: [
      // 기존 NotificationListener + ListView (전체 그대로 유지)
      NotificationListener<OverscrollNotification>(
        // ... 기존 코드 그대로 ...
      ),
      // 스크롤 하단 이동 FAB
      if (_showScrollToBottom)
        Positioned(
          right: AppSpacing.horizontal12,
          bottom: AppSpacing.vertical12,
          child: GestureDetector(
            onTap: _scrollToBottom,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? AppColors.black.withOpacity(0.8)
                    : AppColors.white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20.w,
                color: widget.isDarkMode ? AppColors.white : AppColors.black,
              ),
            ),
          ),
        ),
    ],
  );
}
```

핵심: 기존 `NotificationListener` 반환문을 `Stack`의 첫 번째 자식으로 이동하고, 그 아래에 조건부 FAB `Positioned`를 추가한다.

- [ ] **Step 3: 빌드 확인**

```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/chat/presentation/widgets/chat_message_list.dart
```

Expected: No issues found!

- [ ] **Step 4: 커밋**

```bash
git add lib/features/chat/presentation/widgets/chat_message_list.dart
git commit -m "feat: 채팅 스크롤 하단 이동 플로팅 버튼 추가 #214"
```

---

## 동작 시나리오

1. 사용자가 채팅을 위로 200px 이상 스크롤 → FAB(↓) 우하단에 표시
2. FAB 탭 → 300ms 애니메이션으로 최하단(최신 메시지)으로 이동
3. 스크롤이 200px 이내로 돌아오면 → FAB 자동 숨김
4. 새 메시지 도착 시 기존 `_scrollToBottomIfNear()` 로직은 그대로 유지 (threshold 100)

## 사용자 확인 사항

- FAB 위치/크기/색상 가시성 확인
- 200px threshold 적절성 확인
- 필요 시 애니메이션(fade in/out) 추가 여부
