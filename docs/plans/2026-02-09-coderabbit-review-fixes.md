# CodeRabbit PR #75 리뷰 수정 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CodeRabbit 리뷰에서 지적된 코드 버그 2건 수정 (API 명세 관련 제외)

**Architecture:** 기존 파일 2개의 버그만 수정, 구조 변경 없음

**Tech Stack:** Flutter/Dart, Riverpod, Dio

---

### Task 1: refreshToken.substring(0, 20) RangeError 방어

**파일:**
- Modify: `lib/core/network/auth_interceptor.dart:152`

**문제:** `refreshToken.substring(0, 20)`에서 토큰 길이가 20자 미만이면 `RangeError` 발생. JWT는 보통 길지만 손상된 값이 저장된 경우 crash.

**Step 1: 코드 수정**

`auth_interceptor.dart:152`에서:

```dart
// Before
'   refreshToken: ${refreshToken.substring(0, 20)}...(${refreshToken.length}자)',

// After
'   refreshToken: ${refreshToken.length > 20 ? '${refreshToken.substring(0, 20)}...' : refreshToken}(${refreshToken.length}자)',
```

**Step 2: 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/core/network/auth_interceptor.dart
git commit -m "fix : refreshToken 로그 출력 시 RangeError 방어 처리 #74"
```

---

### Task 2: session_creation_flow_page.dart — async data 콜백 경쟁 상태 수정

**파일:**
- Modify: `lib/features/session/presentation/pages/session_creation_flow_page.dart:189-224`

**문제:** `sessionState.when()`의 `data` 콜백이 `async`로 선언되어 있지만, `.when()`은 반환값을 await하지 않음. 따라서 `clearDraft()`와 `context.go()`가 완료되기 전에 `setState(() => _isLoading = false)`가 실행됨. 결과: Draft 삭제 전 버튼 재활성화 → 중복 탭 가능.

**Step 1: 코드 수정**

`.when()` 패턴 대신 직접 `AsyncValue` 상태를 체크하는 방식으로 변경:

```dart
// Before (lines 189-224)
sessionState.when(
  data: (result) async {
    if (result != null) {
      ...
      await _storageService.clearDraft();
      if (mounted) {
        context.go(RoutePaths.waitingRoomWithId('${result.gameId}'));
      }
    }
  },
  error: (error, stack) {
    ...
  },
  loading: () {},
);

if (mounted) {
  setState(() => _isLoading = false);
}

// After
if (sessionState is AsyncData<CreateSessionResult?> &&
    sessionState.value != null) {
  final result = sessionState.value!;
  if (kDebugMode) {
    debugPrint(
      '✅ [SessionCreationFlow] 세션 생성 완료: '
      'gameId=${result.gameId}, inviteCode=${result.inviteCode}',
    );
  }
  await _storageService.clearDraft();
  if (mounted) {
    context.go(RoutePaths.waitingRoomWithId('${result.gameId}'));
  }
  return; // 네비게이션 후 setState 불필요
} else if (sessionState is AsyncError) {
  if (kDebugMode) {
    debugPrint('❌ [SessionCreationFlow] 세션 생성 실패: ${sessionState.error}');
  }
  if (mounted) {
    final errorMessage = _getErrorMessage(sessionState.error!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
    );
  }
}

if (mounted) {
  setState(() => _isLoading = false);
}
```

**핵심 변경:**
- `.when()` → `if/else` 패턴으로 변경 (async 콜백 문제 제거)
- 성공 시 `await clearDraft()` 후 `context.go()` → `return`으로 조기 종료 (네비게이션 후 setState 불필요)
- 실패 시만 `_isLoading = false`로 버튼 재활성화

**Step 2: 검증**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/session/presentation/pages/session_creation_flow_page.dart
git commit -m "fix : 세션 생성 결과 처리 async 경쟁 상태 수정 #74"
```

---

### 제외 항목 (백엔드 수정 대기)

| 리뷰 항목 | 사유 |
|-----------|------|
| `api-docs.json` "ture" 오타 | 백엔드에 수정 요청 완료 |
| `GameJoinResponse` 스키마/예시 불일치 | 백엔드 응답 형식 확정 대기 |
