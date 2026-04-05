# 채팅 오버레이 바깥 영역 탭 시 시트 접기 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 채팅 시트가 펼쳐진 상태에서 시트 바깥(상단) 영역을 탭하면 최소 크기로 접히도록 한다.

**Architecture:** `chat_overlay.dart`의 기존 Stack 내부에 투명 배리어 `GestureDetector`를 `DraggableScrollableSheet` **앞에** 배치하여, 시트가 차지하지 않는 상단 영역의 탭을 감지한다. Flutter Stack의 hit test 순서(뒤→앞)를 이용해 시트 영역은 정상 터치되고, 시트 밖 영역만 배리어가 잡는다. 새로운 상태 플래그 0개, ChatInputBar와의 결합 0.

**Tech Stack:** Flutter DraggableScrollableSheet, GestureDetector, HitTestBehavior

**주의사항 (#177 롤백 교훈):**
- 새로운 상태 플래그 추가 금지 — `_isExpanded`(기존)만 사용
- ChatInputBar `_userTapped`에 영향 주지 않음
- 키보드 열린 상태에서는 배리어 비활성화 (effectiveMinSize=75%와 animateTo 충돌 방지)

---

## 파일 구조

| 파일 | 변경 유형 | 역할 |
|------|-----------|------|
| `lib/features/chat/presentation/widgets/chat_overlay.dart` | 수정 | 배리어 GestureDetector 추가 + `_collapseSheet()` 메서드 |

---

### Task 1: `_collapseSheet()` 헬퍼 메서드 추가

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_overlay.dart:146-175` (기존 메서드들 사이)

- [ ] **Step 1: `_collapseSheet()` 메서드 작성**

`_handlePreviewTap()` 메서드 아래(line 175 뒤)에 추가:

```dart
/// 시트 바깥 영역 탭 시 최소 크기로 접기
void _collapseSheet() {
  FocusScope.of(context).unfocus();
  if (_sheetController.isAttached) {
    _sheetController.animateTo(
      _minSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
```

**설계 근거:**
- `unfocus()` 먼저 호출 → 키보드가 열려있었다면 닫힘
- 이 메서드는 키보드가 닫힌 상태에서만 호출됨 (배리어가 `!isKeyboardOpen` 조건으로 표시되므로)
- `_minSize`로 애니메이션 → `_onSheetChanged`에서 `_isExpanded = false` 처리됨

- [ ] **Step 2: 빌드 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/chat/presentation/widgets/chat_overlay.dart`
Expected: 에러 없음

- [ ] **Step 3: 커밋**

```bash
git add lib/features/chat/presentation/widgets/chat_overlay.dart
git commit -m "feat : 시트 접기 헬퍼 메서드 추가 #214"
```

---

### Task 2: Stack에 배리어 GestureDetector 추가

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_overlay.dart:228-230` (Stack children 시작 부분)

- [ ] **Step 1: Stack children에 배리어 추가**

`chat_overlay.dart`의 `return Stack(` 내부, `DraggableScrollableSheet` **앞에** 배리어를 삽입:

```dart
return Stack(
  children: [
    // 시트 바깥 영역 탭 → 시트 접기 (키보드 닫힌 + 펼쳐진 상태에서만)
    if (_isExpanded && !isKeyboardOpen)
      Positioned.fill(
        child: GestureDetector(
          onTap: _collapseSheet,
          behavior: HitTestBehavior.opaque,
        ),
      ),
    DraggableScrollableSheet(
      // ... 기존 코드 그대로
```

**설계 근거:**
- `Positioned.fill` — Stack 전체 영역을 덮음
- `HitTestBehavior.opaque` — 투명 영역도 탭 감지
- Stack에서 **앞에 배치** → hit test 순서상 뒤에 있는 `DraggableScrollableSheet`가 먼저 테스트됨 → 시트 영역 탭은 시트가 처리, 시트 밖 탭만 배리어가 처리
- `!isKeyboardOpen` 조건 — 키보드 열림 시 `effectiveMinSize = _snap75`이므로 `animateTo(_minSize)`와 충돌. 키보드 상태에서는 배리어 비활성화
- `_isExpanded` — 시트가 접힌 상태에서는 배리어 불필요 (게임 맵 터치 방해 방지)

- [ ] **Step 2: 빌드 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/chat/presentation/widgets/chat_overlay.dart`
Expected: 에러 없음

- [ ] **Step 3: 커밋**

```bash
git add lib/features/chat/presentation/widgets/chat_overlay.dart
git commit -m "feat : 채팅 시트 바깥 영역 탭 시 접기 배리어 추가 #214"
```

---

### Task 3: 수동 검증

- [ ] **Step 1: 기본 동작 — 시트 펼침 후 바깥 탭**
1. 앱 실행 → 게임 진입
2. 드래그 핸들로 채팅 시트를 50% 또는 75%까지 펼침
3. 시트 위쪽 빈 영역(게임 맵) 탭
4. **Expected:** 시트가 최소 크기(프리뷰 상태)로 접힘

- [ ] **Step 2: 키보드 열림 상태 — 바깥 탭 불가 확인**
1. 채팅 입력바를 탭하여 키보드 올림
2. 시트 위쪽 빈 영역 탭
3. **Expected:** 배리어가 비활성화 상태이므로 게임 맵 터치가 정상 전달됨 (시트는 접히지 않음)

- [ ] **Step 3: 시트 접힌 상태 — 게임 맵 터치 정상 확인**
1. 시트가 최소 크기(접힌 상태)인지 확인
2. 게임 맵 영역 탭/드래그
3. **Expected:** 배리어가 비활성화 상태이므로 게임 맵 조작 정상 동작

- [ ] **Step 4: 드래그 핸들 정상 동작 확인**
1. 드래그 핸들로 시트 올리기 → 정상 올라감
2. 드래그 핸들 탭 → 토글 동작 정상
3. **Expected:** 기존 드래그 핸들 동작에 영향 없음

- [ ] **Step 5: 포커스 복원 버그 재발 확인**
1. 채팅 입력바 탭 → 메시지 입력 → 전송
2. 드래그 핸들로 시트 접기
3. 게임 규칙 다이얼로그 열기 → 닫기
4. **Expected:** 시트가 자동으로 올라오지 않음 (`_userTapped` 방어 정상 동작)

- [ ] **Step 6: 프리뷰 카드 탭 정상 확인**
1. 시트가 접힌 상태에서 새 메시지 수신 대기
2. 프리뷰 카드 탭
3. **Expected:** 시트가 50%로 펼쳐지며 해당 채팅 스코프로 이동
