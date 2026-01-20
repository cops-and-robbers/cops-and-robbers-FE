# Google Maps API Key 설정 가이드

> **작성일**: 2026-01-16
> **대상 독자**: 개발자, 신규 팀원
> **문서 버전**: 1.0.0

이 문서는 Google Maps SDK 사용을 위한 API Key 설정 방법을 설명합니다.

---

## 1. API Key 발급

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속
2. 프로젝트 선택 또는 새 프로젝트 생성
3. **APIs & Services > Credentials** 메뉴로 이동
4. **CREATE CREDENTIALS > API key** 클릭
5. 생성된 API Key 복사

### 권장: API Key 제한 설정

보안을 위해 API Key에 제한을 설정하세요:

- **Android**: 앱 패키지명 + SHA-1 인증서 지문으로 제한
- **iOS**: 앱 번들 ID로 제한

---

## 2. Android 설정

### 2.1 local.properties에 키 추가

`android/local.properties` 파일에 다음 줄을 추가합니다:

```text
GOOGLE_MAPS_API_KEY=발급받은_API_KEY
```

> **참고**: `local.properties`는 `.gitignore`에 포함되어 있어 Git에 커밋되지 않습니다.

### 2.2 템플릿 파일

처음 설정하는 경우 템플릿을 참고하세요:

```bash
# 템플릿 확인
cat android/local.properties.example
```

### 키 주입 흐름

```text
local.properties (GOOGLE_MAPS_API_KEY=xxx)
       ↓
build.gradle.kts (manifestPlaceholders로 주입)
       ↓
AndroidManifest.xml (${GOOGLE_MAPS_API_KEY} → 실제 값)
       ↓
Google Maps SDK 초기화
```

---

## 3. iOS 설정

### 3.1 Secrets.xcconfig 생성

`ios/Flutter/Secrets.xcconfig` 파일을 생성합니다:

```bash
# 템플릿 복사
cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig
```

### 3.2 키 입력

`ios/Flutter/Secrets.xcconfig` 파일을 열고 실제 키를 입력합니다:

```text
GOOGLE_MAPS_API_KEY=발급받은_API_KEY
```

> **참고**: `Secrets.xcconfig`는 `.gitignore`에 포함되어 있어 Git에 커밋되지 않습니다.

### 키 주입 흐름

```text
Secrets.xcconfig (GOOGLE_MAPS_API_KEY=xxx)
       ↓
Debug.xcconfig / Release.xcconfig (#include)
       ↓
Info.plist ($(GOOGLE_MAPS_API_KEY) → 실제 값)
       ↓
AppDelegate.swift (Bundle에서 읽어서 GMSServices.provideAPIKey 호출)
       ↓
Google Maps SDK 초기화
```

---

## 4. 빠른 설정 체크리스트

### Android

- [ ] `android/local.properties`에 `GOOGLE_MAPS_API_KEY` 추가

### iOS

- [ ] `ios/Flutter/Secrets.xcconfig.example`을 `Secrets.xcconfig`로 복사
- [ ] `Secrets.xcconfig`에 실제 API Key 입력

---

## 5. 트러블슈팅

### "API key not found" 오류

1. **Android**: `local.properties`에 키가 있는지 확인
2. **iOS**: `Secrets.xcconfig`에 키가 있는지 확인
3. 빌드 캐시 클리어 후 재빌드:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### iOS 디버그 콘솔에 경고 메시지

```text
⚠️ GOOGLE_MAPS_API_KEY가 비어 있습니다. Secrets.xcconfig 설정을 확인하세요.
```

→ `ios/Flutter/Secrets.xcconfig` 파일이 없거나 키가 비어있습니다.

---

## 6. CI/CD 환경

CI 환경에서는 환경변수를 통해 키를 주입합니다.

### GitHub Actions 예시

```yaml
- name: Setup Android API Keys
  run: |
    echo "GOOGLE_MAPS_API_KEY=${{ secrets.GOOGLE_MAPS_API_KEY }}" >> android/local.properties

- name: Setup iOS API Keys
  run: |
    echo "GOOGLE_MAPS_API_KEY=${{ secrets.GOOGLE_MAPS_API_KEY }}" > ios/Flutter/Secrets.xcconfig
```

---

**문서 작성**: Development Team
**최종 업데이트**: 2026-01-16