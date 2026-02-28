# DialogSpacing 리팩토링 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** AppDialog의 개별 spacing 파라미터(`contentSpacing`)를 `DialogSpacing` 객체로 교체하여 모든 spacing 구간을 선택적으로 오버라이드 가능하게 만든다.

**Architecture:** `DialogSpacing` 클래스를 생성하고, `AppDialog`의 `contentSpacing` 파라미터를 `spacing: DialogSpacing?`으로 교체한다. 각 필드가 null이면 기존 기본값을 사용하므로 하위 호환성이 유지된다.

**Tech Stack:** Flutter, Dart

---

## 현재 spacing 구간 (기본값)

```
[Avatar]
  ↕ avatarToTitle: vertical16
[Title]
  ↕ titleToMessage: vertical12
[Message]
  ↕ toContent: message 있으면 vertical12, 없으면 vertical20
[CustomContent]
  ↕ toButtons: vertical20
[Buttons]
```

---

### Task 1: DialogSpacing 클래스 생성

**Files:**
- Create: `lib/core/widgets/dialogs/dialog_spacing.dart`

**Step 1: DialogSpacing 클래스 파일 생성**

```dart
import 'package:flutter/material.dart';

/// 다이얼로그 내부 섹션 간 간격 오버라이드
///
/// 각 필드가 null이면 AppDialog의 기본값을 사용합니다.
/// 특정 다이얼로그에서만 간격을 조절할 때 사용합니다.
///
/// **사용 예시:**
/// ```dart
/// AppDialog.show(
///   title: '게임 규칙',
///   spacing: DialogSpacing(toContent: AppSpacing.vertical12),
///   customContent: Column(...),
/// );
/// ```
@immutable
class DialogSpacing {
  const DialogSpacing({
    this.avatarToTitle,
    this.titleToMessage,
    this.toContent,
    this.toButtons,
  });

  /// 아바타 ↔ 타이틀 간격 (기본: AppSpacing.vertical16)
  final double? avatarToTitle;

  /// 타이틀 ↔ 메시지 간격 (기본: AppSpacing.vertical12)
  final double? titleToMessage;

  /// 메시지/타이틀 ↔ 커스텀 콘텐츠 간격
  /// (기본: message 있으면 AppSpacing.vertical12, 없으면 AppSpacing.vertical20)
  final double? toContent;

  /// 콘텐츠/메시지 ↔ 버튼 간격 (기본: AppSpacing.vertical20)
  final double? toButtons;
}
```

**Step 2: Commit**

```bash
git add lib/core/widgets/dialogs/dialog_spacing.dart
git commit -m "feat: DialogSpacing 클래스 생성"
```

---

### Task 2: AppDialog에서 contentSpacing → spacing 교체

**Files:**
- Modify: `lib/core/widgets/dialogs/app_dialog.dart`

**Step 1: import 추가 및 필드 교체**

`app_dialog.dart` 상단에 import 추가:
```dart
import 'dialog_spacing.dart';
```

`contentSpacing` 필드를 `spacing`으로 교체:
```dart
// 삭제:
// this.contentSpacing,
// final double? contentSpacing;

// 추가:
this.spacing,

/// 다이얼로그 내부 섹션 간 간격 오버라이드 (미지정 시 기본값 적용)
final DialogSpacing? spacing;
```

**Step 2: show() 메서드의 contentSpacing → spacing 교체**

```dart
// 파라미터 변경:
// double? contentSpacing,  →  DialogSpacing? spacing,

// AppDialog 생성자 전달:
// contentSpacing: contentSpacing,  →  spacing: spacing,
```

**Step 3: confirm() 메서드에 spacing 추가**

```dart
// 파라미터 추가:
DialogSpacing? spacing,

// AppDialog 생성자에 전달:
spacing: spacing,
```

**Step 4: build() 메서드의 4개 spacing 구간 교체**

아바타 ↔ 타이틀:
```dart
// 변경 전:
SizedBox(height: AppSpacing.vertical16),

// 변경 후:
SizedBox(height: widget.spacing?.avatarToTitle ?? AppSpacing.vertical16),
```

타이틀 ↔ 메시지:
```dart
// 변경 전:
SizedBox(height: AppSpacing.vertical12),

// 변경 후:
SizedBox(height: widget.spacing?.titleToMessage ?? AppSpacing.vertical12),
```

메시지/타이틀 ↔ 커스텀 콘텐츠:
```dart
// 변경 전:
SizedBox(
  height: widget.contentSpacing ??
      (widget.message != null
          ? AppSpacing.vertical12
          : AppSpacing.vertical20),
),

// 변경 후:
SizedBox(
  height: widget.spacing?.toContent ??
      (widget.message != null
          ? AppSpacing.vertical12
          : AppSpacing.vertical20),
),
```

콘텐츠/메시지 ↔ 버튼:
```dart
// 변경 전:
SizedBox(height: AppSpacing.vertical20),

// 변경 후:
SizedBox(height: widget.spacing?.toButtons ?? AppSpacing.vertical20),
```

**Step 5: Commit**

```bash
git add lib/core/widgets/dialogs/app_dialog.dart
git commit -m "refactor: AppDialog contentSpacing을 DialogSpacing 객체로 교체"
```

---

### Task 3: 호출부 마이그레이션

**Files:**
- Modify: `lib/test_widget_page.dart`

**Step 1: contentSpacing → spacing 교체**

```dart
// 변경 전:
contentSpacing: AppSpacing.vertical12,

// 변경 후:
spacing: DialogSpacing(toContent: AppSpacing.vertical12),
```

import 추가 필요 시:
```dart
import 'core/widgets/dialogs/dialog_spacing.dart';
```

**Step 2: Commit**

```bash
git add lib/test_widget_page.dart
git commit -m "refactor: test_widget_page contentSpacing → DialogSpacing 마이그레이션"
```

---

### Task 4: DartDoc 주석 업데이트

**Files:**
- Modify: `lib/core/widgets/dialogs/app_dialog.dart` (클래스 상단 DartDoc)

**Step 1: AppDialog 클래스 주석에 spacing 사용법 추가**

기존 사용 예시 섹션에 추가:
```dart
/// // spacing 커스터마이징
/// AppDialog.show(
///   context: context,
///   title: '게임 규칙',
///   spacing: DialogSpacing(toContent: AppSpacing.vertical12),
///   customContent: Column(...),
/// );
```

**Step 2: Commit**

```bash
git add lib/core/widgets/dialogs/app_dialog.dart
git commit -m "docs: AppDialog DartDoc에 DialogSpacing 사용 예시 추가"
```

---

### Task 5: 빌드 검증

**Step 1: flutter analyze 실행**

```bash
flutter analyze
```

Expected: No issues found

**Step 2: contentSpacing 잔여 참조 확인**

```bash
grep -rn "contentSpacing" --include="*.dart" lib/
```

Expected: 결과 없음 (모두 spacing으로 교체됨)
