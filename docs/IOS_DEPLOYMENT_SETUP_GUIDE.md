# 🍎 iOS TestFlight 자동배포 설정 가이드

> Flutter iOS 앱을 GitHub Actions로 TestFlight에 자동 배포하기 위한 설정 가이드

---

## 📋 필요한 GitHub Secrets 목록

| Secret Name | 설명 |
|-------------|------|
| `APPLE_CERTIFICATE_BASE64` | 배포 인증서 (.p12 → base64) |
| `APPLE_CERTIFICATE_PASSWORD` | .p12 인증서 비밀번호 |
| `APPLE_PROVISIONING_PROFILE_BASE64` | 프로비저닝 프로파일 (base64) |
| `IOS_PROVISIONING_PROFILE_NAME` | 프로비저닝 프로파일 이름 |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect Issuer ID |
| `APP_STORE_CONNECT_API_KEY_BASE64` | API Key .p8 파일 (base64) |
| `ENV` | 앱 환경변수 (선택) |
| `SECRETS_XCCONFIG` | iOS 네이티브 빌드 시크릿 (선택) |

---

## 1️⃣ Apple Distribution 인증서 생성

### Step 1: CSR (인증서 서명 요청) 파일 생성

1. **키체인 접근(Keychain Access)** 앱 실행
2. 메뉴: `키체인 접근` → `인증서 지원` → `인증 기관에서 인증서 요청...`
3. 정보 입력:
   - **사용자 이메일 주소**: Apple Developer 계정 이메일
   - **일반 이름**: 본인 이름 또는 팀 이름
   - **CA 이메일 주소**: 비워둠
   - **요청 항목**: ✅ 디스크에 저장됨, ✅ 본인이 키 쌍 정보 지정
4. `계속` 클릭 → 저장 위치 선택 → `CertificateSigningRequest.certSigningRequest` 파일 생성됨

### Step 2: Apple Developer에서 인증서 생성

1. https://developer.apple.com/account/resources/certificates 접속
2. `+` 버튼 클릭
3. **Software** 섹션에서 `Apple Distribution` 선택 → `Continue`
4. `Choose File` → 위에서 생성한 CSR 파일 업로드
5. `Continue` → `Download` 클릭
6. 다운로드된 `distribution.cer` 파일 더블클릭 → 키체인에 자동 설치됨

### Step 3: .p12 파일로 내보내기

1. **키체인 접근** 앱 실행
2. 좌측: `로그인` → 상단 카테고리: `내 인증서`
3. `Apple Distribution: [팀명]` 인증서 찾기
4. 인증서 **왼쪽 화살표 클릭** → 개인 키가 함께 표시되는지 확인
5. 인증서 **우클릭** → `"Apple Distribution: ..." 내보내기...`
6. 파일 포맷: `개인 정보 교환 (.p12)` 선택
7. 저장 위치 선택 → `저장`
8. **비밀번호 설정** (⚠️ 이 비밀번호가 `APPLE_CERTIFICATE_PASSWORD`)
9. 키체인 비밀번호 입력하여 확인

### Step 4: Base64 인코딩

터미널에서 실행:
```bash
# .p12 파일을 base64로 변환 (클립보드에 복사)
base64 -i ~/Downloads/Certificates.p12 | pbcopy

# 확인 (선택사항)
base64 -i ~/Downloads/Certificates.p12 | head -c 100
```

### GitHub Secret 등록

| Secret Name | 값 |
|-------------|-----|
| `APPLE_CERTIFICATE_BASE64` | 위에서 복사한 base64 문자열 |
| `APPLE_CERTIFICATE_PASSWORD` | .p12 내보낼 때 설정한 비밀번호 |

---

## 2️⃣ App ID 등록

> 프로비저닝 프로파일 생성 전에 App ID가 필요합니다.

1. https://developer.apple.com/account/resources/identifiers 접속
2. `+` 버튼 클릭
3. `App IDs` 선택 → `Continue`
4. `App` 선택 → `Continue`
5. 정보 입력:
   - **Description**: `Cops and Robbers` (앱 설명)
   - **Bundle ID**: `Explicit` 선택 → `com.yourcompany.copsandrobbers`
     - ⚠️ Xcode 프로젝트의 Bundle Identifier와 **정확히 일치**해야 함
6. **Capabilities**: 앱에서 사용하는 기능 체크 (Push Notifications 등)
7. `Continue` → `Register`

### Bundle ID 확인 방법

```bash
# 프로젝트에서 Bundle ID 확인
grep -A1 "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -5
```

또는 Xcode에서:
```
ios/Runner.xcworkspace 열기 → Runner 타겟 → Signing & Capabilities → Bundle Identifier
```

---

## 3️⃣ 프로비저닝 프로파일 생성

### Step 1: 프로파일 생성

1. https://developer.apple.com/account/resources/profiles 접속
2. `+` 버튼 클릭
3. **Distribution** 섹션에서 `App Store Connect` 선택 → `Continue`
4. 위에서 만든 **App ID** 선택 → `Continue`
5. 위에서 만든 **Distribution 인증서** 선택 → `Continue`
6. **프로파일 이름** 입력: `CopsAndRobbers AppStore Distribution`
   - ⚠️ 이 이름이 `IOS_PROVISIONING_PROFILE_NAME`
7. `Generate` → `Download`

### Step 2: Base64 인코딩

터미널에서 실행:
```bash
# 프로비저닝 프로파일을 base64로 변환 (클립보드에 복사)
base64 -i ~/Downloads/CopsAndRobbers_AppStore_Distribution.mobileprovision | pbcopy
```

### GitHub Secret 등록

| Secret Name | 값 |
|-------------|-----|
| `APPLE_PROVISIONING_PROFILE_BASE64` | 위에서 복사한 base64 문자열 |
| `IOS_PROVISIONING_PROFILE_NAME` | `CopsAndRobbers AppStore Distribution` (프로파일 생성 시 입력한 이름) |

---

## 4️⃣ App Store Connect API Key 생성

### Step 1: API Key 생성

1. https://appstoreconnect.apple.com/access/integrations/api 접속
2. `App Store Connect API` 탭 선택
3. 상단의 **Issuer ID** 복사해두기 (모든 키가 공유하는 값)
4. `키 생성` 또는 `+` 버튼 클릭
5. 정보 입력:
   - **이름**: `GitHub Actions Deploy Key`
   - **액세스**: `Admin` 또는 `App Manager` (TestFlight 업로드 권한 필요)
6. `생성` 클릭
7. 생성된 키 정보 확인:
   - **키 ID**: 10자리 영숫자 (예: `ABC123DEF4`)
8. `API 키 다운로드` 클릭 → `AuthKey_ABC123DEF4.p8` 파일 저장
   - ⚠️ **한 번만 다운로드 가능!** 안전한 곳에 백업하세요.

### Step 2: Base64 인코딩

터미널에서 실행:
```bash
# API Key를 base64로 변환 (클립보드에 복사)
base64 -i ~/Downloads/AuthKey_ABC123DEF4.p8 | pbcopy
```

### GitHub Secret 등록

| Secret Name | 값 | 예시 |
|-------------|-----|------|
| `APP_STORE_CONNECT_API_KEY_ID` | 키 ID (10자리) | `ABC123DEF4` |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID (UUID) | `12345678-1234-1234-1234-123456789012` |
| `APP_STORE_CONNECT_API_KEY_BASE64` | .p8 파일 base64 | (긴 문자열) |

---

## 5️⃣ ExportOptions.plist 생성

> 워크플로우의 마법사를 사용하거나 수동으로 생성

### 방법 1: 웹 마법사 사용 (권장)

브라우저에서 열기:
```
.github/util/flutter/testflight-wizard/testflight-wizard.html
```

### 방법 2: 수동 생성

`ios/ExportOptions.plist` 파일 생성:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>destination</key>
    <string>upload</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.yourcompany.copsandrobbers</key>
        <string>CopsAndRobbers AppStore Distribution</string>
    </dict>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
</dict>
</plist>
```

### Team ID 확인 방법

https://developer.apple.com/account → 우측 상단 → `Membership details` → Team ID

---

## 6️⃣ Fastfile 생성

`ios/fastlane/Fastfile` 파일 생성:

```ruby
default_platform(:ios)

platform :ios do
  desc "Upload to TestFlight"
  lane :upload_testflight do
    api_key = app_store_connect_api_key(
      key_id: ENV["APP_STORE_CONNECT_API_KEY_ID"],
      issuer_id: ENV["APP_STORE_CONNECT_ISSUER_ID"],
      key_filepath: ENV["API_KEY_PATH"],
      duration: 1200,
      in_house: false
    )

    upload_to_testflight(
      api_key: api_key,
      ipa: ENV["IPA_PATH"],
      skip_waiting_for_build_processing: ENV["SKIP_WAITING_FOR_BUILD_PROCESSING"] == "true",
      changelog: ENV["RELEASE_NOTES"] || "New build"
    )
  end
end
```

---

## 7️⃣ 선택적 Secrets

### ENV (앱 환경변수)

앱에서 `.env` 파일을 사용하는 경우:
```
API_URL=https://api.example.com
DEBUG_MODE=false
```

### SECRETS_XCCONFIG (iOS 네이티브 시크릿)

iOS 네이티브 코드에서 API 키가 필요한 경우:
```
GOOGLE_MAPS_API_KEY=AIzaSy...
FIREBASE_API_KEY=...
```

---

## 📍 GitHub Secrets 등록 위치

```
GitHub 저장소 → Settings → Secrets and variables → Actions → New repository secret
```

---

## ✅ 최종 체크리스트

| # | 항목 | Secret Name | 완료 |
|---|------|-------------|------|
| 1 | Distribution 인증서 생성 | `APPLE_CERTIFICATE_BASE64` | ⬜ |
| 2 | 인증서 비밀번호 | `APPLE_CERTIFICATE_PASSWORD` | ⬜ |
| 3 | App ID 등록 | - | ⬜ |
| 4 | 프로비저닝 프로파일 생성 | `APPLE_PROVISIONING_PROFILE_BASE64` | ⬜ |
| 5 | 프로파일 이름 | `IOS_PROVISIONING_PROFILE_NAME` | ⬜ |
| 6 | App Store Connect API Key 생성 | `APP_STORE_CONNECT_API_KEY_ID` | ⬜ |
| 7 | Issuer ID 확인 | `APP_STORE_CONNECT_ISSUER_ID` | ⬜ |
| 8 | API Key 다운로드 | `APP_STORE_CONNECT_API_KEY_BASE64` | ⬜ |
| 9 | ExportOptions.plist 생성 | - | ⬜ |
| 10 | Fastfile 생성 | - | ⬜ |
| 11 | ENV 설정 (선택) | `ENV` | ⬜ |
| 12 | SECRETS_XCCONFIG (선택) | `SECRETS_XCCONFIG` | ⬜ |

---

## 🚨 주의사항

1. **인증서 유효기간**: Distribution 인증서는 1년 유효. 만료 전 갱신 필요
2. **프로비저닝 프로파일 유효기간**: 1년 유효. 인증서 갱신 시 프로파일도 재생성 필요
3. **API Key 보안**: .p8 파일은 한 번만 다운로드 가능. 안전하게 백업
4. **Bundle ID 일치**: App ID, 프로비저닝 프로파일, Xcode 프로젝트의 Bundle ID가 모두 일치해야 함

---

## 🔗 참고 링크

- [Apple Developer Portal](https://developer.apple.com/account)
- [App Store Connect](https://appstoreconnect.apple.com)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Fastlane Documentation](https://docs.fastlane.tools)
