# PaginationBar 중복 간격 제거 및 Pill Radius 적용

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** PaginationBar의 중복 패딩/간격을 제거하고 borderRadius를 완전한 원형(pill)으로 변경한다.

**Architecture:** Container padding + 내부 위젯 SizedBox/margin이 겹쳐서 과도한 여백이 발생하고 있다. 화살표 버튼의 SizedBox(32x32)를 아이콘 크기에 맞게 축소하고, Container의 radius를 pill(stadium) 형태로 변경한다.

**Tech Stack:** Flutter, flutter_screenutil

---

## 현재 구조 분석

```text
Container (padding: all 16, borderRadius: 24px)
└─ Row (mainAxisSize: min)
   ├─ _buildArrowButton: SizedBox(32x32) → Icon(16x16)  ← 8px 내부 여백
   ├─ _buildPageButton:  Container(28x28, margin: h4)    ← 4px 좌우 마진
   ├─ ellipsis:          Padding(h4) → Text('···')       ← 4px 좌우 패딩
   └─ _buildArrowButton: SizedBox(32x32) → Icon(16x16)  ← 8px 내부 여백
```

### 중복 간격 포인트

| 위치              | 현재 값            | 문제                                                 |
| ----------------- | ------------------ | ---------------------------------------------------- |
| Container padding | 16px all           | OK (의도된 내부 패딩)                                |
| Arrow SizedBox    | 32x32 (icon 16x16) | **8px 내부 여백** → Container padding과 합산 시 24px |
| PageButton margin | horizontal 4.w     | OK (버튼 간 간격)                                    |

### 해결 방향

- `_buildArrowButton` SizedBox 32→28로 축소 (page button과 동일 크기, 내부 여백 6px)
- Container `borderRadius` → pill shape (`BorderRadius.circular(999)`)

---

## Task 1: \_buildArrowButton SizedBox 축소 및 radius 변경

**Files:**

- Modify: `lib/core/widgets/pagination_bar.dart`

**Step 1: \_buildArrowButton의 SizedBox를 28x28로 축소**

```dart
// 변경 전
child: SizedBox(
  width: 32.w,
  height: 32.w,
  child: Icon(icon, size: 16.w, color: AppColors.black600),
),

// 변경 후
child: SizedBox(
  width: 28.w,
  height: 28.w,
  child: Icon(icon, size: 16.w, color: AppColors.black600),
),
```

**Step 2: Container borderRadius를 pill(완전 원형)로 변경**

```dart
// 변경 전
borderRadius: AppRadius.xxlarge,

// 변경 후
borderRadius: BorderRadius.circular(999),
```

`999`는 높이의 절반보다 항상 크므로 pill(stadium) 형태가 된다.

**Step 3: flutter analyze 실행**

Run: `flutter analyze lib/core/widgets/pagination_bar.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/core/widgets/pagination_bar.dart
git commit -m "fix: PaginationBar 화살표 SizedBox 축소 및 pill radius 적용"
```
