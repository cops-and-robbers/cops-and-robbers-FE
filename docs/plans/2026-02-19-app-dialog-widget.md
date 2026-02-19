# AppDialog 위젯 재설계 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 앱 공용 다이얼로그(AppDialog)를 화이트 테마 기반으로 재설계하여, 체포 로직(아바타+닉네임), 정보 표시(단일 버튼), 타이머/공지(버튼 없음) 등 다양한 사용 시나리오를 하나의 위젯으로 지원한다.

**Architecture:** 기존 AppDialog를 프로젝트 디자인 시스템(AppColors, AppTextStyles, AppSpacing, AppRadius)에 맞게 완전 재작성. `TossDesignTokens` 의존성 제거. 버튼 표시를 3단계로 제어(2버튼/1버튼/무버튼)하고, 아바타+닉네임은 `showAvatar` 플래그로 선택적 표시.

**Tech Stack:** Flutter, flutter_screenutil, 기존 AppButton 위젯, AppColors/AppTextStyles/AppSpacing/AppRadius 상수

---

## 설계 결정 (Design Decisions)

### 버튼 없는 다이얼로그 → AppDialog에 통합

타이머/게임종료/공지 등 버튼 없는 다이얼로그를 별도 위젯으로 분리하지 않고 AppDialog에 통합한다.

**근거:**
- 시각적 컨테이너(흰 배경, 24r, 그림자)가 동일
- 제목/메시지 패턴이 동일
- `showButtons: false` + `customContent`로 모든 케이스 커버 가능
- 자동 닫힘(타이머)은 호출부에서 `Navigator.pop()` 제어 — 다이얼로그 책임 아님
- 별도 위젯은 90% 코드 중복 발생

### 버튼 제어 3단계

| 모드 | 조건 | 용도 |
|------|------|------|
| 2버튼 | `showButtons: true` + `cancelText != null` | 체포 확인, 삭제 확인 |
| 1버튼 | `showButtons: true` + `cancelText == null` | 게임규칙, 정보 안내 |
| 무버튼 | `showButtons: false` | 타이머, 공지, 게임종료 |

### 다이얼로그 레이아웃

```
┌─────────────────────────────┐
│        (margin: 36px)       │
│  ┌───────────────────────┐  │
│  │    [아바타 92x108]     │  │  ← showAvatar: true일 때만
│  │      (4px gap)         │  │
│  │    [닉네임 tag_12]     │  │
│  │      (16px gap)        │  │
│  │   제목 heading_20      │  │  ← 항상 표시
│  │      (12px gap)        │  │
│  │   메시지 paragraph_14  │  │  ← message != null일 때
│  │  [customContent]       │  │  ← customContent != null일 때
│  │      (20px gap)        │  │
│  │  [취소]  [확인]        │  │  ← showButtons: true일 때
│  └───────────────────────┘  │
└─────────────────────────────┘
```

---

## Task 1: 누락된 공용 상수 추가

**Files:**
- Modify: `lib/core/constants/spacing_and_radius.dart`

**Step 1: AppRadius에 xxlarge(24r) 추가**

`spacing_and_radius.dart` 파일의 `AppRadius` 클래스에 추가:

```dart
/// 매우 매우 큰 라운드 (24px) - 다이얼로그 등
static BorderRadius get xxlarge => BorderRadius.circular(24.r);
```

위치: `xl20` 아래에 추가.

**Step 2: AppPadding에 all24, horizontal36 추가**

`spacing_and_radius.dart` 파일의 `AppPadding` 클래스에 추가:

```dart
/// 모든 방향 24px
static EdgeInsets get all24 => EdgeInsets.all(24.w);

/// 좌우 36px
static EdgeInsets get horizontal36 => EdgeInsets.symmetric(horizontal: 36.w);
```

위치: `all20` 아래에 `all24`, `horizontal24` 아래에 `horizontal36` 추가.

**Step 3: 검증**

Run: `flutter analyze lib/core/constants/spacing_and_radius.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/core/constants/spacing_and_radius.dart
git commit -m "feat: AppRadius.xxlarge(24r), AppPadding.all24, horizontal36 상수 추가

AppDialog 재설계에 필요한 공용 상수 사전 추가.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 2: AppDialog 위젯 완전 재작성

**Files:**
- Modify: `lib/core/widgets/dialogs/app_dialog.dart`

**Step 1: 전체 파일 재작성**

기존 코드를 완전히 교체. `TossDesignTokens` 의존성 제거, 화이트 테마 적용.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../buttons/app_button.dart';

/// 앱 전역에서 사용하는 공용 다이얼로그 컴포넌트
///
/// **기본 스펙**:
/// - 배경: white, 모서리: 24px 라운드
/// - 양옆 마진: 36px (화면 너비에 맞게 확장)
/// - 애니메이션: 스케일 + 페이드 (250ms, easeOutBack)
///
/// **버튼 모드 3가지**:
/// 1. 2버튼 (취소+확인): `cancelText`를 지정하면 취소 버튼 표시
/// 2. 1버튼 (확인만): `cancelText` 미지정 (기본값)
/// 3. 무버튼: `showButtons: false` (타이머, 공지, 게임종료용)
///
/// **사용 예시**:
/// ```dart
/// // 기본 확인 다이얼로그 (1버튼)
/// AppDialog.show(
///   context: context,
///   title: '게임 규칙',
///   message: '30분 안에 모든 도둑을 체포하세요',
/// );
///
/// // 확인/취소 다이얼로그 (2버튼)
/// AppDialog.show(
///   context: context,
///   title: '체포할까요?',
///   message: '이 플레이어를 체포합니다',
///   cancelText: '취소',
///   onConfirm: () => capture(),
/// );
///
/// // 아바타 포함 다이얼로그 (체포 로직)
/// AppDialog.show(
///   context: context,
///   title: '체포 성공!',
///   message: '도둑을 체포했습니다',
///   showAvatar: true,
///   avatarWidget: CircleAvatar(backgroundImage: NetworkImage(url)),
///   nickname: '도둑닉네임',
/// );
///
/// // 버튼 없는 다이얼로그 (타이머/공지)
/// AppDialog.show(
///   context: context,
///   title: '게임 종료',
///   showButtons: false,
///   customContent: TimerWidget(),
/// );
///
/// // 간편 확인 (bool 반환)
/// final result = await AppDialog.confirm(
///   context: context,
///   title: '삭제할까요?',
///   message: '삭제하면 되돌릴 수 없어요',
///   isDestructive: true,
/// );
/// if (result == true) { /* 삭제 */ }
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmText = '확인',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.showButtons = true,
    this.customContent,
    this.showAvatar = false,
    this.avatarWidget,
    this.nickname,
  });

  /// 제목 (필수) - heading_20, black
  final String title;

  /// 메시지 (선택) - paragraph_14, black600
  final String? message;

  /// 확인 버튼 텍스트 (기본: '확인')
  final String confirmText;

  /// 취소 버튼 텍스트 (null이면 취소 버튼 없음)
  final String? cancelText;

  /// 확인 콜백
  final VoidCallback? onConfirm;

  /// 취소 콜백
  final VoidCallback? onCancel;

  /// 위험 액션 여부 (true면 확인 버튼 빨간색)
  final bool isDestructive;

  /// 버튼 표시 여부 (false면 버튼 영역 전체 숨김)
  final bool showButtons;

  /// 커스텀 콘텐츠 (message 대신 또는 추가로 사용)
  final Widget? customContent;

  /// 아바타 표시 여부 (기본: false, 체포 로직 등 특정 상황에서만 사용)
  final bool showAvatar;

  /// 아바타 위젯 (showAvatar가 true일 때 표시)
  final Widget? avatarWidget;

  /// 닉네임 (showAvatar가 true일 때 아바타 아래 표시)
  final String? nickname;

  // ============================================
  // 애니메이션 상수
  // ============================================
  static const _animationDuration = Duration(milliseconds: 250);
  static const _animationCurve = Curves.easeOutBack;

  // ============================================
  // 정적 메서드
  // ============================================

  /// 다이얼로그 표시
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = '확인',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    bool showButtons = true,
    Widget? customContent,
    bool showAvatar = false,
    Widget? avatarWidget,
    String? nickname,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: _animationDuration,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AppDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          isDestructive: isDestructive,
          showButtons: showButtons,
          customContent: customContent,
          showAvatar: showAvatar,
          avatarWidget: avatarWidget,
          nickname: nickname,
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            onConfirm?.call();
          },
          onCancel: () {
            Navigator.of(dialogContext).pop();
            onCancel?.call();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: _animationCurve,
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// 간편 확인 다이얼로그 (bool 반환)
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDestructive = false,
    bool showAvatar = false,
    Widget? avatarWidget,
    String? nickname,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: _animationDuration,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AppDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          isDestructive: isDestructive,
          showAvatar: showAvatar,
          avatarWidget: avatarWidget,
          nickname: nickname,
          onConfirm: () => Navigator.of(dialogContext).pop(true),
          onCancel: () => Navigator.of(dialogContext).pop(false),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: _animationCurve,
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  // ============================================
  // UI 빌드
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: AppPadding.horizontal36,
        padding: AppPadding.all24,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xxlarge,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아바타 + 닉네임 (선택)
              if (showAvatar) ...[
                _buildAvatarSection(),
                SizedBox(height: AppSpacing.vertical16),
              ],

              // 제목
              Text(
                title,
                style: AppTextStyles.heading_20.copyWith(
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),

              // 메시지
              if (message != null) ...[
                SizedBox(height: AppSpacing.vertical12),
                Text(
                  message!,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.black600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // 커스텀 콘텐츠
              if (customContent != null) ...[
                SizedBox(height: AppSpacing.vertical12),
                customContent!,
              ],

              // 버튼들
              if (showButtons) ...[
                SizedBox(height: AppSpacing.vertical20),
                _buildButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 아바타 + 닉네임 섹션
  Widget _buildAvatarSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 아바타 이미지
        SizedBox(
          width: 92.w,
          height: 108.h,
          child: avatarWidget ?? const SizedBox.shrink(),
        ),
        // 닉네임
        if (nickname != null) ...[
          SizedBox(height: AppSpacing.vertical4),
          Text(
            nickname!,
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.black600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// 버튼 영역
  Widget _buildButtons() {
    final hasCancel = cancelText != null;

    if (hasCancel) {
      // 2버튼: 취소 + 확인
      return Row(
        children: [
          Expanded(
            child: AppButton(
              text: cancelText!,
              onPressed: onCancel,
              backgroundColor: AppColors.black100,
              foregroundColor: AppColors.black600,
              borderRadius: AppRadius.medium,
              showBorder: false,
              height: 48.h,
            ),
          ),
          SizedBox(width: AppSpacing.horizontal8),
          Expanded(
            child: AppButton(
              text: confirmText,
              onPressed: onConfirm,
              backgroundColor:
                  isDestructive ? AppColors.red : AppColors.black,
              foregroundColor: AppColors.white,
              borderRadius: AppRadius.medium,
              showBorder: false,
              height: 48.h,
            ),
          ),
        ],
      );
    }

    // 1버튼: 확인만
    return AppButton(
      text: confirmText,
      onPressed: onConfirm,
      backgroundColor: isDestructive ? AppColors.red : AppColors.black,
      foregroundColor: AppColors.white,
      borderRadius: AppRadius.medium,
      showBorder: false,
      width: double.infinity,
      height: 48.h,
    );
  }
}
```

**Step 2: 검증**

Run: `flutter analyze lib/core/widgets/dialogs/app_dialog.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/core/widgets/dialogs/app_dialog.dart
git commit -m "feat: AppDialog 화이트 테마 기반 재설계 #99

- 배경 white, 모서리 24r, 양옆 마진 36px
- 아바타+닉네임 선택 표시 (showAvatar, 기본 false)
- 버튼 3단계 제어: 2버튼/1버튼/무버튼
- TossDesignTokens 의존성 제거
- 기존 AppButton, AppColors, AppTextStyles 공용 상수 활용

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: flutter analyze 전체 검증

**Step 1: 전체 프로젝트 분석**

Run: `flutter analyze`
Expected: No issues found (또는 기존 이슈만 존재)

**Step 2: 필요 시 수정**

분석 결과에서 새로 추가한 코드 관련 이슈가 있으면 수정.

---

## 상수 매핑 요약

| 디자인 스펙 | 사용 상수 | 값 |
|-------------|----------|-----|
| 다이얼로그 배경 | `AppColors.white` | `#FFFFFF` |
| 다이얼로그 모서리 | `AppRadius.xxlarge` | `24.r` (신규) |
| 양옆 마진 | `AppPadding.horizontal36` | `36.w` (신규) |
| 내부 패딩 | `AppPadding.all24` | `24.w` (신규) |
| 아바타-닉네임 간격 | `AppSpacing.vertical4` | `4.h` |
| 아바타섹션-제목 간격 | `AppSpacing.vertical16` | `16.h` |
| 제목-메시지 간격 | `AppSpacing.vertical12` | `12.h` |
| 메시지-버튼 간격 | `AppSpacing.vertical20` | `20.h` |
| 버튼 사이 간격 | `AppSpacing.horizontal8` | `8.w` |
| 제목 스타일 | `AppTextStyles.heading_20` | 20sp SemiBold |
| 메시지 스타일 | `AppTextStyles.paragraph_14` | 14sp Medium |
| 닉네임 스타일 | `AppTextStyles.tag_12` | 12sp Medium |
| 버튼 텍스트 | `AppTextStyles.label_16` | 16sp SemiBold (AppButton 내부) |
| 취소 버튼 배경 | `AppColors.black100` | `#EDF0F2` |
| 취소 버튼 텍스트 | `AppColors.black600` | `#5D6F83` |
| 확인 버튼 배경 | `AppColors.black` | `#080A0C` |
| 확인 버튼 텍스트 | `AppColors.white` | `#FFFFFF` |
| 위험 버튼 배경 | `AppColors.red` | `#F5383B` |
| 버튼 모서리 | `AppRadius.medium` | `8.r` |
| 애니메이션 시간 | 인라인 상수 | `250ms` |
| 애니메이션 커브 | 인라인 상수 | `easeOutBack` |
