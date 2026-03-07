# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 프로젝트 개요 (Project Overview)

**경찰과 도둑 (Cops and Robbers)**: 위치 기반 실시간 멀티플레이어 모바일 게임
- Flutter 3.9.2+ / Dart 3.9.2+
- Feature-First + Clean Architecture 하이브리드
- 실시간 위치 동기화 (30명 동시 참가자, GPS 3-5초 주기)
- WebSocket STOMP 기반 양방향 통신
- 코드 생성 패턴 (Riverpod, Freezed, Retrofit)

---

## 필수 개발 명령어 (Essential Commands)

### 환경 설정 (Setup)
```bash
# 의존성 설치
flutter pub get

# 코드 생성 (Riverpod, Freezed, Retrofit) - 필수!
flutter pub run build_runner build --delete-conflicting-outputs

# Watch 모드 (개발 중 자동 생성)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 실행 및 테스트 (Run & Test)
```bash
# 앱 실행
flutter run

# 특정 기기에서 실행
flutter run -d <device-id>

# 테스트 실행
flutter test

# 특정 테스트 파일 실행
flutter test test/features/auth/auth_test.dart

# 코드 분석 (Lint)
flutter analyze

# 프로젝트 정리
flutter clean
```

### 코드 생성이 필요한 시점
- `@riverpod`, `@freezed`, `@RestApi`, `@JsonSerializable` 어노테이션 추가/수정 후
- `.g.dart` 또는 `.freezed.dart` 파일 누락 시
- 빌드 에러 발생 시 (특히 "generated file not found")

---

## 아키텍처 핵심 원칙 (Architecture Principles)

### Clean Architecture 3계층 구조

**반드시 준수해야 할 의존성 흐름:**
```
Presentation (UI) → Domain (Business Logic) ← Data (External APIs/DB)
```

**각 계층의 역할:**
- **Data**: API 호출(Retrofit), WebSocket 통신, 로컬 저장소, Repository 구현체
- **Domain**: 비즈니스 로직(Use Case), Entity, Repository 인터페이스 (외부 의존성 없음)
- **Presentation**: UI(Widget/Page), 상태 관리(Riverpod Provider)

**금지 사항:**
- ❌ Domain이 Data/Presentation에 의존하는 것
- ❌ Data가 Presentation에 직접 의존하는 것
- ❌ Repository 인터페이스를 Data 레이어에 정의하는 것

### Feature-First 폴더 구조

각 기능은 독립된 폴더로 관리:
```
features/[기능명]/
├── data/
│   ├── models/         # DTO (@freezed, @JsonSerializable)
│   ├── datasources/    # API 클라이언트 (@RestApi), WebSocket, Local DB
│   └── repositories/   # Repository 구현체
├── domain/
│   ├── entities/       # 비즈니스 엔티티 (@freezed)
│   ├── repositories/   # Repository 인터페이스 (abstract)
│   └── usecases/       # Use Case (비즈니스 로직)
└── presentation/
    ├── providers/      # Riverpod Provider (@riverpod)
    ├── pages/          # 화면 단위 (Scaffold 포함)
    └── widgets/        # 재사용 가능한 UI 컴포넌트
```

**현재 Feature 모듈:**
- `auth/` - Google 로그인 및 인증
- `session/` - 게임 세션 관리
- `game/` - 지도, 위치 추적, 게임 로직 (map 기능 통합)
- `chat/` - 팀별 채팅
- `notification/` - 알림 시스템

---

## 코드 작성 규칙 (Code Conventions)

### 파일 및 클래스 네이밍

| 타입 | 규칙 | 예시 |
|------|------|------|
| 파일명 | `snake_case` | `user_profile_page.dart` |
| 클래스명 | `PascalCase` | `UserProfilePage` |
| 변수/함수명 | `camelCase` | `userName`, `getUserData()` |
| 상수 | `camelCase` | `maxPlayers`, `apiBaseUrl` |
| Private | `_`로 시작 | `_privateMethod()`, `_internalState` |

### 파일 Suffix 규칙

| 파일 타입 | Suffix | 예시 |
|----------|--------|------|
| Model (DTO) | `_model.dart` | `session_model.dart` |
| Entity | `_entity.dart` | `session_entity.dart` |
| Repository | `_repository.dart` | `session_repository.dart` |
| Use Case | `_usecase.dart` | `create_session_usecase.dart` |
| Provider | `_provider.dart` | `session_provider.dart` |
| Page | `_page.dart` | `session_lobby_page.dart` |
| Widget | `_widget.dart` | `session_card_widget.dart` |

### 에러 처리 패턴

**중요: Either 패턴 사용 안 함! (2025-12-30 제거됨)**

Dart 네이티브 try-catch 패턴 사용:
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
  // 비즈니스 검증
  if (request.roundTime < minTime) {
    throw ValidationException('라운드 시간이 너무 짧습니다');
  }
  return await _repository.createSession(request);
}

// Presentation Layer (Riverpod)
Future<void> createSession(CreateSessionRequest request) async {
  state = const AsyncValue.loading();
  try {
    final session = await ref.read(createSessionUsecaseProvider).execute(request);
    state = AsyncValue.data(session);
  } catch (e, stack) {
    state = AsyncValue.error(e, stack);
  }
}
```

**Custom Exception 종류:**
- `NetworkException` - 네트워크 연결 실패
- `ValidationException` - 유효성 검증 실패
- `AuthException` - 인증/인가 실패
- `ServerException` - 서버 에러

---

## 코드 생성 패턴 (Code Generation Patterns)

### 1. Riverpod Provider (@riverpod)

**필수 구조:**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

// ⚠️ 필수: part 선언
part 'session_provider.g.dart';

/// DartDoc 주석 필수 (Public API)
@riverpod
class SessionNotifier extends _$SessionNotifier {
  @override
  FutureOr<SessionEntity?> build() => null;

  Future<void> createSession(CreateSessionRequest request) async {
    state = const AsyncValue.loading();
    try {
      final session = await ref.read(createSessionUsecaseProvider).execute(request);
      state = AsyncValue.data(session);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

**생성 파일:** `session_provider.g.dart`
**사용:** `ref.read(sessionNotifierProvider)`

### 2. Freezed 불변 데이터 클래스 (@freezed)

**Entity 예시:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_entity.freezed.dart';

@freezed
class SessionEntity with _$SessionEntity {
  const factory SessionEntity({
    required String id,
    required String hostId,
    required int maxPlayers,
  }) = _SessionEntity;
}
```

**Model (DTO) 예시 (JSON 직렬화 포함):**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

@freezed
class SessionModel with _$SessionModel {
  const factory SessionModel({
    required String id,
    required String hostId,
    @JsonKey(name: 'max_players') required int maxPlayers,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);
}
```

**생성 파일:** `*.freezed.dart`, `*.g.dart`

### 3. Retrofit REST API (@RestApi)

**API 인터페이스:**
```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'session_api.g.dart';

@RestApi(baseUrl: '/sessions')
abstract class SessionApi {
  factory SessionApi(Dio dio) = _SessionApi;

  @POST('')
  Future<SessionModel> createSession(@Body() CreateSessionRequest request);

  @GET('/{id}')
  Future<SessionModel> getSession(@Path('id') String sessionId);
}
```

**생성 파일:** `session_api.g.dart`

---

## 실시간 통신 아키텍처 (Real-time Communication)

### WebSocket STOMP 클라이언트

**위치:** `lib/core/realtime/`

**주요 기능:**
- WebSocket 연결 생애주기 관리 (연결, 재연결, 종료)
- STOMP 프로토콜 지원 (구독/발행)
- 자동 재연결 로직 (네트워크 끊김 대응)

**사용 예시 (채팅):**
```dart
// 구독 (서버 → 클라이언트)
_client.subscribe(
  '/topic/chat/game/$gameId/team/${team.name}',
  (frame) {
    final message = ChatMessage.fromJson(jsonDecode(frame.body!));
    onMessage(message);
  },
);

// 발행 (클라이언트 → 서버)
_client.send(
  destination: '/app/chat/$gameId/team/${team.name}',
  body: jsonEncode(message.toJson()),
);
```

### 위치 추적 (Location Tracking)

- GPS 주기: 3-5초마다 위치 전송
- 패키지: `geolocator`
- 정확도: `LocationAccuracy.high`
- 거리 필터: 10m (10m 이동 시에만 업데이트)

---

## 백그라운드 위치 추적 (Background Location Tracking)

### 개요

게임 중 사용자가 전화, 카톡, 화면 잠금 등으로 앱을 나가도 위치 추적과 서버 통신이 계속되어야 합니다.

**문제:**
- 백그라운드 전환 → WebSocket 끊김 → 위치 전송 중단 → 다른 플레이어가 순간이동처럼 보임

**해결:**
- **Foreground Service (Android)**: 알림을 표시하며 백그라운드에서 계속 실행
- **Background Modes (iOS)**: 위치 추적 모드로 백그라운드 실행 허용

### 주요 패키지

```yaml
flutter_background_service: ^5.0.0  # 백그라운드 서비스 관리
```

### 사용법

```dart
// 게임 시작 시
await BackgroundLocationService.start(
  gameId: sessionId,
  userId: currentUserId,
  wsUrl: EnvConfig.wsUrl,
);

// 게임 종료 시
await BackgroundLocationService.stop();
```

### 사용자 경험

**Android:**
- 알림바에 "게임 진행 중 🎮" 표시 (Foreground Service)
- 배터리 소모: 30분 게임 시 약 5-10%

**iOS:**
- 상태바에 파란색 배경 또는 위치 아이콘 표시
- 배터리 소모: 30분 게임 시 약 5-10%

### 상세 문서

전체 구현 가이드는 [docs/BACKGROUND_LOCATION_SERVICE.md](docs/BACKGROUND_LOCATION_SERVICE.md)를 참고하세요.

---

## 환경 설정 (.env)

**필수 파일:** 프로젝트 루트에 `.env` 파일 생성

```env
# 백엔드 API URL
API_BASE_URL=http://localhost:8080

# WebSocket URL
WS_URL=ws://localhost:8080/ws

# Mock API 사용 여부
USE_MOCK_API=true
```

**main.dart에서 초기화 필수:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.initialize(); // ⭐ 필수!
  runApp(const MyApp());
}
```

---

## 공통 유틸리티 및 서비스 (Core Services)

### 로깅 시스템

**개발 환경:**
```dart
debugPrint('로그 메시지');
```

**프로덕션 환경:**
```dart
AppLogger.debug('디버그 메시지');
AppLogger.info('정보 메시지');
AppLogger.warning('경고 메시지');
AppLogger.error('에러 메시지', error, stackTrace);
```

**에러 리포팅:**
```dart
await ErrorReporter.reportError(
  error,
  stackTrace,
  context: 'SessionRepository.createSession',
  additionalInfo: {'requestData': request.toJson()},
);
```

### 보안 저장소 (Secure Storage)

JWT 토큰, 민감 데이터 저장:
```dart
final storage = SecureStorageService();

// 저장
await storage.saveAccessToken(token);
await storage.saveRefreshToken(refreshToken);

// 읽기
final token = await storage.getAccessToken();

// 삭제
await storage.clearAll();
```

### Firebase 서비스

**초기화 순서 (main.dart):**
1. Firebase 초기화 (`Firebase.initializeApp()`)
2. 로컬 알림 서비스 초기화 (`LocalNotificationsService`)
3. FCM 서비스 초기화 (`FirebaseMessagingService`)

---

## UI 개발 가이드 (UI Development)

### 반응형 디자인

**기준 화면:** 375x812 (iPhone X)

```dart
ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) => MaterialApp(...),
)
```

**사용:**
```dart
// 크기
width: 100.w,   // 화면 너비 기준
height: 50.h,   // 화면 높이 기준
fontSize: 16.sp, // 폰트 크기

// 간격
SizedBox(width: 10.w, height: 20.h)
```

### 공통 상수 사용

**텍스트 스타일:** `lib/core/constants/text_styles.dart`
```dart
Text('제목', style: AppTextStyles.titleLarge)
Text('본문', style: AppTextStyles.bodyMedium)
```

**간격 및 반경:** `lib/core/constants/spacing_and_radius.dart`
```dart
Padding(padding: EdgeInsets.all(AppSpacing.md))
BorderRadius.circular(AppRadius.lg)
```

**색상:** `lib/core/constants/app_colors.dart`
```dart
Container(color: AppColors.primary)
```

---

## 자주 발생하는 문제 해결 (Troubleshooting)

### 1. Build Runner 충돌
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. 코드 생성 파일이 import되지 않음
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. 환경 변수 로드 실패
- `.env` 파일이 프로젝트 루트에 있는지 확인
- `pubspec.yaml`의 `assets`에 `.env` 포함 확인
- `main.dart`에서 `await EnvConfig.initialize()` 호출 확인

### 4. Firebase 초기화 오류
- `google-services.json` (Android) 파일 존재 확인
- `GoogleService-Info.plist` (iOS) 파일 존재 확인
- Firebase Console에서 SHA-1 인증서 등록 확인

---

## 코드 리뷰 체크리스트 (Code Review Checklist)

### 필수 검증 항목
- [ ] 파일명 `snake_case`, 클래스명 `PascalCase` 준수
- [ ] Public API에 DartDoc 주석 (`///`) 작성
- [ ] Null Safety 준수 (`String?`, `??`, `?.`)
- [ ] `const` 생성자 사용 (성능 최적화)
- [ ] try-catch 에러 처리 (Either 패턴 사용 안 함)
- [ ] 코드 생성 파일 포함 (`.g.dart`, `.freezed.dart`)

### Clean Architecture 검증
- [ ] Data 레이어: Repository 구현만, Domain 참조
- [ ] Domain 레이어: 외부 의존성 없음, 순수 비즈니스 로직
- [ ] Presentation 레이어: Domain Use Case 호출, Data 직접 참조 금지
- [ ] 의존성 흐름: Presentation → Domain ← Data

### 성능 검증
- [ ] 불필요한 rebuild 방지 (`const` 사용)
- [ ] 무한 루프 위험 없음
- [ ] 메모리 누수 위험 없음 (Stream dispose, Timer cancel)

---

## 리뷰 커맨드 (Review Commands)

| 커맨드 | 검사 항목 |
|--------|----------|
| `/review` | 범용 리뷰 (보안, 성능, 버그, 코드 품질 — 모든 프로젝트) |
| `/review-flutter` | **Flutter 종합 리뷰** — safety/design-system/architecture + 범용 리뷰를 4개 병렬 서브에이전트로 실행 |
| `/review-safety` | Dead code, dead lock, 불필요한 리빌드 |
| `/review-design-system` | AppColors/AppSpacing/AppPadding/AppRadius/AppTextStyles 하드코딩, 공통 위젯 미사용 |
| `/review-architecture` | 아키텍처 레이어 위반, DRY 위반, 불필요한 구조, 레이어 분리 문제 |

---

## 참고 문서 (Documentation)

| 문서 | 설명 |
|------|------|
| [README.md](README.md) | 프로젝트 개요 및 빠른 시작 |
| [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) | 빠른 참조 가이드 (핵심 규칙) |
| [docs/01_ARCHITECTURE.md](docs/01_ARCHITECTURE.md) | 아키텍처 상세 설명 |
| [docs/02_FOLDER_STRUCTURE.md](docs/02_FOLDER_STRUCTURE.md) | 폴더 구조 및 파일 배치 규칙 |
| [docs/03_CODE_CONVENTIONS.md](docs/03_CODE_CONVENTIONS.md) | 코딩 컨벤션 및 베스트 프랙티스 |
| [docs/04_CODE_GENERATION_GUIDE.md](docs/04_CODE_GENERATION_GUIDE.md) | 코드 생성 도구 사용법 |
| [docs/경찰과도둑_PRD_2.md](docs/경찰과도둑_PRD_2.md) | 제품 요구사항 문서 |

---

## 핵심 원칙 요약 (Key Principles)

1. **Feature-First + Clean Architecture**: 기능별 폴더 구성, 3계층 분리
2. **코드 생성 필수**: `@riverpod`, `@freezed`, `@RestApi` 사용 후 `build_runner` 실행
3. **try-catch 에러 처리**: Either 패턴 제거됨, Custom Exception 사용
4. **의존성 흐름 준수**: Presentation → Domain ← Data
5. **const 생성자**: 모든 Widget에서 가능한 한 사용
6. **DartDoc 주석**: Public API는 반드시 문서화
7. **파일 네이밍**: `snake_case` 일관성 유지
8. **Null Safety**: 모든 코드에서 엄격히 준수
