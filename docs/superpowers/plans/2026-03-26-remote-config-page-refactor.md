# 점검/강제 업데이트 다이얼로그 → 전용 페이지 리팩토링

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 점검 모드와 강제 업데이트 시 재귀 다이얼로그 대신 전용 페이지로 이동하여 앱을 차단한다. 선택 업데이트는 기존 다이얼로그 유지.

**Architecture:** `MaintenancePage`와 `ForceUpdatePage`를 `core/widgets/pages/`에 생성하고, GoRouter에 public 라우트로 등록한다. SplashPage에서 `context.go()`로 이동하면 뒤로가기 스택이 없으므로 자연스럽게 차단된다.

**Tech Stack:** Flutter, GoRouter, 기존 디자인 시스템 (AppColors, AppTextStyles, AppSpacing, AppButton)

---

## 파일 구조

| 작업 | 파일 | 역할 |
|------|------|------|
| Create | `lib/core/widgets/pages/maintenance_page.dart` | 서버 점검 안내 페이지 |
| Create | `lib/core/widgets/pages/force_update_page.dart` | 강제 업데이트 안내 페이지 |
| Modify | `lib/router/route_paths.dart` | 점검/업데이트 경로 추가 |
| Modify | `lib/router/app_router.dart` | 점검/업데이트 라우트 등록 + publicPaths 추가 |
| Modify | `lib/core/services/remote_config/update_dialog_helper.dart` | 페이지 이동 방식으로 변경, 선택 업데이트만 다이얼로그 유지 |
| Modify | `lib/features/auth/presentation/pages/splash_page.dart` | UpdateDialogHelper 호출 시 context 전달 방식 변경 |

---

### Task 1: MaintenancePage 생성

**Files:**
- Create: `lib/core/widgets/pages/maintenance_page.dart`

- [ ] **Step 1: MaintenancePage 작성**

기존 `LoadingPage` 레이아웃 패턴(Scaffold → SafeArea → Padding → Column with Expanded center)을 따른다. Material Icons의 `Icons.construction_rounded`를 사용한다.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 서버 점검 중 안내 페이지
///
/// Remote Config의 `maintenance`가 `true`일 때 표시된다.
/// 뒤로가기 스택이 없는 상태로 이동(`context.go`)되므로
/// 사용자가 앱을 빠져나갈 수 없다.
class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.construction_rounded,
                        size: 64.w,
                        color: AppColors.black400,
                      ),
                      SizedBox(height: AppSpacing.vertical24),
                      Text(
                        '서버 점검 중',
                        style: AppTextStyles.heading_20.copyWith(
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.vertical8),
                      Text(
                        '더 나은 서비스를 위해 점검 중이에요.\n잠시 후 다시 접속해 주세요.',
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.black600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 56.h),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### Task 2: ForceUpdatePage 생성

**Files:**
- Create: `lib/core/widgets/pages/force_update_page.dart`

- [ ] **Step 1: ForceUpdatePage 작성**

`LoadingPage` 레이아웃 + 하단에 `AppButton`을 배치한다. 버튼은 스토어 URL로 이동시킨다. `dart:io`의 `Platform`으로 플랫폼 분기한다.

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../utils/url_launcher_util.dart';
import '../buttons/app_button.dart';

/// 강제 업데이트 안내 페이지
///
/// Remote Config에서 현재 앱 버전이 `minimum_version`보다 낮고
/// `force_update`가 `true`일 때 표시된다.
/// 뒤로가기 스택이 없는 상태로 이동(`context.go`)되므로
/// 사용자가 업데이트 없이 앱을 사용할 수 없다.
class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({super.key});

  /// 스토어 URL (플랫폼별 분기)
  static String get _storeUrl {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=com.copsandrobbers.app';
    }
    return 'https://apps.apple.com/app/id000000000';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.system_update_rounded,
                        size: 64.w,
                        color: AppColors.black400,
                      ),
                      SizedBox(height: AppSpacing.vertical24),
                      Text(
                        '업데이트 필요',
                        style: AppTextStyles.heading_20.copyWith(
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.vertical8),
                      Text(
                        '새로운 버전이 출시되었어요.\n업데이트 후 이용해 주세요.',
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.black600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              AppButton(
                text: '업데이트',
                onPressed: () => launchExternalUrl(_storeUrl),
                showBorder: false,
              ),
              SizedBox(height: 56.h),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### Task 3: RoutePaths + GoRouter에 라우트 추가

**Files:**
- Modify: `lib/router/route_paths.dart`
- Modify: `lib/router/app_router.dart`

- [ ] **Step 1: RoutePaths에 경로 상수 추가**

`route_paths.dart`의 Developer Tools 섹션 바로 위에 추가:

```dart
  // ============================================================================
  // System Status Routes (점검/업데이트)
  // ============================================================================

  /// 서버 점검 중 페이지
  static const String maintenance = '/maintenance';

  /// 강제 업데이트 페이지
  static const String forceUpdate = '/force-update';

  // Route Names
  static const String maintenanceName = 'maintenance';
  static const String forceUpdateName = 'forceUpdate';
```

- [ ] **Step 2: GoRouter에 라우트 등록**

`app_router.dart`의 routes 리스트에서 Developer Tools 섹션 바로 위에 추가:

```dart
      // ====================================================================
      // System Status Routes (인증 불필요)
      // ====================================================================
      GoRoute(
        path: RoutePaths.maintenance,
        name: RoutePaths.maintenanceName,
        builder: (context, state) => const MaintenancePage(),
      ),

      GoRoute(
        path: RoutePaths.forceUpdate,
        name: RoutePaths.forceUpdateName,
        builder: (context, state) => const ForceUpdatePage(),
      ),
```

import 추가:

```dart
import '../core/widgets/pages/maintenance_page.dart';
import '../core/widgets/pages/force_update_page.dart';
```

- [ ] **Step 3: publicPaths에 추가**

`app_router.dart`의 redirect 함수 내 `publicPaths` 리스트에 추가:

```dart
        final publicPaths = [
          RoutePaths.splash,
          RoutePaths.login,
          RoutePaths.maintenance,    // 추가
          RoutePaths.forceUpdate,    // 추가
          if (kDebugMode) RoutePaths.lifecycleTest,
        ];
```

---

### Task 4: UpdateDialogHelper 리팩토링

**Files:**
- Modify: `lib/core/services/remote_config/update_dialog_helper.dart`

- [ ] **Step 1: UpdateDialogHelper를 페이지 이동 방식으로 변경**

점검/강제 업데이트는 `context.go()`로 전용 페이지 이동, 선택 업데이트만 다이얼로그 유지.

기존 파일을 전체 교체:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../router/route_paths.dart';
import '../../utils/url_launcher_util.dart';
import '../../widgets/dialogs/app_dialog.dart';
import 'app_version_checker.dart';

/// 앱 업데이트 및 점검 처리 헬퍼
///
/// [VersionCheckResult]에 따라 적절한 조치를 수행한다.
/// - [VersionCheckResult.maintenance]: 점검 페이지로 이동 (앱 차단)
/// - [VersionCheckResult.forceUpdate]: 강제 업데이트 페이지로 이동 (앱 차단)
/// - [VersionCheckResult.optionalUpdate]: 선택 업데이트 다이얼로그 표시
class UpdateDialogHelper {
  UpdateDialogHelper._();

  /// 스토어 URL (플랫폼별 분기)
  static String get _storeUrl {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=com.copsandrobbers.app';
    }
    return 'https://apps.apple.com/app/id000000000';
  }

  /// 버전 체크 결과에 따라 페이지 이동 또는 다이얼로그 표시
  ///
  /// 반환값: true면 앱 진행 가능, false면 앱 차단 (페이지 이동 완료)
  static Future<bool> handleResult(
    BuildContext context,
    VersionCheckResult result,
  ) async {
    switch (result) {
      case VersionCheckResult.upToDate:
        return true;

      case VersionCheckResult.maintenance:
        context.go(RoutePaths.maintenance);
        return false;

      case VersionCheckResult.forceUpdate:
        context.go(RoutePaths.forceUpdate);
        return false;

      case VersionCheckResult.optionalUpdate:
        await _showOptionalUpdateDialog(context);
        return true;
    }
  }

  /// 선택 업데이트 다이얼로그 ("나중에" 가능)
  static Future<void> _showOptionalUpdateDialog(BuildContext context) {
    return AppDialog.show(
      context: context,
      title: '업데이트 안내',
      message: '새로운 버전이 출시되었어요.\n업데이트하시겠어요?',
      confirmText: '업데이트',
      cancelText: '나중에',
      barrierDismissible: true,
      onConfirm: () {
        launchExternalUrl(_storeUrl);
      },
    );
  }
}
```

---

### Task 5: SplashPage 호출부 수정

**Files:**
- Modify: `lib/features/auth/presentation/pages/splash_page.dart`

- [ ] **Step 1: showIfNeeded → handleResult 변경**

SplashPage의 Remote Config 체크 블록에서 메서드명만 변경:

변경 전:
```dart
      final canProceed = await UpdateDialogHelper.showIfNeeded(
        context,
        versionResult,
      );
```

변경 후:
```dart
      final canProceed = await UpdateDialogHelper.handleResult(
        context,
        versionResult,
      );
```

---

### Task 6: 빌드 검증

**Files:** (수정 없음)

- [ ] **Step 1: flutter analyze 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze`
Expected: error 없음
