# 코드 생성 도구 사용 가이드 (Code Generation Tools Guide)

> **작성일**: 2025-12-30
> **대상 독자**: 개발자
> **문서 버전**: 1.0.0

---

## 📋 목차

1. [개요](#개요)
2. [상태 관리 (Riverpod)](#상태-관리-riverpod)
3. [불변 데이터 모델 (Freezed)](#불변-데이터-모델-freezed)
4. [REST API 클라이언트 (Retrofit)](#rest-api-클라이언트-retrofit)
5. [코드 생성 실행](#코드-생성-실행)
6. [문제 해결](#문제-해결)

---

## 개요

이 프로젝트는 **코드 생성 (Code Generation)** 패턴을 활용하여 보일러플레이트를 최소화하고 타입 안전성을 보장합니다.

### 사용 중인 코드 생성 패키지

| 패키지 | 버전 | 역할 |
|--------|------|------|
| `riverpod_generator` | 2.6.2 | Riverpod Provider 자동 생성 |
| `freezed` | 2.5.7 | 불변 데이터 클래스 자동 생성 |
| `json_serializable` | 6.9.2 | JSON 직렬화/역직렬화 코드 생성 |
| `retrofit_generator` | 9.1.8 | REST API 클라이언트 인터페이스 생성 |
| `build_runner` | 2.4.14 | 코드 생성 실행 엔진 |

### 코드 생성이 필요한 이유

- ✅ **타입 안전성**: 컴파일 타임에 에러 감지
- ✅ **보일러플레이트 감소**: 반복 코드 80% 감소
- ✅ **유지보수 용이성**: 패턴 일관성 보장
- ✅ **생산성 향상**: 수동 작성 대비 3배 빠른 개발

---

## 상태 관리 (Riverpod)

### 패키지 정보

```yaml
dependencies:
  flutter_riverpod: ^2.6.1        # 상태 관리 런타임
  riverpod_annotation: ^2.6.1     # 어노테이션

dev_dependencies:
  riverpod_generator: ^2.6.2      # 코드 생성기
```

### 기본 사용법

#### 1. Provider 정의 (코드 생성 방식)

```dart
// lib/features/session/presentation/providers/session_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cops_and_robbers/features/session/domain/entities/session_entity.dart';

// ⚠️ 필수: part 선언 (코드 생성 파일)
part 'session_provider.g.dart';

/// 게임 세션 상태 관리 Provider
///
/// 역할:
/// - 게임 세션 생성
/// - 세션 참가
/// - 대기실 상태 관리
@riverpod
class SessionNotifier extends _$SessionNotifier {
  /// 초기 상태 정의
  @override
  FutureOr<SessionEntity?> build() => null;

  /// 게임 세션 생성
  Future<void> createSession(CreateSessionRequest request) async {
    state = const AsyncValue.loading();

    try {
      // Use Case 호출
      final usecase = ref.read(createSessionUsecaseProvider);
      final session = await usecase.execute(request);
      state = AsyncValue.data(session);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 게임 세션 참가
  Future<void> joinSession(String inviteCode) async {
    state = const AsyncValue.loading();

    try {
      final usecase = ref.read(joinSessionUsecaseProvider);
      final session = await usecase.execute(inviteCode);
      state = AsyncValue.data(session);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

**생성되는 코드** (`session_provider.g.dart`):
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

String _$sessionNotifierHash() => r'a1b2c3d4e5f6...';

/// 게임 세션 상태 관리 Provider
///
/// Copied from [SessionNotifier].
@ProviderFor(SessionNotifier)
final sessionNotifierProvider =
    AutoDisposeAsyncNotifierProvider<SessionNotifier, SessionEntity?>.internal(
  SessionNotifier.new,
  name: r'sessionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionNotifier = AutoDisposeAsyncNotifier<SessionEntity?>;
```

---

#### 2. UI에서 Provider 사용

```dart
// lib/features/session/presentation/pages/create_session_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';

class CreateSessionPage extends ConsumerWidget {
  const CreateSessionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Provider 구독 (상태 변화 시 자동 rebuild)
    final sessionState = ref.watch(sessionNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('방 만들기')),
      body: sessionState.when(
        // 로딩 중
        loading: () => const Center(child: CircularProgressIndicator()),

        // 에러 발생
        error: (error, stack) => Center(
          child: Text('에러: $error'),
        ),

        // 데이터 로드 완료
        data: (session) {
          if (session == null) {
            return _buildCreateForm(context, ref);
          }
          return _buildSessionCreated(session);
        },
      ),
    );
  }

  Widget _buildCreateForm(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          final request = CreateSessionRequest(
            roundTime: const Duration(minutes: 30),
            locationShareInterval: const Duration(minutes: 5),
            policeWaitTime: const Duration(minutes: 5),
          );

          // ✅ Provider 메서드 호출
          ref.read(sessionNotifierProvider.notifier).createSession(request);
        },
        child: const Text('게임 생성'),
      ),
    );
  }

  Widget _buildSessionCreated(SessionEntity session) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('초대 코드: ${session.inviteCode}'),
          const SizedBox(height: 16),
          const Text('참가자를 기다리는 중...'),
        ],
      ),
    );
  }
}
```

---

#### 3. Provider 종류별 사용 예시

##### 3-1. 일반 Provider (읽기 전용 값)

```dart
/// API Base URL Provider
@riverpod
String apiBaseUrl(ApiBaseUrlRef ref) {
  return const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}

// 사용
final baseUrl = ref.watch(apiBaseUrlProvider);
```

##### 3-2. Future Provider (비동기 데이터)

```dart
/// 게임 구역 정보 조회 Provider
@riverpod
Future<GameArea> gameArea(GameAreaRef ref, String gameId) async {
  final repository = ref.watch(mapRepositoryProvider);
  return await repository.getGameArea(gameId);
}

// 사용
final areaState = ref.watch(gameAreaProvider('game-123'));
areaState.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
  data: (area) => GameMap(area: area),
);
```

##### 3-3. Stream Provider (실시간 데이터)

```dart
/// 팀 채팅 메시지 스트림 Provider
@riverpod
Stream<ChatMessage> teamChatStream(
  TeamChatStreamRef ref,
  String gameId,
  Team team,
) {
  final dataSource = ref.watch(chatWebSocketDataSourceProvider);
  return dataSource.watchMessages(gameId, team);
}

// 사용
final messagesStream = ref.watch(teamChatStreamProvider('game-123', Team.police));
messagesStream.when(
  loading: () => Text('연결 중...'),
  error: (err, stack) => Text('연결 실패'),
  data: (message) => ChatBubble(message: message),
);
```

---

## 불변 데이터 모델 (Freezed)

### 패키지 정보

```yaml
dependencies:
  freezed_annotation: ^2.4.4      # 어노테이션
  json_annotation: ^4.9.0         # JSON 직렬화 어노테이션

dev_dependencies:
  freezed: ^2.5.7                 # 코드 생성기
  json_serializable: ^6.9.2       # JSON 직렬화 생성기
```

### 기본 사용법

#### 1. 데이터 모델 정의

```dart
// lib/features/session/data/models/game_session.dart
import 'package:freezed_annotation/freezed_annotation.dart';

// ⚠️ 필수: part 선언
part 'game_session.freezed.dart';  // Freezed 생성 파일
part 'game_session.g.dart';        // JSON 직렬화 생성 파일

/// 게임 세션 데이터 모델
///
/// API 응답 DTO로 사용되며, 불변 객체로 관리됩니다.
@freezed
class GameSession with _$GameSession {
  /// 기본 생성자
  const factory GameSession({
    /// 세션 고유 ID
    required String id,

    /// 방장 사용자 ID
    required String hostId,

    /// 초대 코드 (6자리)
    required String inviteCode,

    /// 최대 참가 인원
    @Default(30) int maxPlayers,

    /// 참가자 목록
    @Default([]) List<Participant> participants,

    /// 게임 설정
    required GameConfig config,

    /// 생성 시간
    required DateTime createdAt,
  }) = _GameSession;

  /// JSON → GameSession 변환
  factory GameSession.fromJson(Map<String, dynamic> json)
      => _$GameSessionFromJson(json);
}
```

**생성되는 기능**:
- ✅ `copyWith()` - 불변 객체 복사 및 수정
- ✅ `==` / `hashCode` - 값 기반 동등성 비교
- ✅ `toString()` - 디버깅용 문자열 표현
- ✅ `fromJson()` / `toJson()` - JSON 직렬화

---

#### 2. Freezed 모델 사용 예시

##### 2-1. 객체 생성

```dart
final session = GameSession(
  id: 'session-123',
  hostId: 'user-456',
  inviteCode: 'ABC123',
  maxPlayers: 30,
  participants: [],
  config: GameConfig(
    roundTime: const Duration(minutes: 30),
    locationShareInterval: const Duration(minutes: 5),
    policeWaitTime: const Duration(minutes: 5),
  ),
  createdAt: DateTime.now(),
);
```

##### 2-2. copyWith (불변 복사)

```dart
// ❌ 불가능: Freezed 객체는 불변
session.participants.add(newParticipant); // 컴파일 에러!

// ✅ 가능: copyWith로 새 객체 생성
final updatedSession = session.copyWith(
  participants: [...session.participants, newParticipant],
);
```

##### 2-3. JSON 직렬화

```dart
// JSON → Dart 객체
final json = {
  'id': 'session-123',
  'hostId': 'user-456',
  'inviteCode': 'ABC123',
  'maxPlayers': 30,
  'participants': [],
  'config': {...},
  'createdAt': '2025-12-30T12:00:00.000Z',
};

final session = GameSession.fromJson(json);

// Dart 객체 → JSON
final jsonMap = session.toJson();
print(jsonMap);
// {id: session-123, hostId: user-456, ...}
```

##### 2-4. 동등성 비교

```dart
final session1 = GameSession(id: '123', ...);
final session2 = GameSession(id: '123', ...);

print(session1 == session2); // ✅ true (값 기반 비교)

// copyWith로 복사한 객체도 같은 값이면 동일
final session3 = session1.copyWith();
print(session1 == session3); // ✅ true
```

---

#### 3. Union Type (여러 상태 표현)

```dart
// lib/features/session/data/models/session_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_state.freezed.dart';

/// 게임 세션 상태 Union Type
@freezed
class SessionState with _$SessionState {
  /// 초기 상태
  const factory SessionState.initial() = _Initial;

  /// 로딩 중
  const factory SessionState.loading() = _Loading;

  /// 세션 생성 완료
  const factory SessionState.created(GameSession session) = _Created;

  /// 대기실 입장
  const factory SessionState.waitingRoom(GameSession session) = _WaitingRoom;

  /// 에러 발생
  const factory SessionState.error(String message) = _Error;
}

// 사용 예시
SessionState state = const SessionState.initial();

// when 패턴 매칭
state.when(
  initial: () => Text('초기 화면'),
  loading: () => CircularProgressIndicator(),
  created: (session) => Text('코드: ${session.inviteCode}'),
  waitingRoom: (session) => WaitingRoomWidget(session: session),
  error: (message) => Text('에러: $message'),
);

// maybeWhen (일부만 처리)
state.maybeWhen(
  created: (session) => navigateToWaitingRoom(session),
  error: (message) => showErrorDialog(message),
  orElse: () {}, // 나머지 경우
);
```

---

## REST API 클라이언트 (Retrofit)

### 패키지 정보

```yaml
dependencies:
  dio: ^5.9.0                     # HTTP 클라이언트
  retrofit: ^4.7.2                # REST API 인터페이스

dev_dependencies:
  retrofit_generator: ^9.1.8      # 코드 생성기
```

### 기본 사용법

#### 1. API 인터페이스 정의

```dart
// lib/features/session/data/datasources/session_api.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:cops_and_robbers/features/session/data/models/game_session.dart';

// ⚠️ 필수: part 선언
part 'session_api.g.dart';

/// 게임 세션 API 인터페이스
///
/// Retrofit이 자동으로 HTTP 요청 코드를 생성합니다.
@RestApi(baseUrl: '/api/sessions')
abstract class SessionApi {
  /// Factory 생성자 (코드 생성)
  factory SessionApi(Dio dio, {String? baseUrl}) = _SessionApi;

  /// 게임 세션 생성
  ///
  /// POST /api/sessions
  @POST('')
  Future<GameSession> createSession(
    @Body() CreateSessionRequest request,
  );

  /// 초대 코드로 세션 조회
  ///
  /// GET /api/sessions/join?code={inviteCode}
  @GET('/join')
  Future<GameSession> joinSession(
    @Query('code') String inviteCode,
  );

  /// 세션 정보 조회
  ///
  /// GET /api/sessions/{id}
  @GET('/{id}')
  Future<GameSession> getSession(
    @Path('id') String sessionId,
  );

  /// 팀 선택
  ///
  /// PUT /api/sessions/{id}/team
  @PUT('/{id}/team')
  Future<void> selectTeam(
    @Path('id') String sessionId,
    @Body() SelectTeamRequest request,
  );

  /// 참가자 준비 상태 변경
  ///
  /// PUT /api/sessions/{id}/ready
  @PUT('/{id}/ready')
  Future<void> updateReadyStatus(
    @Path('id') String sessionId,
    @Body() UpdateReadyRequest request,
  );
}
```

**생성되는 코드** (`session_api.g.dart`):
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

class _SessionApi implements SessionApi {
  _SessionApi(this._dio, {this.baseUrl}) {
    baseUrl ??= '/api/sessions';
  }

  final Dio _dio;
  String? baseUrl;

  @override
  Future<GameSession> createSession(CreateSessionRequest request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<GameSession>(Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
      )
          .compose(
            _dio.options,
            '',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)),
    );
    final value = GameSession.fromJson(_result.data!);
    return value;
  }
  // ... 나머지 메서드 구현
}
```

---

#### 2. API 사용 예시

##### 2-1. Dio 설정 및 API 인스턴스 생성

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

/// Dio 인스턴스 Provider
@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // Interceptor 추가 (로깅, 인증 등)
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
}

/// Session API Provider
@riverpod
SessionApi sessionApi(SessionApiRef ref) {
  final dio = ref.watch(dioProvider);
  return SessionApi(dio);
}
```

##### 2-2. Repository에서 API 호출

```dart
// lib/features/session/data/repositories/session_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:cops_and_robbers/core/errors/failures.dart';
import 'package:cops_and_robbers/features/session/data/datasources/session_api.dart';
import 'package:cops_and_robbers/features/session/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionApi _api;

  SessionRepositoryImpl(this._api);

  @override
  Future<SessionEntity> createSession(
    CreateSessionRequest request,
  ) async {
    try {
      // ✅ Retrofit이 생성한 메서드 호출
      final session = await _api.createSession(request);

      // Data Model → Domain Entity 변환
      return SessionEntity.fromModel(session);
    } on DioException catch (e) {
      // HTTP 에러 처리
      if (e.response?.statusCode == 400) {
        throw ValidationException(e.response?.data['message'] ?? '잘못된 요청');
      } else if (e.response?.statusCode == 500) {
        throw ServerException('서버 에러가 발생했습니다');
      }
      throw NetworkException('네트워크 연결을 확인하세요');
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<SessionEntity> joinSession(String inviteCode) async {
    try {
      final session = await _api.joinSession(inviteCode);
      return SessionEntity.fromModel(session);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException('초대 코드를 찾을 수 없습니다');
      }
      throw NetworkException('네트워크 연결을 확인하세요');
    }
  }
}
```

---

## 코드 생성 실행

### 1. 일회성 생성

```bash
# 모든 코드 생성 (Riverpod, Freezed, Retrofit, JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# 생성된 파일 삭제 후 재생성
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Watch 모드 (개발 중 권장)

```bash
# 파일 변경 감지 시 자동 생성
flutter pub run build_runner watch --delete-conflicting-outputs
```

**Watch 모드 사용 시나리오**:
1. 터미널에서 `flutter pub run build_runner watch` 실행
2. 코드 편집 (Provider, Freezed 모델 등)
3. 파일 저장 시 자동으로 `.g.dart`, `.freezed.dart` 생성
4. 개발 완료 시 `Ctrl+C`로 중단

### 3. 특정 파일만 생성

```bash
# 특정 디렉토리만 생성
flutter pub run build_runner build --delete-conflicting-outputs lib/features/session
```

---

## 문제 해결

### ❌ "Conflicting outputs" 에러

**에러 메시지**:
```
[SEVERE] Conflicting outputs were detected and the build is unable to proceed.
```

**해결 방법**:
```bash
# 방법 1: --delete-conflicting-outputs 플래그 사용
flutter pub run build_runner build --delete-conflicting-outputs

# 방법 2: 생성된 파일 모두 삭제 후 재생성
flutter pub run build_runner clean
flutter pub run build_runner build
```

---

### ❌ "Unable to find generated code" 에러

**에러 메시지**:
```
Error: The part 'session_provider.g.dart' was not found in the current directory.
```

**원인**: 코드 생성을 한 번도 실행하지 않음

**해결 방법**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### ❌ "@riverpod annotation not found" 에러

**원인**: `pubspec.yaml`에 `riverpod_annotation` 누락

**해결 방법**:
```yaml
dependencies:
  riverpod_annotation: ^2.6.1  # 추가

dev_dependencies:
  riverpod_generator: ^2.6.2   # 추가
```

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### ❌ JSON 직렬화 에러

**에러 메시지**:
```
Could not generate `fromJson` code for `user`.
```

**원인**: `json_annotation`, `json_serializable` 누락

**해결 방법**:
```yaml
dependencies:
  json_annotation: ^4.9.0      # 추가

dev_dependencies:
  json_serializable: ^6.9.2    # 추가
```

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### ❌ Watch 모드가 변경 감지 안 함

**원인**: IDE 자동 저장 비활성화

**해결 방법**:
1. **VS Code**: `File → Auto Save` 활성화
2. **Android Studio**: `Preferences → Appearance & Behavior → System Settings → Autosave` 활성화
3. 수동 저장: `Cmd+S` (Mac) / `Ctrl+S` (Windows)

---

## 체크리스트

### 새 Provider 생성 시
- [ ] `import 'package:riverpod_annotation/riverpod_annotation.dart';` 추가
- [ ] `part 'provider_name.g.dart';` 선언
- [ ] `@riverpod` 어노테이션 추가
- [ ] 코드 생성 실행: `flutter pub run build_runner build --delete-conflicting-outputs`

### 새 Freezed 모델 생성 시
- [ ] `import 'package:freezed_annotation/freezed_annotation.dart';` 추가
- [ ] `part 'model_name.freezed.dart';` 선언
- [ ] `part 'model_name.g.dart';` 선언 (JSON 직렬화 필요 시)
- [ ] `@freezed` 어노테이션 추가
- [ ] `fromJson()` factory 추가 (JSON 직렬화 필요 시)
- [ ] 코드 생성 실행

### 새 Retrofit API 생성 시
- [ ] `import 'package:retrofit/retrofit.dart';` 추가
- [ ] `import 'package:dio/dio.dart';` 추가
- [ ] `part 'api_name.g.dart';` 선언
- [ ] `@RestApi(baseUrl: '...')` 어노테이션 추가
- [ ] `factory ApiName(Dio dio) = _ApiName;` 추가
- [ ] HTTP 메서드 어노테이션 추가 (`@GET`, `@POST` 등)
- [ ] 코드 생성 실행

---

## 참고 자료

### 공식 문서
- [Riverpod Documentation](https://riverpod.dev/)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [Retrofit Documentation](https://pub.dev/packages/retrofit)
- [Build Runner Documentation](https://pub.dev/packages/build_runner)

### 예제 코드
- [Riverpod Examples](https://github.com/rrousselGit/riverpod/tree/master/examples)
- [Freezed Examples](https://github.com/rrousselGit/freezed/tree/master/packages/freezed/example)

---

**문서 작성**: Development Team
**최종 업데이트**: 2025-12-30
**다음 리뷰 예정일**: 2026-01-30
