# 역할 기반 다이얼로그 테마 구현 계획

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 역할(경찰=라이트, 도둑=다크)에 따라 다이얼로그 테마를 자동 전환하는 기능 구현

**Architecture:** Riverpod Provider로 현재 역할의 다크/라이트 상태를 관리. AppDialog/AppPopup에 backgroundColor·isDarkMode 파라미터를 추가하여 다크 모드 시 버튼 기본값을 자동 적용. 호출부에서 AppColors/AppTextStyles 상수를 직접 선택하여 스타일 지정.

**Tech Stack:** Flutter, Riverpod (@riverpod), AppColors, AppTextStyles, AppButton

**Spec:** `docs/superpowers/specs/2026-03-12-role-based-dialog-theme-design.md`

---

## Task 1: RoleTheme Provider 생성

**Files:**
- Create: `lib/core/theme/role_theme_provider.dart`

- [ ] **Step 1: Provider 파일 생성**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'role_theme_provider.g.dart';

/// 역할 기반 다크/라이트 모드 상태 관리
///
/// - `true` = 다크 모드 (도둑)
/// - `false` = 라이트 모드 (경찰, 기본값)
///
/// 대기방 진입 시 팀 배정에 따라 [setDarkMode] 호출.
/// ```dart
/// // 팀 배정 시
/// ref.read(roleThemeProvider.notifier).setDarkMode(team == 'ROBBER');
///
/// // 읽기
/// final isDark = ref.watch(roleThemeProvider);
/// ```
@riverpod
class RoleTheme extends _$RoleTheme {
  @override
  bool build() => false;

  /// 다크 모드 설정
  void setDarkMode(bool isDark) {
    state = isDark;
  }
}
```

Note: 팀 값은 현재 String `"POLICE"`/`"ROBBER"`로 관리됨. enum이 아니므로 `setDarkMode(bool)`로 단순화.

- [ ] **Step 2: 코드 생성 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `role_theme_provider.g.dart` 생성 성공

- [ ] **Step 3: 커밋**

```bash
git add lib/core/theme/role_theme_provider.dart lib/core/theme/role_theme_provider.g.dart
git commit -m "feat : RoleTheme Provider 생성 #115"
```

---

## Task 2: AppButton에 textStyle 파라미터 추가

AppDialog의 다크 모드 버튼에서 `robber_label` 스타일을 사용해야 하는데, 현재 AppButton은 `label_16`을 하드코딩.
`textStyle` 파라미터를 추가하여 오버라이드 가능하게 한다.

**Files:**
- Modify: `lib/core/widgets/buttons/app_button.dart:244-249`

- [ ] **Step 1: textStyle 파라미터 추가**

`app_button.dart`의 생성자에 파라미터 추가:

```dart
/// 텍스트 스타일 오버라이드 (미지정 시 label_16)
final TextStyle? textStyle;
```

- [ ] **Step 2: _buildButtonContent()에서 textStyle 적용**

`_buildButtonContent()` 메서드 수정 (subtitle 없는 경우 + subtitle 있는 경우 모두):

**subtitle 없는 경우 (line 244-249):**
```dart
// 변경 전
style: AppTextStyles.label_16.copyWith(
  color: _effectiveForegroundColor,
),

// 변경 후
style: (textStyle ?? AppTextStyles.label_16).copyWith(
  color: _effectiveForegroundColor,
),
```

**subtitle 있는 경우 (line 256-260):**
```dart
// 변경 전
style: AppTextStyles.label_16.copyWith(
  color: _effectiveForegroundColor,
),

// 변경 후
style: (textStyle ?? AppTextStyles.label_16).copyWith(
  color: _effectiveForegroundColor,
),
```

- [ ] **Step 3: 커밋**

```bash
git add lib/core/widgets/buttons/app_button.dart
git commit -m "feat : AppButton에 textStyle 파라미터 추가 #115"
```

---

## Task 3: AppDialog에 backgroundColor·isDarkMode 파라미터 추가

**Files:**
- Modify: `lib/core/widgets/dialogs/app_dialog.dart`

- [ ] **Step 1: 생성자에 파라미터 추가**

`AppDialog` 클래스에 2개 필드 추가:

```dart
/// 다이얼로그 배경색 (미지정 시 AppColors.white)
final Color? backgroundColor;

/// 다크 모드 버튼 기본값 활성화
///
/// true일 때 명시적 색상 미지정 시:
/// - confirm: green 배경, robber_label + black 텍스트
/// - cancel: black900 배경, robber_label + black400 텍스트
final bool isDarkMode;
```

생성자에 추가:
```dart
this.backgroundColor,
this.isDarkMode = false,
```

- [ ] **Step 2: show() 정적 메서드에 파라미터 전달**

`show()` 메서드 시그니처에 추가:
```dart
Color? backgroundColor,
bool isDarkMode = false,
```

`AppDialog(...)` 생성에 전달:
```dart
backgroundColor: backgroundColor,
isDarkMode: isDarkMode,
```

- [ ] **Step 3: confirm() 정적 메서드에도 파라미터 전달**

`confirm()` 메서드 시그니처에 추가:
```dart
Color? backgroundColor,
bool isDarkMode = false,
```

`AppDialog(...)` 생성에 전달:
```dart
backgroundColor: backgroundColor,
isDarkMode: isDarkMode,
```

- [ ] **Step 4: _AppDialogState의 resolved 색상 로직 수정**

`_resolvedConfirmColor` 수정:
```dart
Color get _resolvedConfirmColor =>
    widget.confirmColor ??
    (widget.isDestructive
        ? AppColors.red
        : widget.isDarkMode
            ? AppColors.green
            : AppColors.black);
```

`_resolvedConfirmTextColor` 수정:
```dart
Color get _resolvedConfirmTextColor =>
    widget.confirmTextColor ??
    (widget.isDarkMode ? AppColors.black : AppColors.white);
```

`_resolvedCancelColor` 수정:
```dart
Color get _resolvedCancelColor =>
    widget.cancelColor ??
    (widget.isDarkMode ? AppColors.black900 : AppColors.black100);
```

`_resolvedCancelTextColor` 수정:
```dart
Color get _resolvedCancelTextColor =>
    widget.cancelTextColor ??
    (widget.isDarkMode ? AppColors.black400 : AppColors.black600);
```

- [ ] **Step 5: build()에서 배경색과 버튼 textStyle 적용**

배경색 변경 (line 377):
```dart
// 변경 전
color: AppColors.white,

// 변경 후
color: widget.backgroundColor ?? AppColors.white,
```

메시지 색상도 isDarkMode 반영 (line 421-425):
```dart
// 변경 전
style: AppTextStyles.paragraph_14.copyWith(
  color: AppColors.black600,
),

// 변경 후
style: AppTextStyles.paragraph_14.copyWith(
  color: widget.isDarkMode ? AppColors.black400 : AppColors.black600,
),
```

- [ ] **Step 6: _buildButtons()에서 isDarkMode 시 textStyle 전달**

`_buildButtons()` 메서드 수정. AppButton에 `textStyle` 전달:

confirm 버튼 (2버튼 모드, line 516-524):
```dart
AppButton(
  text: widget.confirmText,
  onPressed: widget.onConfirm,
  backgroundColor: _resolvedConfirmColor,
  foregroundColor: _resolvedConfirmTextColor,
  textStyle: widget.isDarkMode ? AppTextStyles.robber_label : null,
  borderRadius: AppRadius.medium,
  showBorder: false,
  height: 48.h,
),
```

cancel 버튼 (line 504-512):
```dart
AppButton(
  text: widget.cancelText!,
  onPressed: widget.onCancel,
  backgroundColor: _resolvedCancelColor,
  foregroundColor: _resolvedCancelTextColor,
  textStyle: widget.isDarkMode ? AppTextStyles.robber_label : null,
  borderRadius: AppRadius.medium,
  showBorder: false,
  height: 48.h,
),
```

1버튼 모드 (line 531-540)에도 동일 적용:
```dart
AppButton(
  text: widget.confirmText,
  onPressed: widget.onConfirm,
  backgroundColor: _resolvedConfirmColor,
  foregroundColor: _resolvedConfirmTextColor,
  textStyle: widget.isDarkMode ? AppTextStyles.robber_label : null,
  borderRadius: AppRadius.medium,
  showBorder: false,
  width: double.infinity,
  height: 48.h,
),
```

- [ ] **Step 7: 커밋**

```bash
git add lib/core/widgets/dialogs/app_dialog.dart
git commit -m "feat : AppDialog에 backgroundColor·isDarkMode 파라미터 추가 #115"
```

---

## Task 4: AppPopup에 backgroundColor 파라미터 추가

**Files:**
- Modify: `lib/core/widgets/dialogs/app_popup.dart`

- [ ] **Step 1: 파라미터 추가**

`AppPopup` 생성자에 필드 추가:
```dart
/// 팝업 배경색 (미지정 시 AppColors.white)
final Color? backgroundColor;
```

생성자: `this.backgroundColor`

`show()` 정적 메서드에 파라미터 추가:
```dart
Color? backgroundColor,
```

`AppPopup(...)` 생성에 전달:
```dart
backgroundColor: backgroundColor,
```

- [ ] **Step 2: build()에서 배경색 적용**

line 128 수정:
```dart
// 변경 전
color: AppColors.white,

// 변경 후
color: backgroundColor ?? AppColors.white,
```

- [ ] **Step 3: 커밋**

```bash
git add lib/core/widgets/dialogs/app_popup.dart
git commit -m "feat : AppPopup에 backgroundColor 파라미터 추가 #115"
```

---

## Task 5: 초대코드 다이얼로그에 다크 모드 적용

**Files:**
- Modify: `lib/features/session/presentation/pages/waiting_room_page.dart:504-564`

- [ ] **Step 1: import 추가**

파일 상단에 import 추가 (없는 경우):
```dart
import 'package:cops_and_robbers/core/theme/role_theme_provider.dart';
```

- [ ] **Step 2: _showInviteCodeDialog() 수정**

메서드를 다크/라이트 분기 적용하여 전체 교체:

```dart
/// 초대코드 모달 (방 생성 직후 표시)
void _showInviteCodeDialog() {
  final code = widget.inviteCode!;
  final messenger = ScaffoldMessenger.of(context);
  final isDark = ref.read(roleThemeProvider);

  AppDialog.show(
    context: context,
    isDarkMode: isDark,
    backgroundColor: isDark ? AppColors.black : null,
    title: '초대코드를 생성했어요',
    titleStyle: isDark
        ? AppTextStyles.robber_heading.copyWith(color: AppColors.white)
        : null,
    message: '친구에게 코드를 공유하고 게임에 참여해 보세요!',
    customContent: GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: code));
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('코드가 복사되었습니다', style: AppTextStyles.paragraph_14),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.vertical20,
          horizontal: AppSpacing.horizontal16,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.black800 : AppColors.black100,
          ),
          borderRadius: AppRadius.medium,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: isDark
                  ? AppTextStyles.robber_heading.copyWith(
                      color: AppColors.white,
                    )
                  : AppTextStyles.heading_20.copyWith(
                      color: AppColors.black,
                    ),
            ),
            SizedBox(width: AppSpacing.horizontal4),
            SvgPicture.asset(
              'assets/icons/icon_copy.svg',
              width: 20.w,
              height: 20.w,
              colorFilter: ColorFilter.mode(
                isDark ? AppColors.black500 : AppColors.black300,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    ),
    cancelText: '닫기',
    confirmText: '공유하기',
    // isDarkMode가 true면 버튼 색상은 자동 적용됨
    // 라이트 모드일 때만 기존 blue 유지
    confirmColor: isDark ? null : AppColors.blue,
    confirmTextColor: isDark ? null : AppColors.white,
    onConfirm: () {
      shareText(code);
    },
  );
}
```

- [ ] **Step 3: 빌드 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze`
Expected: 에러 없음

- [ ] **Step 4: 커밋**

```bash
git add lib/features/session/presentation/pages/waiting_room_page.dart
git commit -m "feat : 초대코드 다이얼로그 역할 기반 다크 모드 적용 #115"
```
