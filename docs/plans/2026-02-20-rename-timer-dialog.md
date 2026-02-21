# AppTimerDialog → AppContentDialog 리네이밍 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** `AppTimerDialog`를 `AppContentDialog`로 리네이밍하여 타이머/게임종료 등 버튼 없는 컨텐츠 다이얼로그를 통일

**Architecture:** `AppTimerDialog`는 현재 타이머 전용이라는 이름이지만, 실제로는 "버튼 없이 커스텀 content만 표시"하는 범용 다이얼로그. 이름을 `AppContentDialog`로 변경하고, test_widget_page의 "게임 종료" 다이얼로그도 이것으로 마이그레이션.

**Tech Stack:** Flutter, Dart

---

## 현재 상태

| 항목 | AppTimerDialog | AppDialog (showButtons: false) |
|------|---------------|-------------------------------|
| 용도 | 타이머 표시 | 게임 종료 등 버튼 없는 다이얼로그 |
| 파라미터 | `content` (Widget) | `title`, `message`, `showButtons: false` |
| 패딩 | vertical 42, horizontal 16 | top 24, left/right 16, bottom 16 |
| boxShadow | 있음 | 없음 |

## 변경 후

- `AppContentDialog` = 버튼 없이 content만 표시하는 범용 다이얼로그
- 타이머, 게임 종료 등 모두 `AppContentDialog.show()` 사용
- `AppDialog`의 `showButtons: false` 모드는 제거하지 않음 (title/message 구조가 필요한 경우 유지)

---

## 영향 범위

**변경 파일:**
- `lib/core/widgets/dialogs/app_timer_dialog.dart` → `lib/core/widgets/dialogs/app_content_dialog.dart`
- `lib/test_widget_page.dart` (import + 클래스명 2곳 + 게임종료 다이얼로그 마이그레이션)

**변경 없는 파일:**
- `lib/core/widgets/dialogs/app_dialog.dart` (그대로 유지)
- `lib/features/settings/presentation/pages/settings_page.dart` (AppDialog.confirm 사용, 영향 없음)
- `lib/features/session/presentation/pages/home_page.dart` (AppDialog.show 사용, 영향 없음)

---

### Task 1: 파일 리네이밍 및 클래스명 변경

**Files:**
- Rename: `lib/core/widgets/dialogs/app_timer_dialog.dart` → `lib/core/widgets/dialogs/app_content_dialog.dart`

**Step 1: 파일 이름 변경**

```bash
mv lib/core/widgets/dialogs/app_timer_dialog.dart lib/core/widgets/dialogs/app_content_dialog.dart
```

**Step 2: 클래스명 및 DartDoc 변경**

`app_content_dialog.dart` 내부:
- `AppTimerDialog` → `AppContentDialog` (클래스명, 생성자, 내부 참조)
- DartDoc: "타이머 전용" → "버튼 없이 커스텀 콘텐츠만 표시하는 범용 다이얼로그"
- barrierLabel: `'TimerDialog'` → `'ContentDialog'`
- 사용 예시 업데이트

**Step 3: flutter analyze 확인**

```bash
flutter analyze lib/core/widgets/dialogs/app_content_dialog.dart
```
Expected: No issues

**Step 4: Commit**

```bash
git add lib/core/widgets/dialogs/
git commit -m "refactor: AppTimerDialog를 AppContentDialog로 리네이밍 #99"
```

---

### Task 2: test_widget_page.dart 참조 업데이트

**Files:**
- Modify: `lib/test_widget_page.dart`

**Step 1: import 변경**

```dart
// Before
import 'core/widgets/dialogs/app_timer_dialog.dart';
// After
import 'core/widgets/dialogs/app_content_dialog.dart';
```

**Step 2: 타이머 다이얼로그 호출 2곳 변경**

```dart
// Before
AppTimerDialog.show(
// After
AppContentDialog.show(
```

**Step 3: "게임 종료" 다이얼로그를 AppContentDialog로 마이그레이션**

현재 (AppDialog.show + showButtons: false):
```dart
AppDialog.show(
  context: context,
  title: '게임 종료!',
  message: '게임 시작 지점으로 모여 주세요!',
  showButtons: false,
);
```

변경 후 (AppContentDialog.show):
```dart
AppContentDialog.show(
  context: context,
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '게임 종료!',
        style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: AppSpacing.vertical12),
      Text(
        '게임 시작 지점으로 모여 주세요!',
        style: AppTextStyles.paragraph_14_100.copyWith(color: AppColors.black600),
        textAlign: TextAlign.center,
      ),
    ],
  ),
);
```

**Step 4: flutter analyze 확인**

```bash
flutter analyze lib/test_widget_page.dart
```
Expected: No issues

**Step 5: Commit**

```bash
git add lib/test_widget_page.dart
git commit -m "refactor: test_widget_page AppTimerDialog → AppContentDialog 마이그레이션 #99"
```
