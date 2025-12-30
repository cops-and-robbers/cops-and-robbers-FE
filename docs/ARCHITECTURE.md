# 경찰과 도둑 - 아키텍처 문서 (Architecture Documentation)

> **작성일**: 2025-12-30
> **대상 독자**: 개발자, 아키텍트
> **문서 버전**: 1.0.0

---

## 📋 목차 (Table of Contents)

1. [개요](#개요)
2. [아키텍처 전략](#아키텍처-전략)
3. [기술 스택](#기술-스택)
4. [계층 구조](#계층-구조)
5. [핵심 설계 결정](#핵심-설계-결정)
6. [데이터 흐름](#데이터-흐름)
7. [실시간 통신 아키텍처](#실시간-통신-아키텍처)
8. [참고 자료](#참고-자료)

---

## 개요

'경찰과 도둑' 앱은 **위치 기반 실시간 멀티플레이어 게임**을 지원하는 Flutter 모바일 애플리케이션입니다.

### 핵심 목표
- ✅ **실시간 위치 동기화**: 30명 동시 참가자의 GPS 위치를 3~5초마다 추적
- ✅ **즉각적인 게임 이벤트**: WebSocket 기반 양방향 실시간 통신
- ✅ **확장 가능한 아키텍처**: 새로운 기능 추가 시 기존 코드 영향 최소화
- ✅ **테스트 용이성**: 비즈니스 로직과 UI의 명확한 분리

### 아키텍처 철학
```
"기능별로 나누고, 계층별로 분리한다"
(Feature-First organization + Clean Architecture layers)
```

---

## 아키텍처 전략

### Feature-First + Clean Architecture Hybrid

#### 선택 이유
| 요구사항 | Feature-First | Clean Architecture |
|---------|---------------|-------------------|
| 기능별 병렬 개발 | ✅ 독립적인 feature 폴더 | - |
| 코드 탐색 편의성 | ✅ 관련 파일 한 곳에 집중 | - |
| 테스트 용이성 | - | ✅ 도메인 로직 격리 |
| 의존성 역전 | - | ✅ 인터페이스 기반 설계 |
| 확장성 | ✅ 새 feature 추가 용이 | ✅ 레이어 교체 가능 |

#### 대안 아키텍처 (Layer-First) 배제 이유
❌ **Layer-First** (`lib/data/`, `lib/domain/`, `lib/presentation/`)
- 하나의 기능 수정 시 3개 폴더 탐색 필요
- 코드 리뷰 시 관련 파일들이 분산됨
- 기능 단위 재사용 어려움

---

## 기술 스택

### 핵심 프레임워크
```yaml
flutter: 3.9.2+
dart: 3.9.2+
```

### 상태 관리 (State Management)
```yaml
flutter_riverpod: ^2.6.1         # 선언적 상태 관리
riverpod_annotation: ^2.6.1       # 코드 생성 기반 Provider
riverpod_generator: ^2.6.2        # @riverpod 어노테이션 처리
```

**선택 이유**:
- ✅ **컴파일 타임 안전성**: 런타임 에러 방지
- ✅ **코드 생성**: 보일러플레이트 최소화
- ✅ **테스트 친화적**: Provider Override 지원

### 불변 데이터 모델 (Immutable Data Models)
```yaml
freezed: ^2.5.7                  # 불변 클래스 생성
freezed_annotation: ^2.4.4
json_serializable: ^6.9.2        # JSON 직렬화
json_annotation: ^4.9.0
```

**패턴**:
```dart
@freezed
class GameSession with _$GameSession {
  const factory GameSession({
    required String id,
    required String hostId,
    required GameConfig config,
  }) = _GameSession;

  factory GameSession.fromJson(Map<String, dynamic> json)
      => _$GameSessionFromJson(json);
}
```

### 네트워킹 (Networking)
```yaml
dio: ^5.9.0                      # HTTP 클라이언트
retrofit: ^4.7.2                 # REST API 인터페이스 생성
retrofit_generator: ^9.1.8       # Retrofit 코드 생성
```

**구조**:
```dart
@RestApi(baseUrl: "https://api.example.com")
abstract class GameApi {
  factory GameApi(Dio dio) = _GameApi;

  @POST("/sessions")
  Future<GameSession> createSession(@Body CreateSessionRequest request);
}
```

### 실시간 통신 (Real-time Communication)
```yaml
# WebSocket (STOMP over SockJS)
stomp_dart_client: ^2.0.0        # STOMP 프로토콜 지원
web_socket_channel: ^3.0.0       # WebSocket 채널 관리
```

### 위치 서비스 (Location Services)
```yaml
geolocator: ^12.0.0              # GPS 위치 추적
google_maps_flutter: ^2.5.0      # 지도 표시
```

### 로컬 저장소 (Local Storage)
```yaml
flutter_secure_storage: ^9.2.4   # 민감 데이터 (JWT 토큰)
shared_preferences: ^2.3.4       # 앱 설정
```

### 알림 (Notifications)
```yaml
firebase_core: ^4.1.0
firebase_messaging: ^16.0.1      # FCM 푸시 알림
flutter_local_notifications: ^19.4.2  # 로컬 알림
```

### UI/UX
```yaml
flutter_screenutil: ^5.9.3       # 반응형 디자인 (375x812 기준)
smooth_page_indicator: ^1.2.1    # 온보딩 인디케이터
showcaseview: ^5.0.1             # 튜토리얼 오버레이
```

---

## 계층 구조

### 1. Core 레이어 (공통 인프라)

```
lib/core/
├── constants/      # 앱 전역 상수
├── network/        # 네트워크 인프라 (Dio, WebSocket)
├── services/       # 범용 서비스 (FCM, Device, Storage)
├── utils/          # 유틸리티 함수 및 Extension
├── errors/         # 에러 정의 (Exception, Failure)
└── widgets/        # 공통 UI 위젯
```

**역할**: 모든 feature에서 재사용 가능한 범용 코드

**예시**:
- `constants/api_endpoints.dart` → 모든 API URL 중앙 관리
- `network/dio_client.dart` → Dio 인스턴스 전역 설정
- `services/storage/secure_storage_service.dart` → JWT 토큰 안전 저장
- `widgets/app_button.dart` → 앱 전체에서 사용하는 버튼 스타일

---

### 2. Features 레이어 (기능 모듈)

각 feature는 **Clean Architecture 3계층**으로 구성:

```
features/[feature_name]/
├── data/           # 데이터 레이어
│   ├── models/     # API 응답 DTO (freezed)
│   ├── datasources/  # 데이터 소스 (Remote/Local)
│   └── repositories/ # Repository 구현체
├── domain/         # 도메인 레이어
│   ├── entities/   # 비즈니스 엔티티
│   ├── repositories/ # Repository 인터페이스
│   └── usecases/   # 비즈니스 로직
└── presentation/   # UI 레이어
    ├── providers/  # Riverpod Provider
    ├── pages/      # 화면 (Scaffold)
    └── widgets/    # 기능 특화 위젯
```

#### 계층별 역할 및 의존성 규칙

##### 📦 Data 레이어 (외부 세계와의 통신)
**역할**:
- REST API 호출 (Retrofit)
- WebSocket 실시간 통신 (STOMP)
- 로컬 데이터베이스/캐시 (SharedPreferences, SecureStorage)
- JSON 직렬화/역직렬화

**의존성**: `domain` ← `data`
```dart
// ❌ 잘못된 예시: domain이 data에 의존
// domain/entities/session_entity.dart
import 'package:cops_and_robbers/features/session/data/models/session_model.dart'; // 금지!

// ✅ 올바른 예시: data가 domain에 의존
// data/repositories/session_repository_impl.dart
import 'package:cops_and_robbers/features/session/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remoteDataSource;
  // ...
}
```

##### 🧠 Domain 레이어 (비즈니스 로직)
**역할**:
- 순수 비즈니스 규칙 (외부 의존성 없음)
- Repository 인터페이스 정의 (추상화)
- Use Case 패턴 (단일 책임 비즈니스 로직)

**의존성**: **없음** (완전히 독립적)
```dart
/// ✅ 외부 프레임워크 의존성 없는 순수 엔티티
class SessionEntity {
  final String id;
  final int maxPlayers;
  final Duration roundTime;

  const SessionEntity({
    required this.id,
    required this.maxPlayers,
    required this.roundTime,
  });

  /// 비즈니스 규칙: 최대 인원 초과 검증
  bool isFullCapacity(int currentPlayers) {
    return currentPlayers >= maxPlayers;
  }
}
```

##### 🎨 Presentation 레이어 (UI)
**역할**:
- 화면 렌더링 (Widget)
- 사용자 입력 처리
- 상태 관리 (Riverpod Provider)
- UI 로직 (유효성 검증, 포맷팅)

**의존성**: `presentation` → `domain` (Use Case 호출)
```dart
@riverpod
class SessionNotifier extends _$SessionNotifier {
  @override
  FutureOr<GameSession?> build() => null;

  Future<void> createSession(CreateSessionRequest request) async {
    state = const AsyncValue.loading();

    // ✅ domain의 Use Case 호출
    final usecase = ref.read(createSessionUsecaseProvider);
    final result = await usecase.execute(request);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (session) => AsyncValue.data(session),
    );
  }
}
```

---

### 의존성 흐름 요약

```
presentation (UI)
    ↓ (uses)
domain (Business Logic)
    ↑ (implements)
data (External Communication)
```

**핵심 원칙**:
1. ✅ presentation → domain (Use Case 호출)
2. ✅ data → domain (Repository 인터페이스 구현)
3. ❌ domain → data (절대 금지!)
4. ❌ domain → presentation (절대 금지!)

---

## 핵심 설계 결정

### 1. Riverpod 코드 생성 패턴

**Before (수동 작성)**:
```dart
final sessionProvider = StateNotifierProvider<SessionNotifier, AsyncValue<GameSession?>>((ref) {
  return SessionNotifier(ref.watch(createSessionUsecaseProvider));
});
```

**After (코드 생성)**:
```dart
@riverpod
class SessionNotifier extends _$SessionNotifier {
  @override
  FutureOr<GameSession?> build() => null;
  // Provider 자동 생성: sessionNotifierProvider
}
```

**장점**:
- ✅ 타입 안전성 보장
- ✅ 보일러플레이트 80% 감소
- ✅ 자동 의존성 주입

---

### 2. Freezed 불변 데이터 클래스

**패턴**:
```dart
@freezed
class GameSession with _$GameSession {
  const factory GameSession({
    required String id,
    required String hostId,
    required GameConfig config,
    required List<Participant> participants,
  }) = _GameSession;

  factory GameSession.fromJson(Map<String, dynamic> json)
      => _$GameSessionFromJson(json);
}
```

**자동 생성 기능**:
- ✅ `copyWith()` 메서드
- ✅ `==` / `hashCode` 오버라이드
- ✅ `toString()` 디버깅 지원
- ✅ JSON 직렬화/역직렬화

---

### 3. Either 패턴 (에러 처리)

**dartz 패키지 사용**:
```dart
import 'package:dartz/dartz.dart';

abstract class SessionRepository {
  Future<Either<Failure, GameSession>> createSession(CreateSessionRequest request);
}

// 사용 예시
final result = await repository.createSession(request);
result.fold(
  (failure) => print('에러: ${failure.message}'),
  (session) => print('성공: ${session.id}'),
);
```

**장점**:
- ✅ 명시적 에러 처리 (try-catch 대비)
- ✅ 컴파일 타임 안전성
- ✅ 함수형 프로그래밍 패턴

---

### 4. WebSocket 연결 관리

**구조**:
```dart
// core/network/websocket/websocket_client.dart
class WebSocketClient {
  late StompClient _stompClient;

  void connect(String url, {required VoidCallback onConnect}) {
    _stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: onConnect,
        onWebSocketError: _handleError,
        reconnectDelay: const Duration(seconds: 5),
      ),
    );
    _stompClient.activate();
  }

  void subscribe(String destination, void Function(StompFrame) callback) {
    _stompClient.subscribe(
      destination: destination,
      callback: callback,
    );
  }
}
```

**사용 예시**:
```dart
// features/chat/data/datasources/chat_websocket_datasource.dart
class ChatWebSocketDataSource {
  final WebSocketClient _client;

  void subscribeToTeamChat(String gameId, Team team, Function(ChatMessage) onMessage) {
    _client.subscribe(
      '/topic/chat/game/$gameId/team/${team.name}',
      (frame) {
        final message = ChatMessage.fromJson(jsonDecode(frame.body!));
        onMessage(message);
      },
    );
  }
}
```

---

## 데이터 흐름

### 일반적인 API 호출 흐름

```
[User Tap Button]
    ↓
[Widget] → onPressed()
    ↓
[Provider] → sessionNotifier.createSession()
    ↓
[Use Case] → CreateSessionUseCase.execute()
    ↓
[Repository Interface] → SessionRepository.createSession()
    ↓
[Repository Impl] → SessionRepositoryImpl.createSession()
    ↓
[Data Source] → SessionRemoteDataSource.createSession()
    ↓
[Retrofit API] → @POST("/sessions")
    ↓
[Server] → Response
    ↓
[Data Source] → JSON parsing
    ↓
[Repository Impl] → Entity 변환
    ↓
[Use Case] → Either<Failure, Entity> 반환
    ↓
[Provider] → state 업데이트
    ↓
[Widget] → UI rebuild
```

### 실시간 WebSocket 흐름

```
[Server Event]
    ↓
[WebSocket Client] → onMessage
    ↓
[WebSocket DataSource] → JSON parsing
    ↓
[Stream Controller] → add(event)
    ↓
[StreamProvider] → listen
    ↓
[Widget] → ref.watch(streamProvider)
    ↓
[UI Update]
```

---

## 실시간 통신 아키텍처

### 1. 위치 추적 (Location Tracking)

**주기**: 3~5초마다 GPS 위치 전송

```dart
// features/map/data/datasources/location_stream_datasource.dart
class LocationStreamDataSource {
  Stream<LocationData> watchLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10m 이동 시에만 업데이트
      ),
    ).map((position) => LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
    ));
  }
}
```

**서버 전송**:
```dart
// features/map/presentation/providers/location_provider.dart
@riverpod
class LocationTracker extends _$LocationTracker {
  Timer? _uploadTimer;

  @override
  FutureOr<void> build() {
    // 3초마다 서버로 위치 전송
    _uploadTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final location = await ref.read(currentLocationProvider.future);
      await ref.read(uploadLocationUsecaseProvider).execute(location);
    });
  }

  @override
  void dispose() {
    _uploadTimer?.cancel();
    super.dispose();
  }
}
```

---

### 2. 게임 이벤트 알림 (Game Events)

**서버 → 클라이언트 PUSH**:
```dart
// features/notification/data/datasources/notification_websocket_datasource.dart
class NotificationWebSocketDataSource {
  final WebSocketClient _client;
  final StreamController<GameEvent> _eventController = StreamController.broadcast();

  Stream<GameEvent> get eventStream => _eventController.stream;

  void subscribeToGameEvents(String gameId) {
    _client.subscribe(
      '/topic/game/$gameId/events',
      (frame) {
        final event = GameEvent.fromJson(jsonDecode(frame.body!));
        _eventController.add(event);
      },
    );
  }
}
```

**UI 반영**:
```dart
// features/game/presentation/widgets/game_event_listener.dart
class GameEventListener extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(gameEventStreamProvider, (previous, next) {
      next.whenData((event) {
        switch (event.type) {
          case GameEventType.playerCaptured:
            _showBannerNotification('도둑 ${event.playerName}이(가) 체포되었습니다!');
            break;
          case GameEventType.locationRevealed:
            _showBannerNotification('도둑들의 위치가 공개되었습니다!');
            break;
          // ...
        }
      });
    });

    return const SizedBox.shrink();
  }
}
```

---

### 3. 팀 채팅 (Team Chat)

**양방향 통신**:
```dart
// features/chat/data/datasources/chat_websocket_datasource.dart
class ChatWebSocketDataSource {
  final WebSocketClient _client;

  // 메시지 전송 (Client → Server)
  void sendMessage(String gameId, Team team, String message) {
    _client.send(
      destination: '/app/chat/$gameId/team/${team.name}',
      body: jsonEncode({
        'senderId': userId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  // 메시지 수신 (Server → Client)
  Stream<ChatMessage> watchMessages(String gameId, Team team) {
    final controller = StreamController<ChatMessage>.broadcast();

    _client.subscribe(
      '/topic/chat/game/$gameId/team/${team.name}',
      (frame) {
        final message = ChatMessage.fromJson(jsonDecode(frame.body!));
        controller.add(message);
      },
    );

    return controller.stream;
  }
}
```

---

## 참고 자료

### Flutter 아키텍처
- [Riverpod Architecture Guide](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Feature-First vs Layer-First](https://codewithandrea.com/articles/flutter-project-structure/)

### 상태 관리
- [Riverpod Official Documentation](https://riverpod.dev/docs/introduction/getting_started)
- [Riverpod Code Generation](https://riverpod.dev/docs/concepts/about_code_generation)

### 실시간 통신
- [STOMP Dart Client](https://pub.dev/packages/stomp_dart_client)
- [WebSocket in Flutter](https://docs.flutter.dev/cookbook/networking/web-sockets)

### 디자인 패턴
- [Either Pattern in Dart (dartz)](https://pub.dev/packages/dartz)
- [Repository Pattern](https://medium.com/@jun.chenying/flutter-repository-pattern-5dc3d8dd0fa6)

---

**문서 작성**: Development Team
**최종 업데이트**: 2025-12-30
**다음 리뷰 예정일**: 2026-01-30
