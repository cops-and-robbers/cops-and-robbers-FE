# 경찰과 도둑 - 폴더 구조 가이드 (Folder Structure Guide)

> **작성일**: 2025-12-30
> **대상 독자**: 개발자, 신규 팀원
> **문서 버전**: 1.0.0

---

## 📋 목차

1. [전체 구조 개요](#전체-구조-개요)
2. [Core 레이어 상세](#core-레이어-상세)
3. [Features 레이어 상세](#features-레이어-상세)
4. [파일 명명 규칙](#파일-명명-규칙)
5. [파일 생성 가이드](#파일-생성-가이드)
6. [자주 묻는 질문](#자주-묻는-질문)

---

## 전체 구조 개요

```
lib/
├── core/                          # 공통 인프라 (재사용 가능)
│   ├── constants/                 # 앱 전역 상수
│   ├── network/                   # 네트워크 레이어
│   ├── services/                  # 범용 서비스
│   ├── utils/                     # 유틸리티 함수
│   ├── errors/                    # 에러 정의
│   └── widgets/                   # 공통 UI 위젯
│
├── features/                      # 기능 중심 모듈
│   ├── session/                   # F1: 세션 관리
│   ├── map/                       # F2: 지도 및 위치
│   ├── game/                      # F3: 게임 로직
│   ├── chat/                      # F4: 팀 채팅
│   └── notification/              # F4: 알림 시스템
│
├── router/                        # 라우팅 설정
├── firebase_options.dart          # Firebase 설정
└── main.dart                      # 앱 진입점
```

---

## Core 레이어 상세

### 📁 core/constants/

**목적**: 앱 전역에서 사용되는 상수 정의

```
core/constants/
├── app_colors.dart                # 컬러 팔레트
├── text_styles.dart              # 텍스트 스타일 (기존)
├── spacing_and_radius.dart       # 간격/라운드 (기존)
├── api_endpoints.dart            # API URL 상수
└── game_config.dart              # 게임 설정 상수
```

#### 파일별 역할

##### `app_colors.dart`
```dart
/// 앱 전역 색상 팔레트
///
/// 사용법:
/// - Container(color: AppColors.primary)
class AppColors {
  AppColors._();

  /// 주요 색상 (Primary)
  static const Color primary = Color(0xFF4A90E2);

  /// 경찰 팀 색상
  static const Color policeTeam = Color(0xFF2196F3);

  /// 도둑 팀 색상
  static const Color robberTeam = Color(0xFFE53935);
}
```

##### `api_endpoints.dart`
```dart
/// API 엔드포인트 중앙 관리
///
/// 환경별 Base URL:
/// - Development: http://localhost:8080
/// - Production: https://api.copsandrobbers.com
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  // 세션 관리
  static const String createSession = '/api/sessions';
  static const String joinSession = '/api/sessions/join';

  // 게임 로직
  static const String startGame = '/api/games/{id}/start';
  static const String captureRobber = '/api/games/{id}/capture';
}
```

##### `game_config.dart`
```dart
/// 게임 설정 상수 (PRD F1.2 기반)
class GameConfig {
  GameConfig._();

  // 라운드 시간 제약
  static const Duration minRoundTime = Duration(minutes: 10);
  static const Duration maxRoundTime = Duration(minutes: 180);
  static const Duration defaultRoundTime = Duration(minutes: 30);

  // 위치 공유 주기
  static const Duration minLocationShareInterval = Duration(minutes: 5);
  static const Duration defaultLocationShareInterval = Duration(minutes: 5);

  // 경찰 대기 시간
  static const Duration minPoliceWaitTime = Duration.zero;
  static const Duration maxPoliceWaitTime = Duration(minutes: 15);
  static const Duration defaultPoliceWaitTime = Duration(minutes: 5);

  // 최대 인원
  static const int maxPlayers = 30;
}
```

---

### 📁 core/network/

**목적**: 네트워크 통신 인프라 (HTTP, WebSocket)

```
core/network/
├── dio_client.dart               # Dio 인스턴스 설정
├── api_interceptor.dart          # JWT 토큰 자동 추가
├── error_handler.dart            # API 에러 핸들링
└── websocket/
    ├── websocket_client.dart     # STOMP 클라이언트
    └── websocket_events.dart     # 이벤트 정의
```

#### `dio_client.dart`
```dart
/// 앱 전역 Dio 인스턴스 제공
///
/// 자동 설정:
/// - Base URL 설정
/// - Timeout 설정 (30초)
/// - Interceptor 추가 (로깅, 인증)
@riverpod
Dio dioClient(DioClientRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // 인증 Interceptor 추가
  dio.interceptors.add(ref.watch(apiInterceptorProvider));

  // 로깅 (개발 환경에서만)
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  return dio;
}
```

#### `websocket/websocket_client.dart`
```dart
/// WebSocket STOMP 클라이언트 싱글톤
///
/// 사용법:
/// ```dart
/// final client = WebSocketClient.instance;
/// client.connect(url, onConnect: () {
///   client.subscribe('/topic/game/123/events', (frame) {
///     // 이벤트 처리
///   });
/// });
/// ```
class WebSocketClient {
  static final WebSocketClient _instance = WebSocketClient._internal();
  factory WebSocketClient.instance() => _instance;
  WebSocketClient._internal();

  late StompClient _stompClient;
  bool _isConnected = false;

  /// WebSocket 연결
  void connect(String url, {required VoidCallback onConnect}) {
    _stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: (frame) {
          _isConnected = true;
          onConnect();
        },
        onWebSocketError: (error) => _handleError(error),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );
    _stompClient.activate();
  }

  /// 특정 주제 구독
  void subscribe(String destination, void Function(StompFrame) callback) {
    if (!_isConnected) {
      throw WebSocketNotConnectedException();
    }
    _stompClient.subscribe(destination: destination, callback: callback);
  }

  /// 메시지 전송
  void send({required String destination, required String body}) {
    if (!_isConnected) {
      throw WebSocketNotConnectedException();
    }
    _stompClient.send(destination: destination, body: body);
  }

  /// 연결 해제
  void disconnect() {
    _stompClient.deactivate();
    _isConnected = false;
  }
}
```

---

### 📁 core/services/

**목적**: 범용 서비스 (FCM, Device, Storage, Permission)

```
core/services/
├── fcm/
│   ├── firebase_messaging_service.dart    # FCM 초기화 및 토큰 관리
│   └── local_notifications_service.dart   # 로컬 알림 생성
├── device/
│   ├── device_id_manager.dart             # 디바이스 고유 ID
│   └── device_info_service.dart           # 디바이스 정보 수집
├── storage/
│   ├── secure_storage_service.dart        # JWT 토큰 암호화 저장
│   └── shared_prefs_service.dart          # 앱 설정 저장
└── permission/
    └── location_permission_service.dart   # 위치 권한 요청
```

#### `storage/secure_storage_service.dart`
```dart
/// 민감 데이터 암호화 저장 서비스 (JWT 토큰 등)
///
/// 사용 예시:
/// ```dart
/// final service = ref.watch(secureStorageServiceProvider);
/// await service.saveAccessToken(token);
/// final token = await service.getAccessToken();
/// ```
@riverpod
SecureStorageService secureStorageService(SecureStorageServiceRef ref) {
  return SecureStorageService();
}

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 키 상수
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Access Token 저장
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Access Token 조회
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// 모든 토큰 삭제 (로그아웃 시)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

---

### 📁 core/utils/

**목적**: 유틸리티 함수 및 Dart Extension

```
core/utils/
├── date_formatter.dart            # 날짜/시간 포맷팅
├── validators.dart                # 입력 검증 (닉네임 등)
├── logger.dart                    # 로그 관리
└── extensions/
    ├── string_extensions.dart     # String 확장 메서드
    └── context_extensions.dart    # BuildContext 확장 메서드
```

#### `validators.dart`
```dart
/// 입력 검증 유틸리티
///
/// 사용 예시:
/// ```dart
/// final error = Validators.validateNickname('홍길동');
/// if (error != null) {
///   // 에러 메시지 표시
/// }
/// ```
class Validators {
  Validators._();

  /// 닉네임 검증 (PRD F1.5: 2~10자, 한글/영문/숫자)
  static String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return '닉네임을 입력하세요';
    }

    if (value.length < 2 || value.length > 10) {
      return '닉네임은 2~10자 이내로 입력하세요';
    }

    final regex = RegExp(r'^[가-힣a-zA-Z0-9]+$');
    if (!regex.hasMatch(value)) {
      return '한글, 영문, 숫자만 사용 가능합니다';
    }

    return null;
  }

  /// 초대 코드 검증 (PRD F1.3: 6자리 영문/숫자)
  static String? validateInviteCode(String? value) {
    if (value == null || value.isEmpty) {
      return '초대 코드를 입력하세요';
    }

    if (value.length != 6) {
      return '초대 코드는 6자리입니다';
    }

    final regex = RegExp(r'^[A-Za-z0-9]{6}$');
    if (!regex.hasMatch(value)) {
      return '잘못된 초대 코드 형식입니다';
    }

    return null;
  }
}
```

#### `extensions/context_extensions.dart`
```dart
/// BuildContext 확장 메서드
///
/// 사용 예시:
/// ```dart
/// context.showSnackBar('저장되었습니다');
/// final width = context.screenWidth;
/// ```
extension ContextExtensions on BuildContext {
  /// 화면 너비
  double get screenWidth => MediaQuery.of(this).size.width;

  /// 화면 높이
  double get screenHeight => MediaQuery.of(this).size.height;

  /// SnackBar 표시
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  /// 다이얼로그 표시
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
```

---

### 📁 core/widgets/

**목적**: 앱 전체에서 재사용 가능한 공통 UI 위젯

```
core/widgets/
├── loading_indicator.dart         # 로딩 스피너
├── error_widget.dart              # 에러 표시 위젯
├── app_button.dart                # 공통 버튼
├── app_text_field.dart            # 공통 입력 필드
└── app_dialog.dart                # 공통 다이얼로그
```

#### `app_button.dart`
```dart
/// 앱 공통 버튼 위젯
///
/// 사용 예시:
/// ```dart
/// AppButton(
///   text: '게임 시작',
///   onPressed: () => startGame(),
///   isLoading: isStarting,
/// )
/// ```
class AppButton extends StatelessWidget {
  /// 버튼 텍스트
  final String text;

  /// 탭 이벤트 콜백
  final VoidCallback? onPressed;

  /// 로딩 상태
  final bool isLoading;

  /// 버튼 스타일 (primary / secondary)
  final AppButtonStyle style;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.style = AppButtonStyle.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: style == AppButtonStyle.primary
            ? AppColors.primary
            : AppColors.secondary,
        padding: AppPadding.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.button,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Text(
              text,
              style: AppTextStyles.body1.semiBold().copyWith(
                    color: Colors.white,
                  ),
            ),
    );
  }
}

enum AppButtonStyle { primary, secondary }
```

---

## Features 레이어 상세

### 공통 구조 (모든 feature 동일)

```
features/[feature_name]/
├── data/                          # 데이터 레이어
│   ├── models/                    # API 응답 DTO
│   ├── datasources/               # 데이터 소스
│   └── repositories/              # Repository 구현체
├── domain/                        # 도메인 레이어
│   ├── entities/                  # 비즈니스 엔티티
│   ├── repositories/              # Repository 인터페이스
│   └── usecases/                  # Use Case
└── presentation/                  # UI 레이어
    ├── providers/                 # Riverpod Provider
    ├── pages/                     # 화면
    └── widgets/                   # 기능 특화 위젯
```

---

### 📁 features/session/ (세션 관리)

**PRD 매핑**: F1 - 게임 생성, 참가, 대기실

```
features/session/
├── data/
│   ├── models/
│   │   ├── game_session.dart              # 게임 세션 모델
│   │   ├── game_session.freezed.dart      # 코드 생성
│   │   ├── game_session.g.dart            # JSON 직렬화
│   │   ├── participant.dart               # 참가자 모델
│   │   ├── participant.freezed.dart
│   │   ├── participant.g.dart
│   │   ├── invite_code.dart               # 초대 코드 모델
│   │   └── create_session_request.dart    # API 요청 DTO
│   ├── datasources/
│   │   ├── session_remote_datasource.dart # REST API 호출
│   │   └── session_local_datasource.dart  # 로컬 캐시
│   └── repositories/
│       └── session_repository_impl.dart   # Repository 구현
│
├── domain/
│   ├── entities/
│   │   └── session_entity.dart            # 순수 비즈니스 엔티티
│   ├── repositories/
│   │   └── session_repository.dart        # Repository 인터페이스
│   └── usecases/
│       ├── create_session_usecase.dart    # F1.1 게임 생성
│       ├── join_session_usecase.dart      # F1.4 게임 참가
│       ├── set_nickname_usecase.dart      # F1.5 닉네임 설정
│       └── select_team_usecase.dart       # F1.6 팀 선택
│
└── presentation/
    ├── providers/
    │   ├── session_provider.dart          # 세션 상태 관리
    │   ├── session_provider.g.dart
    │   └── waiting_room_provider.dart     # 대기실 상태
    ├── pages/
    │   ├── create_session_page.dart       # 방 만들기 화면
    │   ├── join_session_page.dart         # 게임 참가 화면
    │   └── waiting_room_page.dart         # 대기실 화면
    └── widgets/
        ├── participant_list_item.dart     # 참가자 리스트 아이템
        ├── team_selector.dart             # 팀 선택 버튼
        └── ready_button.dart              # 준비 완료 버튼
```

#### 파일 생성 예시: `create_session_usecase.dart`

```dart
/// 게임 세션 생성 Use Case (PRD F1.1)
///
/// 요구사항:
/// - 구역 설정(F2.1) 먼저 완료 필수
/// - 라운드 시간, 위치 공유 주기, 경찰 대기 시간 설정
/// - 초대 코드 자동 생성
class CreateSessionUseCase {
  final SessionRepository _repository;

  CreateSessionUseCase(this._repository);

  /// 게임 세션 생성 실행
  ///
  /// [request] - 게임 설정 정보
  /// 반환: Either<Failure, GameSession>
  Future<Either<Failure, SessionEntity>> execute(
    CreateSessionRequest request,
  ) async {
    // 1. 검증: 라운드 시간 범위 체크
    if (request.roundTime < GameConfig.minRoundTime ||
        request.roundTime > GameConfig.maxRoundTime) {
      return Left(ValidationFailure('라운드 시간은 ${GameConfig.minRoundTime.inMinutes}~${GameConfig.maxRoundTime.inMinutes}분 사이여야 합니다'));
    }

    // 2. Repository 호출
    return await _repository.createSession(request);
  }
}
```

---

### 📁 features/map/ (지도 및 위치)

**PRD 매핑**: F2 - 구역 설정, 지도 UI, 위치 공유, 구역 이탈 감지

```
features/map/
├── data/
│   ├── models/
│   │   ├── game_area.dart                 # 플레이그라운드/감옥 구역
│   │   ├── location_data.dart             # GPS 좌표
│   │   └── footprint.dart                 # 도둑 발자국
│   ├── datasources/
│   │   ├── location_remote_datasource.dart  # 위치 API
│   │   └── location_stream_datasource.dart  # GPS 스트림
│   └── repositories/
│       └── map_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── game_boundary_entity.dart
│   ├── repositories/
│   │   └── map_repository.dart
│   └── usecases/
│       ├── set_playground_usecase.dart    # F2.1 플레이그라운드 설정
│       ├── set_jail_usecase.dart          # F2.1 감옥 설정
│       ├── track_location_usecase.dart    # 위치 추적
│       └── detect_zone_exit_usecase.dart  # F2.4 구역 이탈 감지
│
└── presentation/
    ├── providers/
    │   ├── map_provider.dart
    │   └── location_provider.dart
    ├── pages/
    │   ├── area_setup_page.dart           # F2.1 구역 설정 화면
    │   └── game_map_page.dart             # F2.2 인게임 지도
    └── widgets/
        ├── playground_circle_painter.dart # 경계선 그리기
        ├── jail_marker.dart               # 감옥 마커
        └── footprint_marker.dart          # F2.3 발자국 표시
```

---

### 📁 features/game/ (게임 로직)

**PRD 매핑**: F3 - 게임 시작/종료, 체포, 감옥, 승패 판정

```
features/game/
├── data/
│   ├── models/
│   │   ├── game_state.dart                # 게임 상태
│   │   ├── player_state.dart              # 플레이어 상태
│   │   └── capture_record.dart            # 체포 기록
│   ├── datasources/
│   │   └── game_remote_datasource.dart
│   └── repositories/
│       └── game_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── game_entity.dart
│   ├── repositories/
│   │   └── game_repository.dart
│   └── usecases/
│       ├── start_game_usecase.dart        # F3.1 게임 시작
│       ├── capture_robber_usecase.dart    # F3.2 체포
│       ├── arrive_at_jail_usecase.dart    # F3.3 감옥 도착
│       └── end_game_usecase.dart          # F3.4 게임 종료 판정
│
└── presentation/
    ├── providers/
    │   ├── game_state_provider.dart
    │   └── timer_provider.dart            # F4.1 타이머 관리
    ├── pages/
    │   ├── game_screen.dart               # 메인 게임 화면
    │   └── result_screen.dart             # 결과 화면
    └── widgets/
        ├── game_hud.dart                  # F4.1 HUD (타이머, 현황)
        ├── capture_dialog.dart            # F3.2 체포 다이얼로그
        └── jail_arrival_button.dart       # F3.3 감옥 도착 버튼
```

---

### 📁 features/chat/ (팀 채팅)

**PRD 매핑**: F4.3 - 경찰/도둑 팀별 채팅

```
features/chat/
├── data/
│   ├── models/
│   │   └── chat_message.dart              # 채팅 메시지 모델
│   ├── datasources/
│   │   ├── chat_websocket_datasource.dart # WebSocket 채팅
│   │   └── chat_local_datasource.dart     # 로컬 캐시
│   └── repositories/
│       └── chat_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── message_entity.dart
│   ├── repositories/
│   │   └── chat_repository.dart
│   └── usecases/
│       ├── send_message_usecase.dart      # 메시지 전송
│       └── fetch_history_usecase.dart     # 채팅 내역 조회
│
└── presentation/
    ├── providers/
    │   └── chat_provider.dart             # 채팅 상태 관리
    ├── pages/
    │   └── team_chat_page.dart            # 팀 채팅 화면
    └── widgets/
        ├── chat_message_bubble.dart       # 메시지 말풍선
        └── chat_input_field.dart          # 입력 필드
```

---

### 📁 features/notification/ (알림 시스템)

**PRD 매핑**: F4.2 - 전체 공지, 개인 알림

```
features/notification/
├── data/
│   ├── models/
│   │   └── notification_event.dart
│   ├── datasources/
│   │   └── notification_websocket_datasource.dart
│   └── repositories/
│       └── notification_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── notification_entity.dart
│   ├── repositories/
│   │   └── notification_repository.dart
│   └── usecases/
│       └── show_notification_usecase.dart
│
└── presentation/
    ├── providers/
    │   └── notification_provider.dart
    └── widgets/
        ├── banner_notification.dart       # F4.2 전체 공지 배너
        └── toast_notification.dart        # F4.2 개인 알림 토스트
```

---

## 파일 명명 규칙

### Dart 파일 이름
✅ **snake_case** 사용 (Dart 공식 가이드)

```
✅ 올바른 예시:
- game_session.dart
- create_session_usecase.dart
- session_remote_datasource.dart

❌ 잘못된 예시:
- GameSession.dart
- createSessionUseCase.dart
- SessionRemoteDataSource.dart
```

### 클래스 이름
✅ **PascalCase** 사용

```dart
✅ 올바른 예시:
class GameSession {}
class CreateSessionUseCase {}
class SessionRemoteDataSource {}

❌ 잘못된 예시:
class gameSession {}
class createSessionUseCase {}
```

### 변수 및 메서드 이름
✅ **camelCase** 사용

```dart
✅ 올바른 예시:
final gameSession = GameSession();
Future<void> createSession() {}

❌ 잘못된 예시:
final GameSession = GameSession();
Future<void> CreateSession() {}
```

### 파일 접미사 규칙

| 파일 타입 | 접미사 | 예시 |
|----------|--------|------|
| 데이터 모델 | `없음` | `game_session.dart` |
| Repository 구현체 | `_impl` | `session_repository_impl.dart` |
| Data Source | `_datasource` | `session_remote_datasource.dart` |
| Use Case | `_usecase` | `create_session_usecase.dart` |
| Provider | `_provider` | `session_provider.dart` |
| Page | `_page` | `create_session_page.dart` |
| Widget | `없음` | `participant_list_item.dart` |

---

## 파일 생성 가이드

### 1. 새로운 Feature 추가 시

**예시**: `features/voice/` (음성 통신 기능 추가)

```bash
# 1. feature 폴더 생성
mkdir -p lib/features/voice/{data,domain,presentation}/{models,datasources,repositories,entities,usecases,providers,pages,widgets}

# 2. 필수 파일 생성 (최소 구조)
touch lib/features/voice/data/models/voice_channel.dart
touch lib/features/voice/data/datasources/voice_remote_datasource.dart
touch lib/features/voice/data/repositories/voice_repository_impl.dart

touch lib/features/voice/domain/entities/voice_entity.dart
touch lib/features/voice/domain/repositories/voice_repository.dart
touch lib/features/voice/domain/usecases/start_voice_chat_usecase.dart

touch lib/features/voice/presentation/providers/voice_provider.dart
touch lib/features/voice/presentation/pages/voice_chat_page.dart
```

### 2. Data Model 생성 (Freezed + JSON Serializable)

```dart
// lib/features/session/data/models/game_session.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_session.freezed.dart';
part 'game_session.g.dart';

/// 게임 세션 데이터 모델
///
/// API 응답 DTO로 사용되며, Freezed로 불변 클래스 생성
@freezed
class GameSession with _$GameSession {
  const factory GameSession({
    required String id,
    required String hostId,
    required String inviteCode,
    required int maxPlayers,
    required List<Participant> participants,
  }) = _GameSession;

  /// JSON → GameSession
  factory GameSession.fromJson(Map<String, dynamic> json)
      => _$GameSessionFromJson(json);
}
```

```bash
# 코드 생성 실행
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Use Case 생성

```dart
// lib/features/session/domain/usecases/create_session_usecase.dart

/// 게임 세션 생성 Use Case
///
/// 책임:
/// - 입력 검증 (라운드 시간, 위치 공유 주기)
/// - Repository 호출
/// - 에러 처리 (Either 패턴)
class CreateSessionUseCase {
  final SessionRepository _repository;

  CreateSessionUseCase(this._repository);

  Future<Either<Failure, SessionEntity>> execute(
    CreateSessionRequest request,
  ) async {
    // 비즈니스 로직 구현
    return await _repository.createSession(request);
  }
}
```

### 4. Riverpod Provider 생성

```dart
// lib/features/session/presentation/providers/session_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_provider.g.dart';

/// 게임 세션 상태 관리 Provider
@riverpod
class SessionNotifier extends _$SessionNotifier {
  @override
  FutureOr<GameSession?> build() => null;

  /// 게임 세션 생성
  Future<void> createSession(CreateSessionRequest request) async {
    state = const AsyncValue.loading();

    final usecase = ref.read(createSessionUsecaseProvider);
    final result = await usecase.execute(request);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (session) => AsyncValue.data(session),
    );
  }
}
```

```bash
# Provider 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 자주 묻는 질문

### Q1: 파일을 어디에 생성해야 할지 모르겠어요.

**A**: 다음 질문에 답하세요:

1. **모든 feature에서 사용하나요?** → `lib/core/`
2. **특정 기능에만 사용하나요?** → `lib/features/[기능명]/`
3. **API 호출인가요?** → `data/datasources/`
4. **비즈니스 로직인가요?** → `domain/usecases/`
5. **UI인가요?** → `presentation/pages/` 또는 `widgets/`

### Q2: Data Model과 Entity의 차이는 무엇인가요?

**A**:
- **Data Model** (`data/models/`): API 응답 JSON 구조와 1:1 매핑, Freezed 사용
- **Entity** (`domain/entities/`): 순수 비즈니스 개념, 외부 의존성 없음

```dart
// ❌ Entity에서 Data Model 사용 금지
class SessionEntity {
  final GameSession session; // 금지!
}

// ✅ Entity는 독립적
class SessionEntity {
  final String id;
  final int maxPlayers;
}
```

### Q3: Provider는 어디에 배치하나요?

**A**: `presentation/providers/`에 배치합니다.

```
✅ 올바른 위치:
features/session/presentation/providers/session_provider.dart

❌ 잘못된 위치:
lib/providers/session_provider.dart (core 레이어에 배치 금지)
```

### Q4: 공통 위젯인지 feature 위젯인지 판단 기준은?

**A**:
- **공통 위젯** (`core/widgets/`): 2개 이상의 feature에서 사용
- **Feature 위젯** (`features/[기능]/presentation/widgets/`): 단일 feature에서만 사용

```dart
// core/widgets/app_button.dart - 모든 feature에서 사용
class AppButton extends StatelessWidget {}

// features/session/presentation/widgets/team_selector.dart
// → 세션 기능에서만 사용
class TeamSelector extends StatelessWidget {}
```

### Q5: 코드 생성이 필요한 파일은?

**A**: 다음 어노테이션 사용 시 코드 생성 필요:
- `@freezed` → Freezed
- `@riverpod` → Riverpod Generator
- `@RestApi` → Retrofit
- `@JsonSerializable` → JSON Serializable

```bash
# 코드 생성 실행 (변경 후 매번 실행)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch 모드 (자동 감지 후 생성)
flutter pub run build_runner watch
```

---

**문서 작성**: Development Team
**최종 업데이트**: 2025-12-30
**다음 리뷰 예정일**: 2026-01-30
