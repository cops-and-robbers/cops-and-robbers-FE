### 📌 작업 개요

App Transfer 이후 옛 Firebase 프로젝트(`copsandrobbers-c2281`)를 가리키던 dead code 및 메타데이터 파일을 제거하고, iOS 빌드 환경을 새 Apple Developer 팀과 새 Firebase 프로젝트(`copsandrobbers-8c026`)에 맞게 갱신. 추가로 도둑 위치 공유 간격 슬라이더 최소값을 1분에서 0분으로 조정. 또한 FCM 알림 처리 로직을 정비하여 iOS 포그라운드에서 배너가 표시되지 않던 문제를 해결하고, 알림 수신 시 진동 피드백 및 페이로드 구조 파악용 디버그 로그를 추가.

**관련 이슈**: #303

### 🔍 문제 분석

#### 1. `lib/firebase_options.dart` — Dead Code

- 파일은 존재하지만 `main.dart`를 비롯한 어디에서도 import되지 않음
- `Firebase.initializeApp()`이 옵션 인자 없이 호출되어 네이티브 설정 파일(`GoogleService-Info.plist`, `google-services.json`)을 자동 사용
- 즉, 86줄의 `DefaultFirebaseOptions` 정의가 실제 동작에 전혀 관여하지 않는 상태

#### 2. 루트 `firebase.json` — Stale Metadata (시한폭탄)

- 옛 Firebase 프로젝트 `copsandrobbers-c2281`을 가리키는 메타데이터 파일
- App Transfer 후 새 프로젝트 `copsandrobbers-8c026`으로 교체되었으나 메타데이터는 갱신되지 않음
- 누군가 `flutterfire configure`를 옵션 없이 실행하면 이 파일을 참조해 옛 프로젝트로 재구성을 시도 → `GoogleService-Info.plist` / `google-services.json`이 옛 프로젝트 값으로 덮어써질 위험
- 기존 내용 (제거됨):
  ```json
  {
    "flutter": {
      "platforms": {
        "android": { "default": { "projectId": "copsandrobbers-c2281", ... } },
        "ios":     { "default": { "projectId": "copsandrobbers-c2281", ... } },
        ...
      }
    }
  }
  ```

#### 3. iOS 빌드 환경 — App Transfer 후 미반영

- `DEVELOPMENT_TEAM`이 옛 팀(`98QY4938R9`)을 가리키고 있어 새 팀에서 코드 사이닝 실패 가능성
- `GoogleService-Info.plist`의 `ANDROID_CLIENT_ID`가 옛 OAuth 클라이언트 ID 사용 중

#### 4. FCM 포그라운드 알림 — iOS 배너 미표시

- iOS는 `UNUserNotificationCenter.delegate`를 단 하나만 가질 수 있고, Firebase Messaging이 점유
- 기존 로직은 `flutter_local_notifications`로 직접 알림을 띄우고 있었으나, FCM delegate가 포그라운드 표시 옵션을 제어하기 때문에 로컬 알림이 알림 센터에는 들어가도 **포그라운드 배너로는 표시되지 않음**
- Android는 별개로, FCM이 포그라운드에서 자동 표시하지 않으므로 어차피 로컬 알림으로 띄워야 정상 동작

#### 5. FCM 디버그 로그 — 페이로드 구조 파악 어려움

- 기존 로그는 `message.data`만 출력하여 빈 `{}`로 보이는 케이스가 다수
- FCM은 `notification`(제목/본문)과 `data`(커스텀 키-값) 두 페이로드로 분리되어 있는데 한쪽만 찍혀 디버깅 시 혼란 야기
- `_onForegroundMessage`, `_onMessageOpenedApp`, 백그라운드 핸들러 3곳 모두 동일한 문제

#### 6. 알림 수신 진동 피드백 부재

- 포그라운드에서 FCM 도착 시 시각 알림만 발생하고 햅틱 피드백 없음
- 사용자가 화면을 보고 있지 않을 때 알림 인지율 저하

### ✅ 구현 내용

#### 1. Dead Firebase 파일 정리 (`5c08dd7`)

- **파일**: `lib/firebase_options.dart` 삭제 (86줄)
- **파일**: `firebase.json` 삭제 (1줄)
- **이유**: 사용처 0인 dead code 제거 + 옛 프로젝트를 가리키던 stale 메타데이터로 인한 잠재적 사고 차단

#### 2. iOS 새 Apple Developer 팀 및 Firebase 프로젝트 전환 (`e3d3c86`)

- **파일**: `ios/Runner.xcodeproj/project.pbxproj`
- **변경 내용**: `DEVELOPMENT_TEAM` 3곳 모두 `98QY4938R9` → `5FZ789N4RT`로 변경
- **이유**: App Transfer로 양도된 새 Apple Developer 팀 적용

- **파일**: `ios/Runner/GoogleService-Info.plist`
- **변경 내용**: `ANDROID_CLIENT_ID`를 새 Firebase 프로젝트(`copsandrobbers-8c026`) 기준으로 갱신
  - Before: `54954969671-3dpcga46ljqdkn11u7m78te93b9r2gb9.apps.googleusercontent.com`
  - After: `54954969671-02d018blq67asg3s988kqentjo3iesg2.apps.googleusercontent.com`
- **이유**: Google Sign-In 시 새 프로젝트의 OAuth 클라이언트 사용 보장

#### 3. 도둑 위치 공유 간격 최소값 조정 (`e90247b`)

- **파일**: `lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart`
- **변경 내용**: 슬라이더 `min: 1` → `min: 0`
- **이유**: 백엔드 API에서 0분(공유 안 함)을 허용하면서 코드의 임시 제약(`TODO : 추후에 API 생기면 0으로 변경`) 해제

#### 4. FCM 포그라운드 알림 배너 미표시 수정 + 로그 개선 (`49df929`)

- **파일**: `lib/core/services/fcm/firebase_messaging_service.dart`
- **변경 내용**:
  - `init()`에 `setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true)` 추가 → iOS 포그라운드에서 FCM이 직접 시스템 배너 표시
  - `_onForegroundMessage`에서 `Platform.isAndroid` 분기 추가 → Android에서만 로컬 알림 호출 (iOS는 FCM이 자동 표시하므로 중복 방지)
  - `_onForegroundMessage` / `_onMessageOpenedApp` / `_firebaseMessagingBackgroundHandler` 3곳의 디버그 로그를 `notification.title` / `notification.body` / `data` 분리 출력으로 변경

- **파일**: `android/app/src/main/AndroidManifest.xml`
- **변경 내용**: `default_notification_channel_id` 메타데이터 추가 → 백그라운드 FCM이 우리 채널(`channel_id`) 사용
- **이유**: `Missing Default Notification Channel metadata` 경고 제거 + 백그라운드 알림이 OS 기본 저우선순위 채널 대신 importance.max 채널 사용 보장

- **파일**: `lib/core/services/fcm/local_notifications_service.dart`
- **변경 내용**: `DarwinNotificationDetails`에 `presentAlert` / `presentBadge` / `presentSound` / `presentBanner` / `presentList` 모두 `true`로 명시
- **이유**: 향후 iOS에서 로컬 알림을 직접 호출할 경로가 생길 경우를 대비한 기본값 명시 (현재는 사용 경로 없으나 안전장치)

#### 5. FCM 포그라운드 알림 수신 시 진동 피드백 추가 (`097335c`)

- **파일**: `lib/core/services/fcm/firebase_messaging_service.dart`
- **변경 내용**: `_onForegroundMessage`에 `VibrationService.instance().messageReceived()` 호출 추가
- **이유**: 포그라운드 상태에서도 명시적 진동으로 알림 인지율 보강. 기존 `VibrationPatterns.messageReceived`(duration 100ms / amplitude 80) 패턴을 재사용하여 채팅 메시지 수신과 동일한 햅틱 일관성 유지

### 🔧 주요 변경사항 상세

#### `Firebase.initializeApp()` 동작 방식 (변경 없음)

`main.dart`의 Firebase 초기화는 옵션 인자 없이 호출되며, 네이티브 플랫폼이 자동으로 설정 파일을 로드:

- iOS: `ios/Runner/GoogleService-Info.plist`
- Android: `android/app/google-services.json`

따라서 `lib/firebase_options.dart` 삭제는 런타임에 영향 없음.

#### Step2GameSettingsContent 슬라이더 변경

```dart
// Before
min: 1,  // TODO : 추후에 API 생기면 0으로 변경

// After
min: 0,
```

`divisions: 30`은 그대로 유지되어 0~30분 사이 1분 단위로 선택 가능.

**특이사항**:
- 0분 선택 시 도둑 위치 공유 비활성화 의미. 백엔드 API가 `locationRevealIntervalMinutes: 0` 값을 정상 처리하는지 서버측 확인 필요
- `max: 30`, `unit: '분'` 등 다른 파라미터 변경 없음

#### FCM 포그라운드 알림 처리 — 플랫폼별 분기

iOS와 Android의 포그라운드 알림 동작 차이를 수용하기 위해 명시적으로 분기:

| 플랫폼 | 포그라운드 동작 | 본 작업의 처리 |
|--------|---------------|--------------|
| iOS | `setForegroundNotificationPresentationOptions(true)` 활성화 시 FCM이 직접 시스템 배너 표시 | 로컬 알림 호출 스킵 (중복 방지) |
| Android | FCM은 백그라운드에서만 자동 표시, 포그라운드에선 `onMessage`로만 전달 | `Platform.isAndroid` 분기로 로컬 알림 직접 띄움 |

#### FCM 디버그 로그 개선

기존:
```dart
debugPrint('Foreground message received: ${message.data.toString()}');
```

변경:
```dart
debugPrint('[FCM] Foreground message received');
debugPrint('  notification.title: ${message.notification?.title}');
debugPrint('  notification.body : ${message.notification?.body}');
debugPrint('  data: ${message.data}');
```

`_onMessageOpenedApp`, `_firebaseMessagingBackgroundHandler` 동일하게 적용. `notification` 페이로드와 `data` 페이로드를 분리해 출력하여 백엔드 페이로드 구조 디버깅 용이.

#### 진동 피드백 호출 위치

```dart
void _onForegroundMessage(RemoteMessage message) {
  // 로그 출력...

  // 1. 커스텀 진동 피드백
  VibrationService.instance().messageReceived();

  // 2. 메시지 타입 분기 처리
  final messageType = message.data['type'];
  // ...
}
```

`VibrationService`는 기존 채팅 메시지 수신 진동에 사용하던 인프라를 그대로 재사용. iOS / Android 모두 동작하며 디바이스 무음 모드와 무관하게 햅틱 발생 (포그라운드 한정).

### 📦 의존성 변경

- 없음

### 🧪 테스트 및 검증

- [x] `flutter analyze` 통과 (이슈 체크리스트 항목)
- [x] 실기기에서 앱 실행 후 Firebase 정상 초기화 확인 (콘솔 로그)
- [x] FCM 토큰 정상 발급 확인 (콘솔 로그)
- [x] Firebase Console에서 테스트 푸시 메시지 도달 확인
- [x] iOS 포그라운드에서 FCM 배너 표시 확인
- [x] iOS 포그라운드에서 알림 수신 시 진동 발생 확인
- [x] Android 포그라운드 로컬 알림 표시 확인 + `Missing Default Notification Channel metadata` 경고 사라짐 확인
- [ ] iOS 새 팀(`5FZ789N4RT`)에서 코드 사이닝 정상 동작 확인
- [ ] 도둑 위치 공유 간격 0분 선택 시 백엔드 API 정상 동작 확인
- [ ] iOS 백그라운드 사운드/진동 동작 검증 (백엔드 페이로드에 `apns.payload.aps.sound: "default"` 포함 시점에 재검증 필요)

### 📌 참고사항

#### 향후 `flutterfire configure` 실행 시 주의

`firebase.json`이 제거되었으므로 향후 명시적으로 `flutterfire configure` 실행 시:

- 새 프로젝트(`copsandrobbers-8c026`) 기준으로 다시 구성 필요
- 모바일 전용 앱(iOS/Android)이므로 웹 지원이나 명시적 Firebase 옵션 주입이 불필요한 한 굳이 재실행할 이유 없음
- 재실행 시 `--platforms=android,ios`만 지정하여 macOS/Web 메타데이터 생성 방지 권장

#### iOS `DEVELOPMENT_TEAM` 변경 위치

`project.pbxproj` 내 3개 빌드 컨피그(Debug/Release/Profile)에 모두 반영되어, 모든 빌드 모드에서 새 팀 사용.

#### FCM 백엔드 페이로드 명세 (백엔드 작업 시 전달용)

iOS 백그라운드에서 사운드/진동이 동작하려면 백엔드가 보내는 APNs 페이로드에 `sound` 필드가 반드시 포함되어야 함. Firebase Console 테스트 시에는 "Additional options → Sound: default" 명시 필요.

권장 페이로드 예시:
```json
{
  "token": "<FCM_TOKEN>",
  "notification": {
    "title": "알림 제목",
    "body": "알림 본문"
  },
  "data": {
    "type": "<event_type>",
    "gameId": "<id>"
  },
  "apns": {
    "payload": {
      "aps": {
        "sound": "default",
        "badge": 1
      }
    }
  },
  "android": {
    "priority": "high",
    "notification": {
      "channel_id": "channel_id",
      "default_sound": true,
      "default_vibrate_timings": true
    }
  }
}
```

핵심 필드:
- `apns.payload.aps.sound: "default"` — iOS 백그라운드 사운드 + 진동 발동 (이게 빠지면 백그라운드에서 무음/무진동)
- `android.priority: "high"` — Android 즉시 전달 (기본 normal은 도즈 모드에서 지연)
- `android.notification.channel_id: "channel_id"` — 우리 채널 사용 강제 (importance.max 적용)
- `data.type` — 클라이언트 측 분기 처리 키 (예: `content_completed`, `websocket_disconnected`)

#### iOS 백그라운드 화면 깨우기

iOS 잠금화면에서 알림이 와도 화면이 깨지 않는 경우는 보통 다음 중 하나:
- 페이로드에 `sound` 필드 누락 (저우선순위 처리)
- 디바이스 `Settings → Notifications → 경찰과도둑 → Lock Screen` 토글 OFF
- Focus / DND / Sleep 모드 활성화

Xcode `Background Modes` 카발리티는 화면 깨우기와 무관 (백그라운드 코드 실행 권한이지 알림 표시 제어가 아님).

#### 커밋 단위

이슈 #303은 5개 커밋으로 분리됨:
- `e3d3c86` — iOS 팀/Firebase 프로젝트 전환
- `5c08dd7` — dead code 삭제
- `e90247b` — 슬라이더 min 0 조정
- `49df929` — FCM 포그라운드 알림 배너 미표시 수정 + 로그 개선
- `097335c` — FCM 포그라운드 알림 수신 시 커스텀 진동 피드백 추가
