# 백그라운드 위치 추적 및 실시간 통신 가이드

## 개요

경찰과도둑 게임은 30분 동안 실시간 위치 추적이 필요합니다. 사용자가 게임 중 전화를 받거나, 카톡을 확인하거나, 화면을 끄는 경우에도 위치 추적과 서버 통신이 계속되어야 합니다.

### 문제 상황

```
게임 중 → 전화 수신 → 통화 앱으로 전환
       → 카톡 알림 → 잠깐 카톡 확인
       → 잠금 버튼 → 화면 꺼짐

❌ 현재: WebSocket 끊김 → 위치 전송 중단 → 다른 플레이어가 순간이동처럼 보임
✅ 목표: WebSocket 유지 → 위치 전송 계속 → 부드러운 이동 표시
```

### 해결책

**Foreground Service (Android) + Background Modes (iOS)**를 사용하여 백그라운드에서도 앱이 계속 실행되도록 합니다.

---

## 기술 스택

### 필요한 패키지

- **flutter_background_service**: 백그라운드에서 Dart 코드를 계속 실행할 수 있게 해주는 Flutter 플러그인
- **stomp_dart_client**: WebSocket STOMP 프로토콜 통신 (기존 사용 중)
- **geolocator**: GPS 위치 추적 (기존 사용 중)

### 플랫폼 권한

**Android (이미 설정됨):**
- `ACCESS_BACKGROUND_LOCATION`: 앱이 백그라운드에 있을 때도 위치 정보에 접근 가능
- `FOREGROUND_SERVICE`: Foreground Service 실행 권한
- `FOREGROUND_SERVICE_LOCATION`: 위치 추적 전용 Foreground Service 권한

**iOS (이미 설정됨):**
- `NSLocationAlwaysAndWhenInUseUsageDescription`: 백그라운드 위치 권한 설명
- `UIBackgroundModes` - `location`: iOS에서 백그라운드 위치 추적 활성화

---

## 시스템 아키텍처

### 전체 구조

Flutter 앱은 두 개의 독립적인 실행 영역(Isolate)으로 분리됩니다:

1. **메인 Isolate (UI 영역)**
   - 사용자 인터페이스 표시
   - 사용자 상호작용 처리
   - 게임 로직 실행
   - 화면이 꺼지거나 다른 앱으로 전환되면 일시정지됨

2. **백그라운드 서비스 Isolate (독립 실행 영역)**
   - GPS 위치 스트림을 3-5초 주기로 수신
   - WebSocket STOMP 클라이언트가 계속 연결 유지
   - 수신한 위치 데이터를 WebSocket으로 서버에 전송
   - **앱이 백그라운드로 가도 계속 실행됨** (Foreground Service 덕분)

### 데이터 흐름

**게임 시작 시:**
1. 사용자가 게임을 시작함
2. 메인 앱이 백그라운드 서비스 시작 명령을 보냄
3. 시스템이 새로운 Isolate(독립 실행 영역)을 생성함
4. 백그라운드 서비스 Isolate가 초기화됨

**백그라운드 서비스 Isolate 내부 흐름:**
1. WebSocket 서버에 연결함
2. WebSocket 연결이 성공하면 GPS 위치 스트림을 시작함
3. GPS에서 3-5초마다 위치 데이터를 수신함
4. 수신한 위치 데이터(위도, 경도, 정확도, 시간)를 JSON으로 변환함
5. WebSocket STOMP 프로토콜로 서버의 `/app/game/{gameId}/location` 엔드포인트에 전송함
6. 서버가 해당 위치 데이터를 같은 게임의 다른 플레이어들에게 브로드캐스트함

**백그라운드 전환 시 (전화, 카톡, 잠금):**
1. 메인 앱 UI가 일시정지됨
2. **하지만 백그라운드 서비스 Isolate는 계속 실행됨**
3. GPS는 계속 위치를 수신함
4. WebSocket은 계속 연결 상태를 유지함
5. 위치 데이터는 계속 서버로 전송됨
6. 다른 플레이어들은 해당 사용자의 위치 업데이트를 계속 받음

**앱 복귀 시:**
1. 메인 앱 UI가 다시 활성화됨
2. 백그라운드 서비스는 이미 계속 실행 중이었으므로 끊김 없이 동작함
3. 지도 화면이 최신 위치로 업데이트됨 (카메라 이동 로직 필요)

---

## 구현 로직

### 서비스 초기화 로직

**파일 위치:** `lib/core/services/location/background_location_service.dart`

**서비스 설정 로직:**
1. FlutterBackgroundService 인스턴스를 생성함
2. Android와 iOS 각각에 대한 설정을 지정함
   - **Android**: Foreground Service로 설정하여 알림이 표시되도록 함
   - **iOS**: Background Modes 활성화로 백그라운드 실행 허용

**Android Foreground Service 설정:**
- `isForegroundMode: true`로 설정하면 서비스가 Foreground Service로 실행됨
- 알림 채널 정보 지정: 채널 ID, 채널 이름, 알림 제목/내용
- `foregroundServiceTypes: [AndroidForegroundType.location]`로 위치 추적용임을 명시
- 시스템이 이 서비스에 높은 우선순위를 부여하여 쉽게 종료되지 않음

**iOS Background Modes 설정:**
- `onForeground`, `onBackground` 핸들러 지정
- iOS는 `UIBackgroundModes` - `location` 설정이 있으면 백그라운드에서도 위치 추적 가능

**서비스 시작 로직:**
1. `startService()` 메서드를 호출하여 백그라운드 Isolate 생성
2. `invoke('configure', {...})`로 게임 ID, 사용자 ID, WebSocket URL 전달
3. 백그라운드 Isolate가 이 파라미터를 받아서 WebSocket 연결 및 GPS 시작

### 백그라운드 서비스 메인 로직

**백그라운드 Isolate 내부에서 실행되는 로직:**

1. **초기화 단계**
   - `DartPluginRegistrant.ensureInitialized()`를 호출하여 Flutter 플러그인 등록
   - 이것 없이는 GPS, WebSocket 같은 네이티브 기능을 사용할 수 없음

2. **설정 수신 대기**
   - 메인 앱으로부터 `configure` 이벤트를 수신함
   - 이벤트에 포함된 gameId, userId, wsUrl 파라미터를 저장함

3. **WebSocket 연결 로직**
   - STOMP 클라이언트 인스턴스를 생성함
   - 서버 URL을 지정하고 연결 콜백 함수를 등록함
   - `activate()` 메서드로 실제 연결 시도

4. **연결 성공 시 GPS 스트림 시작**
   - `Geolocator.getPositionStream()`으로 위치 스트림을 구독함
   - LocationSettings로 정확도(high), 거리 필터(5m), 시간 제한(5초) 지정
   - 이 설정에 따라 GPS가 3-5초마다 위치 데이터를 발행함

5. **위치 데이터 수신 시 처리 로직**
   - GPS 스트림이 Position 객체를 발행함
   - Position에서 위도, 경도, 정확도를 추출함
   - 현재 시간을 ISO8601 포맷으로 변환함
   - JSON 객체로 구성: {gameId, userId, latitude, longitude, accuracy, timestamp}
   - STOMP 클라이언트로 서버 엔드포인트에 전송함

6. **주기적 알림 업데이트 (Android 전용)**
   - 30초마다 타이머가 실행됨
   - 알림 내용을 현재 시간으로 업데이트함 (예: "게임 진행 중 🎮 - 15:23")
   - 사용자에게 서비스가 계속 실행 중임을 알림

7. **서비스 중지 이벤트 처리**
   - 메인 앱에서 `stopService` 이벤트를 보내면
   - GPS 위치 스트림 구독을 취소함
   - WebSocket 연결을 해제함 (`deactivate()`)
   - 서비스 Isolate를 종료함 (`stopSelf()`)

### 게임 화면 통합 로직

**게임 시작 시:**
1. GamePage가 initState에서 `_startBackgroundService()` 호출
2. BackgroundLocationService.start() 메서드에 게임 정보 전달
3. 서비스가 성공적으로 시작되면 백그라운드 추적 활성화

**게임 종료 시:**
1. dispose() 또는 나가기 버튼에서 `BackgroundLocationService.stop()` 호출
2. 백그라운드 서비스가 정리되고 Isolate 종료
3. GPS와 WebSocket 리소스 해제

---

## 사용자 경험

### Android 사용자 경험

**알림 표시 방식:**
- 게임 시작 시 상단 알림바에 지속적인 알림이 표시됨
- 알림 제목: "경찰과도둑"
- 알림 내용: "게임 진행 중 🎮" + 현재 시간
- 이 알림은 사용자가 스와이프해도 사라지지 않음 (Foreground Service 특성)
- 알림을 탭하면 게임 화면으로 복귀함
- 게임이 종료되어야만 알림이 제거됨

**Foreground Service가 제공하는 보호:**
- 시스템이 메모리 부족 시에도 이 서비스를 쉽게 종료하지 않음
- 사용자가 "최근 앱"에서 앱을 스와이프해도 서비스는 계속 실행됨
- 배터리 최적화 예외 대상이 됨

### iOS 사용자 경험

**상태바 표시 방식:**
- 백그라운드에서 위치 추적 중일 때 화면 최상단 상태바가 변경됨
- 옵션 1: 파란색 배경이 표시됨 (iOS 13 이하)
- 옵션 2: 위치 아이콘이 표시됨 (iOS 14+)
- 그러나 우리프로젝트에서는 IOS 15+ 만 지원함으로 옵션2로 가야함
- iOS 시스템이 자동으로 표시하므로 개발자가 별도 설정 불필요

**iOS Background Modes 동작:**
- `UIBackgroundModes` - `location` 설정이 있으면
- 앱이 백그라운드에 있어도 위치 서비스를 계속 사용할 수 있음
- "앱을 사용하는 동안" 권한만으로도 게임 세션 중 백그라운드 추적 가능
- **차이점**: "항상 허용"은 앱 완전 종료 후에도 추적 (불필요), "앱을 사용하는 동안"은 앱 실행 중 백그라운드만 추적 (우리 게임에 적합)

---

## 앱 생명주기 관리

### WidgetsBindingObserver 방식 (기본 Flutter)

**개념:**
- Flutter에서 제공하는 앱 생명주기 감지 Mixin
- AppLifecycleState 변화를 감지함: resumed, paused, inactive, detached

**동작 로직:**
1. 앱이 백그라운드로 전환되면 `paused` 상태가 됨
2. 앱이 다시 포그라운드로 오면 `resumed` 상태가 됨
3. 각 상태 전환 시 `didChangeAppLifecycleState()` 콜백이 호출됨

**한계:**
- 이 방식만으로는 백그라운드에서 GPS와 WebSocket을 유지할 수 없음
- 앱이 `paused` 상태가 되면 Dart 코드 실행이 멈춤
- 따라서 위치 스트림도 멈추고 WebSocket 연결도 끊김

**보완 방법:**
- WidgetsBindingObserver로 상태 변화를 감지하되
- 백그라운드 실행은 flutter_background_service로 처리
- 즉, **상태 감지 + 백그라운드 서비스**를 함께 사용

### Foreground Service 방식 (flutter_background_service)

**핵심 차이점:**
- WidgetsBindingObserver는 **감지만** 하지만
- Foreground Service는 **실제로 백그라운드에서 코드를 실행**함

**동작 원리:**
1. 메인 앱과 **완전히 독립된 Isolate**를 생성함
2. 이 Isolate는 앱 생명주기와 무관하게 계속 실행됨
3. 메인 앱이 paused 상태가 되어도 백그라운드 Isolate는 resumed 상태 유지
4. 따라서 GPS 스트림과 WebSocket 연결이 끊기지 않음

**Android Foreground Service 특성:**
- 사용자에게 알림을 표시하는 조건으로 높은 우선순위를 부여받음
- 시스템이 메모리 부족 시에도 마지막에 종료함
- 사용자가 알림을 통해 서비스가 실행 중임을 항상 인지함

**iOS Background Modes 특성:**
- 특정 작업(location, audio, VoIP 등)에 한해 백그라운드 실행 허용
- `location` 모드는 위치 기반 앱에 필수
- iOS가 더 제한적이지만 위치 추적 같은 정당한 이유가 있으면 허용

---

## 백엔드 API 통신 로직

### WebSocket 연결 관리

**초기 연결 시:**
1. 백그라운드 서비스 Isolate가 시작되면
2. STOMP 클라이언트가 WebSocket 서버에 연결 시도
3. 연결 성공 시 `onConnect` 콜백이 호출됨
4. 이때 GPS 위치 스트림을 시작함 (연결 성공 보장)

**위치 데이터 전송 로직:**
1. GPS가 새 위치 데이터를 발행함
2. 데이터를 JSON으로 직렬화함
3. STOMP `send()` 메서드로 서버 엔드포인트에 전송
4. destination: `/app/game/{gameId}/location`
5. body: JSON 문자열

**연결 끊김 처리:**
1. 네트워크가 끊기면 `onDisconnect` 콜백 호출
2. STOMP 클라이언트가 자동으로 재연결 시도 (기본 동작)
3. 재연결 성공 시 다시 `onConnect` 호출됨
4. GPS 스트림은 계속 실행 중이므로 즉시 전송 재개

**에러 처리 로직:**
- `onStompError`: STOMP 프로토콜 수준 에러 발생 시 로그 기록
- `onWebSocketError`: WebSocket 연결 수준 에러 발생 시 로그 기록
- 에러가 발생해도 재연결 로직이 계속 시도함

### 서버 브로드캐스트 흐름

**서버 측 처리:**
1. 클라이언트가 `/app/game/{gameId}/location`으로 위치 전송
2. 서버가 해당 게임 세션의 모든 플레이어 목록을 조회
3. 각 플레이어가 구독 중인 `/topic/game/{gameId}/location` 토픽으로 브로드캐스트
4. 모든 플레이어의 WebSocket이 동시에 해당 위치 업데이트를 수신

**클라이언트 수신 측:**
1. 메인 앱이 `/topic/game/{gameId}/location` 토픽을 구독함
2. 서버에서 브로드캐스트가 오면 구독 콜백이 호출됨
3. 수신한 위치 데이터를 파싱하여 지도에 마커 업데이트
4. 다른 플레이어의 위치가 실시간으로 화면에 반영됨

---

## 플랫폼별 동작 방식

### Android 플랫폼

**Foreground Service 생명주기:**
1. `startService()` 호출 시 시스템이 Service 생성
2. `setAsForegroundService()` 호출로 Foreground Service 승격
3. 알림이 자동으로 표시됨 (시스템 요구사항)
4. 서비스가 실행되는 동안 알림은 계속 유지됨
5. `stopSelf()` 호출 시 서비스와 알림이 함께 제거됨

**알림 업데이트 메커니즘:**
- 30초마다 타이머가 `setForegroundNotificationInfo()` 호출
- 알림 제목과 내용을 새로운 값으로 업데이트
- 사용자는 알림바에서 현재 시간이 계속 갱신되는 것을 확인 가능
- 이를 통해 서비스가 정지하지 않고 실행 중임을 시각적으로 확인

**메모리 관리:**
- Foreground Service는 높은 우선순위 (PROCESS_FOREGROUND)
- 시스템이 메모리 확보 시 가장 마지막에 종료함
- 사용자가 "최근 앱"에서 스와이프해도 서비스는 유지됨
- 단, 사용자가 "앱 정보 → 강제 중지"를 누르면 종료됨

### iOS 플랫폼

**Background Modes - Location:**
- Info.plist의 `UIBackgroundModes` 배열에 `location` 포함 시
- 앱이 백그라운드에서도 Core Location 프레임워크 사용 가능
- GPS 수신과 위치 업데이트가 백그라운드에서 계속됨

**상태바 표시 로직:**
- iOS 시스템이 자동으로 위치 추적 표시
- iOS 13 이하: 화면 최상단 상태바가 파란색 배경으로 변경
- iOS 14+: 상태바 우측에 위치 아이콘 표시
- 현재 프로젝트는 IOS 15+ 로만 됨. (PodFile : 참고)
- 사용자가 상태바를 탭하면 앱으로 복귀 (iOS 기본 동작)

**Background Task 제한:**
- iOS는 백그라운드 작업에 더 제한적
- 정당한 이유(위치 추적, 오디오 재생, VoIP 등)가 있어야 허용
- 위치 기반 게임은 정당한 이유로 인정됨
- "앱을 사용하는 동안" 권한으로 게임 진행 가능 (네이버지도 방식)
- **중요**: 앱이 실행 중(게임 진행 중)일 때는 백그라운드로 가도 추적 계속됨

**권한 요청 플로우:**
1. "앱을 사용하는 동안" 권한만 요청함
2. 이 권한만으로도 게임 중 백그라운드 위치 추적 가능 (네이버지도와 동일)
3. "항상 허용"은 앱이 완전히 종료된 후에도 추적할 때 필요 (우리 게임에서는 불필요)
4. Foreground Service 또는 Background Modes가 활성화되어 있으면 "앱을 사용하는 동안" 권한으로 충분함

---

## 앱 복귀 시 동작 로직

### 백그라운드 서비스 상태 확인

**복귀 시 시스템 동작:**
1. 사용자가 앱을 다시 열면 Flutter 앱의 메인 Isolate가 resumed 상태로 전환됨
2. 백그라운드 서비스 Isolate는 이미 계속 실행 중이었음
3. 두 Isolate는 독립적이므로 서로 영향 없음

**UI 갱신 로직:**
1. 메인 앱이 resumed 상태가 되면 WidgetsBindingObserver의 `didChangeAppLifecycleState()` 호출
2. 이때 현재 위치를 다시 조회하거나
3. WebSocket 구독을 통해 최신 위치 업데이트를 수신
4. 지도 카메라를 최신 위치로 이동 (animateCamera 또는 moveCamera)

**데이터 동기화 전략:**
- 백그라운드 서비스는 계속 위치를 전송했으므로 서버에는 최신 데이터 있음
- 앱 복귀 시 서버에서 최신 게임 상태를 fetch하거나
- WebSocket 구독이 이미 활성화되어 있으면 자동으로 업데이트 수신

### 카메라 추적 로직

**현재 문제:**
- GoogleMap 위젯의 `myLocationEnabled: true`는 파란 점만 표시
- 카메라는 자동으로 따라가지 않음 (기본 동작)

**해결 방법 로직:**
1. GPS 위치 스트림을 메인 앱에서도 구독함
2. 위치가 업데이트될 때마다 MapController의 `animateCamera()` 호출
3. CameraPosition을 새 위치로 설정하여 부드럽게 이동
4. 백그라운드에서 복귀 시에도 같은 로직 적용

**구현 로직 흐름:**
1. initState에서 위치 스트림 구독 시작
2. Stream.listen() 콜백에서 새 Position 수신
3. GoogleMapController.animateCamera() 호출
4. CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 17)
5. 지도가 부드럽게 현재 위치로 이동
6. dispose 시 스트림 구독 취소

---

## 에러 처리 및 재연결 로직

### WebSocket 연결 실패 처리

**연결 실패 시나리오:**
1. 네트워크가 끊김 (Wi-Fi → 모바일 데이터 전환 등)
2. 서버가 일시적으로 다운됨
3. 터널, 지하 등 신호 약한 지역 진입

**자동 재연결 메커니즘:**
1. STOMP 클라이언트가 기본적으로 재연결 로직을 포함함
2. `onDisconnect` 콜백이 호출되면 로그를 기록함
3. 클라이언트가 내부적으로 지수 백오프(exponential backoff)로 재연결 시도
4. 재연결 성공 시 `onConnect` 콜백이 다시 호출됨
5. GPS 스트림은 계속 실행 중이므로 즉시 전송 재개

**수동 재연결 로직 (옵션):**
1. 연결 실패가 일정 시간 이상 지속되면
2. 서비스를 완전히 중지하고 재시작하는 전략도 가능
3. `stopService()` 호출 → 1초 대기 → `startService()` 호출
4. 새로운 Isolate로 완전히 재생성되어 깨끗한 상태로 시작

### GPS 위치 수신 실패 처리

**위치 수신 불가 시나리오:**
1. 실내 깊숙한 곳에서 GPS 신호 약함
2. 사용자가 위치 권한을 취소함
3. 비행기 모드 활성화

**처리 로직:**
1. Geolocator의 `getPositionStream()`이 에러를 발행함
2. Stream의 `onError` 콜백에서 에러를 잡아냄
3. 로그에 에러를 기록하고 계속 스트림 유지
4. GPS 신호가 복구되면 자동으로 Position 발행 재개

**타임아웃 처리:**
- LocationSettings의 `timeLimit`으로 타임아웃 설정
- 지정 시간 내에 위치를 받지 못하면 TimeoutException 발생
- 이를 catch하여 재시도하거나 사용자에게 알림

### 배터리 절약 모드 대응

**Android 배터리 최적화:**
- Android 6.0+ (Marshmallow)부터 Doze 모드 도입
- Foreground Service는 Doze 모드에서도 예외 처리됨
- 따라서 백그라운드 서비스가 계속 실행됨

**iOS 저전력 모드:**
- 저전력 모드에서는 백그라운드 작업이 제한됨
- 위치 업데이트 빈도가 줄어들 수 있음
- 앱이 이를 감지하여 사용자에게 저전력 모드 해제 권장 가능

---

## 성능 최적화 로직

### 배터리 소모 최적화

**GPS 정확도 조정:**
- `LocationAccuracy.high`: 가장 정확하지만 배터리 소모 많음 (GPS + Wi-Fi + 셀룰러)
- `LocationAccuracy.medium`: 적당한 정확도, 배터리 절약 (Wi-Fi + 셀룰러 위주)
- `LocationAccuracy.low`: 낮은 정확도, 배터리 대폭 절약 (셀룰러 위주)

**거리 필터 활용:**
- `distanceFilter: 5`: 5m 이동 시마다 업데이트 (빈번한 업데이트)
- `distanceFilter: 10`: 10m 이동 시마다 업데이트 (적당한 빈도)
- `distanceFilter: 20`: 20m 이동 시마다 업데이트 (드문 업데이트, 배터리 절약)

**권장 설정 로직:**
1. 게임 시작 시에는 `high` 정확도로 시작
2. 배터리가 20% 이하로 떨어지면 자동으로 `medium`으로 전환
3. 사용자가 설정에서 "절전 모드" 활성화 시 `low`로 전환

### 네트워크 데이터 최적화

**전송 데이터 최소화:**
- 필수 필드만 전송: gameId, userId, latitude, longitude, timestamp
- 선택적 필드는 조건부 전송: accuracy는 10m 이상 차이날 때만
- JSON 압축 고려: gzip 압축으로 데이터 크기 50% 감소 가능

**전송 빈도 조정:**
- 이동 속도에 따라 동적 조정
- 정지 상태(속도 < 1m/s): 10초마다 전송
- 걷기(속도 1-2m/s): 5초마다 전송
- 뛰기(속도 > 2m/s): 3초마다 전송

### 메모리 사용량 최적화

**Isolate 메모리 관리:**
- 백그라운드 Isolate는 최소한의 데이터만 유지
- 위치 기록은 서버에서 관리하고 Isolate는 현재 위치만 보유
- 사용하지 않는 변수는 null로 설정하여 GC 유도

**스트림 리소스 관리:**
1. 게임 시작 시 스트림 구독 시작
2. 게임 종료 시 `subscription.cancel()` 호출하여 리소스 해제
3. WebSocket도 `deactivate()` 호출하여 연결 종료
4. 타이머도 `cancel()` 호출하여 정리

---

## 테스트 시나리오

### 1. 백그라운드 전환 테스트

**시나리오:**
1. 게임을 시작함 → 백그라운드 서비스가 초기화됨
2. 홈 버튼을 눌러 백그라운드로 전환 → 메인 앱이 paused 상태로 전환됨
3. 다른 앱(카톡, 크롬 등)을 실행함 → 메인 앱이 inactive 상태를 거쳐 paused 유지
4. 30초~1분 대기 → 백그라운드 서비스는 계속 GPS 수신 및 WebSocket 전송 중
5. 게임으로 복귀함 → 메인 앱이 resumed 상태로 전환됨
6. 지도 화면 확인 → 위치가 최신 상태로 갱신되어 있음 ✅

**검증 포인트:**
- Android: 알림이 계속 표시되고 있는지
- iOS: 상태바에 위치 추적 표시가 있는지
- 서버 로그에 위치 데이터가 계속 수신되고 있는지
- 다른 플레이어 화면에서 해당 플레이어가 움직이고 있는지

### 2. 전화 수신 테스트

**시나리오:**
1. 게임 중 다른 기기에서 전화를 걸어 수신함
2. 통화 앱이 foreground로 올라오고 게임 앱은 background로 전환됨
3. 통화하면서 걸어 다님 (위치 변경)
4. 통화 종료 후 게임으로 복귀함
5. 지도에서 이동한 경로가 정확히 반영되어 있는지 확인 ✅

**검증 포인트:**
- 통화 중에도 위치 전송이 계속되었는지 서버 로그 확인
- 다른 플레이어 화면에 실시간 이동이 표시되었는지 확인
- 복귀 시 카메라가 현재 위치로 이동했는지 확인

### 3. 화면 잠금 테스트

**시나리오:**
1. 게임 중 전원 버튼을 눌러 화면을 끔
2. 잠금 상태에서 이동함
3. 전원 버튼을 눌러 화면을 켜고 게임으로 복귀함
4. 이동한 거리만큼 위치가 업데이트되어 있는지 확인 ✅

**검증 포인트:**
- 화면 잠금 중에도 GPS가 계속 작동했는지
- WebSocket 연결이 유지되었는지
- 배터리 소모가 예상 범위 내인지 (2-3% 정도)

### 4. 장시간 백그라운드 테스트

**시나리오:**
1. 게임 시작
2. 백그라운드 전환 후 5분 동안 방치
3. 게임 복귀
4. 서버 로그에서 5분 동안 위치 데이터가 계속 전송되었는지 확인 ✅

**검증 포인트:**
- 장시간 백그라운드에서도 서비스가 종료되지 않았는지
- 메모리 누수가 없는지 (메모리 프로파일링)
- 연결이 끊기고 재연결되었는지 로그 확인

### 5. 네트워크 전환 테스트

**시나리오:**
1. Wi-Fi에서 게임 시작
2. Wi-Fi를 끄고 모바일 데이터로 전환
3. WebSocket이 자동으로 재연결되는지 확인 ✅

**검증 포인트:**
- `onDisconnect` → `onConnect` 로그가 순서대로 찍히는지
- 재연결 후 위치 전송이 즉시 재개되는지
- 사용자가 끊김 없이 게임을 계속할 수 있는지

---

## 보안 고려사항

### 위치 데이터 보호

**전송 암호화:**
- WebSocket 연결 시 `wss://` 프로토콜 사용 (WebSocket Secure)
- TLS/SSL로 전송 구간 암호화되어 중간자 공격 방지
- 서버 인증서 검증으로 위장 서버 접속 차단

**인증 및 권한 검증:**
- WebSocket 연결 시 JWT 토큰 또는 세션 ID 전송
- 서버가 각 위치 데이터 전송마다 사용자 권한 검증
- 해당 게임에 참여한 사용자만 위치 전송 가능

### 사용자 프라이버시

**명확한 동의 획득:**
1. 게임 시작 전 백그라운드 위치 추적에 대한 설명 다이얼로그 표시
2. 배터리 소모 가능성 안내
3. 위치 데이터 사용 목적(게임 진행) 명시
4. 사용자가 "동의 및 시작" 버튼을 눌러야 게임 시작

**데이터 보관 정책:**
- 위치 데이터는 게임 진행 중에만 서버에 전송됨
- 게임 종료 후 일정 시간(예: 24시간) 경과 시 자동 삭제
- 사용자가 게임 기록 삭제 요청 시 즉시 삭제

**투명성 제공:**
- 설정 화면에서 현재 백그라운드 서비스 실행 여부 표시
- 위치 전송 통계 제공 (오늘 전송된 위치 데이터 수 등)
- 언제든지 게임 중단하여 위치 추적 중지 가능

---

## 자주 묻는 질문 (FAQ)

### Q1: 백그라운드에서 얼마나 오래 실행될 수 있나요?

**A:** Foreground Service(Android) 또는 Background Modes(iOS)를 사용하면 이론적으로 무제한 실행 가능합니다. 하지만 다음 요소를 고려해야 합니다:

- **배터리 소모**: 30분 게임 기준 약 8-12% 소모 예상
- **사용자 경험**: 장시간 실행 시 사용자가 불편함을 느낄 수 있음
- **플랫폼 제한**: iOS는 백그라운드 작업에 더 제한적일 수 있음

권장 사항은 게임 시간(30분)에 맞춰 서비스를 자동 종료하는 것입니다.

### Q2: 사용자가 강제로 서비스를 종료할 수 있나요?

**A:** 플랫폼에 따라 다릅니다:

**Android:**
- 알림을 통해 앱으로 복귀하여 정상적으로 게임 종료 가능
- "앱 정보 → 강제 중지" 메뉴로 완전 종료 가능
- "최근 앱"에서 스와이프해도 Foreground Service는 계속 실행됨

**iOS:**
- 앱 스위처에서 스와이프로 강제 종료 시 백그라운드 작업도 중단됨
- iOS는 사용자가 명시적으로 앱을 종료하면 백그라운드 권한도 박탈함

### Q3: 비행기 모드에서는 어떻게 되나요?

**A:** 비행기 모드 활성화 시:

1. **GPS는 계속 작동함**: GPS는 수신 전용이므로 비행기 모드에서도 사용 가능
2. **네트워크 연결이 끊김**: WebSocket 연결이 해제됨
3. **위치 전송 실패**: 서버로 전송할 수 없으므로 로컬에 임시 저장되거나 드랍됨
4. **비행기 모드 해제 시**: WebSocket이 자동 재연결되고 위치 전송 재개

실시간 멀티플레이어 게임이므로 네트워크 연결이 필수적입니다. 비행기 모드에서는 사실상 게임 진행이 불가능합니다.

### Q4: 다른 위치 기반 앱(배민, 카카오T)과 동시에 사용할 수 있나요?

**A:** 가능합니다.

- 각 앱은 독립적인 Foreground Service를 실행함
- GPS는 공유 리소스이므로 여러 앱이 동시에 사용 가능
- 단, 배터리 소모는 증가함 (GPS 정확도가 높을수록)
- Android는 여러 Foreground Service를 동시에 표시할 수 있음 (알림 여러 개)

권장 사항은 게임 진행 중에는 다른 위치 기반 앱 사용을 최소화하는 것입니다.

### Q5: 배터리 소모를 줄이려면 어떻게 해야 하나요?

**A:** 다음 설정 조정을 고려하세요:

1. **GPS 정확도 낮추기**: `high` → `medium` (정확도 약간 감소, 배터리 30% 절약)
2. **거리 필터 늘리기**: `5m` → `10m` (업데이트 빈도 감소)
3. **시간 제한 늘리기**: `5초` → `10초` (업데이트 간격 증가)
4. **게임 종료 즉시**: 사용하지 않을 때는 바로 게임을 종료하여 서비스 중지

예상 배터리 소모 비교:
- 현재 설정 (high, 5m, 5초): 30분에 8-12%
- 최적화 설정 (medium, 10m, 10초): 30분에 5-8%

### Q6: iOS에서 "항상 허용" 권한이 필수인가요?

**A:** 아니요, **"앱을 사용하는 동안"만으로도 충분합니다.**

**권한 차이:**
- **"앱을 사용하는 동안" (While Using)**: 앱이 실행 중일 때 + 백그라운드 전환 시에도 추적 가능 (우리 게임에 적합 ✅)
- **"항상 허용" (Always)**: 앱이 완전히 종료된 후에도 추적 가능 (불필요 ❌)

**실제 동작:**
1. 게임 시작 → "앱을 사용하는 동안" 권한으로 위치 추적 시작
2. 전화/카톡으로 백그라운드 전환 → 계속 추적됨 (Foreground Service 덕분)
3. 게임 종료 → 추적 중단 (당연함)

네이버지도, 카카오맵 등도 "앱을 사용하는 동안" 권한만 사용합니다. "항상 허용"은 배달앱(배달의민족)처럼 앱 종료 후에도 추적이 필요한 경우에만 필요합니다. -> 근데 쿠팡이츠는 "항상 허용" 없음

---

## 참고 자료

- [Flutter Background Service 패키지](https://pub.dev/packages/flutter_background_service)
- [Android Foreground Services 공식 문서](https://developer.android.com/develop/background-work/services/foreground-services)
- [iOS Background Execution 공식 문서](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background)
- [Geolocator 패키지](https://pub.dev/packages/geolocator)
- [STOMP Dart Client](https://pub.dev/packages/stomp_dart_client)

---

**작성일**: 2026-01-21
**작성자**: @EM-H20
**문서 버전**: 2.0.0 (로직 중심 개편)
