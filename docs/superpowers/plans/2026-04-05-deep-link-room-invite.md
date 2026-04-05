# 딥링크 기반 방 초대 — 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `app_links` 패키지로 딥링크 URI를 수신하고, 초대코드로 방에 자동 참가하는 프론트엔드 환경을 구축한다.

**Architecture:** `app_links`가 OS로부터 URI를 수신 → `DeepLinkHandler`(Riverpod provider)가 파싱/검증 → 기존 `joinGameProvider`로 방 참가 API 호출 → `go_router`로 대기실 이동. 도메인은 `DeepLinkConfig` 상수 1곳에서 관리하되, 확정 전까지 기존 초대코드 공유 기능을 유지한다.

**Tech Stack:** Flutter, app_links ^7.0.0, go_router ^17.0.1, Riverpod, share_plus ^12.0.1

---

## 파일 구조

### 신규 파일

| 파일 | 역할 |
|------|------|
| `lib/core/constants/deep_link_config.dart` | 도메인 상수 + URL 빌더 |
| `lib/core/deep_link/deep_link_handler.dart` | URI 수신 → 파싱 → 방 참가 → 라우팅 |
| `test/core/constants/deep_link_config_test.dart` | DeepLinkConfig 단위 테스트 |
| `test/core/deep_link/deep_link_handler_test.dart` | DeepLinkHandler 단위 테스트 |

### 변경 파일

| 파일 | 변경 내용 |
|------|-----------|
| `pubspec.yaml` | `app_links: ^7.0.0` 추가 |
| `android/app/src/main/AndroidManifest.xml` | intent-filter + flutter_deeplinking_enabled=false |
| `ios/Runner/Runner.entitlements` | `com.apple.developer.associated-domains` 추가 |
| `lib/main.dart` | DeepLinkHandler 초기화 연결 |
| `lib/features/session/presentation/pages/waiting_room_page.dart` | 공유 텍스트에 딥링크 URL 준비 (주석 처리, 기존 코드 유지) |

---

## Task 1: 패키지 추가 및 네이티브 설정

**Files:**
- Modify: `pubspec.yaml:66` (app_settings 아래)
- Modify: `android/app/src/main/AndroidManifest.xml:35-47` (activity 내부)
- Modify: `ios/Runner/Runner.entitlements:4-11` (dict 내부)

- [ ] **Step 1: pubspec.yaml에 app_links 추가**

`pubspec.yaml`의 `app_settings: ^7.0.0` 아래에 추가:

```yaml
  app_links: ^7.0.0 # 딥링크 URI 수신 (Cold Start + 실행 중)
```

- [ ] **Step 2: flutter pub get 실행**

Run: `flutter pub get`
Expected: `Got dependencies!`

- [ ] **Step 3: AndroidManifest.xml에 intent-filter 및 meta-data 추가**

`android/app/src/main/AndroidManifest.xml`의 `<activity>` 태그 내부, 기존 `<intent-filter>` (MAIN/LAUNCHER) 바로 아래에 추가:

```xml
            <!-- 딥링크: Flutter 기본 핸들러 비활성화 (app_links 사용) -->
            <meta-data
                android:name="flutter_deeplinking_enabled"
                android:value="false" />

            <!-- 딥링크: App Links intent-filter -->
            <!-- TODO: 도메인 확정 시 android:host 값 변경 -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="https"
                    android:host="example.com"
                    android:pathPrefix="/room" />
            </intent-filter>
```

- [ ] **Step 4: Runner.entitlements에 Associated Domains 추가**

`ios/Runner/Runner.entitlements`의 `</dict>` 바로 위에 추가:

```xml
	<key>com.apple.developer.associated-domains</key>
	<array>
		<!-- TODO: 도메인 확정 시 applinks: 뒤의 도메인 변경 -->
		<string>applinks:example.com</string>
	</array>
```

- [ ] **Step 5: 빌드 확인**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: 커밋**

```bash
git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml ios/Runner/Runner.entitlements
git commit -m "chore: app_links 패키지 추가 및 Android/iOS 딥링크 네이티브 설정 #216"
```

---

## Task 2: DeepLinkConfig 상수 클래스

**Files:**
- Create: `lib/core/constants/deep_link_config.dart`
- Test: `test/core/constants/deep_link_config_test.dart`

- [ ] **Step 1: 테스트 작성**

`test/core/constants/deep_link_config_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/core/constants/deep_link_config.dart';

void main() {
  group('DeepLinkConfig', () {
    test('roomInviteUrl은 올바른 형식의 딥링크 URL을 생성한다', () {
      final url = DeepLinkConfig.roomInviteUrl('ABC123');

      expect(url, 'https://example.com/room?code=ABC123');
    });

    test('roomInviteUrl은 다양한 초대코드를 처리한다', () {
      expect(
        DeepLinkConfig.roomInviteUrl('XYZ789'),
        'https://example.com/room?code=XYZ789',
      );
    });

    test('isDeepLink는 올바른 호스트의 URI를 true로 판별한다', () {
      final uri = Uri.parse('https://example.com/room?code=ABC123');

      expect(DeepLinkConfig.isDeepLink(uri), isTrue);
    });

    test('isDeepLink는 다른 호스트의 URI를 false로 판별한다', () {
      final uri = Uri.parse('https://other.com/room?code=ABC123');

      expect(DeepLinkConfig.isDeepLink(uri), isFalse);
    });

    test('isRoomInvite는 /room 경로를 true로 판별한다', () {
      final uri = Uri.parse('https://example.com/room?code=ABC123');

      expect(DeepLinkConfig.isRoomInvite(uri), isTrue);
    });

    test('isRoomInvite는 /friend 경로를 false로 판별한다', () {
      final uri = Uri.parse('https://example.com/friend?code=USER456');

      expect(DeepLinkConfig.isRoomInvite(uri), isFalse);
    });

    test('extractRoomCode는 code 파라미터를 추출한다', () {
      final uri = Uri.parse('https://example.com/room?code=ABC123');

      expect(DeepLinkConfig.extractRoomCode(uri), 'ABC123');
    });

    test('extractRoomCode는 code 파라미터가 없으면 null을 반환한다', () {
      final uri = Uri.parse('https://example.com/room');

      expect(DeepLinkConfig.extractRoomCode(uri), isNull);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/core/constants/deep_link_config_test.dart`
Expected: FAIL — `deep_link_config.dart` 파일이 없으므로 컴파일 에러

- [ ] **Step 3: DeepLinkConfig 구현**

`lib/core/constants/deep_link_config.dart`:

```dart
/// 딥링크 설정 상수
///
/// 도메인 변경 시 [host]만 수정하면 앱 전체 딥링크가 연동된다.
/// Android/iOS 네이티브 설정도 함께 변경 필요:
/// - android/app/src/main/AndroidManifest.xml (android:host)
/// - ios/Runner/Runner.entitlements (applinks:도메인)
class DeepLinkConfig {
  DeepLinkConfig._();

  // TODO: 백엔드 도메인 확정 시 변경
  static const String host = 'example.com';
  static const String scheme = 'https';

  /// 방 초대 딥링크 URL 생성
  static String roomInviteUrl(String inviteCode) =>
      '$scheme://$host/room?code=$inviteCode';

  /// 이 앱의 딥링크인지 호스트로 판별
  static bool isDeepLink(Uri uri) => uri.host == host;

  /// 방 초대 딥링크인지 경로로 판별
  static bool isRoomInvite(Uri uri) => uri.path == '/room';

  /// 방 초대코드 추출 (없으면 null)
  static String? extractRoomCode(Uri uri) =>
      uri.queryParameters['code'];
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/core/constants/deep_link_config_test.dart`
Expected: `All tests passed!`

- [ ] **Step 5: 커밋**

```bash
git add lib/core/constants/deep_link_config.dart test/core/constants/deep_link_config_test.dart
git commit -m "feat: DeepLinkConfig 상수 클래스 추가 (도메인 플레이스홀더) #216"
```

---

## Task 3: DeepLinkHandler 구현

**Files:**
- Create: `lib/core/deep_link/deep_link_handler.dart`
- Test: `test/core/deep_link/deep_link_handler_test.dart`

- [ ] **Step 1: 테스트 작성**

`test/core/deep_link/deep_link_handler_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/core/constants/deep_link_config.dart';
import 'package:cops_and_robbers/core/deep_link/deep_link_handler.dart';

void main() {
  group('DeepLinkHandler', () {
    group('parseDeepLink', () {
      test('유효한 방 초대 URI에서 DeepLinkResult.roomInvite를 반환한다', () {
        final uri = Uri.parse('https://example.com/room?code=ABC123');

        final result = DeepLinkHandler.parseDeepLink(uri);

        expect(result, isA<RoomInviteResult>());
        expect((result as RoomInviteResult).inviteCode, 'ABC123');
      });

      test('호스트가 다르면 null을 반환한다', () {
        final uri = Uri.parse('https://other.com/room?code=ABC123');

        final result = DeepLinkHandler.parseDeepLink(uri);

        expect(result, isNull);
      });

      test('경로가 /room이 아니면 null을 반환한다', () {
        final uri = Uri.parse('https://example.com/friend?code=ABC123');

        final result = DeepLinkHandler.parseDeepLink(uri);

        expect(result, isNull);
      });

      test('code 파라미터가 없으면 null을 반환한다', () {
        final uri = Uri.parse('https://example.com/room');

        final result = DeepLinkHandler.parseDeepLink(uri);

        expect(result, isNull);
      });

      test('code가 빈 문자열이면 null을 반환한다', () {
        final uri = Uri.parse('https://example.com/room?code=');

        final result = DeepLinkHandler.parseDeepLink(uri);

        expect(result, isNull);
      });
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/core/deep_link/deep_link_handler_test.dart`
Expected: FAIL — 파일이 없으므로 컴파일 에러

- [ ] **Step 3: DeepLinkHandler 구현**

`lib/core/deep_link/deep_link_handler.dart`:

```dart
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import '../constants/deep_link_config.dart';

/// 딥링크 파싱 결과 sealed class
sealed class DeepLinkResult {}

/// 방 초대 딥링크 결과
class RoomInviteResult extends DeepLinkResult {
  RoomInviteResult({required this.inviteCode});

  final String inviteCode;
}

/// 딥링크 수신 및 파싱을 담당하는 핸들러
///
/// [init]을 호출하면 Cold Start 링크 확인 + 실행 중 링크 스트림을 구독한다.
/// 수신된 URI는 [parseDeepLink]로 파싱하여 [onDeepLink] 콜백으로 전달한다.
class DeepLinkHandler {
  DeepLinkHandler({required this.onDeepLink});

  final void Function(DeepLinkResult result) onDeepLink;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  /// 딥링크 수신 시작 (Cold Start + 실행 중)
  Future<void> init() async {
    // Cold Start: 앱이 종료 상태에서 딥링크로 열린 경우
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('[DeepLink] 🔗 Cold Start URI: $initialUri');
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('[DeepLink] ❌ Cold Start 링크 확인 실패: $e');
    }

    // 실행 중: 앱이 이미 떠있는 상태에서 딥링크 수신
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[DeepLink] 🔗 실행 중 URI 수신: $uri');
        _handleUri(uri);
      },
      onError: (error) {
        debugPrint('[DeepLink] ❌ URI 스트림 에러: $error');
      },
    );
  }

  /// URI를 파싱하고 유효하면 콜백 호출
  void _handleUri(Uri uri) {
    final result = parseDeepLink(uri);
    if (result != null) {
      onDeepLink(result);
    }
  }

  /// URI를 파싱하여 딥링크 결과 반환 (유효하지 않으면 null)
  ///
  /// 순수 함수로 테스트 용이성을 위해 static 메서드로 분리.
  static DeepLinkResult? parseDeepLink(Uri uri) {
    // 호스트 검증
    if (!DeepLinkConfig.isDeepLink(uri)) return null;

    // 방 초대 경로 확인
    if (!DeepLinkConfig.isRoomInvite(uri)) return null;

    // 초대코드 추출
    final code = DeepLinkConfig.extractRoomCode(uri);
    if (code == null || code.isEmpty) return null;

    return RoomInviteResult(inviteCode: code);
  }

  /// 리소스 해제
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/core/deep_link/deep_link_handler_test.dart`
Expected: `All tests passed!`

- [ ] **Step 5: 커밋**

```bash
git add lib/core/deep_link/deep_link_handler.dart test/core/deep_link/deep_link_handler_test.dart
git commit -m "feat: DeepLinkHandler 구현 (URI 수신/파싱/콜백) #216"
```

---

## Task 4: main.dart에 DeepLinkHandler 연결

**Files:**
- Modify: `lib/main.dart:161-163` (runApp 직전)
- Modify: `lib/main.dart:166-201` (MyApp 클래스)

- [ ] **Step 1: main.dart에 DeepLinkHandler 초기화 및 MyApp 연결**

`lib/main.dart` 상단에 import 추가:

```dart
import 'package:cops_and_robbers/core/deep_link/deep_link_handler.dart';
```

`runApp` 호출 부분(161-163행)을 다음으로 교체:

```dart
  // ============================================================
  // 6. 딥링크 핸들러 생성 (ProviderScope 생성 전에 인스턴스화)
  // ============================================================
  // 실제 딥링크 처리는 MyApp에서 ref 획득 후 init() 호출
  runApp(
    ProviderScope(child: MyApp(isFirebaseInitialized: isFirebaseInitialized)),
  );
```

`MyApp` 클래스를 다음으로 교체:

```dart
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, this.isFirebaseInitialized = true});

  final bool isFirebaseInitialized;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  DeepLinkHandler? _deepLinkHandler;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  /// 딥링크 핸들러 초기화
  ///
  /// 방 초대 딥링크 수신 시 기존 joinGameProvider로 방 참가 후 대기실로 이동.
  /// 인증되지 않은 상태에서는 무시 (go_router redirect가 로그인으로 보냄).
  void _initDeepLinks() {
    _deepLinkHandler = DeepLinkHandler(
      onDeepLink: (result) {
        switch (result) {
          case RoomInviteResult(:final inviteCode):
            debugPrint('[DeepLink] 🎯 방 초대코드 수신: $inviteCode');
            _handleRoomInvite(inviteCode);
        }
      },
    );
    _deepLinkHandler!.init();
  }

  /// 방 초대 딥링크 처리
  ///
  /// 인증 상태 확인 후 방 참가 API 호출 → 대기실로 이동.
  Future<void> _handleRoomInvite(String inviteCode) async {
    final authState = ref.read(authNotifierProvider);

    // 로그인 안 된 상태면 무시 (로그인 화면 유지)
    if (authState.isLoading || authState.value == null) {
      debugPrint('[DeepLink] ⚠️ 미인증 상태 — 딥링크 무시');
      return;
    }

    final router = ref.read(routerProvider);

    try {
      final response = await ref.read(
        joinGameProvider(inviteCode: inviteCode).future,
      );

      if (response != null) {
        debugPrint(
          '[DeepLink] ✅ 방 참가 성공: gameId=${response.gameId}',
        );
        router.go(
          '${RoutePaths.waitingRoomWithId('${response.gameId}')}'
          '?inviteCode=$inviteCode',
        );
      }
    } catch (e) {
      debugPrint('[DeepLink] ❌ 방 참가 실패: $e');
      // 에러 시 별도 UI 처리 없음 (로그만 기록)
      // 추후 스낵바 등 사용자 피드백 추가 가능
    }
  }

  @override
  void dispose() {
    _deepLinkHandler?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: '경찰과도둑',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routerConfig: router,
        );
      },
    );
  }
}
```

필요한 추가 import:

```dart
import 'package:cops_and_robbers/core/deep_link/deep_link_handler.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
```

- [ ] **Step 2: 빌드 확인**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/main.dart
git commit -m "feat: main.dart에 DeepLinkHandler 초기화 연결 #216"
```

---

## Task 5: 공유 기능에 딥링크 URL 준비

**Files:**
- Modify: `lib/features/session/presentation/pages/waiting_room_page.dart:16` (import)
- Modify: `lib/features/session/presentation/pages/waiting_room_page.dart:790-792` (onConfirm)

기존 초대코드 공유는 유지하고, 도메인 확정 후 전환할 수 있도록 딥링크 URL 공유 코드를 주석으로 준비한다.

- [ ] **Step 1: waiting_room_page.dart에 import 추가**

`lib/features/session/presentation/pages/waiting_room_page.dart` 상단 import 영역에 추가:

```dart
import '../../../../core/constants/deep_link_config.dart';
```

- [ ] **Step 2: onConfirm 공유 부분에 딥링크 URL 준비**

`waiting_room_page.dart` 790-792행의 `onConfirm` 부분을 다음으로 교체:

```dart
      onConfirm: () {
        // TODO: 딥링크 도메인 확정 후 아래 주석 해제하고 기존 코드 삭제
        // shareText(
        //   DeepLinkConfig.roomInviteUrl(code),
        //   subject: '경찰과도둑 초대',
        // );
        shareText(code);
      },
```

- [ ] **Step 3: 빌드 확인**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: 커밋**

```bash
git add lib/features/session/presentation/pages/waiting_room_page.dart
git commit -m "chore: 공유 기능에 딥링크 URL 코드 주석 준비 (도메인 확정 후 활성화) #216"
```

---

## Task 6: 전체 테스트 및 빌드 검증

**Files:** (변경 없음, 검증만)

- [ ] **Step 1: 전체 테스트 실행**

Run: `flutter test`
Expected: 모든 테스트 통과

- [ ] **Step 2: 정적 분석**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: 도메인 변경 체크리스트 확인**

아래 3곳에 플레이스홀더 `example.com`이 있는지 확인:
1. `lib/core/constants/deep_link_config.dart` — `host` 상수
2. `android/app/src/main/AndroidManifest.xml` — `android:host` 속성
3. `ios/Runner/Runner.entitlements` — `applinks:` 뒤의 도메인

---

## 도메인 확정 후 활성화 가이드

도메인이 확정되면 다음 3+1곳을 변경:

1. **`lib/core/constants/deep_link_config.dart`** — `host = '확정도메인'`
2. **`android/app/src/main/AndroidManifest.xml`** — `android:host="확정도메인"`
3. **`ios/Runner/Runner.entitlements`** — `applinks:확정도메인`
4. **`waiting_room_page.dart`** — TODO 주석 해제 + 기존 `shareText(code)` 삭제

추가로 Apple Developer Portal에서:
- Identifiers → App ID → Associated Domains 체크박스 활성화
- Provisioning Profile 재생성
