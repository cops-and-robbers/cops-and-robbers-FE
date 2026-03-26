# Firebase Remote Config 기반 앱 버전 관리 및 점검 모드 구현

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Firebase Remote Config를 도입하여 앱 버전 강제/선택 업데이트 및 서버 점검 모드를 제어한다.

**Architecture:** SplashPage에서 인증 확인 전에 Remote Config를 fetch하고, 점검 모드 → 버전 비교 → 업데이트 다이얼로그 순서로 체크한다. Remote Config 서비스는 `core/services/remote_config/`에 위치하며, Riverpod Provider로 상태를 관리한다. 스토어 URL은 `dart:io`의 `Platform`으로 플랫폼 분기 처리한다.

**Tech Stack:** `firebase_remote_config`, `package_info_plus` (이미 설치됨), `url_launcher` (이미 설치됨), Riverpod

---

## 파일 구조

| 작업 | 파일 | 역할 |
|------|------|------|
| Create | `lib/core/services/remote_config/remote_config_service.dart` | Remote Config 초기화, fetch, 값 조회 |
| Create | `lib/core/services/remote_config/app_version_checker.dart` | 버전 비교 로직 + 점검 모드 체크 |
| Create | `lib/core/services/remote_config/update_dialog_helper.dart` | 강제/선택 업데이트 및 점검 다이얼로그 표시 |
| Modify | `lib/features/auth/presentation/pages/splash_page.dart` | Remote Config 체크를 인증 전에 실행 |
| Modify | `pubspec.yaml` | `firebase_remote_config` 의존성 추가 |

---

### Task 1: firebase_remote_config 의존성 추가

**Files:**
- Modify: `pubspec.yaml:55-58`

- [ ] **Step 1: pubspec.yaml에 firebase_remote_config 추가**

`firebase_core` 아래에 추가:

```yaml
  firebase_remote_config: ^5.0.5 # 앱 버전 관리 및 점검 모드 (Remote Config)
```

- [ ] **Step 2: 의존성 설치**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter pub get`
Expected: "Got dependencies!" 성공 메시지

- [ ] **Step 3: 커밋**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore : 앱 버전 관리를 위한 firebase_remote_config 의존성 추가 #191"
```

---

### Task 2: RemoteConfigService 구현

**Files:**
- Create: `lib/core/services/remote_config/remote_config_service.dart`

- [ ] **Step 1: RemoteConfigService 작성**

Firebase Remote Config 초기화, fetch, 값 조회를 담당하는 서비스 클래스를 작성한다.

```dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Firebase Remote Config 서비스
///
/// 앱 버전 관리 및 점검 모드 파라미터를 서버에서 가져온다.
/// 싱글톤으로 관리하며, 앱 시작 시 [initialize]를 호출해야 한다.
///
/// Remote Config 파라미터:
/// - `minimum_version` (String): 최소 허용 버전
/// - `latest_version` (String): 최신 버전
/// - `force_update` (bool): 강제 업데이트 여부
/// - `maintenance` (bool): 서버 점검 모드
class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService _instance = RemoteConfigService._();

  /// 싱글톤 인스턴스
  static RemoteConfigService get instance => _instance;

  late final FirebaseRemoteConfig _remoteConfig;
  bool _isInitialized = false;

  /// Remote Config 초기화 및 서버 값 fetch
  ///
  /// [fetchTimeout]: fetch 타임아웃 (기본 10초)
  /// [minimumFetchInterval]: 최소 fetch 간격 (디버그: 0초, 릴리스: 1시간)
  Future<void> initialize() async {
    if (_isInitialized) return;

    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(hours: 1),
      ),
    );

    // 기본값 설정 (서버 연결 실패 시 사용)
    await _remoteConfig.setDefaults({
      'minimum_version': '1.0.0',
      'latest_version': '1.0.0',
      'force_update': false,
      'maintenance': false,
    });

    // 서버에서 최신 값 가져오기
    try {
      await _remoteConfig.fetchAndActivate();
      debugPrint('✅ Remote Config fetched successfully');
    } catch (e) {
      debugPrint('⚠️ Remote Config fetch failed, using defaults: $e');
    }

    _isInitialized = true;
  }

  /// 최소 허용 버전
  String get minimumVersion => _remoteConfig.getString('minimum_version');

  /// 최신 버전
  String get latestVersion => _remoteConfig.getString('latest_version');

  /// 강제 업데이트 여부
  bool get forceUpdate => _remoteConfig.getBool('force_update');

  /// 서버 점검 모드 여부
  bool get maintenance => _remoteConfig.getBool('maintenance');
}
```

- [ ] **Step 2: 커밋**

```bash
git add lib/core/services/remote_config/remote_config_service.dart
git commit -m "feat : Firebase Remote Config 서비스 구현 #191"
```

---

### Task 3: AppVersionChecker 구현

**Files:**
- Create: `lib/core/services/remote_config/app_version_checker.dart`

- [ ] **Step 1: AppVersionChecker 작성**

현재 앱 버전과 Remote Config 값을 비교하여 업데이트 필요 여부를 판단하는 클래스를 작성한다.

```dart
import 'package:package_info_plus/package_info_plus.dart';

import 'remote_config_service.dart';

/// 앱 버전 체크 결과
enum VersionCheckResult {
  /// 서버 점검 중
  maintenance,

  /// 강제 업데이트 필요 (앱 사용 차단)
  forceUpdate,

  /// 선택 업데이트 가능 (사용자가 "나중에" 선택 가능)
  optionalUpdate,

  /// 최신 버전 (업데이트 불필요)
  upToDate,
}

/// 앱 버전 체크 유틸리티
///
/// Remote Config의 파라미터와 현재 앱 버전을 비교하여
/// 점검 모드, 강제/선택 업데이트 여부를 판단한다.
///
/// 체크 순서:
/// 1. maintenance == true → [VersionCheckResult.maintenance]
/// 2. 현재 버전 < minimum_version → force_update에 따라 forceUpdate 또는 optionalUpdate
/// 3. 그 외 → [VersionCheckResult.upToDate]
class AppVersionChecker {
  AppVersionChecker._();

  /// 버전 체크 실행
  ///
  /// Remote Config 값과 현재 앱 버전을 비교하여 결과를 반환한다.
  /// Remote Config가 초기화되지 않았거나 에러 발생 시 [VersionCheckResult.upToDate]를 반환한다.
  static Future<VersionCheckResult> check() async {
    final config = RemoteConfigService.instance;

    // 1. 점검 모드 체크
    if (config.maintenance) {
      return VersionCheckResult.maintenance;
    }

    // 2. 버전 비교
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final minimumVersion = config.minimumVersion;

    if (_isVersionLower(currentVersion, minimumVersion)) {
      // 3. 업데이트 방식 결정
      return config.forceUpdate
          ? VersionCheckResult.forceUpdate
          : VersionCheckResult.optionalUpdate;
    }

    return VersionCheckResult.upToDate;
  }

  /// 버전 A가 버전 B보다 낮은지 비교 (semantic versioning)
  ///
  /// 예: _isVersionLower('1.2.3', '1.3.0') → true
  ///     _isVersionLower('2.0.0', '1.9.9') → false
  static bool _isVersionLower(String versionA, String versionB) {
    final partsA = versionA.split('.').map(int.tryParse).toList();
    final partsB = versionB.split('.').map(int.tryParse).toList();

    for (var i = 0; i < 3; i++) {
      final a = i < partsA.length ? (partsA[i] ?? 0) : 0;
      final b = i < partsB.length ? (partsB[i] ?? 0) : 0;

      if (a < b) return true;
      if (a > b) return false;
    }

    return false; // 동일 버전
  }
}
```

- [ ] **Step 2: 커밋**

```bash
git add lib/core/services/remote_config/app_version_checker.dart
git commit -m "feat : 앱 버전 비교 및 점검 모드 체크 로직 구현 #191"
```

---

### Task 4: UpdateDialogHelper 구현

**Files:**
- Create: `lib/core/services/remote_config/update_dialog_helper.dart`

- [ ] **Step 1: UpdateDialogHelper 작성**

VersionCheckResult에 따라 적절한 다이얼로그를 표시하는 헬퍼 클래스를 작성한다. 기존 `AppDialog`를 활용한다.

```dart
import 'dart:io';

import 'package:flutter/material.dart';

import '../../widgets/dialogs/app_dialog.dart';
import '../../utils/url_launcher_helper.dart';
import 'app_version_checker.dart';

/// 앱 업데이트 및 점검 다이얼로그 표시 헬퍼
///
/// [VersionCheckResult]에 따라 적절한 다이얼로그를 표시한다.
/// - [VersionCheckResult.maintenance]: 점검 안내 (앱 차단)
/// - [VersionCheckResult.forceUpdate]: 강제 업데이트 (스토어 이동만 가능)
/// - [VersionCheckResult.optionalUpdate]: 선택 업데이트 ("나중에" 가능)
class UpdateDialogHelper {
  UpdateDialogHelper._();

  /// 스토어 URL (플랫폼별 분기)
  static String get _storeUrl {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=com.copsandrobbers.app';
    }
    return 'https://apps.apple.com/app/id000000000';
  }

  /// 버전 체크 결과에 따라 다이얼로그 표시
  ///
  /// [VersionCheckResult.upToDate]이면 아무것도 표시하지 않고 true를 반환한다.
  /// 반환값: true면 앱 진행 가능, false면 앱 차단 (강제 업데이트/점검)
  static Future<bool> showIfNeeded(
    BuildContext context,
    VersionCheckResult result,
  ) async {
    switch (result) {
      case VersionCheckResult.upToDate:
        return true;

      case VersionCheckResult.maintenance:
        await _showMaintenanceDialog(context);
        return false;

      case VersionCheckResult.forceUpdate:
        await _showForceUpdateDialog(context);
        return false;

      case VersionCheckResult.optionalUpdate:
        await _showOptionalUpdateDialog(context);
        return true;
    }
  }

  /// 서버 점검 다이얼로그 (닫기 불가)
  static Future<void> _showMaintenanceDialog(BuildContext context) {
    return AppDialog.show(
      context: context,
      title: '서버 점검 중',
      message: '더 나은 서비스를 위해 점검 중이에요.\n잠시 후 다시 접속해 주세요.',
      confirmText: '확인',
      barrierDismissible: false,
      onConfirm: () {
        // 앱 종료 대신 다이얼로그를 다시 표시하여 차단 유지
        // iOS는 앱 종료 API를 허용하지 않으므로 다이얼로그 유지 방식 사용
        _showMaintenanceDialog(context);
      },
    );
  }

  /// 강제 업데이트 다이얼로그 (스토어 이동만 가능, 닫기 불가)
  static Future<void> _showForceUpdateDialog(BuildContext context) {
    return AppDialog.show(
      context: context,
      title: '업데이트 필요',
      message: '새로운 버전이 출시되었어요.\n업데이트 후 이용해 주세요.',
      confirmText: '업데이트',
      barrierDismissible: false,
      onConfirm: () {
        UrlLauncherHelper.launchURL(_storeUrl);
        // 스토어 이동 후에도 다이얼로그 유지 (앱으로 돌아왔을 때 차단)
        _showForceUpdateDialog(context);
      },
    );
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
        UrlLauncherHelper.launchURL(_storeUrl);
      },
    );
  }
}
```

- [ ] **Step 2: UrlLauncherHelper 존재 여부 확인**

Run: `grep -r "class UrlLauncherHelper" /Users/luca/workspace/Flutter_Project/cops_and_robbers/lib/`
Expected: `lib/core/utils/url_launcher_helper.dart` 에서 해당 클래스가 발견되어야 함.

만약 없다면 import 경로를 실제 url_launcher 유틸리티 경로로 수정한다.

- [ ] **Step 3: 커밋**

```bash
git add lib/core/services/remote_config/update_dialog_helper.dart
git commit -m "feat : 강제/선택 업데이트 및 점검 다이얼로그 헬퍼 구현 #191"
```

---

### Task 5: SplashPage에 Remote Config 체크 통합

**Files:**
- Modify: `lib/features/auth/presentation/pages/splash_page.dart`

- [ ] **Step 1: SplashPage 수정**

`_navigateToNextScreen()` 메서드의 최상단(auth 초기화 대기 전)에 Remote Config 초기화 및 버전 체크 로직을 추가한다.

기존 코드에서 `_navigateToNextScreen()` 메서드의 시작 부분을 다음과 같이 수정:

```dart
import '../../../../core/services/remote_config/remote_config_service.dart';
import '../../../../core/services/remote_config/app_version_checker.dart';
import '../../../../core/services/remote_config/update_dialog_helper.dart';
```

`_navigateToNextScreen()` 메서드의 `final startTime = DateTime.now();` 바로 다음에 아래 코드를 삽입:

```dart
    // ================================================================
    // Remote Config: 점검 모드 및 앱 버전 체크
    // ================================================================
    try {
      await RemoteConfigService.instance.initialize();
      final versionResult = await AppVersionChecker.check();

      if (!mounted) return;

      final canProceed = await UpdateDialogHelper.showIfNeeded(
        context,
        versionResult,
      );

      if (!canProceed) return; // 점검/강제 업데이트 → 앱 차단
    } catch (e) {
      debugPrint('⚠️ SplashPage: Remote Config 체크 실패, 앱 진행: $e');
      // Remote Config 실패 시 앱 정상 진행 (fail-open)
    }
```

- [ ] **Step 2: 전체 import 확인 및 빌드 테스트**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/auth/presentation/pages/splash_page.dart`
Expected: "No issues found!" 또는 warning만 (error 없음)

- [ ] **Step 3: 커밋**

```bash
git add lib/features/auth/presentation/pages/splash_page.dart
git commit -m "feat : SplashPage에 Remote Config 버전 체크 통합 #191"
```

---

### Task 6: 전체 빌드 검증

**Files:** (수정 없음 - 검증만)

- [ ] **Step 1: flutter analyze 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze`
Expected: error 없음

- [ ] **Step 2: UrlLauncherHelper import 경로 최종 확인**

`update_dialog_helper.dart`에서 import한 `UrlLauncherHelper`가 실제 프로젝트의 URL 런처 유틸리티와 일치하는지 확인한다. 불일치하면 실제 경로로 수정한다.

Run: `grep -rn "launchURL\|launchUrl\|openUrl" /Users/luca/workspace/Flutter_Project/cops_and_robbers/lib/core/utils/`

- [ ] **Step 3: 최종 커밋 (필요 시)**

import 경로 수정 등이 있었다면:

```bash
git add -A
git commit -m "fix : Remote Config 관련 import 경로 수정 #191"
```
