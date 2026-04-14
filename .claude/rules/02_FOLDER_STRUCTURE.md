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
│   ├── auth/                      # Google 로그인 및 인증
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

**왜 필요한가?**:
- ✅ **일관성 유지**: 색상, 텍스트 스타일, 간격을 중앙에서 관리하여 디자인 일관성 보장
- ✅ **유지보수 용이**: 값 변경 시 한 곳만 수정하면 전체 앱 반영 (예: 주요 색상 변경 시 app_colors.dart만 수정)
- ✅ **매직 넘버 제거**: 하드코딩된 숫자/문자열 대신 의미 있는 상수명 사용 (예: `30` → `GameConfig.maxPlayers`)
- ✅ **타입 안전성**: 상수로 정의하여 컴파일 타임에 오류 감지
- ❌ **없다면?**: 각 파일에 하드코딩 → 변경 시 수십 개 파일 수정 필요 → 누락 가능성 높음

```
core/constants/
├── app_colors.dart                # 컬러 팔레트 (primary, team colors 등)
├── text_styles.dart              # 텍스트 스타일 (Pretendard 폰트 기반 스타일)
├── spacing_and_radius.dart       # 간격/라운드 (AppSpacing, AppPadding, AppRadius)
├── api_endpoints.dart            # API URL 상수 (환경별 base URL, 엔드포인트)
└── game_config.dart              # 게임 설정 상수 (라운드 시간, 인원 제한 등)
```

#### 파일별 역할

##### `app_colors.dart`

**역할**: 앱 전역 색상 팔레트 관리 (primary, team colors, background 등)

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

**역할**: API 엔드포인트 중앙 관리 (환경별 base URL, REST API 경로)

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

**역할**: 게임 룰 상수 관리 (라운드 시간, 인원 제한, 위치 공유 주기 등 - PRD F1.2 기반)

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

**왜 필요한가?**:
- ✅ **중복 제거**: Dio 인스턴스를 매번 생성하지 않고 전역으로 공유 (싱글톤 패턴)
- ✅ **인증 자동화**: JWT 토큰을 Interceptor로 자동 추가 → 매 API 호출마다 수동으로 헤더 설정 불필요
- ✅ **에러 통일**: DioException → Custom Exception 변환을 한 곳에서 처리 (NetworkException, ServerException 등)
- ✅ **실시간 통신**: WebSocket STOMP 클라이언트로 게임 이벤트, 채팅, 위치 동기화 처리
- ❌ **없다면?**: 각 Repository마다 Dio 설정 중복 → 인증 헤더 누락 가능 → 에러 처리 불일치

```
core/network/
├── dio_client.dart               # Dio 인스턴스 설정 (baseURL, timeout, interceptor)
├── api_interceptor.dart          # JWT 토큰 자동 추가 (Authorization header)
├── error_handler.dart            # API 에러 핸들링 (DioException → Custom Exception)
└── websocket/
    ├── websocket_client.dart     # STOMP 클라이언트 (싱글톤, 연결/구독/전송)
    └── websocket_events.dart     # 이벤트 정의 (GameStartedEvent, LocationUpdateEvent 등)
```

#### `dio_client.dart`

**역할**: 앱 전역 Dio HTTP 클라이언트 설정 (base URL, timeout, interceptor 추가)

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

**역할**: WebSocket STOMP 클라이언트 싱글톤 (게임 이벤트, 채팅, 위치 동기화용 실시간 통신)

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

**왜 필요한가?**:
- ✅ **범용성**: 여러 Feature에서 공통으로 사용하는 플랫폼 기능 (FCM, 저장소, 디바이스 정보 등)
- ✅ **플랫폼 추상화**: Flutter 패키지를 직접 사용하지 않고 서비스로 감싸서 테스트 가능 + 교체 용이
- ✅ **보안**: JWT 토큰을 암호화하여 저장 (flutter_secure_storage 사용)
- ✅ **권한 관리**: 위치 권한 요청 로직을 중앙화하여 일관성 보장
- ❌ **없다면?**: 각 Feature마다 FlutterSecureStorage, SharedPreferences를 직접 사용 → 중복 코드 + 보안 취약

```
core/services/
├── fcm/
│   ├── firebase_messaging_service.dart    # FCM 초기화 및 토큰 관리 (pushToken 발급)
│   └── local_notifications_service.dart   # 로컬 알림 생성 (foreground 알림 표시)
├── device/
│   ├── device_id_manager.dart             # 디바이스 고유 ID (FCM 기기 식별용)
│   └── device_info_service.dart           # 디바이스 정보 수집 (OS 버전, 모델명 등)
├── storage/
│   ├── secure_storage_service.dart        # JWT 토큰 암호화 저장 (access/refresh token)
│   └── shared_prefs_service.dart          # 앱 설정 저장 (테마, 온보딩 완료 여부 등)
└── permission/
    └── location_permission_service.dart   # 위치 권한 요청 (게임 플레이 필수)
```

#### `storage/secure_storage_service.dart`

**역할**: JWT 토큰 암호화 저장 서비스 (flutter_secure_storage 기반, 플랫폼 암호화 적용)

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

**왜 필요한가?**:
- ✅ **재사용성**: 날짜 포맷팅, 입력 검증 등 반복되는 로직을 한 곳에서 관리
- ✅ **입력 검증**: PRD 기반 검증 로직 (닉네임 2~10자, 초대 코드 6자리 등)을 중앙화하여 일관성 보장
- ✅ **코드 간결화**: Extension으로 `context.screenWidth`, `context.showSnackBar` 같은 편의 메서드 제공
- ✅ **로깅 통일**: 디버깅용 로그를 일관된 형식으로 출력 (`[AUTH] ✅ 로그인 성공` 형태)
- ❌ **없다면?**: 각 파일마다 날짜 포맷팅, 검증 로직 중복 작성 → 유지보수 어려움 + 검증 로직 불일치

```
core/utils/
├── date_formatter.dart            # 날짜/시간 포맷팅 (2025-12-30 15:30 형태)
├── validators.dart                # 입력 검증 (닉네임, 초대 코드 등 PRD 기반 규칙)
├── logger.dart                    # 로그 관리 (디버그용 통일된 형식)
└── extensions/
    ├── string_extensions.dart     # String 확장 메서드 (capitalize 등)
    └── context_extensions.dart    # BuildContext 확장 메서드 (screenWidth, showSnackBar 등)
```

#### `validators.dart`

**역할**: PRD 기반 입력 검증 로직 (닉네임 2~10자, 초대 코드 6자리 등)

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

**역할**: BuildContext 확장 메서드 (화면 크기, SnackBar 표시 등 편의 기능)

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

**왜 필요한가?**:
- ✅ **UI 일관성**: 버튼, 입력 필드, 다이얼로그 등을 통일된 디자인으로 제공
- ✅ **중복 제거**: 매번 스타일, 색상, 크기를 지정하지 않고 공통 위젯 사용
- ✅ **유지보수**: 디자인 변경 시 core/widgets/만 수정하면 앱 전체 반영
- ✅ **접근성**: 로딩 상태, 에러 처리, 비활성화 상태를 표준화하여 사용자 경험 개선
- ❌ **없다면?**: 각 화면마다 버튼, 입력 필드를 직접 구현 → 디자인 불일치 + 중복 코드 발생

```
core/widgets/
├── loading_indicator.dart         # 로딩 스피너 (CircularProgressIndicator 래핑)
├── error_widget.dart              # 에러 표시 위젯 (에러 메시지 + 재시도 버튼)
├── app_button.dart                # 공통 버튼 (primary/secondary 스타일, 로딩 상태)
├── app_text_field.dart            # 공통 입력 필드 (검증 메시지, 포커스 스타일)
└── app_dialog.dart                # 공통 다이얼로그 (확인/취소 버튼, 스타일)
```

#### `app_button.dart`

**역할**: 앱 공통 버튼 위젯 (primary/secondary 스타일, 로딩/비활성화 상태 지원)

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

**왜 3계층으로 분리하는가?**:
- ✅ **관심사 분리 (Separation of Concerns)**: 데이터 통신 / 비즈니스 로직 / UI를 분리하여 각 계층의 책임 명확화
- ✅ **테스트 용이성**: Domain 계층은 순수 Dart로 작성되어 UI/API 없이도 단독 테스트 가능
- ✅ **유지보수**: API 변경 시 data/ 계층만 수정, UI 변경 시 presentation/ 계층만 수정 → 다른 계층 영향 최소화
- ✅ **재사용성**: Domain 로직을 다른 플랫폼(Web, Desktop)에서도 재사용 가능
- ❌ **없다면?**: UI 코드에 API 호출 + 비즈니스 로직이 섞임 → 테스트 불가 + 변경 파급 효과 큼

```
features/[feature_name]/
├── data/                          # 데이터 레이어 (외부와의 통신)
│   ├── models/                    # API 응답 DTO (JSON ↔ Dart 변환)
│   ├── datasources/               # 데이터 소스 (REST API, WebSocket 호출)
│   └── repositories/              # Repository 구현체 (DioException → Custom Exception 변환)
├── domain/                        # 도메인 레이어 (순수 비즈니스 로직)
│   ├── entities/                  # 비즈니스 엔티티 (앱 내부 데이터 구조)
│   ├── repositories/              # Repository 인터페이스 (추상화)
│   └── usecases/                  # Use Case (비즈니스 규칙 검증 및 실행)
└── presentation/                  # UI 레이어 (사용자 인터페이스)
    ├── providers/                 # Riverpod Provider (상태 관리 + UseCase 호출)
    ├── pages/                     # 화면 (ConsumerWidget)
    └── widgets/                   # 기능 특화 위젯 (해당 Feature 전용)
```

---

### 📁 features/auth/ (Google 로그인 및 인증)

**기능**: Google 소셜 로그인 및 JWT 토큰 관리

**왜 필요한가?**:
- ✅ **사용자 인증**: Google 소셜 로그인으로 사용자 신원 확인
- ✅ **보안**: JWT 토큰을 암호화 저장하여 API 호출 시 자동 인증 (Interceptor 사용)
- ✅ **토큰 갱신**: Access Token 만료 시 Refresh Token으로 자동 갱신
- ✅ **계층별 역할 분리**:
  - **Data**: Google SDK 호출 + 백엔드 API 호출 + 로컬 토큰 저장
  - **Domain**: 로그인/로그아웃 비즈니스 로직 (예: 이미 로그인된 경우 체크)
  - **Presentation**: 로그인 화면 + 인증 상태 관리 (로그인 중, 성공, 실패)

```
features/auth/
├── data/                                  # 데이터 레이어 (외부 통신 + 저장)
│   ├── models/
│   │   ├── auth_user.dart                 # 인증 사용자 모델 (API 응답 DTO)
│   │   ├── auth_user.freezed.dart
│   │   ├── auth_user.g.dart
│   │   ├── auth_token.dart                # JWT Access/Refresh Token DTO
│   │   ├── auth_token.freezed.dart
│   │   ├── auth_token.g.dart
│   │   └── login_request.dart             # 로그인 요청 DTO (idToken 전달)
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart    # 백엔드 인증 API (POST /api/auth/login)
│   │   ├── auth_local_datasource.dart     # 로컬 토큰 저장 (FlutterSecureStorage 사용)
│   │   └── social_auth_datasource.dart    # 소셜 로그인 SDK 통합 (GoogleSignIn)
│   └── repositories/
│       └── auth_repository_impl.dart      # Repository 구현체 (DataSource 조합)
│
├── domain/                                # 도메인 레이어 (순수 비즈니스 로직)
│   ├── entities/
│   │   └── user_entity.dart               # 사용자 엔티티 (앱 내부 데이터 구조)
│   ├── repositories/
│   │   └── auth_repository.dart           # Repository 인터페이스 (추상화)
│   └── usecases/
│       ├── google_sign_in_usecase.dart    # Google 로그인 Use Case (SDK → 백엔드 → 토큰 저장)
│       ├── refresh_token_usecase.dart     # Token 갱신 Use Case (Refresh Token → Access Token)
│       └── logout_usecase.dart            # 로그아웃 Use Case (토큰 삭제 + SDK 로그아웃)
│
└── presentation/                          # UI 레이어 (사용자 인터페이스)
    ├── providers/
    │   ├── auth_provider.dart             # 인증 상태 관리 (AsyncNotifier, UseCase 호출)
    │   └── auth_provider.g.dart
    ├── pages/
    │   └── login_page.dart                # 로그인 화면 (Google 로그인 버튼)
    └── widgets/
        └── google_sign_in_button.dart     # Google 로그인 버튼 위젯 (재사용 가능)
```

#### 파일 생성 예시: `social_auth_datasource.dart`

```dart
/// Google 로그인 SDK 통합 Data Source
class SocialAuthDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Google 로그인 실행
  ///
  /// 반환: ID Token (JWT)
  Future<String> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw AuthCancelledException('사용자가 로그인을 취소했습니다');
    }
    final auth = await account.authentication;
    if (auth.idToken == null) {
      throw AuthTokenException('ID Token을 가져올 수 없습니다');
    }
    return auth.idToken!;
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
```

#### 파일 생성 예시: `google_sign_in_usecase.dart`

```dart
/// Google 소셜 로그인 Use Case
///
/// 프로세스:
/// 1. Google Sign-In SDK로 ID Token 획득
/// 2. 백엔드에 ID Token 전송
/// 3. JWT Access/Refresh Token 수신
/// 4. SecureStorage에 토큰 저장
class GoogleSignInUseCase {
  final AuthRepository _repository;

  GoogleSignInUseCase(this._repository);

  /// Google 로그인 실행
  Future<UserEntity> execute() async {
    return await _repository.signInWithGoogle();
  }
}
```

#### 파일 생성 예시: `auth_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

/// 인증 상태 관리 Provider
///
/// 상태:
/// - null: 로그인 전
/// - UserEntity: 로그인 완료
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<UserEntity?> build() async {
    // 앱 시작 시 저장된 토큰 확인
    final storage = ref.read(secureStorageServiceProvider);
    final accessToken = await storage.getAccessToken();

    if (accessToken != null) {
      try {
        // 토큰이 있으면 사용자 정보 로드
        final usecase = ref.read(getCurrentUserUsecaseProvider);
        return await usecase.execute();
      } catch (e) {
        // 토큰 만료 시 null 반환
        return null;
      }
    }

    return null;
  }

  /// Google 로그인
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

  /// 로그아웃
  Future<void> logout() async {
    final usecase = ref.read(logoutUsecaseProvider);
    await usecase.execute();
    state = const AsyncValue.data(null);
  }
}
```

#### 백엔드 연동: `core/network/api_interceptor.dart` 수정

```dart
/// Dio Interceptor - JWT 토큰 자동 추가 및 갱신
class ApiInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;

  ApiInterceptor(this._storage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Access Token을 요청 헤더에 자동 추가
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 Unauthorized → Token 갱신 시도
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken != null) {
        try {
          // Refresh Token으로 새로운 Access Token 요청
          final response = await _dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          final newAccessToken = response.data['accessToken'];
          await _storage.saveAccessToken(newAccessToken);

          // 실패한 요청 재시도
          final retryRequest = err.requestOptions;
          retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await _dio.fetch(retryRequest);

          return handler.resolve(retryResponse);
        } catch (refreshError) {
          // Refresh Token도 만료 → 로그아웃 처리
          await _storage.clearAll();
        }
      }
    }

    handler.next(err);
  }
}
```

---

### 📁 features/session/ (세션 관리)

**PRD 매핑**: F1 - 게임 생성, 참가, 대기실

**왜 필요한가?**:
- ✅ **게임 생성**: 방장이 게임 설정 (라운드 시간, 경찰 대기 시간, 위치 공유 주기 등) 후 초대 코드 발급
- ✅ **입력 검증**: PRD 기반 검증 (라운드 시간 10~180분, 닉네임 2~10자, 초대 코드 6자리 등)을 UseCase에서 처리
- ✅ **참가자 관리**: 대기실에서 참가자 목록 표시, 팀 선택, 준비 상태 확인
- ✅ **계층별 역할 분리**:
  - **Data**: REST API 호출 (게임 생성, 참가) + 로컬 캐시 (현재 세션 정보)
  - **Domain**: 입력 검증 + 비즈니스 규칙 (예: 라운드 시간 10분 미만 불가)
  - **Presentation**: 게임 생성 화면 + 대기실 화면 + 상태 관리

```
features/session/
├── data/                                  # 데이터 레이어 (API 통신 + 로컬 캐시)
│   ├── models/
│   │   ├── game_session.dart              # 게임 세션 모델 (API 응답 DTO)
│   │   ├── game_session.freezed.dart      # Freezed 코드 생성
│   │   ├── game_session.g.dart            # JSON 직렬화 코드 생성
│   │   ├── participant.dart               # 참가자 모델 DTO
│   │   ├── participant.freezed.dart
│   │   ├── participant.g.dart
│   │   ├── invite_code.dart               # 초대 코드 모델 (6자리 영문/숫자)
│   │   └── create_session_request.dart    # API 요청 DTO (게임 생성 시 전송)
│   ├── datasources/
│   │   ├── session_remote_datasource.dart # REST API 호출 (POST /api/sessions, POST /api/sessions/join)
│   │   └── session_local_datasource.dart  # 로컬 캐시 (현재 세션 정보 저장)
│   └── repositories/
│       └── session_repository_impl.dart   # Repository 구현체 (DataSource 조합)
│
├── domain/                                # 도메인 레이어 (비즈니스 로직 + 검증)
│   ├── entities/
│   │   └── session_entity.dart            # 순수 비즈니스 엔티티 (앱 내부 데이터)
│   ├── repositories/
│   │   └── session_repository.dart        # Repository 인터페이스 (추상화)
│   └── usecases/
│       ├── create_session_usecase.dart    # F1.1 게임 생성 (검증: 라운드 10~180분, 경찰 대기 0~15분)
│       ├── join_session_usecase.dart      # F1.4 게임 참가 (검증: 초대 코드 6자리)
│       ├── set_nickname_usecase.dart      # F1.5 닉네임 설정 (검증: 2~10자, 한글/영문/숫자)
│       └── select_team_usecase.dart       # F1.6 팀 선택 (검증: 중복 방지)
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
  /// 반환: SessionEntity (또는 Exception throw)
  Future<SessionEntity> execute(
    CreateSessionRequest request,
  ) async {
    // 1. 검증: 라운드 시간 범위 체크
    if (request.roundTime < GameConfig.minRoundTime ||
        request.roundTime > GameConfig.maxRoundTime) {
      throw ValidationException('라운드 시간은 ${GameConfig.minRoundTime.inMinutes}~${GameConfig.maxRoundTime.inMinutes}분 사이여야 합니다');
    }

    // 2. Repository 호출
    return await _repository.createSession(request);
  }
}
```

---

### 📁 features/game/ (게임 로직 + 지도/위치 통합)

**PRD 매핑**:
- F2: 구역 설정, 지도 UI, 위치 공유, 구역 이탈 감지
- F3: 게임 시작/종료, 체포, 감옥, 승패 판정

**왜 map/을 game/으로 통합했는가?**:
- ✅ **강한 결합**: 지도/위치 기능은 게임 중에만 사용되며, 게임 로직과 분리 불가능
  - 예: 체포 버튼 활성화는 "상대가 50m 이내 + 게임 진행 중" 조건 모두 필요
  - 예: 구역 이탈 감지는 "현재 위치 + 게임 상태(플레이그라운드 좌표)" 동시 필요
- ✅ **중복 제거**: map/ 별도 분리 시 game/과 map/ 간 Provider 상호 의존 발생 → 순환 참조 위험
- ✅ **복잡도 감소**: Feature를 분리하면 오히려 의존성 관리가 복잡해짐 (map ⇄ game 양방향 참조)
- ✅ **응집도**: 게임 관련 모든 기능(로직 + 지도 + 위치)을 한 곳에서 관리하여 이해 및 수정 용이
- ❌ **분리 시 문제**: game_provider와 map_provider가 서로 watch 필요 → 상태 동기화 어려움

**통합 후 장점**:
- 게임 로직과 지도/위치 기능을 하나의 Provider에서 관리 → 상태 일관성 보장
- 체포, 구역 이탈 등 게임+위치 복합 기능 구현 간소화
- 파일 구조 단순화 (features/game/ 하나로 통합)

```
features/game/
├── data/
│   ├── models/
│   │   ├── game_state.dart                # 게임 상태
│   │   ├── player_state.dart              # 플레이어 상태
│   │   ├── capture_record.dart            # 체포 기록
│   │   ├── game_area.dart                 # F2: 플레이그라운드/감옥 구역
│   │   ├── location_data.dart             # F2: GPS 좌표
│   │   └── footprint.dart                 # F2: 도둑 발자국
│   ├── datasources/
│   │   ├── game_remote_datasource.dart
│   │   ├── location_remote_datasource.dart  # F2: 위치 API
│   │   └── location_stream_datasource.dart  # F2: GPS 스트림
│   └── repositories/
│       ├── game_repository_impl.dart
│       └── map_repository_impl.dart       # F2: 지도/위치 Repository
│
├── domain/
│   ├── entities/
│   │   ├── game_entity.dart
│   │   └── game_boundary_entity.dart      # F2: 게임 구역
│   ├── repositories/
│   │   ├── game_repository.dart
│   │   └── map_repository.dart            # F2: 지도/위치 Repository
│   └── usecases/
│       ├── start_game_usecase.dart        # F3.1 게임 시작
│       ├── capture_robber_usecase.dart    # F3.2 체포
│       ├── arrive_at_jail_usecase.dart    # F3.3 감옥 도착
│       ├── end_game_usecase.dart          # F3.4 게임 종료 판정
│       ├── set_playground_usecase.dart    # F2.1 플레이그라운드 설정
│       ├── set_jail_usecase.dart          # F2.1 감옥 설정
│       ├── track_location_usecase.dart    # F2.2 위치 추적
│       └── detect_zone_exit_usecase.dart  # F2.4 구역 이탈 감지
│
└── presentation/
    ├── providers/
    │   ├── game_state_provider.dart
    │   ├── timer_provider.dart            # F4.1 타이머 관리
    │   ├── map_provider.dart              # F2: 지도 상태
    │   └── location_provider.dart         # F2: 위치 추적
    ├── pages/
    │   ├── game_screen.dart               # 메인 게임 화면 (지도 포함)
    │   └── area_setup_page.dart           # F2.1 구역 설정 화면
    │   # Note: 결과 화면(F3.4)은 별도 페이지가 아닌 game_screen.dart 내부에서
    │   # 모달을 띄우는 방식으로 표시 
    └── widgets/
        ├── game_hud.dart                  # F4.1 HUD (타이머, 현황)
        ├── capture_dialog.dart            # F3.2 체포 다이얼로그
        ├── jail_arrival_button.dart       # F3.3 감옥 도착 버튼
        ├── game_map.dart                  # F2.2 인게임 지도
        ├── playground_circle_painter.dart # F2: 경계선 그리기
        ├── jail_marker.dart               # F2: 감옥 마커
        └── footprint_marker.dart          # F2.3 발자국 표시
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
/// - 에러 처리 (try-catch 패턴)
class CreateSessionUseCase {
  final SessionRepository _repository;

  CreateSessionUseCase(this._repository);

  Future<SessionEntity> execute(
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

    try {
      final usecase = ref.read(createSessionUsecaseProvider);
      final session = await usecase.execute(request);
      state = AsyncValue.data(session);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
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

### Q6: 왜 이렇게 복잡하게 구조를 나눈 건가요?

**A**: 단기적으로는 복잡해 보이지만, 장기적으로 다음과 같은 이점이 있습니다:

| 측면 | 복잡한 구조 (Clean Architecture) | 단순한 구조 (UI에 모든 로직) |
|------|----------------------------------|------------------------------|
| **테스트** | ✅ Domain 계층 단독 테스트 가능 (UI 없이) | ❌ UI와 함께 테스트해야 함 (느림) |
| **API 변경** | ✅ data/ 계층만 수정 (다른 계층 영향 없음) | ❌ UI 코드까지 모두 수정 필요 |
| **UI 변경** | ✅ presentation/ 계층만 수정 | ❌ 로직 코드와 섞여서 위험 |
| **재사용** | ✅ Domain 로직을 Web/Desktop에서 재사용 | ❌ 모든 플랫폼에서 코드 재작성 |
| **협업** | ✅ 백엔드 개발자가 data/ 수정, UI 개발자가 presentation/ 수정 가능 | ❌ 모든 개발자가 동일 파일 수정 (충돌 발생) |

**실제 예시**:
- API 응답 구조 변경 시: `data/models/` 파일만 수정 → Domain, Presentation 영향 없음
- UI 디자인 변경 시: `presentation/pages/` 파일만 수정 → 비즈니스 로직 안전

### Q7: Model과 Entity를 왜 분리하나요? 같은 데이터 아닌가요?

**A**: 목적과 책임이 다릅니다:

| 구분 | Data Model (DTO) | Domain Entity |
|------|------------------|---------------|
| **위치** | `data/models/` | `domain/entities/` |
| **역할** | API 응답 JSON ↔ Dart 변환 | 앱 내부 비즈니스 데이터 |
| **의존성** | API 구조에 의존 (외부) | 순수 Dart (외부 의존성 없음) |
| **변경 이유** | 백엔드 API 변경 시 | 비즈니스 요구사항 변경 시 |
| **어노테이션** | `@freezed`, `@JsonSerializable` | 없음 (순수 Dart 클래스) |

**실제 예시**:
```dart
// data/models/game_session.dart (API DTO)
@freezed
class GameSession with _$GameSession {
  factory GameSession({
    required String sessionId,        // 백엔드 응답: "sessionId"
    required int maxPlayerCount,      // 백엔드 응답: "maxPlayerCount"
  }) = _GameSession;

  factory GameSession.fromJson(Map<String, dynamic> json) => _$GameSessionFromJson(json);
}

// domain/entities/session_entity.dart (비즈니스 엔티티)
class SessionEntity {
  final String id;                    // 앱 내부: "id" (sessionId에서 변환)
  final int maxPlayers;               // 앱 내부: "maxPlayers" (더 명확한 이름)

  const SessionEntity({required this.id, required this.maxPlayers});

  // API 응답과 무관하게 비즈니스 로직 추가 가능
  bool get isFull => currentPlayers >= maxPlayers;
}
```

**장점**:
- 백엔드 API 변경 시 Model만 수정 → Entity 영향 없음
- 앱 내부에서 더 명확한 이름 사용 가능 (sessionId → id)
- Domain 계층이 외부 의존성 없이 독립적으로 동작

### Q8: core/와 features/의 차이는 뭔가요?

**A**: 사용 범위와 재사용성으로 구분합니다:

| 구분 | core/ | features/ |
|------|-------|-----------|
| **사용 범위** | 앱 전체 (모든 Feature) | 특정 기능에만 사용 |
| **재사용성** | 높음 (범용) | 낮음 (기능 특화) |
| **의존성 방향** | features → core (허용) | features → features (❌ 금지) |
| **예시** | constants, network, widgets | auth, session, game |

**실제 예시**:
```
✅ 올바른 의존성:
features/auth/ → core/network/dio_client.dart (허용)
features/session/ → core/widgets/app_button.dart (허용)
features/game/ → core/constants/game_config.dart (허용)

❌ 잘못된 의존성:
features/auth/ → features/session/ (금지! Feature 간 직접 의존 금지)
core/widgets/ → features/auth/ (금지! Core는 Feature에 의존 불가)
```

**판단 기준**:
- **2개 이상의 Feature에서 사용하나요?** → `core/`
- **1개의 Feature에서만 사용하나요?** → `features/[기능명]/`

**예외 상황**: Feature 간 데이터 공유 필요 시
- ❌ 직접 의존: `features/game/` → `features/session/`
- ✅ Provider를 통한 참조: `features/game/`에서 `sessionProvider.watch()` 사용

---

**문서 작성**: Development Team
**최종 업데이트**: 2025-12-30
**다음 리뷰 예정일**: 2026-01-30
