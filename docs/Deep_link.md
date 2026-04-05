경찰과도둑 — 딥링크 구현 가이드

## 개요

딥링크란 **URL을 클릭하면 앱의 특정 화면으로 바로 이동**시키는 기술이다.
방 초대코드 공유, 친구 추가 코드 등에서 사용한다.

> Firebase Dynamic Links는 2025년 8월 25일에 서비스 종료됨.
> **OS 네이티브 딥링크 (Android App Links + iOS Universal Links)** 로 구현한다.

---

## 사용 시나리오

| 시나리오         | URL 패턴                             | 동작                         |
| ---------------- | ------------------------------------ | ---------------------------- |
| 방 초대코드 공유 | `https://도메인/room?code=ABC123`    | 해당 방 입장 화면으로 이동   |
| 친구 추가 코드   | `https://도메인/friend?code=USER456` | 친구 추가 처리 화면으로 이동 |

---

## 전체 흐름

```
사용자가 공유 링크 클릭
       ↓
  앱 설치 여부 확인 (OS가 자동 판단)
       ↓
  ┌────────────┬──────────────┐
  │ 앱 설치됨  │ 앱 미설치    │
  ├────────────┼──────────────┤
  │ 앱 실행    │ 브라우저에서  │
  │ + URI 전달 │ 웹페이지 열림 │
  │ + 해당     │ + 스토어     │
  │   화면으로 │   안내 표시   │
  │   라우팅   │              │
  └────────────┴──────────────┘
```

---

## 구현 단계

---

### STEP 1. 도메인 결정

딥링크에 사용할 HTTPS 도메인을 정한다.
이 도메인 서버에서 OS 검증 파일을 서빙할 수 있어야 한다.

**선택지:**

| 방법                      | 예시                               | 비고                 |
| ------------------------- | ---------------------------------- | -------------------- |
| 백엔드 도메인 그대로 사용 | `api.example.com/room?code=XXX`    | 추가 비용 없음       |
| 백엔드에 서브도메인 추가  | `link.example.com/room?code=XXX`   | URL이 깔끔           |
| 별도 도메인 구매          | `copsandrobbers.app/room?code=XXX` | 가장 깔끔, 비용 발생 |

**핵심:** 어떤 도메인이든 **HTTPS**로 접근 가능하고, `/.well-known/` 경로에 파일을 서빙할 수 있으면 된다.

---

### STEP 2. 서버에 OS 검증 파일 배치 (Spring Boot)

Android와 iOS는 각각 "이 도메인 링크를 클릭하면 이 앱을 열어도 되는지" 서버의 검증 파일을 통해 확인한다.

### 2-1. Android용: `assetlinks.json`

- **경로:** `https://도메인/.well-known/assetlinks.json`
- **역할:** "이 도메인은 이 Android 앱과 연결되어 있다"는 것을 Google에 증명
- **필요한 정보:**
  - 앱 패키지명 (`com.dongsim.copsandrobbers` 등)
  - 앱 서명 SHA256 해시값

**SHA256 확인 방법:**

- 디버그 키: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android`
- 릴리즈 키: Google Play Console → 설정 → 앱 무결성 → 앱 서명 탭에서 확인

**파일 내용:**

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.dongsim.copsandrobbers",
      "sha256_cert_fingerprints": ["디버그_또는_릴리즈_SHA256"]
    }
  }
]
```

> 📎 참조: [Android App Links 검증 문서](https://developer.android.com/training/app-links/verify-android-applinks)

### 2-2. iOS용: `apple-app-site-association` (AASA)

- **경로:** `https://도메인/.well-known/apple-app-site-association`
- **역할:** "이 도메인은 이 iOS 앱과 연결되어 있다"는 것을 Apple에 증명
- **필요한 정보:**
  - Apple Team ID (Apple Developer 계정에서 확인)
  - Bundle ID (Xcode 프로젝트에서 확인)
- **주의:** 파일 확장자 없이 저장 (`.json` 붙이지 않음), `Content-Type: application/json`으로 서빙

**파일 내용:**

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appIDs": ["TEAMID.com.dongsim.copsandrobbers"],
        "paths": ["/room/*", "/friend/*"]
      }
    ]
  }
}
```

> 📎 참조: [Apple Universal Links 문서](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app)

### 2-3. Spring Boot에서 서빙

두 파일을 API 엔드포인트로 만들거나, `/src/main/resources/static/.well-known/` 경로에 정적 파일로 배치한다.

**API 방식일 경우:**

- `GET /.well-known/assetlinks.json` → JSON 응답
- `GET /.well-known/apple-app-site-association` → JSON 응답
- Content-Type은 `application/json`으로 설정
- **반드시 HTTPS**로 서빙되어야 함

**검증 방법:**

- Android: [Google Digital Asset Links 검증 도구](https://developers.google.com/digital-asset-links/tools/generator)
- iOS: `https://도메인/.well-known/apple-app-site-association` 브라우저에서 직접 접근해서 JSON 나오는지 확인

---

### STEP 3. Android 앱 설정

`android/app/src/main/AndroidManifest.xml`의 `<activity>` 태그 안에 intent-filter를 추가한다.

**추가할 내용:**

- `android:autoVerify="true"` → OS가 자동으로 assetlinks.json 검증
- `<data>` 태그에 도메인, scheme(https), 경로 패턴 지정
- `/room`, `/friend` 등 딥링크로 받을 경로 등록

**핵심 포인트:**

- `autoVerify="true"`가 있어야 "이 앱으로 열기 vs 브라우저로 열기" 선택 없이 바로 앱이 열림
- Play Store에 배포된 앱은 Play Console → 설정 → 딥링크에서 검증 상태 확인 가능

> 📎 참조: [Flutter Android App Links 설정](https://docs.flutter.dev/cookbook/navigation/set-up-app-links)

---

### STEP 4. iOS 앱 설정

두 곳을 설정해야 한다.

**4-1. Xcode에서 Associated Domains 추가**

- Xcode → Runner → Signing & Capabilities → Associated Domains 추가
- `applinks:도메인` 형식으로 입력 (예: `applinks:link.example.com`)
- `https://` 붙이지 않음

**4-2. Apple Developer 계정에서 Associated Domains 활성화**

- Apple Developer Portal → Identifiers → 해당 App ID → Associated Domains 체크

**핵심 포인트:**

- AASA 파일에 등록한 paths와 실제 딥링크 URL 경로가 일치해야 함
- iOS는 앱 설치/업데이트 시점에 AASA 파일을 캐싱함 (Apple CDN 경유)

> 📎 참조: [Flutter iOS Universal Links 설정](https://docs.flutter.dev/cookbook/navigation/set-up-universal-links)

---

### STEP 5. Flutter 앱에서 딥링크 수신 처리

`app_links` 패키지를 사용한다.

**패키지:** `app_links` ([pub.dev](https://pub.dev/packages/app_links))

**처리해야 할 상황 2가지:**

| 상황       | 설명                                | 처리 방법                          |
| ---------- | ----------------------------------- | ---------------------------------- |
| Cold Start | 앱이 꺼져있다가 링크로 열림         | `getInitialLink()`로 초기 URI 확인 |
| 앱 실행 중 | 앱이 이미 떠있는 상태에서 링크 클릭 | `uriLinkStream`으로 스트림 수신    |

**수신 후 처리 로직:**

```
URI 수신
  ↓
path 확인 ("/room" 또는 "/friend")
  ↓
query parameter에서 code 추출
  ↓
해당 화면으로 라우팅
  - /room → 방 입장 화면 (code로 API 조회 → 방 정보 표시)
  - /friend → 친구 추가 화면 (code로 API 조회 → 유저 정보 표시)
```

**라우팅:** `go_router` 패키지와 함께 사용하면 딥링크 경로를 라우트에 매핑하기 편하다.

**주의사항:**

- `app_links`를 쓸 경우, Flutter 기본 딥링크 핸들러를 비활성화해야 충돌 안 남
- AndroidManifest.xml에서 `<meta-data android:name="flutter_deeplinking_enabled" android:value="false" />` 추가
- `AppLinks()` 인스턴스는 앱 시작 초기(main 또는 App 위젯 초기화 시점)에 생성해야 Cold Start 링크를 놓치지 않음

> 📎 참조:
>
> - [app_links 패키지](https://pub.dev/packages/app_links)
> - [go_router 패키지](https://pub.dev/packages/go_router)
> - [Flutter Deep Linking 공식 문서](https://docs.flutter.dev/ui/navigation/deep-linking)

---

### STEP 6. 폴백 웹페이지 (앱 미설치 시)

앱이 없으면 OS가 브라우저로 해당 URL을 연다.
이때 스토어로 안내하는 웹페이지를 Spring Boot에서 서빙한다.

**동작 로직:**

1. `GET /room?code=ABC123` 요청 들어옴
2. User-Agent 확인 → Android인지 iOS인지 판별
3. 해당 스토어 링크로 리다이렉트 또는 안내 페이지 표시

**개발 단계에서:**

- 스토어 URL이 아직 없으므로 "앱을 설치해주세요" 안내 페이지로 대체
- 배포 후 실제 Play Store / App Store URL로 교체하면 됨

**선택적 고급 기능 (Deferred Deep Link):**

- 앱 설치 후 처음 열었을 때 원래 공유된 코드로 이동시키는 기능
- 구현하려면 code를 서버에 저장해두고, 앱 최초 실행 시 서버에서 조회하는 로직 필요
- 1차에선 없어도 되고, 필요해지면 추가하면 됨

---

### STEP 7. 공유 기능 연결 (방장/유저 → 링크 공유)

**공유 플로우:**

```
방장이 "초대 링크 공유" 버튼 클릭
       ↓
URL 생성: "https://도메인/room?code={방_초대코드}"
       ↓
Flutter의 Share API 호출 (share_plus 패키지)
       ↓
카카오톡 / 문자 / 기타 앱으로 링크 전송
```

**code 생성 주체:** 백엔드에서 방 생성 시 초대코드(랜덤 문자열)를 생성하고, 프론트는 이 코드를 URL에 붙여서 공유

> 📎 참조: [share_plus 패키지](https://pub.dev/packages/share_plus)

---

## 테스트 방법

### Android 테스트

1. **ADB 명령어로 테스트** (가장 빠름)
   - `adb shell am start -a android.intent.action.VIEW -d "https://도메인/room?code=TEST123" com.dongsim.copsandrobbers`
   - 앱이 열리면서 해당 URI가 전달되는지 확인
2. **실제 링크 클릭 테스트**
   - Google Docs에 링크를 적고 탭하여 테스트 (권장)
   - 브라우저 주소창 직접 입력은 딥링크 테스트 안 됨
3. **주의:** 디버그 모드에서는 autoVerify가 안 될 수 있음 → 기기 설정에서 수동으로 "지원되는 웹 주소" 토글 켜야 할 수 있음

### iOS 테스트

1. **시뮬레이터 명령어**
   - `xcrun simctl openurl booted "https://도메인/room?code=TEST123"`
2. **실제 기기**
   - 메모/Safari에서 링크 길게 눌러서 "앱에서 열기" 확인
3. **Apple AASA 검증**
   - `https://app-site-association.cdn-apple.com/a/v1/도메인` 접속해서 캐싱된 AASA 파일 확인

> 📎 참조: [Flutter Deep Link 테스트 가이드](https://docs.flutter.dev/cookbook/navigation/set-up-app-links#testing)

---

## 체크리스트

### 서버 (백엔드)

- [ ] 사용할 도메인 결정
- [ ] HTTPS 적용 확인
- [ ] `/.well-known/assetlinks.json` 서빙 (Android)
- [ ] `/.well-known/apple-app-site-association` 서빙 (iOS)
- [ ] 폴백 웹페이지 구현 (`/room`, `/friend` 경로)
- [ ] 방 초대코드 생성 API (방 생성 시)

### Android

- [ ] `AndroidManifest.xml`에 intent-filter 추가 (`autoVerify="true"`)
- [ ] Flutter 기본 딥링크 핸들러 비활성화
- [ ] Google Digital Asset Links 검증 통과 확인

### iOS

- [ ] Xcode Associated Domains 설정 (`applinks:도메인`)
- [ ] Apple Developer Portal에서 Associated Domains 활성화
- [ ] AASA 파일 paths와 실제 URL 경로 일치 확인

### Flutter 앱

- [ ] `app_links` 패키지 추가
- [ ] Cold Start 링크 처리 (`getInitialLink`)
- [ ] 실행 중 링크 처리 (`uriLinkStream`)
- [ ] URI 파싱 → path, code 추출 → 화면 라우팅
- [ ] 공유 기능 구현 (`share_plus`)

### 배포 후

- [ ] 폴백 페이지에 실제 스토어 URL 연결
- [ ] Play Console에서 딥링크 검증 상태 확인

---

## 참조 문서 모음

| 구분                                 | 링크                                                                                   |
| ------------------------------------ | -------------------------------------------------------------------------------------- |
| Flutter 딥링크 공식 문서             | https://docs.flutter.dev/ui/navigation/deep-linking                                    |
| Flutter Android App Links 설정       | https://docs.flutter.dev/cookbook/navigation/set-up-app-links                          |
| Flutter iOS Universal Links 설정     | https://docs.flutter.dev/cookbook/navigation/set-up-universal-links                    |
| app_links 패키지                     | https://pub.dev/packages/app_links                                                     |
| go_router 패키지                     | https://pub.dev/packages/go_router                                                     |
| share_plus 패키지                    | https://pub.dev/packages/share_plus                                                    |
| Android App Links 검증               | https://developer.android.com/training/app-links/verify-android-applinks               |
| Apple Universal Links 문서           | https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app |
| Google Digital Asset Links 검증 도구 | https://developers.google.com/digital-asset-links/tools/generator                      |
| Firebase Dynamic Links 종료 FAQ      | https://firebase.google.com/support/dynamic-links-faq                                  |
