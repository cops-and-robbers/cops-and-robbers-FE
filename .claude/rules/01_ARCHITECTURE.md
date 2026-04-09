# 경찰과 도둑 - 아키텍처 문서 (Architecture Documentation)

> **작성일**: 2025-12-30
> **대상 독자**: 개발자, 아키텍트
> **문서 버전**: 1.0.0

---

## 📋 목차 (Table of Contents)

1. [개요](#개요)
2. [아키텍처 전략](#아키텍처-전략)
3. [기술 스택](#기술-스택)
   - 3.1 [핵심 프레임워크](#핵심-프레임워크)
   - 3.2 [상태 관리](#상태-관리-state-management)
   - 3.3 [불변 데이터 모델](#불변-데이터-모델-immutable-data-models)
   - 3.4 [네트워킹](#네트워킹-networking)
   - 3.5 [실시간 통신](#실시간-통신-real-time-communication)
   - 3.6 [위치 서비스](#위치-서비스-location-services)
   - 3.7 [로컬 저장소](#로컬-저장소-local-storage)
   - 3.8 [알림](#알림-notifications)
   - 3.9 [UI/UX](#uiux)
4. [계층 구조](#계층-구조)
   - 4.1 [Core 레이어](#1-core-레이어-공통-인프라)
   - 4.2 [Features 레이어](#2-features-레이어-기능-모듈)
   - 4.3 [의존성 흐름](#의존성-흐름-요약)
5. [핵심 설계 결정](#핵심-설계-결정)
   - 5.1 [Riverpod 코드 생성](#1-riverpod-코드-생성-패턴)
   - 5.2 [Freezed 불변 데이터](#2-freezed-불변-데이터-클래스)
   - 5.3 [에러 처리 패턴](#3-에러-처리-패턴-try-catch)
   - 5.4 [실시간 통신 레이어](#4-실시간-통신-레이어-corerealtime)
   - 5.5 [로깅 시스템](#5-로깅-시스템-corelogging)
6. [Google 로그인 아키텍처](#google-로그인-아키텍처)
7. [데이터 흐름](#데이터-흐름)
8. [실시간 통신 아키텍처](#실시간-통신-아키텍처)
9. [참고 자료](#참고-자료)

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
├── realtime/       # 실시간 통신 (WebSocket, STOMP)
├── logging/        # 로깅 시스템 (Logger, 에러 리포팅)
├── services/       # 범용 서비스 (FCM, Device, Storage)
├── utils/          # 유틸리티 함수 및 Extension
├── errors/         # 에러 정의 (Exception, Failure)
└── widgets/        # 공통 UI 위젯
```

**역할**: 모든 feature에서 재사용 가능한 범용 코드

**예시**:
- `constants/api_endpoints.dart` → 모든 API URL 중앙 관리
- `network/dio_client.dart` → Dio 인스턴스 전역 설정
- `realtime/websocket_client.dart` → WebSocket 연결 관리 및 재연결 로직
- `realtime/stomp_client.dart` → STOMP 프로토콜 구현 (게임 이벤트, 채팅, 위치 동기화)
- `logging/logger.dart` → 통합 로깅 시스템 (Debug, Info, Warning, Error)
- `logging/error_reporter.dart` → 에러 리포팅 (Crashlytics, Sentry 등)
- `services/storage/secure_storage_service.dart` → JWT 토큰 안전 저장
- `widgets/app_button.dart` → 앱 전체에서 사용하는 버튼 스타일

---

### 2. Features 레이어 (기능 모듈)

**프로젝트 Feature 목록**:
```
features/
├── auth/           # Google 로그인 및 인증
├── session/        # F1: 게임 세션 관리
├── game/           # F2+F3: 지도, 위치 추적, 게임 로직 (통합)
├── chat/           # F4: 팀별 채팅
└── notification/   # F4: 알림 시스템
```

**참고**: `features/map/` 폴더는 `features/game/`로 통합되었습니다. 게임 로직과 지도/위치 기능이 밀접하게 연관되어 있어 하나의 feature로 관리합니다.

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

    try {
      // ✅ domain의 Use Case 호출
      final usecase = ref.read(createSessionUsecaseProvider);
      final session = await usecase.execute(request);
      state = AsyncValue.data(session);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
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

### 3. 에러 처리 패턴 (try-catch)

**프로젝트 표준**: Dart 네이티브 try-catch 패턴 사용

**변경 이력**:
- **이전**: Either<Failure, Success> 패턴 (dartz 패키지)
- **현재**: try-catch + Custom Exception
- **변경일**: 2025-12-30

**변경 이유**:
1. ✅ **학습 곡선 감소**: Dart 네이티브 에러 처리로 신규 개발자 진입 장벽 낮춤
2. ✅ **번들 사이즈 감소**: dartz 패키지 제거 (~150KB)
3. ✅ **직관적인 비동기 코드**: async/await와 자연스러운 통합
4. ✅ **Riverpod AsyncValue 통합**: AsyncValue.error()와 자연스러운 연동

**패턴**:
```dart
// Repository Layer
Future<SessionEntity> createSession(CreateSessionRequest request) async {
  try {
    final session = await _api.createSession(request);
    return SessionEntity.fromModel(session);
  } on DioException catch (e) {
    if (e.response?.statusCode == 400) {
      throw ValidationException('잘못된 요청입니다');
    }
    throw NetworkException('네트워크 연결을 확인하세요');
  }
}

// Use Case Layer
Future<SessionEntity> execute(CreateSessionRequest request) async {
  // 비즈니스 로직 검증
  if (request.roundTime < minTime) {
    throw ValidationException('라운드 시간이 너무 짧습니다');
  }

  // Repository 호출 (Exception 전파)
  return await _repository.createSession(request);
}

// Presentation Layer (Riverpod)
Future<void> createSession(CreateSessionRequest request) async {
  state = const AsyncValue.loading();

  try {
    final usecase = ref.read(createSessionUsecaseProvider);
    final session = await usecase.execute(request);
    state = AsyncValue.data(session);
  } catch (e, stack) {
    state = AsyncValue.error(e, stack);
  }
}
```

**Custom Exception 체계**:
```dart
// lib/core/errors/exceptions.dart
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}

class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException(this.message, {this.code});
}

class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}
```

**제거된 의존성**:
- **dartz**: Either<Failure, Success> 함수형 에러 처리 (제거됨)

**참고 문서**: [CODE_CONVENTIONS.md - 에러 처리](./CODE_CONVENTIONS.md#에러-처리)

---

### 4. 실시간 통신 레이어 (core/realtime/)

**패키지 의존성**:
```yaml
dependencies:
  stomp_dart_client: ^2.0.0        # STOMP 프로토콜 지원
  web_socket_channel: ^3.0.0       # WebSocket 채널 관리
```

#### WebSocket Client (core/realtime/websocket_client.dart)

**역할**:
- WebSocket 연결 생애주기 관리 (연결, 재연결, 종료)
- 자동 재연결 로직 (네트워크 끊김 시)
- 연결 상태 모니터링

**구조**:
```dart
// core/realtime/websocket_client.dart
class WebSocketClient {
  late StompClient _stompClient;
  final StreamController<ConnectionState> _connectionStateController =
      StreamController.broadcast();

  Stream<ConnectionState> get connectionState => _connectionStateController.stream;

  void connect(String url, {required VoidCallback onConnect}) {
    _stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: (frame) {
          _connectionStateController.add(ConnectionState.connected);
          onConnect();
        },
        onDisconnect: (frame) {
          _connectionStateController.add(ConnectionState.disconnected);
        },
        onWebSocketError: _handleError,
        reconnectDelay: const Duration(seconds: 5),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
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

  void send({required String destination, required String body}) {
    _stompClient.send(destination: destination, body: body);
  }

  void disconnect() {
    _stompClient.deactivate();
    _connectionStateController.add(ConnectionState.disconnected);
  }
}
```

#### STOMP Client Wrapper (core/realtime/stomp_manager.dart)

**역할**:
- STOMP 프로토콜 추상화
- 구독 관리 (여러 채널 동시 구독)
- 메시지 발행/구독 인터페이스

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

  void sendMessage(String gameId, Team team, ChatMessage message) {
    _client.send(
      destination: '/app/chat/$gameId/team/${team.name}',
      body: jsonEncode(message.toJson()),
    );
  }
}
```

---

### 5. 로깅 시스템 (core/logging/)

**패키지 의존성**:
```yaml
dependencies:
  logger: ^2.5.0                  # 구조화된 로깅

dev_dependencies:
  # 프로덕션 에러 리포팅 (선택사항)
  # sentry_flutter: ^8.0.0        # Sentry 에러 추적
  # firebase_crashlytics: ^4.0.0  # Firebase Crashlytics
```

#### Logger (core/logging/logger.dart)

**역할**:
- 통합 로깅 인터페이스
- 로그 레벨 관리 (Debug, Info, Warning, Error)
- 개발 환경별 로그 설정 (개발/프로덕션)

**구조**:
```dart
// core/logging/logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
```

#### Error Reporter (core/logging/error_reporter.dart)

**역할**:
- 프로덕션 에러 추적
- 사용자 정보 첨부 (익명화)
- 에러 심각도 분류

**구조**:
```dart
// core/logging/error_reporter.dart
class ErrorReporter {
  static Future<void> initialize() async {
    // Sentry, Crashlytics 등 초기화
    // 개발 환경에서는 비활성화
    if (kReleaseMode) {
      // await SentryFlutter.init(...);
    }
  }

  static Future<void> reportError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalInfo,
  }) async {
    // 1. 로컬 로그 기록
    AppLogger.error('Error in $context', error, stackTrace);

    // 2. 프로덕션 환경에서만 원격 리포팅
    if (kReleaseMode) {
      // await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }
}
```

**사용 예시**:
```dart
// features/session/data/repositories/session_repository_impl.dart
@override
Future<SessionEntity> createSession(CreateSessionRequest request) async {
  try {
    final session = await _api.createSession(request);
    AppLogger.info('Session created successfully: ${session.id}');
    return SessionEntity.fromModel(session);
  } on DioException catch (e, stack) {
    AppLogger.error('Failed to create session', e, stack);
    await ErrorReporter.reportError(
      e,
      stack,
      context: 'SessionRepository.createSession',
      additionalInfo: {'requestData': request.toJson()},
    );
    throw NetworkException('네트워크 연결을 확인하세요');
  }
}
```

---

## Google 로그인 아키텍처

### 인증 플로우 (Authentication Flow)

```
[User Tap Google Login Button]
    ↓
[LoginPage Widget] → onPressed()
    ↓
[AuthNotifier Provider] → signInWithGoogle()
    ↓
[GoogleSignInUseCase] → execute()
    ↓
[AuthRepository] → signInWithGoogle()
    ↓
[SocialAuthDataSource] → signInWithGoogle()
    ↓
[Google Sign-In SDK] → GoogleSignIn().signIn()
    ↓
[Google OAuth] → User Authentication
    ↓
[ID Token (JWT)] ← Google Returns
    ↓
[AuthRemoteDataSource] → POST /auth/google { idToken }
    ↓
[Backend Server] → Verify Token with Google
    ↓
[JWT Access/Refresh Token] ← Server Returns
    ↓
[SecureStorageService] → Save Tokens
    ↓
[AuthRepository] → Return UserEntity
    ↓
[AuthNotifier] → state = AsyncValue.data(user)
    ↓
[UI Rebuild] → Navigate to Home
```

### Google Sign-In 구성

**패키지**: `google_sign_in: ^6.2.3`

**설정 요구사항**:
- Android: `google-services.json` 필요
- iOS: `GoogleService-Info.plist` + URL Scheme 설정

**토큰 타입**: ID Token (JWT)

**코드 예시**:
```dart
// features/auth/data/datasources/social_auth_datasource.dart
class SocialAuthDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) throw AuthCancelledException();

    final GoogleSignInAuthentication auth = await account.authentication;
    return auth.idToken!; // JWT Token
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
```

### JWT 토큰 관리

#### 토큰 저장 (Secure Storage)
```dart
// core/services/storage/secure_storage_service.dart
class SecureStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

#### 자동 토큰 갱신 (Dio Interceptor)
```dart
// core/network/api_interceptor.dart
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  if (err.response?.statusCode == 401) {
    final refreshToken = await _storage.getRefreshToken();

    if (refreshToken != null) {
      try {
        // Refresh Token으로 새 Access Token 요청
        final response = await _dio.post('/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        final newAccessToken = response.data['accessToken'];
        await _storage.saveAccessToken(newAccessToken);

        // 원래 요청 재시도
        final retryRequest = err.requestOptions;
        retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(retryRequest);

        return handler.resolve(retryResponse);
      } catch (_) {
        // Refresh Token 만료 → 로그아웃
        await _storage.clearAll();
      }
    }
  }
  handler.next(err);
}
```

### 인증 상태 관리 (Riverpod)

#### AuthNotifier Provider
```dart
// features/auth/presentation/providers/auth_provider.dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<UserEntity?> build() async {
    // 앱 시작 시 저장된 토큰으로 자동 로그인 시도
    final accessToken = await ref.read(secureStorageServiceProvider).getAccessToken();

    if (accessToken != null) {
      try {
        final usecase = ref.read(getCurrentUserUsecaseProvider);
        return await usecase.execute();
      } catch (e) {
        // 토큰 만료 시 null 반환
        return null;
      }
    }

    return null;
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final usecase = ref.read(googleSignInUsecaseProvider);
      final user = await usecase.execute();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    await ref.read(logoutUsecaseProvider).execute();
    state = const AsyncValue.data(null);
  }
}
```

#### UI 사용 예시
```dart
// features/auth/presentation/pages/login_page.dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: authState.when(
        data: (user) {
          if (user != null) {
            // 로그인 완료 → 홈 화면으로 이동
            Future.microtask(() => context.go('/home'));
            return const SizedBox();
          }

          // Google 로그인 버튼 표시
          return Center(
            child: GoogleSignInButton(
              onPressed: () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
            ),
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Text('로그인 실패: $error'),
      ),
    );
  }
}
```

### 백엔드 API 엔드포인트

```
POST /auth/google
Request: { "idToken": "eyJhbGc..." }
Response: { "accessToken": "...", "refreshToken": "..." }

POST /auth/refresh
Request: { "refreshToken": "..." }
Response: { "accessToken": "..." }

POST /auth/logout
Headers: { "Authorization": "Bearer <accessToken>" }
Response: { "message": "Logged out successfully" }
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
[Use Case] → Entity 반환 (또는 Exception throw)
    ↓
[Provider] → state 업데이트 (try-catch)
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
- [Repository Pattern](https://medium.com/@jun.chenying/flutter-repository-pattern-5dc3d8dd0fa6)

---

**문서 작성**: Development Team
**최종 업데이트**: 2025-12-30
**다음 리뷰 예정일**: 2026-01-30
