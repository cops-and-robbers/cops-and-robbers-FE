### 📌 작업 개요
Android 실기기 및 Play Store 배포 앱에서 Google 로그인 실패 문제 수정.
원인은 두 가지: (1) Android 9+에서 cleartext HTTP 차단, (2) CI/CD 워크플로우의 환경변수 시크릿 이름 불일치로 `.env` 파일이 빈 파일로 생성되어 API URL이 `localhost`로 fallback.

**보고서 파일**: `.report/20260214_#79_Android_실기기_Google_로그인_실패_수정.md`

---

### 🔍 문제 분석

#### 증상
- iOS 실기기: Google 로그인 정상
- Android 에뮬레이터(Debug): Google 로그인 정상
- Android 실기기(Release): Google 로그인 실패
- Play Store 내부 테스트 배포: Google 로그인 실패

#### 원인 1: Android cleartext HTTP 차단
Android 9+(API 28+)부터 cleartext HTTP 트래픽이 기본 차단됨.
백엔드가 HTTP를 사용하므로, Google 로그인(HTTPS) 자체는 성공하나 이후 백엔드 JWT 교환(`POST /api/auth/login`)이 HTTP 차단으로 실패.

#### 원인 2: CI/CD 환경변수 시크릿 이름 불일치 (핵심 원인)
GitHub Secrets에 환경변수가 `ENV` 이름으로 저장되어 있으나, Android Play Store CI/CD 워크플로우에서 `secrets.ENV_FILE`만 참조.
`ENV_FILE` 시크릿이 존재하지 않아 `.env` 파일이 빈 파일로 생성됨.

```dart
// env_config.dart - fallback으로 localhost 사용
static String get apiBaseUrl {
  return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
}
```

빈 `.env` → `API_BASE_URL` 미로드 → `localhost:8080` fallback → 실기기에서 접속 불가 → 로그인 실패.

iOS TestFlight 워크플로우는 `secrets.ENV_FILE || secrets.ENV` fallback이 적용되어 있어 정상 동작.

---

### ✅ 구현 내용

#### 1. AndroidManifest.xml - cleartext HTTP 허용
- **파일**: `android/app/src/main/AndroidManifest.xml`
- **변경 내용**: `<application>` 태그에 `android:usesCleartextTraffic="true"` 속성 추가
- **이유**: 백엔드가 HTTP를 사용하므로 Android 9+에서 cleartext 트래픽을 허용해야 함

#### 2. Android Play Store CI/CD - ENV fallback 추가
- **파일**: `.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`
- **변경 내용**: `.env` 파일 생성 시 `secrets.ENV_FILE`만 참조하던 것을 `secrets.ENV_FILE || secrets.ENV`로 변경 (2곳)
- **이유**: GitHub Secrets에 `ENV` 이름으로 저장된 환경변수를 CI/CD에서 정상 로드하도록 fallback 추가

#### 3. Flutter CI - ENV fallback 통일
- **파일**: `.github/workflows/PROJECT-FLUTTER-CI.yaml`
- **변경 내용**: `secrets.ENV`만 참조하던 것을 `secrets.ENV_FILE || secrets.ENV`로 통일
- **이유**: 모든 워크플로우에서 동일한 fallback 패턴 적용하여 시크릿 이름 관계없이 동작하도록 통일

---

### 🔧 주요 변경사항 상세

#### 시도 과정 (커밋 히스토리)

| 순서 | 커밋 | 시도 내용 | 결과 |
|------|------|----------|------|
| 1 | `2c1ed38` | `.env` 기반 `network_security_config.xml` 동적 생성 | 실패 (빌드 시 XML 생성 복잡) |
| 2 | `28599de` | 정적 `network_security_config.xml` 파일 추가 | 실패 (근본 원인이 아님) |
| 3 | `85eaa13` | `usesCleartextTraffic="true"` 단순 적용 | 부분 해결 (HTTP 차단 해제) |
| 4 | `b931b04` | CI/CD `ENV_FILE || ENV` fallback 추가 | **근본 원인 해결** |

#### AndroidManifest.xml
```xml
<application
    android:label="경찰과도둑"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:usesCleartextTraffic="true">
```
모든 도메인에 대해 HTTP 허용. 향후 백엔드 HTTPS 전환 시 제거 예정.

#### CI/CD 워크플로우 통일
모든 워크플로우의 `.env` 생성 패턴을 동일하게 통일:

| 워크플로우 | 수정 전 | 수정 후 |
|-----------|--------|--------|
| **PLAYSTORE-CICD** (2곳) | `secrets.ENV_FILE` | `secrets.ENV_FILE \|\| secrets.ENV` |
| **FLUTTER-CI** (1곳) | `secrets.ENV` | `secrets.ENV_FILE \|\| secrets.ENV` |
| ANDROID-TEST-APK | 이미 정상 | 변경 없음 |
| IOS-TESTFLIGHT | 이미 정상 | 변경 없음 |
| IOS-TEST-TESTFLIGHT | 이미 정상 | 변경 없음 |

---

### 🧪 테스트 및 검증
- Android 실기기에서 `flutter build apk --release` 설치 후 Google 로그인 정상 동작 확인
- CI/CD 배포 후 Play Store 내부 테스트에서 로그인 동작 검증 필요
- iOS TestFlight 배포 앱에서 기존 동작 영향 없음 확인

---

### 📌 참고사항
- `usesCleartextTraffic="true"`는 모든 도메인에 HTTP를 허용하므로, 백엔드 HTTPS 전환 시 해당 속성을 제거하거나 `network_security_config.xml`로 특정 도메인만 허용하도록 변경 권장
- GitHub Secrets 이름을 `ENV_FILE`로 통일하면 fallback 없이도 모든 워크플로우가 동작하나, 현재 `ENV_FILE || ENV` 패턴으로 양쪽 모두 지원
- `build.gradle.kts`에서 기존에 추가했던 `.env` 기반 동적 XML 생성 코드는 제거 완료
