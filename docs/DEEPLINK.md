경찰과도둑 — 딥링크 구현 가이드

## 개요

딥링크란 **URL을 클릭하면 앱의 특정 화면으로 바로 이동**시키는 기술이다.
1차 적용 시나리오는 **방 초대코드 공유**다.

> Firebase Dynamic Links는 2025년 8월 25일에 서비스 종료됨.
> **OS 네이티브 딥링크 (Android App Links + iOS Universal Links)** 로 구현한다.

---

## 사용 시나리오 (1차 범위)

| 시나리오         | URL 패턴                                      | 동작                              |
| ---------------- | --------------------------------------------- | --------------------------------- |
| 방 초대코드 공유 | `https://copsandrobbers.app/join/{inviteCode}` | 해당 방 입장 흐름으로 진입         |
| 모집글 공유      | `https://copsandrobbers.app/g/{id}` (일본어 `/ja/g/{id}`·영어 `/en/g/{id}`) | 해당 모집글 상세로 이동 |
| 모집글 폴백 스킴 | `copsandrobbers://open/community/{id}`        | 웹 상세의 "앱에서 열기"용          |

URL은 **path 방식**으로 통일한다 (`/join/ABC123`). 쿼리 스트링 방식(`?code=`)은 AASA `components` / Android `pathPrefix` 매칭이 까다로워 채택하지 않는다.

> 친구 추가, 결과 공유 등 다른 시나리오는 같은 구조로 확장 가능하지만 1차 범위에서 제외한다.

### 언어 추가 시 체크리스트

모집글 경로는 언어별 경로(`/ja/g` 등)를 명시적으로 나열한다. 지원 언어가 늘면 세 곳을 함께 넓혀야 한다:

1. 웹 `apple-app-site-association` 의 `components` — iOS 가 앱으로 보낼 경로
2. `AndroidManifest.xml` 의 `pathPrefix`
3. `DeeplinkEvent.fromUri` 의 경로 파싱

하나라도 빠지면 그 언어 경로만 앱으로 이어지지 않거나, iOS 가 링크를 앱으로 넘겼는데
앱이 해석하지 못해 홈만 여는 상태가 된다. 특히 AASA 에 경로가 먼저 열려 있으면
파싱 없는 앱 릴리스가 그 경로의 링크를 삼키므로, 경로 파싱과 도메인 선언은 같은
릴리스로 나가야 한다.

### 딥링크 경로는 라우터에 실제 라우트로 존재해야 한다

엔진은 warm 인텐트(앱 실행 중 링크 클릭)의 원시 URI 경로를 GoRouter 로 전달한다.
`AndroidManifest.xml` 의 `flutter_deeplinking_enabled=false` 는 이 전달을 막지
못하는 것을 실기기에서 확인했다. 그래서:

- 새 딥링크 경로를 추가하면 **GoRouter 에 같은 경로의 라우트(또는 별칭 redirect)를
  반드시 함께 추가**한다. 없으면 404 화면이 목적지 위를 덮는다 (`/join`, `/g` 별칭 참조)
- 커스텀 스킴은 `copsandrobbers://open/{라우터 경로}` 규약을 쓴다. host 뒤에 라우터
  경로를 그대로 실어야 엔진이 전달한 경로가 실제 라우트에 안착한다. host 에 의미를
  두면(예: `copsandrobbers://community/{id}`) 엔진 전달 경로가 `/{id}` 로 잘려 404 가 된다
- 기존 `copsandrobbers://join/{code}` 는 이 규약 이전의 형태라 warm 에서 404 가 join
  화면을 덮는 문제가 있다. 웹 브릿지가 이미 쓰고 있어 스킴 교체는 별도 작업이다

---

## 전체 흐름

```text
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

### STEP 1. 도메인

**확정값:** `copsandrobbers.app`

- HTTPS 인증서 적용 확인 필수
- `.app` 은 HSTS 프리로드 목록에 포함된 TLD 라 **HTTP 접속 자체가 차단**된다. 인증서가 없으면 도메인이 열리지 않아 검증 파일 확인도 불가능하다
- 운영 도메인은 Next.js + Vercel 사이트에서 관리한다
- 이 도메인에서 `/.well-known/` 검증 파일과 `/join/{inviteCode}` 폴백 페이지를 서빙해야 한다

---

### STEP 2. 웹 도메인에 OS 검증 파일 배치 (Next.js + Vercel)

Android와 iOS는 각각 "이 도메인 링크를 클릭하면 이 앱을 열어도 되는지" 웹 도메인의 검증 파일을 통해 확인한다.

정적 파일과 Vercel 설정은 [`docs/deeplink-handoff/`](./deeplink-handoff/) 패키지를 정본으로 한다.

```text
nextjs-project/
└── public/
    └── .well-known/
        ├── assetlinks.json
        └── apple-app-site-association
```

Vercel 프로젝트 루트에는 `vercel.json`으로 두 파일의 `Content-Type`을 `application/json`으로 강제한다. 특히 `apple-app-site-association`은 확장자가 없어 기본 정적 서빙 Content-Type이 맞지 않을 수 있다.

### 2-1. Android용: `assetlinks.json`

- **경로:** `https://copsandrobbers.app/.well-known/assetlinks.json`
- **역할:** "이 도메인은 이 Android 앱과 연결되어 있다"는 것을 Google에 증명
- **필요한 정보:**
  - 앱 패키지명: **`com.elipair.copsandrobbers`** (확정값)
  - 앱 서명 SHA256 해시값 — **반드시 아래 ⚠️ 참고**

#### ⚠️ Play App Signing 사용 중 — 인증서 함정 주의

본 프로젝트는 **Google Play App Signing**을 사용한다 (CI에서 `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64`로 내부 테스트 자동 배포 중).

이 경우 우리가 CI에 보관한 `RELEASE_KEYSTORE`로 서명한 APK/AAB를 Play가 받아 **재서명** 해서 사용자에게 배포한다. 즉 실 사용자 단말에 설치된 앱의 인증서는 **본인 keystore가 아니라 Play가 생성한 서명 키 인증서**다.

따라서 `assetlinks.json`에는 다음 **세 가지 SHA-256을 모두** 배열로 넣어야 한다:

| 출처 | 확인 위치 | 용도 |
| --- | --- | --- |
| 디버그 키 | `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android` | 로컬 개발/디버그 빌드 |
| 업로드 키 (본인 keystore) | CI에 보관 중인 `RELEASE_KEYSTORE` | 로컬 release 빌드, 사이드로드 검증 |
| **앱 서명 키 (Play 생성)** | **Play Console → 설정 → 앱 무결성 → 앱 서명 → "앱 서명 키 인증서" 의 SHA-256** | **Play Store 배포본 (실 사용자 단말)** |

세 번째를 빠뜨리면 **Play Store에서 받은 앱에서 딥링크가 절대 작동하지 않는다.** 가장 잘 막히는 함정이다.

**파일 내용 예시:**

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.elipair.copsandrobbers",
      "sha256_cert_fingerprints": [
        "AA:AA:..디버그 키 SHA-256..",
        "BB:BB:..업로드 키 SHA-256..",
        "CC:CC:..Play 앱 서명 키 SHA-256.."
      ]
    }
  }
]
```

> 📎 참조: [Android App Links 검증 문서](https://developer.android.com/training/app-links/verify-android-applinks)

### 2-2. iOS용: `apple-app-site-association` (AASA)

- **경로:** `https://copsandrobbers.app/.well-known/apple-app-site-association`
- **역할:** "이 도메인은 이 iOS 앱과 연결되어 있다"는 것을 Apple에 증명
- **필요한 정보:**
  - Apple Team ID: **`5FZ789N4RT`** (확정값, `ios/Runner.xcodeproj`에서 확인)
  - Bundle ID: **`com.elipair.copsandrobbers`** (확정값)
- **주의:** 파일 확장자 없이 저장 (`.json` 붙이지 않음), `Content-Type: application/json`으로 서빙

**파일 내용:**

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["5FZ789N4RT.com.elipair.copsandrobbers"],
        "components": [
          {
            "/": "/join/*",
            "comment": "Matches invite join links"
          }
        ]
      }
    ]
  }
}
```

> 📎 참조: [Apple Supporting Associated Domains](https://developer.apple.com/documentation/xcode/supporting-associated-domains)

#### ⚠️ Apple CDN 24시간 캐싱 주의

iOS 14+ 부터 AASA 파일은 Apple 자체 CDN(`app-site-association.cdn-apple.com`)에 **최대 24시간** 캐싱된다. 잘못 올린 파일이 풀리는 데 하루가 걸릴 수 있으므로:

1. **첫 배포 전 반드시 검증 도구로 사전 확인**
   - https://branch.io/resources/aasa-validator/ 에서 도메인 입력 후 검증
   - 또는 `curl -v https://copsandrobbers.app/.well-known/apple-app-site-association`로 직접 확인 (200 + `application/json`)
2. **개발 중에는 entitlements에 dev mode 옵션 활용 가능**
   - Xcode → Signing & Capabilities → Associated Domains에 `applinks:copsandrobbers.app?mode=developer` 로 추가하면 Apple CDN을 우회하고 도메인에 직접 요청 (개발 빌드 한정, App Store 빌드에는 사용 금지)

### 2-3. Vercel에서 서빙

두 파일은 Next.js 프로젝트의 `public/.well-known/` 아래에 배치한다.

```json
{
  "headers": [
    {
      "source": "/.well-known/apple-app-site-association",
      "headers": [{ "key": "Content-Type", "value": "application/json" }]
    },
    {
      "source": "/.well-known/assetlinks.json",
      "headers": [{ "key": "Content-Type", "value": "application/json" }]
    }
  ]
}
```

기존 `vercel.json`이 있으면 `headers` 항목만 병합한다.

**필수 조건:**

- `https://copsandrobbers.app/.well-known/assetlinks.json` → HTTP 200, redirect 없음, `Content-Type: application/json`
- `https://copsandrobbers.app/.well-known/apple-app-site-association` → HTTP 200, redirect 없음, `Content-Type: application/json`
- `/join/{inviteCode}` → 앱 미설치 사용자를 위한 폴백 페이지

**검증 방법:**

- Android: [Google Digital Asset Links 검증 도구](https://developers.google.com/digital-asset-links/tools/generator) 또는 `adb` 테스트 (STEP 7 참조)
- iOS: 위 ⚠️ 박스의 Branch AASA Validator 사용 권장

---

### STEP 3. Android 앱 설정

`android/app/src/main/AndroidManifest.xml`의 `<activity>` 태그 안에 intent-filter를 추가한다.

**추가할 내용:**

- `android:autoVerify="true"` → OS가 자동으로 assetlinks.json 검증
- `<data>` 태그에 도메인, scheme(https), path 접두사 지정
- `pathPrefix="/join/"` 으로 `/join/` 하위 모든 URL 가로채기

**예시:**

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https"
          android:host="copsandrobbers.app"
          android:pathPrefix="/join/" />
</intent-filter>
```

**핵심 포인트:**

- `autoVerify="true"`가 있어야 "이 앱으로 열기 vs 브라우저로 열기" 선택 없이 바로 앱이 열림
- Play Store에 배포된 앱은 Play Console → 설정 → 딥링크에서 검증 상태 확인 가능
- 디버그 빌드에서 검증이 안 되면 기기 설정 → 앱 → 경찰과도둑 → "지원되는 웹 주소" 토글을 수동으로 켜서 테스트 가능

> 📎 참조: [Flutter Android App Links 설정](https://docs.flutter.dev/cookbook/navigation/set-up-app-links)

---

### STEP 4. iOS 앱 설정

두 곳을 설정해야 한다.

**4-1. Xcode에서 Associated Domains 추가**

- Xcode → Runner → Signing & Capabilities → Associated Domains 추가
- `applinks:copsandrobbers.app` 형식으로 입력
- `https://` 붙이지 않음
- 개발 중에는 `applinks:copsandrobbers.app?mode=developer` 로 추가하면 Apple CDN 캐싱 우회 (개발 빌드 한정)

**4-2. Apple Developer 계정에서 Associated Domains 활성화**

- Apple Developer Portal → Identifiers → 해당 App ID(`com.elipair.copsandrobbers`) → Associated Domains 체크

**핵심 포인트:**

- AASA `components`의 path matcher(`/join/*`)와 실제 딥링크 URL 경로(`/join/{code}`)가 일치해야 함
- 첫 배포 후 24시간은 AASA 변경이 즉시 반영되지 않을 수 있음 (위 Apple CDN 주의사항 참조)

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

```text
URI 수신 (예: https://copsandrobbers.app/join/ABC123)
  ↓
path segments에서 inviteCode 추출 ("ABC123")
  ↓
인증 상태 확인
  ├─ 미로그인 → pending invite code 저장 → 로그인 화면으로 이동 → 로그인 완료 후 자동 join
  └─ 로그인됨 → POST /api/games/join { inviteCode } 호출
                ↓
                ├─ 200: gameId → 대기실(GameLobbyPage)로 이동
                ├─ 409 "이미 참가 중인 게임" → 토스트 안내 ("이미 참여 중인 방이 있어요. 현재 방에서 나간 후 다시 시도해주세요")
                ├─ 400/404 "유효하지 않은/존재하지 않는 코드" → 토스트 + 메인
                └─ 400 "게임 인원 초과" → 토스트 + 메인
```

> 백엔드 정책: 이미 다른 방에 참가 중인 사용자는 새 방 참가가 거부된다. 따라서 프론트에서 사전에 게임 상태를 조회하거나 확인 모달을 띄울 필요가 없다 — 그냥 join 시도 후 응답을 따른다.

**관련 백엔드 API (이미 존재):**

- `POST /api/games/join` — Request `{ inviteCode }` / Response `{ gameId, participantId }`
- 자세한 에러 케이스는 `docs/api-docs.json`의 `/api/games/join` 항목 참조

**라우팅:** 본 프로젝트는 `go_router` 사용. `/join/:inviteCode` 라우트를 추가하고, 라우트 진입 시 위 로직 실행.

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

앱이 없으면 OS가 브라우저로 해당 URL을 연다. 이때 스토어로 안내하는 웹페이지를 Next.js + Vercel에서 서빙한다.

**동작 로직:**

1. `GET /join/{inviteCode}` 요청 들어옴
2. Next.js App Router 또는 Pages Router에서 처리
3. User-Agent 확인 → Android인지 iOS인지 판별
4. 해당 스토어 링크로 안내 페이지 표시

**구현 옵션:**

- **권장**: `app/join/[code]/page.tsx` 또는 `pages/join/[code].tsx`에서 초대 코드와 스토어 버튼 표시
- 폴백 페이지 구현 계약은 [`docs/deeplink-handoff/README.md`](./deeplink-handoff/README.md)를 따른다
- iOS는 같은 도메인 Universal Link를 웹페이지 안에서 다시 열 때 Safari에 남을 수 있으므로, 폴백 페이지에서는 App Store 안내를 기본 동작으로 둔다

**선택적 고급 기능 (Deferred Deep Link):**

- 앱 설치 후 처음 열었을 때 원래 공유된 코드로 이동시키는 기능
- 구현하려면 code를 서버에 저장해두고, 앱 최초 실행 시 서버에서 조회하는 로직 필요
- 1차에선 제외, 필요해지면 추가

**OG 메타 (선택):**

카톡 등에서 링크 미리보기 카드를 띄우고 싶다면 폴백 HTML `<head>`에 OG 태그 추가. 코드별 동적 메시지가 필요하면 컨트롤러 방식 사용.

```html
<meta property="og:title" content="경찰과도둑 - 초대받았어요">
<meta property="og:description" content="친구가 게임에 초대했어요!">
<meta property="og:image" content="https://copsandrobbers.app/og-invite.png">
```

---

### STEP 7. 공유 기능 연결 (방장 → 링크 공유)

**공유 플로우:**

```text
방장이 "초대 링크 공유" 버튼 클릭
       ↓
URL 생성: "https://copsandrobbers.app/join/{inviteCode}"
       ↓
Flutter의 Share API 호출 (share_plus 패키지)
       ↓
카카오톡 / 문자 / 기타 앱으로 링크 전송
```

**inviteCode 생성 주체:** 백엔드 (`POST /api/games` 응답의 `inviteCode` 필드). 프론트는 이 값을 URL 템플릿에 끼워서 공유한다.

> 📎 참조: [share_plus 패키지](https://pub.dev/packages/share_plus)

---

## 테스트 방법

### Android 테스트

1. **ADB 명령어로 테스트** (가장 빠름)
   - `adb shell am start -a android.intent.action.VIEW -d "https://copsandrobbers.app/join/TEST123" com.elipair.copsandrobbers`
   - 앱이 열리면서 해당 URI가 전달되는지 확인
2. **실제 링크 클릭 테스트**
   - Google Docs / 메모 앱에 링크를 적고 탭하여 테스트 (권장)
   - 브라우저 주소창 직접 입력은 딥링크 테스트 안 됨
3. **검증 상태 확인**
   - `adb shell pm get-app-links com.elipair.copsandrobbers`
   - `verified` 상태여야 autoVerify 성공
4. **주의:** 디버그 빌드에서 autoVerify가 실패하는 경우 기기 설정 → 앱 → "지원되는 웹 주소" 토글 수동 ON

### iOS 테스트

1. **시뮬레이터 명령어**
   - `xcrun simctl openurl booted "https://copsandrobbers.app/join/TEST123"`
2. **실제 기기**
   - 메모/Safari에서 링크 길게 눌러서 "앱에서 열기" 확인
3. **Apple AASA 검증**
   - https://branch.io/resources/aasa-validator/ 에 도메인 입력
   - 또는 `https://app-site-association.cdn-apple.com/a/v1/copsandrobbers.app` 접속해서 Apple CDN이 캐싱한 AASA 확인

> 📎 참조: [Flutter Deep Link 테스트 가이드](https://docs.flutter.dev/cookbook/navigation/set-up-app-links#testing)

---

## 체크리스트

### 도메인

- [x] 사용할 도메인 결정 (`copsandrobbers.app`)
- [ ] HTTPS 적용 확인

### 웹 호스팅 (Next.js + Vercel)

- [ ] `/.well-known/assetlinks.json` 서빙 (Android, **3개 SHA-256 모두**)
- [ ] `/.well-known/apple-app-site-association` 서빙 (iOS, 확장자 없이, `application/json`, `appIDs + components` 형식)
- [ ] `vercel.json` headers로 두 검증 파일 Content-Type 강제
- [ ] 폴백 웹페이지 구현 (`/join/{code}` Next.js route)
- [ ] Apple AASA validator로 사전 검증

### Android

- [ ] `AndroidManifest.xml`에 intent-filter 추가 (`autoVerify="true"`, `pathPrefix="/join/"`)
- [ ] Flutter 기본 딥링크 핸들러 비활성화 (`flutter_deeplinking_enabled=false`)
- [ ] Play Console에서 앱 서명 키 SHA-256 추출하여 `assetlinks.json`에 포함
- [ ] `adb shell pm get-app-links` 로 verified 확인

### iOS

- [ ] Xcode Associated Domains 설정 (`applinks:copsandrobbers.app`)
- [ ] Apple Developer Portal에서 Associated Domains 활성화
- [ ] AASA `components`(`/join/*`)와 실제 URL 경로 일치 확인
- [ ] AASA validator 통과

### Flutter 앱

- [ ] `app_links` 패키지 추가
- [ ] Cold Start 링크 처리 (`getInitialLink`)
- [ ] 실행 중 링크 처리 (`uriLinkStream`)
- [ ] `go_router`에 `/join/:inviteCode` 라우트 추가
- [ ] URI 파싱 → inviteCode 추출 → 인증/게임 상태에 따라 라우팅
- [ ] 미로그인 시 pending invite code 저장 → 로그인 완료 후 자동 join
- [ ] 이미 다른 게임 참가 중이면 join API 409 응답 기반 안내
- [ ] 백엔드 응답 에러 분기 (4xx, 409 등) → 토스트 + 메인 이동
- [ ] 공유 기능 구현 (`share_plus`)

### 배포 후

- [ ] 폴백 페이지에 실제 스토어 URL 연결
- [ ] Play Console에서 딥링크 검증 상태 확인
- [ ] iOS는 첫 배포 후 24시간 AASA 캐싱 풀릴 때까지 모니터링

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
| Branch AASA Validator                | https://branch.io/resources/aasa-validator/                                            |
| Firebase Dynamic Links 종료 FAQ      | https://firebase.google.com/support/dynamic-links-faq                                  |
