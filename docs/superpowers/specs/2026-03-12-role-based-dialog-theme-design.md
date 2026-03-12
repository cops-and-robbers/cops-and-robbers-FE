# 역할 기반 다이얼로그 테마 설계

## 개요

대기방/게임 화면에서 역할(경찰=라이트, 도둑=다크)에 따라 UI 테마를 변경한다.
전역 다크/라이트 모드가 아니라 역할 기반으로만 적용한다.
첫 번째 적용 대상은 초대코드 다이얼로그이며, 이후 게임규칙·AppPopup·대기방·게임화면으로 확장한다.

## 핵심 원칙

- 모든 색상은 `AppColors` 상수 사용
- 모든 텍스트 스타일은 `AppTextStyles` 상수 사용
- 별도 테마 클래스 없이 호출부에서 상수를 직접 선택
- `isDarkMode` 파라미터로 다크 모드 버튼 기본값 자동 적용

## 1. RoleTheme Provider

**파일:** `lib/core/theme/role_theme_provider.dart`

Riverpod `@riverpod` Notifier로 구현.

```dart
@riverpod
class RoleTheme extends _$RoleTheme {
  @override
  bool build() => false; // 기본값: 라이트(경찰)

  void setRole(TeamRole role) {
    state = role == TeamRole.robber;
  }
}
```

- `state == true` → 다크(도둑)
- `state == false` → 라이트(경찰)
- 대기방 진입 시 팀 배정에 따라 `setRole()` 호출

## 2. AppDialog 변경

### 추가 파라미터

| 파라미터 | 타입 | 기본값 | 설명 |
|---------|------|-------|------|
| `backgroundColor` | `Color?` | `null` (→ white) | 다이얼로그 배경색 |
| `isDarkMode` | `bool` | `false` | 다크 모드 버튼 기본값 활성화 |

### isDarkMode 버튼 기본값

`isDarkMode: true`이고 명시적 색상 미지정 시 자동 적용:

| 요소 | 라이트 (기본) | 다크 (isDarkMode: true) |
|------|-------------|------------------------|
| confirm 배경 | `AppColors.black` | `AppColors.green` |
| confirm 텍스트 스타일 | `label_16` + `white` | `robber_label` + `black` |
| cancel 배경 | `AppColors.black100` | `AppColors.black900` |
| cancel 텍스트 스타일 | `label_16` + `black600` | `robber_label` + `black400` |

`confirmColor`/`cancelColor` 등을 명시적으로 전달하면 오버라이드 가능.

### build() 변경

```dart
// 배경색
color: widget.backgroundColor ?? AppColors.white,

// 버튼 기본색 resolve 로직에 isDarkMode 반영
Color get _resolvedConfirmColor =>
    widget.confirmColor ??
    (widget.isDestructive
        ? AppColors.red
        : widget.isDarkMode
            ? AppColors.green
            : AppColors.black);
```

## 3. AppPopup 변경

동일하게 `backgroundColor` 파라미터 추가. 기본값 white 유지.

## 4. 초대코드 다이얼로그 적용

**파일:** `waiting_room_page.dart` `_showInviteCodeDialog()`

### 변경 전후 비교

| 요소 | 라이트 (현재/경찰) | 다크 (도둑) |
|------|-------------------|------------|
| 다이얼로그 배경 | `white` | `black` |
| 제목 스타일 | `heading_20` + `black` | `robber_heading` + `white` |
| 메시지 스타일 | `paragraph_14` + `black600` | `paragraph_14` + `black400` |
| 코드 박스 외곽선 | `black100` | `black800` |
| 코드 박스 배경 | 투명 | `black` |
| 초대코드 텍스트 | `heading_20` + `black` | `robber_heading` + `white` |
| 복사 아이콘 색 | `black300` | `black500` |
| 공유하기(confirm) | `blue` 배경 + `white` 텍스트 | `green` 배경 + `robber_label` + `black` (isDarkMode 자동) |
| 닫기(cancel) | `black100` 배경 + `black600` 텍스트 | `black900` 배경 + `robber_label` + `black400` (isDarkMode 자동) |

### 호출부 코드 (다크 모드)

```dart
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
  // customContent 내부에서도 isDark에 따라 색상 분기
  customContent: _buildInviteCodeBox(code, isDark),
  cancelText: '닫기',
  confirmText: '공유하기',
  onConfirm: () => shareText(code),
);
```

## 5. 향후 확장

같은 패턴으로 확장:
- **게임규칙 다이얼로그**: `isDarkMode` + `backgroundColor` + 커스텀 스타일
- **AppPopup**: `backgroundColor` 파라미터로 배경 변경
- **대기방/게임 화면**: `ref.watch(roleThemeProvider)`로 isDark 읽고 화면 전체 색상 분기

## 변경 파일 목록

| 파일 | 변경 내용 |
|------|----------|
| `lib/core/theme/role_theme_provider.dart` | 신규 - RoleTheme Provider |
| `lib/core/widgets/dialogs/app_dialog.dart` | `backgroundColor`, `isDarkMode` 파라미터 추가 + 버튼 기본값 로직 |
| `lib/core/widgets/dialogs/app_popup.dart` | `backgroundColor` 파라미터 추가 |
| `lib/features/session/presentation/pages/waiting_room_page.dart` | 초대코드 다이얼로그 다크 모드 적용 |
