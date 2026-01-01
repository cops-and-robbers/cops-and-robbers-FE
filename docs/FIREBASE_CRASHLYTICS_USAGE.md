# Firebase Crashlytics 사용법
# Firebase Crashlytics Usage Guide

Firebase Crashlytics는 앱의 크래시 및 에러를 실시간으로 수집하고 분석하는 도구입니다.

Firebase Crashlytics is a tool that collects and analyzes app crashes and errors in real-time.

---

## 📌 목차 (Table of Contents)

1. [현재 프로젝트 설정 확인](#1-현재-프로젝트-설정-확인)
2. [에러 리포팅 방법](#2-에러-리포팅-방법)
3. [디버그 vs 프로덕션 모드](#3-디버그-vs-프로덕션-모드)
4. [Firebase Console에서 확인](#4-firebase-console에서-확인)
5. [주의사항 및 팁](#5-주의사항-및-팁)

---

## 1. 현재 프로젝트 설정 확인
## 1. Check Current Project Setup

### ✅ 이미 완료된 설정 (Already Configured)

이 프로젝트는 Firebase Crashlytics가 이미 설정되어 있습니다.

This project already has Firebase Crashlytics configured.

#### 의존성 (Dependencies)
**파일**: `pubspec.yaml`

```yaml
dependencies:
  firebase_core: ^4.1.0
  firebase_crashlytics: ^5.0.6
```

#### Android 설정 (Android Configuration)
**파일**: `android/app/build.gradle.kts`

```kotlin
plugins {
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}
```

#### 초기화 코드 (Initialization Code)
**파일**: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  bool isFirebaseInitialized = false;
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));
    isFirebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Firebase initialization failed: $e');
  }

  // Crashlytics 설정
  if (isFirebaseInitialized) {
    try {
      if (kDebugMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      }

      FlutterError.onError = (errorDetails) {
        if (kDebugMode) {
          debugPrint('🔥 Flutter Error: ${errorDetails.exception}');
        } else {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        }
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        if (kDebugMode) {
          debugPrint('🔥 Async Error: $error');
        } else {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        return true;
      };

      debugPrint('✅ Crashlytics configured successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Crashlytics setup failed: $e');
    }
  }

  runApp(MyApp(isFirebaseInitialized: isFirebaseInitialized));
}
```

---

## 2. 에러 리포팅 방법
## 2. How to Report Errors

### 2.1 자동 리포팅 (Automatic Reporting)

앱이 크래시되면 자동으로 Firebase에 리포트됩니다. (프로덕션 모드에서만)

App crashes are automatically reported to Firebase (only in production mode).

**자동으로 캡처되는 에러**:
- Flutter 위젯 빌드 에러 (`FlutterError.onError`)
- 비동기 에러 (`PlatformDispatcher.instance.onError`)
- 처리되지 않은 예외 (Unhandled exceptions)

### 2.2 수동 리포팅 (Manual Reporting)

try-catch 블록에서 에러를 명시적으로 리포트할 수 있습니다.

You can explicitly report errors from try-catch blocks.

#### 기본 에러 리포팅 (Basic Error Reporting)

```dart
try {
  // 위험한 작업
  await riskyOperation();
} catch (e, stackTrace) {
  // 프로덕션 모드에서만 전송
  if (!kDebugMode) {
    await FirebaseCrashlytics.instance.recordError(
      e,
      stackTrace,
      fatal: false, // 앱이 종료되지 않는 에러
    );
  }

  // 개발 중에는 콘솔에 출력
  if (kDebugMode) {
    debugPrint('에러 발생: $e');
    debugPrint('스택 트레이스: $stackTrace');
  }
}
```

#### 추가 정보와 함께 리포팅 (Report with Additional Info)

```dart
try {
  await someOperation();
} catch (e, stackTrace) {
  if (!kDebugMode) {
    await FirebaseCrashlytics.instance.recordError(
      e,
      stackTrace,
      reason: '세션 생성 중 에러 발생', // 에러 발생 이유
      fatal: false,
    );
  }
}
```

#### 치명적인 에러 리포팅 (Fatal Error Reporting)

```dart
try {
  await criticalOperation();
} catch (e, stackTrace) {
  if (!kDebugMode) {
    await FirebaseCrashlytics.instance.recordError(
      e,
      stackTrace,
      fatal: true, // 치명적인 에러로 표시
    );
  }
  rethrow; // 에러를 다시 던져서 앱 종료
}
```

### 2.3 커스텀 로그 추가 (Custom Logs)

에러 발생 전 컨텍스트를 로그로 남길 수 있습니다.

You can add context logs before errors occur.

```dart
Future<void> createSession(String userId) async {
  // 커스텀 로그 추가 (디버그 흔적)
  if (!kDebugMode) {
    FirebaseCrashlytics.instance.log('세션 생성 시작: userId=$userId');
  }

  try {
    await sessionApi.create(userId);

    if (!kDebugMode) {
      FirebaseCrashlytics.instance.log('세션 생성 성공');
    }
  } catch (e, stackTrace) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.log('세션 생성 실패');
      await FirebaseCrashlytics.instance.recordError(e, stackTrace);
    }
  }
}
```

### 2.4 사용자 정보 설정 (Set User Information)

에러 발생 시 사용자를 식별할 수 있습니다.

You can identify users when errors occur.

```dart
// 로그인 후 사용자 ID 설정
if (!kDebugMode) {
  await FirebaseCrashlytics.instance.setUserIdentifier(userId);
}

// 커스텀 키-값 추가
if (!kDebugMode) {
  await FirebaseCrashlytics.instance.setCustomKey('user_role', 'admin');
  await FirebaseCrashlytics.instance.setCustomKey('session_id', sessionId);
}
```

---

## 3. 디버그 vs 프로덕션 모드
## 3. Debug vs Production Mode

### 3.1 디버그 모드 (Debug Mode)

**설정**: Crashlytics 비활성화 (`setCrashlyticsCollectionEnabled(false)`)

**동작**:
- ✅ 에러가 콘솔에 `debugPrint`로 출력됨
- ❌ Firebase Console에 전송되지 않음
- 목적: 개발 중 Firebase 할당량 절약, 불필요한 노이즈 제거

**실행 방법**:
```bash
# VSCode에서 "Debug" 구성 선택
flutter run

# 또는 명령어
flutter run --debug
```

### 3.2 프로파일 모드 (Profile Mode)

**설정**: Crashlytics 활성화 (기본값)

**동작**:
- ✅ 에러가 Firebase Console에 전송됨
- ✅ 성능 프로파일링 가능
- 목적: 프로덕션과 유사한 환경에서 성능 테스트

**실행 방법**:
```bash
# VSCode에서 "Profile" 구성 선택
flutter run --profile
```

### 3.3 릴리스 모드 (Release Mode)

**설정**: Crashlytics 활성화 (기본값)

**동작**:
- ✅ 에러가 Firebase Console에 전송됨
- ✅ 최적화된 빌드 (프로덕션 배포용)
- 목적: 실제 사용자 환경에서 에러 모니터링

**실행 방법**:
```bash
# VSCode에서 "Release (실제 기기만)" 구성 선택
# 또는 명령어
flutter run --release

# APK/IPA 빌드
flutter build apk --release
flutter build ios --release
```

### 3.4 모드별 비교표 (Mode Comparison)

| 항목 | Debug | Profile | Release |
|------|-------|---------|---------|
| Crashlytics 전송 | ❌ 비활성화 | ✅ 활성화 | ✅ 활성화 |
| 콘솔 로그 | ✅ 출력됨 | ❌ 출력 안 됨 | ❌ 출력 안 됨 |
| 성능 | 느림 | 빠름 | 가장 빠름 |
| 용도 | 개발 | 성능 테스트 | 프로덕션 배포 |
| 시뮬레이터 지원 | ✅ | ✅ | ❌ (iOS) |

---

## 4. Firebase Console에서 확인
## 4. Check in Firebase Console

### 4.1 Firebase Console 접속

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. 프로젝트 선택: **copsandrobbers-c2281**
3. 왼쪽 메뉴에서 **Crashlytics** 클릭

### 4.2 크래시 리포트 확인

**대시보드 섹션**:
- **Crash-free users**: 크래시 없이 앱을 사용한 사용자 비율
- **Crashes**: 총 크래시 발생 횟수
- **Issues**: 고유한 크래시 이슈 목록

**이슈 상세 정보**:
- Stack trace (스택 트레이스)
- Device information (기기 정보)
- OS version (운영체제 버전)
- App version (앱 버전)
- Custom logs (커스텀 로그)
- User identifier (사용자 식별자)

### 4.3 로그가 나타나는 시점

**중요**: Firebase Console에 로그가 나타나기까지 시간이 걸립니다.

**일반적인 타임라인**:
1. **에러 발생**: 앱에서 에러가 발생하고 Crashlytics가 기록
2. **로컬 저장**: 에러 정보가 기기에 임시 저장됨
3. **앱 재시작**: 다음번 앱 실행 시 Firebase에 전송
4. **Firebase 처리**: 5-10분 후 Console에 표시

**빠르게 확인하는 방법**:
1. 에러 발생 후 앱 종료
2. 앱 다시 실행 (에러 전송)
3. 5-10분 대기
4. Firebase Console 새로고침

---

## 5. 주의사항 및 팁
## 5. Notes and Tips

### 5.1 주의사항 (Important Notes)

#### ⚠️ 개인정보 보호
```dart
// ❌ 나쁜 예: 민감한 정보 포함
FirebaseCrashlytics.instance.log('비밀번호: $password');
FirebaseCrashlytics.instance.setUserIdentifier(userEmail);

// ✅ 좋은 예: 익명화된 정보
FirebaseCrashlytics.instance.log('로그인 시도');
FirebaseCrashlytics.instance.setUserIdentifier(hashedUserId);
```

#### ⚠️ 디버그 모드에서 테스트 불가
디버그 모드에서는 Crashlytics가 비활성화되어 있습니다.

Firebase Console에서 확인하려면 **Profile 또는 Release 모드**로 실행하세요.

```bash
flutter run --profile  # Profile 모드로 실행
```

#### ⚠️ 앱 재시작 필요
에러가 발생한 직후에는 Firebase Console에 나타나지 않습니다.

앱을 종료하고 다시 실행해야 에러가 전송됩니다.

### 5.2 베스트 프랙티스 (Best Practices)

#### ✅ Repository 레이어에서 에러 리포팅

```dart
class SessionRepository {
  Future<SessionEntity> createSession(CreateSessionRequest request) async {
    try {
      final session = await _api.createSession(request);
      return SessionEntity.fromModel(session);
    } on DioException catch (e) {
      // 에러 컨텍스트 로깅
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.log('API 호출 실패: POST /sessions');
        FirebaseCrashlytics.instance.setCustomKey('request', request.toJson().toString());
        await FirebaseCrashlytics.instance.recordError(e, e.stackTrace);
      }

      if (e.response?.statusCode == 400) {
        throw ValidationException('잘못된 요청입니다');
      }
      throw NetworkException('네트워크 연결을 확인하세요');
    }
  }
}
```

#### ✅ fatal 플래그 적절히 사용

```dart
// 앱이 계속 실행 가능한 에러
await FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);

// 앱이 종료되어야 하는 치명적 에러
await FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
```

#### ✅ 의미 있는 로그 남기기

```dart
// ❌ 나쁜 예
FirebaseCrashlytics.instance.log('에러');

// ✅ 좋은 예
FirebaseCrashlytics.instance.log('세션 생성 API 호출 시작 - sessionId: $sessionId');
```

### 5.3 디버깅 팁 (Debugging Tips)

#### Firebase Console에 로그가 안 보일 때

1. **디버그 모드 확인**: Profile/Release 모드로 실행했는지 확인
2. **앱 재시작**: 앱을 종료하고 다시 실행
3. **시간 대기**: 5-10분 후 Firebase Console 새로고침
4. **인터넷 연결**: 기기가 인터넷에 연결되어 있는지 확인
5. **Firebase 초기화**: `main.dart`에서 Firebase가 정상 초기화되었는지 로그 확인

#### 로컬에서 에러 확인

디버그 모드에서는 콘솔에 에러가 출력됩니다:

```bash
flutter run

# 출력 예시:
# 🔥 Flutter Error: Exception: 테스트 에러
# 🔥 Async Error: Exception: 비동기 에러
```

#### 강제로 크래시 발생시키기 (테스트용)

**주의**: Profile/Release 모드에서만 실행하세요.

```dart
// 강제 크래시 (앱 종료)
throw Exception('테스트 크래시');

// 수동 에러 리포팅 (앱 계속 실행)
try {
  throw Exception('테스트 에러');
} catch (e, stackTrace) {
  if (!kDebugMode) {
    await FirebaseCrashlytics.instance.recordError(
      e,
      stackTrace,
      reason: '테스트 에러',
      fatal: false,
    );
  }
}
```

---

## 📚 참고 자료 (References)

- [Firebase Crashlytics 공식 문서](https://firebase.google.com/docs/crashlytics)
- [FlutterFire Crashlytics](https://firebase.flutter.dev/docs/crashlytics/overview)
- [프로젝트 설정 파일](../lib/main.dart) (`lib/main.dart`)

---

## 🔗 관련 문서 (Related Documents)

- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - 빠른 참조 가이드
- [03_CODE_CONVENTIONS.md](03_CODE_CONVENTIONS.md) - 코드 규칙 및 에러 처리 패턴
