# Settings Page Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 설정 페이지 구현 — 홈 화면 설정 아이콘에서 진입, 닉네임 변경/알림/버그 제보/개인정보 처리방침/로그아웃/회원탈퇴 메뉴 제공

**Architecture:** `lib/features/settings/presentation/pages/settings_page.dart` 신규 생성. 순수 UI 페이지 — 별도 data/domain 레이어 불필요. 로그아웃은 기존 `authNotifierProvider.signOut()` 재사용.

**Tech Stack:** Flutter, Riverpod, GoRouter, 기존 디자인 시스템 (AppColors, AppTextStyles, AppSpacing, AppPadding)

---

## Reference: Design Spec

```
┌──────────────────────────────────┐
│  ←         설정                   │  ← AppBar: PreviousButton + Center("설정" heading_20 black)
│                                  │
│  닉네임 변경                      │  ← label_16, black
│  1~10글자로 생성할 수 있어요       │  ← tag_12, black600
│  ┌─────────────────┬──────────┐  │
│  │ 기존 닉네임       │ 중복 확인 │  │  ← AppTextField + ActionChip (기존 nickname_setup 패턴)
│  └─────────────────┴──────────┘  │
│  ─────────────────────────────── │  ← Divider(black100)
│  알림                            │  ← label_16, black + Switch 토글
│  게임 중 알림을 제외한 기타 알림의  │
│  설정이에요                       │  ← tag_12, black600
│  ─────────────────────────────── │
│  버그 제보                        │  ← label_16, black
│  ─────────────────────────────── │
│  개인정보 처리방침                 │  ← label_16, black
│  ─────────────────────────────── │
│  로그아웃                         │  ← label_16, red
│  ─────────────────────────────── │
│  회원 탈퇴                        │  ← label_16, black600
└──────────────────────────────────┘
```

## Key Design Values

| Element | Spec |
|---------|------|
| AppBar leading | `PreviousButton(onPressed: () => context.pop())` |
| AppBar title | `heading_20`, `AppColors.black`, center 정렬 |
| 메뉴 텍스트 | `label_16`, `AppColors.black` |
| 로그아웃 텍스트 | `label_16`, `AppColors.red` |
| 회원탈퇴 텍스트 | `label_16`, `AppColors.black600` |
| 설명 텍스트 | `tag_12`, `AppColors.black600` |
| Divider | `AppColors.black100`, thickness 1 |
| 닉네임 입력 | `AppTextField` + `ActionChip` (중복 확인) |
| 알림 토글 | `Switch` (Material) |
| 페이지 패딩 | `AppPadding.horizontal20` (좌우 20px) |
| 라우트 | `/home/settings` (home의 sub-route, push로 진입) |

---

### Task 1: 라우트 등록 및 홈 화면 네비게이션 연결

**Files:**
- Modify: `lib/router/route_paths.dart`
- Modify: `lib/router/app_router.dart`
- Modify: `lib/features/session/presentation/pages/home_page.dart`

**Step 1: RoutePaths에 설정 경로 추가**

`lib/router/route_paths.dart`의 Home 영역에 추가:

```dart
/// 설정 화면
static const String settings = '/home/settings';
static const String settingsName = 'settings';
```

**Step 2: GoRouter에 설정 라우트 등록**

`lib/router/app_router.dart`의 home GoRoute의 `routes:` 배열 안에 추가 (create-session과 같은 레벨):

```dart
// 설정 페이지
GoRoute(
  path: 'settings',
  name: RoutePaths.settingsName,
  pageBuilder: (context, state) => buildDirectionalSlide(
    key: state.pageKey,
    child: const SettingsPage(),
    isForward: true,
  ),
),
```

import 추가:
```dart
import 'package:cops_and_robbers/features/settings/presentation/pages/settings_page.dart';
```

**Step 3: 홈 화면 설정 아이콘에 네비게이션 연결**

`lib/features/session/presentation/pages/home_page.dart`의 설정 GestureDetector onTap:

```dart
onTap: () {
  context.push(RoutePaths.settings);
},
```

기존 TODO 주석 제거.

**Step 4: flutter analyze 확인**

Run: `flutter analyze lib/router/ lib/features/session/presentation/pages/home_page.dart`
Expected: No issues (SettingsPage 미존재로 에러 발생 가능 — Task 2에서 생성)

**Step 5: Commit**

```
feat : 설정 페이지 라우트 등록 및 홈 화면 네비게이션 연결 #95
```

---

### Task 2: 설정 페이지 UI 구현

**Files:**
- Create: `lib/features/settings/presentation/pages/settings_page.dart`

**Step 1: settings_page.dart 생성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// 설정 페이지
///
/// 닉네임 변경, 알림, 버그 제보, 개인정보 처리방침,
/// 로그아웃, 회원탈퇴 메뉴를 제공합니다.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _notificationEnabled = true;

  @override
  void initState() {
    super.initState();
    // 현재 닉네임을 텍스트 필드에 설정
    final authState = ref.read(authNotifierProvider);
    final nickname = authState.value?.nickname ?? '';
    _nicknameController.text = nickname;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: Text(
          '설정',
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppPadding.horizontal20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.vertical24),

              // ── 닉네임 변경 섹션 ──
              Text(
                '닉네임 변경',
                style: AppTextStyles.label_16.copyWith(color: AppColors.black),
              ),
              SizedBox(height: AppSpacing.vertical4),
              Text(
                '1~10글자로 생성할 수 있어요',
                style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
              ),
              SizedBox(height: AppSpacing.vertical12),

              // 닉네임 입력 + 중복 확인 Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nicknameController,
                      maxLength: 10,
                      style: AppTextStyles.label16Medium.copyWith(
                        color: AppColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: '기존 닉네임',
                        hintStyle: AppTextStyles.label16Medium.copyWith(
                          color: AppColors.black400,
                        ),
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.horizontal16,
                          vertical: AppSpacing.vertical12,
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.large,
                          borderSide: const BorderSide(color: AppColors.black100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.large,
                          borderSide: const BorderSide(color: AppColors.black100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.large,
                          borderSide: const BorderSide(color: AppColors.black),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.horizontal8),
                  GestureDetector(
                    onTap: () {
                      // TODO: 중복 확인 로직
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontal16,
                        vertical: AppSpacing.vertical12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black200,
                        borderRadius: AppRadius.large,
                      ),
                      child: Text(
                        '중복 확인',
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.vertical20),
              Divider(color: AppColors.black100, height: 1),

              // ── 알림 섹션 ──
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '알림',
                            style: AppTextStyles.label_16.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: AppSpacing.vertical4),
                          Text(
                            '게임 중 알림을 제외한 기타 알림의 설정이에요',
                            style: AppTextStyles.tag_12.copyWith(
                              color: AppColors.black600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _notificationEnabled,
                      onChanged: (value) {
                        setState(() => _notificationEnabled = value);
                        // TODO: 알림 설정 저장 로직
                      },
                      activeColor: AppColors.white,
                      activeTrackColor: AppColors.black,
                    ),
                  ],
                ),
              ),

              Divider(color: AppColors.black100, height: 1),

              // ── 버그 제보 ──
              _buildMenuItem(
                text: '버그 제보',
                onTap: () {
                  // TODO: 버그 제보 페이지 이동
                },
              ),

              Divider(color: AppColors.black100, height: 1),

              // ── 개인정보 처리방침 ──
              _buildMenuItem(
                text: '개인정보 처리방침',
                onTap: () {
                  // TODO: 개인정보 처리방침 페이지 이동
                },
              ),

              Divider(color: AppColors.black100, height: 1),

              // ── 로그아웃 ──
              _buildMenuItem(
                text: '로그아웃',
                textColor: AppColors.red,
                onTap: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                },
              ),

              Divider(color: AppColors.black100, height: 1),

              // ── 회원 탈퇴 ──
              _buildMenuItem(
                text: '회원 탈퇴',
                textColor: AppColors.black600,
                onTap: () {
                  // TODO: 회원 탈퇴 로직
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 설정 메뉴 아이템 빌더
  Widget _buildMenuItem({
    required String text,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical16),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            text,
            style: AppTextStyles.label_16.copyWith(
              color: textColor ?? AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/features/settings/`
Expected: No issues found

**Step 3: Commit**

```
feat : 설정 페이지 UI 구현 #95
```

---

## Notes

- **닉네임 변경 로직**: 현재 TODO. 기존 `user_provider.dart`의 닉네임 체크/업데이트 API 재사용 가능 (별도 이슈에서 구현)
- **알림 토글**: 현재 로컬 state만. 서버 연동은 별도 이슈
- **버그 제보**: 외부 링크 또는 별도 페이지 (별도 이슈)
- **개인정보 처리방침**: WebView 또는 외부 링크 (별도 이슈)
- **회원 탈퇴**: 별도 API + 확인 다이얼로그 필요 (별도 이슈)
- **로그아웃**: `authNotifierProvider.signOut()` 호출 → GoRouter redirect가 자동으로 LoginPage 이동
- **Switch 스타일**: Figma 디자인의 토글 색상에 맞춰 `activeColor: white, activeTrackColor: black` 설정
