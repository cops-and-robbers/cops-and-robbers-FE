# API 연동 가이드

새로운 백엔드 API를 연동할 때 참고하는 문서입니다.

---

## 1. 인증(JWT)은 자동입니다

`AuthInterceptor`가 **모든 API 요청에 자동으로** JWT Access Token을 주입합니다.

```text
[내 코드] → POST /api/games/{gameId}/participants
                ↓ AuthInterceptor 자동 개입
[실제 요청] → Authorization: Bearer eyJhbGci...  ← 자동 주입됨
```

**자동으로 처리되는 것:**

| 동작 | 설명 |
|------|------|
| 토큰 주입 | 모든 요청 헤더에 `Authorization: Bearer {accessToken}` 자동 추가 |
| 토큰 재발급 | 401 응답 시 자동으로 `/api/auth/reissue` 호출 → 새 토큰 저장 → 원래 요청 재시도 |
| 강제 로그아웃 | 재발급도 실패하면 토큰 삭제 + Firebase 로그아웃 + 로그인 화면 이동 |
| 동시 요청 처리 | 재발급 중 들어온 다른 401 요청은 대기 → 재발급 완료 후 일괄 재시도 |

**토큰 주입이 제외되는 경로** (공개 API):

- `/api/auth/login`
- `/api/auth/reissue`
- `/api/user/check-nickname`

> 위 3개를 제외한 모든 API는 토큰 관련 코드를 작성할 필요가 없습니다.

---

## 2. 새 API 연동 순서

Clean Architecture 기준으로 4단계입니다.

```text
① Data 계층 — DTO(Model) + Retrofit DataSource
② Domain 계층 — Entity + Repository 인터페이스
③ Data 계층 — Repository 구현체
④ Presentation 계층 — Provider + UI 연결
```

아래에서 **게임 참가 API** (`POST /api/games/{gameId}/participants`)를 예시로 설명합니다.

---

### 2.1 Data 계층 — DTO 만들기

요청/응답 JSON에 대응하는 Freezed 모델을 만듭니다.

**`lib/features/session/data/models/game_join_request_model.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_join_request_model.freezed.dart';
part 'game_join_request_model.g.dart';

@freezed
class GameJoinRequestModel with _$GameJoinRequestModel {
  const factory GameJoinRequestModel({
    required String inviteCode,
  }) = _GameJoinRequestModel;

  factory GameJoinRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GameJoinRequestModelFromJson(json);
}
```

**`lib/features/session/data/models/game_join_response_model.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_join_response_model.freezed.dart';
part 'game_join_response_model.g.dart';

@freezed
class GameJoinResponseModel with _$GameJoinResponseModel {
  const factory GameJoinResponseModel({
    required int gameId,
    required int participantId,
  }) = _GameJoinResponseModel;

  factory GameJoinResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GameJoinResponseModelFromJson(json);
}
```

### 2.2 Data 계층 — Retrofit DataSource에 메서드 추가

기존 DataSource에 메서드를 추가하거나, 새 DataSource를 만듭니다.

**`lib/features/session/data/datasources/session_remote_datasource.dart`**

```dart
@RestApi()
abstract class SessionRemoteDataSource {
  factory SessionRemoteDataSource(Dio dio) = _SessionRemoteDataSource;

  // 기존
  @POST(ApiEndpoints.createGame)
  Future<CreateSessionResponse> createGame(
    @Body() GameCreateRequestModel request,
  );

  // 추가 — 토큰 관련 코드 없음!
  @POST('/api/games/{gameId}/participants')
  Future<GameJoinResponseModel> joinGame(
    @Path('gameId') int gameId,
    @Body() GameJoinRequestModel request,
  );
}
```

> `@POST`, `@Body()`, `@Path()` 등 Retrofit 어노테이션만 쓰면 됩니다. **토큰은 자동 주입됩니다.**

### 2.3 Domain 계층 — Entity + Repository 인터페이스

**Entity** (`lib/features/session/domain/entities/game_join_result.dart`):

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_join_result.freezed.dart';

@freezed
class GameJoinResult with _$GameJoinResult {
  const factory GameJoinResult({
    required int gameId,
    required int participantId,
  }) = _GameJoinResult;
}
```

**Repository 인터페이스**에 메서드 추가 (`lib/features/session/domain/repositories/session_repository.dart`):

```dart
abstract class SessionRepository {
  Future<CreateSessionResult> createGame({...}); // 기존
  Future<GameJoinResult> joinGame({             // 추가
    required int gameId,
    required String inviteCode,
  });
}
```

### 2.4 Data 계층 — Repository 구현체

**`lib/features/session/data/repositories/session_repository_impl.dart`**

```dart
@override
Future<GameJoinResult> joinGame({
  required int gameId,
  required String inviteCode,
}) async {
  try {
    final response = await _dataSource.joinGame(
      gameId,
      GameJoinRequestModel(inviteCode: inviteCode),
    );
    // Data DTO → Domain Entity 변환
    return GameJoinResult(
      gameId: response.gameId,
      participantId: response.participantId,
    );
  } on DioException catch (e) {
    throw DioExceptionHandler.handle(e);  // ← 에러 처리는 이 한 줄
  }
}
```

### 2.5 Presentation 계층 — Provider

**`lib/features/session/presentation/providers/session_provider.dart`**

```dart
@riverpod
class GameJoinNotifier extends _$GameJoinNotifier {
  @override
  FutureOr<GameJoinResult?> build() => null;

  Future<void> joinGame({
    required int gameId,
    required String inviteCode,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(sessionRepositoryProvider).joinGame(
        gameId: gameId,
        inviteCode: inviteCode,
      );
    });
  }
}
```

### 2.6 코드 생성 실행

DTO/Provider 추가 후 반드시 실행:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 3. 에러 처리

### 에러는 Repository에서 한 번만 처리

```dart
// Repository 구현체 — 이 패턴만 쓰면 됩니다
try {
  final response = await _dataSource.someApi(request);
  return SomeEntity(...);
} on DioException catch (e) {
  throw DioExceptionHandler.handle(e);  // DioException → AppException 변환
}
```

`DioExceptionHandler.handle(e)`가 HTTP 상태 코드에 따라 적절한 예외로 변환합니다:

| HTTP 상태코드 | 변환되는 예외 | 예시 |
|---------------|--------------|------|
| 400 | `ValidationException` | 필수 필드 누락, 잘못된 요청 |
| 401 | `AuthException` | 인증 실패 (보통 인터셉터가 먼저 처리) |
| 403 | `AuthException` | 접근 권한 없음 |
| 404 | `ServerException` | 리소스 없음 |
| 409 | `ServerException` | 상태 충돌 (이미 참가 중 등) |
| 5xx | `ServerException` | 서버 에러 |
| 타임아웃 | `NetworkException` | 연결 시간 초과 |
| 연결 에러 | `NetworkException` | 네트워크 없음 |

### Presentation에서 에러 표시

```dart
// UI에서 상태 감시
final state = ref.watch(gameJoinNotifierProvider);

state.when(
  data: (result) {
    if (result != null) {
      // 성공 처리 — 화면 이동 등
    }
  },
  error: (error, _) {
    // error는 AppException 타입
    final message = error is AppException ? error.message : '알 수 없는 오류';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  },
  loading: () {
    // 로딩 표시
  },
);
```

---

## 4. 204 No Content 응답 처리

`PATCH .../team`, `PATCH .../ready`, `POST .../start` 같이 응답 본문이 없는 API:

**DataSource:**

```dart
@PATCH('/api/games/{gameId}/team')
Future<void> changeTeam(
  @Path('gameId') int gameId,
  @Body() TeamChangeRequest request,
);
```

**Repository:**

```dart
Future<void> changeTeam({required int gameId, required String team}) async {
  try {
    await _dataSource.changeTeam(
      gameId,
      TeamChangeRequest(targetTeam: team),
    );
  } on DioException catch (e) {
    throw DioExceptionHandler.handle(e);
  }
}
```

**Provider:**

```dart
@riverpod
class TeamChangeNotifier extends _$TeamChangeNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> changeTeam({required int gameId, required String team}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(sessionRepositoryProvider).changeTeam(
        gameId: gameId,
        team: team,
      );
    });
  }
}
```

---

## 5. 주의사항

### autoDispose + 비동기 작업

`@riverpod`는 기본적으로 autoDispose provider를 생성합니다. 긴 비동기 작업(401 재발급 등) 동안 provider가 dispose되면 crash가 발생합니다.

**반드시 UI의 `build()`에서 `ref.watch()`로 구독 유지:**

```dart
@override
Widget build(BuildContext context) {
  // 이 줄이 없으면 async 작업 중 provider가 dispose될 수 있음!
  final state = ref.watch(gameJoinNotifierProvider);

  // 액션 실행은 ref.read()로
  onPressed: () {
    ref.read(gameJoinNotifierProvider.notifier).joinGame(...);
  }
}
```

### ApiEndpoints 상수 활용

새 엔드포인트 추가 시 `lib/core/constants/api_endpoints.dart`에도 등록:

```dart
class ApiEndpoints {
  // 게임 시작
  static String startGame(int gameId) => '/api/games/$gameId/start';
}
```

### 공개 API 추가 시

인증이 필요 없는 API를 추가할 경우, `AuthInterceptor._publicPaths`에 경로 추가 필요:

```dart
// lib/core/network/auth_interceptor.dart
static const List<String> _publicPaths = [
  ApiEndpoints.login,
  ApiEndpoints.reissue,
  ApiEndpoints.checkNickname,
  // '/api/new-public-endpoint',  ← 여기에 추가
];
```

---

## 6. 체크리스트

새 API 연동 시 아래 항목 확인:

- [ ] `api-docs.json` (OpenAPI 정본)에서 요청/응답 스키마 확인
- [ ] Data: DTO (`@freezed` + `@JsonSerializable`) 작성
- [ ] Data: Retrofit DataSource 메서드 추가
- [ ] Domain: Entity (`@freezed`) 작성
- [ ] Domain: Repository 인터페이스 메서드 추가
- [ ] Data: Repository 구현체 (`DioExceptionHandler.handle(e)` 에러 처리)
- [ ] Presentation: Provider (`AsyncValue.guard()` 패턴)
- [ ] Presentation: UI에서 `ref.watch()` 구독 유지
- [ ] `flutter pub run build_runner build --delete-conflicting-outputs` 실행
- [ ] 인증 불필요 API인 경우 `_publicPaths`에 추가
