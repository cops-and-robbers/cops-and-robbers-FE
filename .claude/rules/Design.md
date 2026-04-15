# 디자인 패턴 가이드 (Design Patterns Guide)

> **작성일**: 2026-04-15
> **대상 독자**: 개발자, 신규 팀원
> **문서 버전**: 1.0.0
> **범위**: cops_and_robbers 프로젝트에서 실제로 사용 중인 디자인 패턴

---

## 📋 목차

1. [개요](#개요)
2. [아키텍처 패턴](#1-아키텍처-패턴)
3. [GoF 디자인 패턴](#2-gof-디자인-패턴)
4. [Flutter/Dart 특화 패턴](#3-flutterdart-특화-패턴)
5. [상태 관리 패턴](#4-상태-관리-패턴)
6. [실시간 통신 패턴](#5-실시간-통신-패턴)
7. [에러 처리 패턴](#6-에러-처리-패턴)
8. [기타 주요 패턴](#7-기타-주요-패턴)
9. [사용하지 않는 패턴](#8-사용하지-않는-패턴)
10. [패턴 선택 가이드](#9-패턴-선택-가이드)

---

## 개요

이 문서는 `cops_and_robbers` 프로젝트에서 **실제로 사용 중인** 디자인 패턴을 정리합니다.
새로운 기능 추가 시 기존 패턴과의 **일관성 유지**를 최우선으로 하며, 본 문서를 참고하여 동일한 패턴을 적용하세요.

### 핵심 원칙

- ✅ **일관성 > 베스트 프랙티스**: 기존 코드 스타일을 100% 따른다
- ✅ **불변성**: 모든 데이터 객체는 Freezed 기반 불변 클래스
- ✅ **의존성 역전**: Domain은 Data에 의존하지 않음
- ✅ **try-catch 에러 처리**: Either 패턴 사용 금지 (2025-12-30 제거)
- ✅ **코드 생성 우선**: Riverpod / Freezed / Retrofit 어노테이션 적극 활용

---

## 1. 아키텍처 패턴

### 1.1 Clean Architecture (3계층)

**상태**: ✅ 모든 feature에 일관되게 적용됨

```
Presentation Layer (UI + Riverpod)
       ↓ (uses)
Domain Layer (비즈니스 로직 - 순수 Dart)
       ↑ (implements)
Data Layer (외부 시스템 통신)
```

#### 구현 예시

| 계층 | 파일 경로 | 역할 |
| --- | --- | --- |
| Data | `lib/features/auth/data/repositories/auth_repository_impl.dart` | Firebase + REST API 조합, DTO↔Entity 변환 |
| Domain | `lib/features/auth/domain/repositories/auth_repository.dart` | 인터페이스만 정의 (추상화) |
| Domain | `lib/features/auth/domain/usecases/sign_in_with_google_usecase.dart` | 비즈니스 규칙 캡슐화 |
| Presentation | `lib/features/auth/presentation/providers/auth_provider.dart` | AsyncNotifier 상태 관리 |

#### 의존성 규칙

- ❌ **Domain → Data 의존 금지** — Domain은 순수 Dart, 외부 의존성 없음
- ❌ **Domain → Presentation 의존 금지** — Domain은 UI를 모름
- ✅ **Presentation → Domain** — UseCase 호출
- ✅ **Data → Domain** — Repository 인터페이스 구현

### 1.2 Feature-First 조직

**상태**: ✅ 모든 기능이 동일한 폴더 구조를 따름

```text
lib/features/{feature}/
├── data/
│   ├── datasources/    # Retrofit, STOMP, Local Storage
│   ├── models/         # DTO (Freezed)
│   └── repositories/   # Repository 구현체
├── domain/
│   ├── entities/       # 엔티티 (Freezed)
│   ├── repositories/   # Repository 인터페이스
│   └── usecases/       # UseCase (Facade)
└── presentation/
    ├── providers/      # Riverpod (@riverpod)
    ├── pages/          # 화면
    └── widgets/        # 컴포넌트
```

**현재 feature 목록**: auth, chat, game, session, user, notification, lobby, report

### 1.3 의존성 역전 원칙 (DIP)

**상태**: ✅ 모든 Repository에 적용됨

```dart
// Domain: 인터페이스만 정의
// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<AuthResultEntity> signInWithGoogle();
  Future<void> signOut();
}

// Data: 구현체
// lib/features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<AuthResultEntity> signInWithGoogle() async { ... }
}

// Presentation: Riverpod으로 주입
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(...);
}
```

---

## 2. GoF 디자인 패턴

### 2.1 Repository Pattern

**상태**: ✅ 모든 feature에서 사용중
**위치**:
- 인터페이스: `lib/features/*/domain/repositories/*_repository.dart`
- 구현체: `lib/features/*/data/repositories/*_repository_impl.dart`

**규칙**:
- Repository는 여러 DataSource(REST API, Firebase, Local Storage, WebSocket)를 조합한다
- 에러 처리는 구현체에서 `DioExceptionHandler.handle(e)`로 중앙화한다
- DTO → Entity 변환은 Repository에서 수행한다

### 2.2 Factory Pattern

**상태**: ✅ Freezed + Retrofit 코드 생성으로 광범위하게 사용

```dart
// Freezed: 불변 객체 생성
@freezed
class LoginResponseModel with _$LoginResponseModel {
  const factory LoginResponseModel({
    required int userId,
    required TokensModel tokens,
  }) = _LoginResponseModel;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);
}

// Retrofit: REST 클라이언트 생성
@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;
}
```

### 2.3 Singleton Pattern

**상태**: ✅ Riverpod `keepAlive`로 구현

**적용 대상**: 앱 생애주기 동안 유지되어야 하는 서비스

| 서비스 | 위치 | 이유 |
| --- | --- | --- |
| Dio Client | `lib/core/network/dio_client.dart` | HTTP 연결 재사용 |
| SecureTokenStorage | `lib/core/storage/secure_token_storage.dart` | Interceptor 콜백에서 접근 |
| FirebaseAuthDataSource | `lib/features/auth/presentation/providers/auth_provider.dart` | 세션 유지 |

```dart
@Riverpod(keepAlive: true)  // 앱 종료 시까지 유지
Dio dio(Ref ref) {
  return DioClient.create(...);
}
```

### 2.4 Adapter Pattern

**상태**: ✅ 다층적으로 구현

**적용 사례**:

1. **DTO ↔ Entity 변환** (Data → Domain)
   ```dart
   // Repository 구현체에서
   return AuthResultEntity(
     userId: response.userId,
     nickname: response.nickname,
   );
   ```

2. **DioException → AppException 변환**
   - 위치: `lib/core/network/dio_exception_handler.dart`
   - HTTP 상태 코드별로 적절한 `AppException` 생성

3. **JSON → STOMP DTO 변환**
   - 위치: `lib/features/chat/data/datasources/chat_stomp_datasource.dart`
   - STOMP 프레임 body를 파싱하여 DTO로 변환

### 2.5 Strategy Pattern

**상태**: ✅ Interceptor 및 에러 핸들러에 적용

**사례 1**: `AuthInterceptor` — 상황별 다른 전략 선택
- 전략 1: `onRequest()` — 토큰 자동 주입
- 전략 2: `onError()` — 401 응답 시 토큰 재발급 + 재시도
- 전략 3: 무한 루프 방지 (재시도 헤더 체크)

**사례 2**: `DioExceptionHandler.handle()` — 상태 코드별 예외 전략
```dart
return switch (statusCode) {
  400 => ValidationException(...),
  401 => AuthException(...),
  403 => AuthException(...),
  500 => ServerException(...),
  _   => NetworkException(...),
};
```

### 2.6 Observer Pattern

**상태**: ✅ Stream + Broadcast StreamController로 구현

**핵심**: `BaseStompDatasource`에서 다중 구독자 지원 Broadcast Stream 제공

```dart
// lib/core/network/websocket/base_stomp_datasource.dart
final _connectionStateController =
    StreamController<StompConnectionState>.broadcast();
Stream<StompConnectionState> get onConnectionState =>
    _connectionStateController.stream;
```

**구독 예시** (Notifier에서):
```dart
_connectionSub = datasource.onConnectionState.listen((state) {
  this.state = this.state.copyWith(connectionState: state);
});
```

### 2.7 Facade Pattern (UseCase)

**상태**: ✅ Domain Layer UseCase로 구현

**목적**: Repository의 복잡한 로직을 단순한 인터페이스로 노출

```dart
// lib/features/auth/domain/usecases/sign_in_with_google_usecase.dart
class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  Future<AuthResultEntity> execute() async {
    return await _repository.signInWithGoogle();
    // 내부에서 Firebase 로그인 → 백엔드 호출 → 토큰 저장
  }
}
```

**규칙**: UseCase는 **단일 책임**을 가진다. 복잡한 비즈니스 검증이 있을 때만 생성하고, 단순 CRUD는 Provider에서 Repository를 직접 호출해도 된다.

### 2.8 Builder Pattern

**상태**: ✅ Freezed `copyWith`로 자동 구현

```dart
// 불변 객체의 일부 필드만 업데이트
state = state.copyWith(
  connectionState: StompConnectionState.connected,
  errorMessage: null,
  unreadAllCount: 0,
);
```

**Sentinel 패턴** (고급):
`null` 값을 "값 없음"과 "명시적 null"로 구분해야 할 때 사용

```dart
// lib/features/chat/presentation/providers/chat_provider.dart
const _sentinel = Object();

ChatState copyWith({
  Object? errorMessage = _sentinel,  // 기본값: sentinel
}) {
  return ChatState(
    errorMessage: errorMessage == _sentinel
        ? this.errorMessage              // 전달 안 함 → 기존 값 유지
        : errorMessage as String?,       // null 또는 새 값
  );
}
```

### 2.9 Decorator Pattern

**상태**: ✅ Dio Interceptor 체인으로 구현

**위치**: `lib/core/network/dio_client.dart`

```dart
dio.interceptors.addAll([
  AuthInterceptor(...),        // 1. 토큰 주입 + 재발급
  if (kDebugMode) LogInterceptor(...),  // 2. 디버그 로깅
]);
```

**특징**: 각 인터셉터는 독립적인 책임을 가지며 체인 순서대로 HTTP 요청/응답을 "장식"한다.

---

## 3. Flutter/Dart 특화 패턴

### 3.1 Riverpod Provider 패턴

**상태**: ✅ 코드 생성 기반 `@riverpod` 사용 (30+ Provider)

**Provider 종류**:

| 종류 | 어노테이션 | 사용 시기 | 예시 |
| --- | --- | --- | --- |
| Function Provider | `@Riverpod(keepAlive: true)` | 싱글톤 서비스 | `dio`, `secureTokenStorage` |
| Class Notifier | `@riverpod class XxxNotifier` | 복잡한 상태 + 액션 | `AuthNotifier`, `ChatNotifier` |
| Stream Provider | `@riverpod Stream<T> xxx` | 실시간 데이터 | `authState` (Firebase) |

**규칙**:
- 싱글톤 서비스는 `keepAlive: true` 필수
- Notifier는 `onDispose`로 정리 작업 수행
- 비동기 상태는 `AsyncValue` 활용

### 3.2 Freezed Immutable Data Class

**상태**: ✅ 모든 DTO, Entity, State에 사용

**적용 대상**:
- **DTO** (Data Layer): JSON 직렬화 포함
- **Entity** (Domain Layer): 순수 비즈니스 객체
- **State** (Presentation Layer): Notifier 상태

```dart
@freezed
class AuthResultEntity with _$AuthResultEntity {
  const factory AuthResultEntity({
    required int userId,
    required String nickname,
    required bool isNewUser,
  }) = _AuthResultEntity;
}
```

**자동 생성**: `copyWith`, `==`, `hashCode`, `toString`, `fromJson`/`toJson`

### 3.3 Retrofit REST API 추상화

**상태**: ✅ 모든 REST API 호출에 사용

**규칙**:
- 모든 Data Source는 `@RestApi()` 어노테이션으로 정의
- `factory XxxDataSource(Dio dio) = _XxxDataSource;` 패턴 필수
- 엔드포인트는 `lib/core/constants/api_endpoints.dart`에 중앙화
- 토큰은 `AuthInterceptor`가 자동 주입하므로 수동으로 추가하지 않음

**버전 주의**: `retrofit: 4.7.3` 고정 사용 (4.9.x는 `ParseErrorLogger.logError` 시그니처 호환 문제)

### 3.4 AsyncValue 상태 관리

**상태**: ✅ Notifier의 비동기 상태 관리에 사용

**3가지 상태**:
```dart
state = const AsyncValue.loading();           // 로딩
state = AsyncValue.data(result);              // 데이터
state = AsyncValue.error(exception, stack);   // 에러
```

**UI에서 사용**:
```dart
state.when(
  loading: () => const CircularProgressIndicator(),
  data: (result) => SuccessWidget(result),
  error: (error, stack) {
    final message = error is AppException ? error.message : '오류';
    return ErrorWidget(message);
  },
);
```

### 3.5 Stream 기반 실시간 통신

**상태**: ✅ STOMP WebSocket에 Broadcast StreamController 사용

**흐름**:
```text
STOMP 서버 → STOMP Frame → DataSource._handleMessage()
  → DTO 파싱 → StreamController.add()
  → Notifier._sub.listen() → state.copyWith() → UI rebuild
```

### 3.6 try-catch + Custom Exception 패턴

**상태**: ✅ 프로젝트 표준 에러 처리 방식

**절대 금지**: Either 패턴 (dartz 패키지) — 2025-12-30 제거됨

```dart
try {
  final response = await _dataSource.someApi(request);
  return SomeEntity(...);
} on DioException catch (e) {
  throw DioExceptionHandler.handle(e);  // 이 한 줄로 변환
} on FirebaseAuthException catch (e) {
  throw AuthException(message: e.message ?? '...');
} catch (e) {
  if (e is AppException) rethrow;
  throw AuthException(message: '알 수 없는 오류', originalException: e);
}
```

---

## 4. 상태 관리 패턴

### 4.1 AsyncNotifier 패턴

**상태**: ✅ 주요 기능(auth, chat, game)에서 사용

**구조**:
```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthResultEntity?> build() async {
    // 초기 상태 계산 (async 가능)
    return await _restoreFromStorage();
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final result = await useCase.execute();
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

### 4.2 Provider Scoping

**현재 정책**:
- **`keepAlive: true`** — 싱글톤 서비스 (Dio, Storage, 인증)
- **autoDispose** — 현재 프로젝트에서 미사용 (필요 시 도입)
- **family** — 현재 프로젝트에서 미사용

**주의사항**: `@riverpod`는 기본적으로 autoDispose이므로, 긴 비동기 작업(401 재발급 등) 중 Provider가 dispose될 수 있다. 반드시 UI의 `build()`에서 `ref.watch()`로 구독을 유지할 것.

---

## 5. 실시간 통신 패턴

### 5.1 BaseStompDatasource (추상화)

**위치**: `lib/core/network/websocket/base_stomp_datasource.dart`

**책임**:
- STOMP 연결 생애주기 관리 (connect/disconnect)
- 연결 상태 Broadcast Stream 제공
- 에러 이벤트 Broadcast Stream 제공
- 하위 클래스가 `subscribe()`, `publish()`를 구현하도록 유도

**상속 클래스**:
- `ChatStompDatasource` — 채팅 메시지 송수신
- `GameEventStompDatasource` — 게임 이벤트 수신

### 5.2 STOMP Subscribe/Publish

```dart
// Subscribe
_allSub = stompClient!.subscribe(
  destination: '/subscribe/game/$gameId/chat/all',
  callback: _handleMessage,
);

// Publish
stompClient!.send(
  destination: '/publish/game/$gameId/chat',
  body: jsonEncode(request.toJson()),
);
```

### 5.3 지수 백오프 재연결 전략

**상태**: ✅ `ChatNotifier`, `GameEventNotifier`에서 구현

```dart
// 1s → 2s → 4s → 8s → 10s(최대), 최대 5회 재시도
int _calculateBackoffDelay(int attempt) {
  final delay = 1 << (attempt - 1);
  return delay.clamp(1, 10);
}
```

---

## 6. 에러 처리 패턴

### 6.1 Custom Exception Hierarchy

**위치**: `lib/core/errors/app_exception.dart`

```text
AppException (abstract)
├── NetworkException
├── AuthException
│   └── AuthCancelledException
├── ValidationException
├── ServerException
├── DatabaseException
├── WebSocketException
├── LocationException
└── GameException
```

### 6.2 DioExceptionHandler (중앙 집중화)

**위치**: `lib/core/network/dio_exception_handler.dart`

**사용법**: 모든 Repository의 `catch (DioException e)` 블록에서 단 한 줄로 사용

```dart
} on DioException catch (e) {
  throw DioExceptionHandler.handle(e);
}
```

### 6.3 RFC 7807 Problem Details

**위치**: `lib/core/network/api_error_response.dart`

```dart
class ApiErrorResponse {
  final String title;      // "Bad Request"
  final int status;        // 400
  final String detail;     // "닉네임은 2~10자여야 합니다"
  final String instance;   // "STOMP" 또는 API 경로
}
```

백엔드 에러 응답이 RFC 7807 형식을 따르므로, `tryParse`로 파싱 후 `AppException.message`에 `detail` 필드를 사용한다.

### 6.4 AsyncValue.error 전파

**원칙**: Notifier는 에러를 AsyncValue.error로 저장하고 UI에서 처리

```dart
} catch (e, stack) {
  if (e is AppException) {
    state = AsyncValue.error(e, stack);
  } else {
    state = AsyncValue.error(
      AuthException(message: '알 수 없는 오류', originalException: e),
      stack,
    );
  }
  rethrow;  // 호출자도 에러를 알 수 있도록
}
```

---

## 7. 기타 주요 패턴

### 7.1 강제 로그아웃 콜백 (Core → Feature 의존성 역전)

**문제**: `AuthInterceptor`(core)가 로그아웃 로직(feature)을 호출해야 하지만, core가 feature에 의존하면 안 됨

**해결**: `StateProvider`로 콜백 등록 패턴

```dart
// Core에서 콜백 슬롯 제공
final forceLogoutCallbackNotifierProvider = StateProvider<ForceLogoutFn?>(...);

// Feature에서 콜백 등록
ref.read(forceLogoutCallbackNotifierProvider.notifier).register(() async {
  await firebaseDataSource.signOut();
  await tokenStorage.clearTokens();
});

// Core에서 콜백 호출
final forceLogout = ref.read(forceLogoutCallbackNotifierProvider);
await forceLogout?.call();
```

### 7.2 401 Queued Interceptor Lock Pattern

**위치**: `lib/core/network/auth_interceptor.dart`

**문제**: 여러 요청이 동시에 401을 받으면 토큰 재발급이 중복 발생

**해결**: `QueuedInterceptor` + 재발급 락(Lock)
- 첫 번째 401 요청이 재발급 시작 → 다른 401 요청은 대기
- 재발급 완료 후 대기 중인 요청을 일괄 재시도

---

## 8. 사용하지 않는 패턴

| 패턴 | 이유 |
| --- | --- |
| **Either/Result 패턴** (dartz) | 2025-12-30 제거. try-catch + Custom Exception으로 통일 |
| **autoDispose Provider** | 현재 미사용. 비동기 작업 중 dispose 위험 |
| **Family Provider** | 현재 미사용. 매개변수화 필요 시 고려 |
| **`Provider.select()`** | 현재 미사용. 전체 state를 watch |
| **필드 주입** | 전부 생성자 주입 사용 |
| **Singleton 수동 구현** | Riverpod `keepAlive`로 대체 |

---

## 9. 패턴 선택 가이드

### 새 기능 추가 시 체크리스트

- [ ] `lib/features/{feature}/` 폴더를 3계층(data/domain/presentation)으로 생성
- [ ] DTO는 `@freezed` + `@JsonSerializable()`로 작성
- [ ] Entity는 `@freezed`로 작성 (순수 Dart, JSON 의존성 없음)
- [ ] Repository는 Domain에 인터페이스, Data에 구현체
- [ ] 복잡한 비즈니스 로직은 UseCase로 추출, 단순 CRUD는 Provider에서 Repository 직접 호출
- [ ] Notifier는 `@riverpod class`로 작성, 초기 상태는 `build()`에서 반환
- [ ] 비동기 상태는 `AsyncValue`, 복잡한 상태는 Freezed State + `copyWith`
- [ ] 에러는 try-catch로 처리, Repository에서 `DioExceptionHandler.handle(e)` 사용
- [ ] REST API는 `@RestApi()` Retrofit, 토큰 수동 주입 금지
- [ ] WebSocket은 `BaseStompDatasource` 상속, Broadcast Stream으로 이벤트 노출
- [ ] 싱글톤이 필요하면 `@Riverpod(keepAlive: true)`
- [ ] 코드 변경 후 `dart run build_runner build --delete-conflicting-outputs` 실행

### 패턴 선택 플로우

```text
Q1. 비동기 외부 데이터에 접근하나?
  Yes → Repository Pattern (Domain 인터페이스 + Data 구현체)
  No  → Q2

Q2. 복잡한 비즈니스 검증이 있나?
  Yes → UseCase Pattern (Facade)
  No  → Provider에서 Repository 직접 호출

Q3. 여러 구독자가 같은 이벤트를 받아야 하나?
  Yes → Broadcast StreamController (Observer)
  No  → Future 기반 단발성 호출

Q4. 앱 생애주기 동안 유지되어야 하나?
  Yes → @Riverpod(keepAlive: true)
  No  → 기본 @riverpod (autoDispose)

Q5. 불변 데이터 객체가 필요한가?
  항상 Yes → Freezed
```

---

## 참고 문서

- [01_ARCHITECTURE.md](01_ARCHITECTURE.md) — 아키텍처 상세 설계
- [02_FOLDER_STRUCTURE.md](02_FOLDER_STRUCTURE.md) — 폴더 구조 및 네이밍
- [03_CODE_CONVENTIONS.md](03_CODE_CONVENTIONS.md) — 코드 작성 규칙
- [04_CODE_GENERATION_GUIDE.md](04_CODE_GENERATION_GUIDE.md) — Riverpod/Freezed/Retrofit 사용법
- [06_API_INTEGRATION_GUIDE.md](06_API_INTEGRATION_GUIDE.md) — API 연동 절차
- [08_TIMER_ARCHITECTURE.md](08_TIMER_ARCHITECTURE.md) — 타이머 로직 참고

---

**문서 작성**: Development Team
**최종 업데이트**: 2026-04-15
