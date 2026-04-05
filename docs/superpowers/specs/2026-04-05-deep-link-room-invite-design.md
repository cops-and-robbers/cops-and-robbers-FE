# 딥링크 기반 방 초대 — 프론트엔드 환경 설계

## 개요

딥링크 URL(`https://도메인/room?code=XXX`)을 통해 방에 자동 참가할 수 있는 시스템의 프론트엔드 환경을 세팅한다.
도메인은 아직 미확정이므로 플레이스홀더로 두고, 확정 시 상수 1곳만 변경하면 전체가 연결되는 구조.

## 범위

- `/room?code=XXX` 경로만 구현 (`/friend`는 추후)
- 프론트엔드 환경 세팅에 집중 (서버 검증 파일 배치는 백엔드 영역)
- 로그인 안 된 상태에서 딥링크 수신 시 로그인 화면 표시 (pending 미구현, 추후 확장 가능)

## 기술 스택

- `app_links: ^7.0.0` — URI 수신 (Cold Start + 실행 중)
- `go_router: ^17.0.1` — 화면 라우팅 (기존 사용 중)
- `share_plus: ^12.0.1` — 링크 공유 (기존 사용 중)

### app_links 선택 이유

go_router 내장 딥링크만으로는 `/room?code=XXX` → API 조회(code→sessionId 변환) → `/waiting-room/:sessionId` 이동이라는 중간 단계를 처리할 수 없다.
app_links로 URI 수신 시점을 제어하여 파싱/검증/API 조회 후 라우팅하는 구조가 필요.

## 아키텍처

```
┌─────────────────────────────────────────────┐
│            deep_link_config.dart             │
│  (도메인 상수 + URL 빌더)                     │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────┐    ┌───────────────────┐  │
│  │ Android      │    │ iOS               │  │
│  │ Manifest     │    │ Entitlements      │  │
│  │ intent-filter│    │ Associated Domain │  │
│  └──────┬───────┘    └──────┬────────────┘  │
│         │                   │               │
│         └─────────┬─────────┘               │
│                   ↓                         │
│         ┌─────────────────┐                 │
│         │   app_links     │                 │
│         │  (URI 수신)     │                 │
│         └────────┬────────┘                 │
│                  ↓                          │
│         ┌─────────────────┐                 │
│         │ DeepLinkHandler │                 │
│         │ (파싱 + 검증)   │                 │
│         └────────┬────────┘                 │
│                  ↓                          │
│         ┌─────────────────┐                 │
│         │   go_router     │                 │
│         │ (화면 라우팅)   │                 │
│         └─────────────────┘                 │
└─────────────────────────────────────────────┘
```

## 파일 구조

### 신규 파일 (2개)

| 파일 | 역할 |
|------|------|
| `lib/core/constants/deep_link_config.dart` | 도메인 상수 + URL 빌더. 도메인 변경 시 이 파일 1곳만 수정 |
| `lib/core/deep_link/deep_link_handler.dart` | Riverpod provider. app_links URI 수신 → 파싱 → 인증 체크 → go_router 이동 |

### 변경 파일 (4개)

| 파일 | 변경 내용 |
|------|-----------|
| `pubspec.yaml` | `app_links: ^7.0.0` 추가 |
| `android/app/src/main/AndroidManifest.xml` | intent-filter 추가 + flutter_deeplinking_enabled=false |
| `ios/Runner/Runner.entitlements` | `com.apple.developer.associated-domains` 추가 |
| `lib/features/session/presentation/pages/waiting_room_page.dart` | `shareText(code)` → `shareText(DeepLinkConfig.roomInviteUrl(code))` |

## 상세 설계

### 1. `deep_link_config.dart`

```dart
/// 딥링크 설정 상수
///
/// 도메인 변경 시 [host]만 수정하면 앱 전체 딥링크가 연동된다.
/// Android(AndroidManifest.xml), iOS(Runner.entitlements)의
/// 도메인도 함께 변경해야 함 — 각 파일에 변경 위치 주석 표기.
class DeepLinkConfig {
  DeepLinkConfig._();

  // TODO: 백엔드 도메인 확정 시 변경
  // 변경 시 함께 수정할 파일:
  // - android/app/src/main/AndroidManifest.xml (android:host)
  // - ios/Runner/Runner.entitlements (applinks:도메인)
  static const String host = 'example.com';
  static const String scheme = 'https';

  /// 방 초대 딥링크 URL 생성
  static String roomInviteUrl(String inviteCode) =>
      '$scheme://$host/room?code=$inviteCode';
}
```

### 2. `deep_link_handler.dart`

Riverpod `@riverpod` provider로 구현.

**처리 플로우:**

```
앱 시작 시 초기화
  ↓
Cold Start: getInitialLink() → URI 확인
실행 중: uriLinkStream 구독
  ↓
URI 수신
  ↓
호스트 검증 (DeepLinkConfig.host와 일치하는지)
  ↓
path 확인 (/room인지)
  ↓
query parameter에서 code 추출
  ↓
인증 상태 확인
  ├── 로그인 O → 방 참가 API 호출 → go_router로 /waiting-room/:sessionId 이동
  └── 로그인 X → 무시 (로그인 화면 유지)
```

**핵심 고려사항:**
- `AppLinks()` 인스턴스는 앱 시작 초기에 생성해야 Cold Start 링크를 놓치지 않음
- 스트림 구독 해제를 위한 lifecycle 관리 필요
- 호스트 검증으로 다른 도메인 URI 무시

### 3. Android 설정 (`AndroidManifest.xml`)

MainActivity `<activity>` 안에 추가:

```xml
<!-- 딥링크: Flutter 기본 핸들러 비활성화 (app_links 사용) -->
<meta-data
    android:name="flutter_deeplinking_enabled"
    android:value="false" />

<!-- 딥링크: App Links intent-filter -->
<!-- TODO: 도메인 변경 시 android:host 값 수정 -->
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

### 4. iOS 설정 (`Runner.entitlements`)

기존 항목에 추가:

```xml
<!-- TODO: 도메인 변경 시 applinks: 뒤의 도메인 수정 -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:example.com</string>
</array>
```

**추가 필요 작업 (수동):**
- Apple Developer Portal → Identifiers → App ID → Associated Domains 체크박스 활성화
- Provisioning Profile 재생성 (Associated Domains 활성화 후 기존 프로파일 무효화됨)

### 5. 공유 변경 (`waiting_room_page.dart`)

```dart
// 변경 전 (790행)
onConfirm: () {
  shareText(code);
},

// 변경 후
onConfirm: () {
  shareText(DeepLinkConfig.roomInviteUrl(code));
},
```

공유 시 `ABC123` 대신 `https://example.com/room?code=ABC123`이 전송됨.
`share_util.dart`는 변경 없음 (범용 텍스트 공유 유틸 유지).

## 도메인 변경 체크리스트

백엔드 도메인 확정 시 변경할 파일 3곳:

1. `lib/core/constants/deep_link_config.dart` — `host` 상수
2. `android/app/src/main/AndroidManifest.xml` — `android:host` 속성
3. `ios/Runner/Runner.entitlements` — `applinks:도메인` 값

## 추후 확장 포인트

| 항목 | 설명 |
|------|------|
| `/friend` 경로 추가 | DeepLinkHandler에 path 분기 추가 + 네이티브 설정에 pathPrefix 추가 |
| Pending deep link | 로그인 안 된 상태에서 수신한 URI를 저장 → 로그인 완료 후 자동 처리 |
| Deferred deep link | 앱 미설치 → 설치 후 첫 실행 시 원래 코드로 이동 (서버 연동 필요) |
