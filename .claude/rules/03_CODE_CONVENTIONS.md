# 코드 컨벤션 가이드 (Code Conventions Guide)

> **작성일**: 2025-12-30
> **대상 독자**: 개발자, 신규 팀원
> **문서 버전**: 1.0.0

---

## 📋 목차

1. [개요](#개요)
2. [Dart 언어 규칙](#dart-언어-규칙)
3. [주석 및 문서화](#주석-및-문서화)
4. [에러 처리](#에러-처리)
5. [디버그 및 로깅](#디버그-및-로깅)
6. [위젯 작성 규칙](#위젯-작성-규칙)
7. [테스트 코드 규칙](#테스트-코드-규칙)
8. [코드 리뷰 체크리스트](#코드-리뷰-체크리스트)

---

## 개요

이 문서는 '경찰과 도둑' Flutter 프로젝트의 **코드 작성 규칙**을 정의합니다.

### 문서 범위

- ✅ **Dart 언어 사용 규칙** (변수 선언, Null Safety, 비동기 코드)
- ✅ **주석 및 문서화 방법** (DartDoc, 한글/영문 병행)
- ✅ **에러 처리 패턴** (try-catch, Custom Exception)
- ✅ **디버그 및 로깅 규칙** (debugPrint, 이모지 사용)
- ✅ **위젯 작성 규칙** (StatelessWidget vs StatefulWidget)
- ✅ **테스트 코드 작성 규칙**

### 관련 문서

**다른 문서와의 관계**:
- **[ARCHITECTURE.md](ARCHITECTURE.md)**: 아키텍처 전략, 계층 구조 → 이 문서는 **코드 작성 방법**
- **[FOLDER_STRUCTURE.md](FOLDER_STRUCTURE.md)**: 폴더 구조, 파일 배치 → 이 문서는 **코드 내부 규칙**
- **[CODE_GENERATION_GUIDE.md](CODE_GENERATION_GUIDE.md)**: Freezed, Riverpod 사용법 → 이 문서는 **일반 Dart 코드 규칙**

---

## Dart 언어 규칙

### 1. 변수 선언

#### 1-1. final vs const vs var

```dart
// ✅ 올바른 예시
final String userName = 'John';        // 런타임 상수 (값은 실행 시 결정)
const int maxPlayers = 30;             // 컴파일 타임 상수
final DateTime now = DateTime.now();   // 런타임에만 값 결정 가능

// ❌ 잘못된 예시
var userName = 'John';                 // 타입 추론 가능하지만 명시 권장
const DateTime now = DateTime.now();   // 컴파일 에러! const는 컴파일 타임 상수만
```

**사용 기준**:
| 키워드 | 사용 시기 | 예시 |
|--------|----------|------|
| `const` | 컴파일 타임에 값이 확정되는 상수 | `const int maxValue = 100` |
| `final` | 런타임에 한 번만 할당되는 값 | `final String id = uuid.v4()` |
| `var` | 타입 추론이 명확하고 간단한 경우 (지양) | `var count = 0` (대신 `int count = 0` 권장) |

---

#### 1-2. 타입 명시 vs 추론

```dart
// ✅ 올바른 예시 - 타입 명시 (가독성 우선)
final String userName = 'John';
final List<String> tags = ['flutter', 'dart'];
final Map<String, int> scores = {'Alice': 100, 'Bob': 95};

// ✅ 허용되는 경우 - 타입 추론이 명확할 때
final userName = 'John';  // String으로 추론 가능
final count = 0;          // int로 추론 가능

// ❌ 잘못된 예시 - 타입 추론이 불명확
final data = getData();   // 반환 타입이 명확하지 않으면 타입 명시 필요
```

**권장 사항**:
- Public API (함수 파라미터, 반환값): **항상 타입 명시**
- Private 변수: 타입 추론 허용 (단, 명확한 경우만)

---

### 2. Null Safety

#### 2-1. Nullable 타입 (`?`, `!`, `??`, `?.`)

```dart
// ✅ 올바른 Null Safety 사용
String? nullableName;                  // Nullable 타입
String nonNullName = 'John';           // Non-nullable 타입

// Null 체크
if (nullableName != null) {
  print(nullableName.length);          // 안전하게 접근
}

// Null-aware operator
final displayName = nullableName ?? 'Guest';  // null이면 'Guest' 사용
final length = nullableName?.length;          // null이면 null 반환

// ❌ 잘못된 예시
print(nullableName!.length);           // ! 연산자 남용 (런타임 에러 위험)
```

**사용 기준**:
| 연산자 | 사용 시기 | 주의사항 |
|--------|----------|----------|
| `?` | 변수가 null일 수 있을 때 | Nullable 타입 선언 |
| `!` | **100% null이 아님을 확신할 때만** | 남용 금지! 가능하면 if 체크 |
| `??` | null일 때 기본값 제공 | `value ?? defaultValue` |
| `?.` | null 체크 후 접근 | `user?.name` (null이면 null 반환) |

---

#### 2-2. late 키워드

```dart
// ✅ 올바른 late 사용
class GameSession {
  late final String sessionId;  // 생성자 외부에서 초기화 예정

  void initialize() {
    sessionId = uuid.v4();      // 나중에 초기화
  }
}

// ✅ 허용되는 경우 - 순환 참조 방지
class Widget {
  late final ThemeData theme = _computeTheme();  // 초기화 지연
}

// ❌ 잘못된 예시
late String userName;  // 초기화 전 접근 시 런타임 에러
print(userName);       // 에러 발생!
```

**주의사항**: `late` 사용 시 반드시 접근 전에 초기화 필요

---

### 3. Collections

#### 3-1. List, Set, Map 초기화

```dart
// ✅ 올바른 Collections 초기화
final List<String> tags = [];                     // 빈 리스트
final List<String> names = ['Alice', 'Bob'];      // 초기값 포함

final Set<int> uniqueIds = {};                    // 빈 Set
final Set<int> scores = {100, 95, 100};           // 중복 제거

final Map<String, int> ages = {};                 // 빈 Map
final Map<String, int> userAges = {
  'Alice': 25,
  'Bob': 30,
};

// ❌ 잘못된 예시
final tags = [];                                  // 타입 추론 불가능 (List<dynamic>)
final Map ages = {};                              // 제네릭 타입 명시 필요
```

---

#### 3-2. Spread Operator (`...`)

```dart
// ✅ 올바른 Spread Operator 사용
final list1 = [1, 2, 3];
final list2 = [4, 5, 6];
final combined = [...list1, ...list2];  // [1, 2, 3, 4, 5, 6]

// Conditional spread
final extraItems = shouldInclude ? [...additionalItems] : [];
final finalList = [...baseItems, ...extraItems];

// ❌ 잘못된 예시
final combined = list1 + list2;  // 성능 저하 (새 리스트 생성)
```

---

#### 3-3. Collection if/for

```dart
// ✅ 올바른 Collection if 사용
final items = [
  'Apple',
  'Banana',
  if (shouldIncludeOrange) 'Orange',  // 조건부 추가
];

// Collection for 사용
final numbers = [1, 2, 3];
final doubled = [
  for (var num in numbers) num * 2,  // [2, 4, 6]
];

// ❌ 잘못된 예시
final items = ['Apple', 'Banana'];
if (shouldIncludeOrange) {
  items.add('Orange');  // 불변성 위반 가능
}
```

---

### 4. 비동기 코드

#### 4-1. async/await 패턴

```dart
// ✅ 올바른 async/await 사용
Future<User> fetchUser(String userId) async {
  final response = await apiClient.getUser(userId);
  return User.fromJson(response.data);
}

// 여러 비동기 작업 병렬 처리
Future<void> loadData() async {
  final results = await Future.wait([
    fetchUser('user1'),
    fetchUser('user2'),
  ]);
}

// ❌ 잘못된 예시
Future<User> fetchUser(String userId) {
  return apiClient.getUser(userId).then((response) {
    return User.fromJson(response.data);  // then 체인보다 async/await 권장
  });
}
```

---

#### 4-2. Future vs Stream

```dart
// ✅ Future 사용 (1회성 비동기 작업)
Future<GameSession> createSession() async {
  final session = await api.createSession();
  return session;
}

// ✅ Stream 사용 (지속적인 데이터 흐름)
Stream<LocationData> watchLocation() {
  return Geolocator.getPositionStream().map(
    (position) => LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
    ),
  );
}

// ❌ 잘못된 예시
Future<List<ChatMessage>> watchMessages() async {
  // Stream 사용해야 함! Future는 1회성
  return await api.getMessages();
}
```

**사용 기준**:
| 타입 | 사용 시기 | 예시 |
|------|----------|------|
| `Future<T>` | 1회성 비동기 작업 | API 호출, 파일 읽기 |
| `Stream<T>` | 지속적인 데이터 흐름 | WebSocket, GPS 위치, 타이머 |

---

#### 4-3. StreamController 사용

```dart
// ✅ 올바른 StreamController 사용
class ChatService {
  final StreamController<ChatMessage> _messageController =
      StreamController.broadcast();  // 여러 리스너 허용

  Stream<ChatMessage> get messages => _messageController.stream;

  void addMessage(ChatMessage message) {
    _messageController.add(message);
  }

  void dispose() {
    _messageController.close();  // ⚠️ 필수: 메모리 누수 방지
  }
}

// ❌ 잘못된 예시
class ChatService {
  final StreamController<ChatMessage> _messageController =
      StreamController();  // broadcast 누락 시 여러 리스너 에러

  // dispose() 누락 → 메모리 누수!
}
```

**주의사항**:
- ✅ `StreamController.broadcast()` 사용 (여러 리스너 지원)
- ✅ `dispose()`에서 `close()` 호출 필수

---

### 5. Cascade Notation (`..`)

```dart
// ✅ 올바른 Cascade 사용
final button = ElevatedButton(
  onPressed: () {},
  child: const Text('Click'),
)
  ..style = ButtonStyle()  // Cascade로 연속 설정
  ..tooltip = 'Submit';

// Paint 객체 설정
final paint = Paint()
  ..color = Colors.blue
  ..strokeWidth = 5.0
  ..style = PaintingStyle.stroke;

// ❌ 잘못된 예시
final button = ElevatedButton(
  onPressed: () {},
  child: const Text('Click'),
);
button.style = ButtonStyle();  // Cascade 사용이 더 간결
button.tooltip = 'Submit';
```

---

## 주석 및 문서화

### 1. DartDoc 주석 (`///`)

#### 1-1. 기본 규칙

```dart
/// Firebase Cloud Messaging 서비스
/// FCM 푸시 알림을 관리하고 메시지를 처리합니다
///
/// **주요 기능**:
/// - FCM 토큰 발급 및 관리
/// - 푸시 알림 수신 및 처리
/// - 알림 탭 이벤트 핸들링
class FirebaseMessagingService {
  // Private constructor for singleton pattern
  // 싱글톤 패턴을 위한 private 생성자
  FirebaseMessagingService._internal();

  /// 백엔드 등록용 FCM 토큰을 가져옵니다
  ///
  /// 로그인 API 호출 시 이 메서드를 사용하여 FCM 토큰을 가져옵니다.
  ///
  /// **주의**:
  /// - iOS 시뮬레이터에서는 토큰을 사용할 수 없어 null을 반환합니다
  /// - 권한이 거부된 경우에도 null을 반환합니다
  ///
  /// Returns:
  /// - 성공: FCM 토큰 문자열
  /// - 실패/시뮬레이터: null
  Future<String?> getFcmToken() async {
    // 구현...
  }
}
```

**DartDoc 작성 규칙**:
1. **첫 줄**: 간단한 한 줄 설명 (한글)
2. **두 번째 줄**: 상세 설명 (한글)
3. **빈 줄** 후 추가 정보
4. **주의사항**: `**주의**:` 볼드체 사용
5. **파라미터 설명**: 각 파라미터마다 설명
6. **반환값 설명**: Returns 섹션에 명시

---

#### 1-2. 사용 예시 포함

```dart
/// 앱 전역 TextStyle 상수
///
/// 사용법:
/// ```dart
/// // 기본 사용
/// Text('제목', style: AppTextStyles.heading1)
///
/// // Weight 변경
/// Text('강조', style: AppTextStyles.heading1.bold())
///
/// // 색상 추가
/// Text('경고', style: AppTextStyles.body1.medium().copyWith(
///   color: Colors.red,
/// ))
/// ```
class AppTextStyles {
  // ...
}
```

**사용 예시 작성 규칙**:
- ✅ 코드 블록 (``` ``` `) 안에 예시 작성
- ✅ 주석으로 각 예시 설명
- ✅ 실제 동작하는 코드 작성

---

### 2. 한글/영문 병행 주석

#### 2-1. 주석 패턴

**프로젝트 표준**: 영문 주석 먼저, 한글 주석 후행

```dart
// ✅ 올바른 주석 패턴
class FirebaseMessagingService {
  // Private constructor for singleton pattern
  // 싱글톤 패턴을 위한 private 생성자
  FirebaseMessagingService._internal();

  // Singleton instance
  // 싱글톤 인스턴스
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  // Reference to local notifications service for displaying notifications
  // 알림 표시를 위한 로컬 알림 서비스 참조
  LocalNotificationsService? _localNotificationsService;
}

// ❌ 잘못된 예시
class FirebaseMessagingService {
  // 싱글톤 패턴을 위한 private 생성자 (한글만)
  FirebaseMessagingService._internal();

  // Private constructor (영문만)
  FirebaseMessagingService._internal();
}
```

---

#### 2-2. 섹션 구분자

```dart
class AppTextStyles {
  // Private 생성자 - 인스턴스화 방지
  AppTextStyles._();

  // ============================================
  // Heading Styles (제목)
  // ============================================

  /// Heading 1 - 메인 타이틀 (32sp)
  static TextStyle get heading1 =>
      TextStyle(fontFamily: 'Pretendard-Regular', fontSize: 32.sp);

  // ============================================
  // Body Styles (본문)
  // ============================================

  /// Body 1 - 본문 강조 (16sp)
  static TextStyle get body1 =>
      TextStyle(fontFamily: 'Pretendard-Regular', fontSize: 16.sp);
}
```

**섹션 구분자 규칙**:
- ✅ `// ============================================` 사용
- ✅ 섹션 제목은 영문 + 한글 병행
- ✅ 관련 코드 그룹화

---

### 3. TODO/FIXME/HACK 주석

```dart
// ✅ 올바른 TODO 주석
// TODO: Add navigation or specific handling based on message data
// TODO: 메시지 데이터를 기반으로 화면 이동 또는 특정 처리를 추가하세요
void _onMessageOpenedApp(RemoteMessage message) {
  // 구현...
}

// FIXME: 권한 거부 시 재요청 로직 추가 필요
Future<void> _requestPermission() async {
  // 구현...
}

// HACK: 임시 해결책 - 추후 리팩토링 필요
final token = await getFcmToken();

// ❌ 잘못된 예시
// todo 권한 처리 (소문자, 설명 불충분)
// TODO (이유 없음)
```

**TODO 주석 규칙**:
- ✅ **TODO**: 미래에 추가할 기능
- ✅ **FIXME**: 버그 또는 개선 필요
- ✅ **HACK**: 임시 해결책
- ✅ 항상 이유 및 설명 포함

---

### 4. 복잡한 로직 설명

```dart
// ✅ 올바른 로직 설명 주석
Future<void> _handlePushNotificationsToken() async {
  // 1. Get device information first (always runs, even on simulator)
  // 1. 먼저 기기 정보 수집 (시뮬레이터에서도 항상 실행됨)
  final deviceName = await DeviceInfoService.getDeviceName();
  final deviceType = DeviceInfoService.getDeviceType();

  // 2. Print device info (always visible, even on simulator)
  // 2. 기기 정보 출력 (시뮬레이터에서도 항상 표시됨)
  debugPrint('📱 Device Name: $deviceName');
  debugPrint('📱 Device Type: $deviceType');

  // 3. Try to get FCM token (may fail on iOS simulator)
  // 3. FCM 토큰 가져오기 시도 (iOS 시뮬레이터에서는 실패할 수 있음)
  final token = await getFcmToken();

  // 4. Setup token refresh listener if token exists
  // 4. 토큰이 있으면 갱신 리스너 등록
  if (token != null) {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // 토큰 갱신 처리
    });
  }
}
```

**복잡한 로직 주석 규칙**:
- ✅ 단계별로 번호 매기기 (1. 2. 3.)
- ✅ 각 단계마다 영문/한글 설명
- ✅ 왜 이렇게 했는지 이유 설명

---

## 에러 처리

### 1. try-catch 패턴

#### 1-1. 기본 에러 처리

**프로젝트 표준**: Either 패턴 제거, try-catch 사용

```dart
// ✅ 올바른 try-catch 패턴
Future<String?> getFcmToken() async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      debugPrint('[FCM] ✅ 토큰 가져오기 성공: ${token.substring(0, 20)}...');
    } else {
      debugPrint('[FCM] ⚠️ 토큰 없음 (시뮬레이터 또는 권한 거부)');
    }
    return token;
  } catch (e) {
    debugPrint('[FCM] ❌ 토큰 가져오기 실패: $e');
    return null;
  }
}

// ❌ 잘못된 예시 (Either 패턴 사용 금지)
Future<Either<Failure, String>> getFcmToken() async {
  // 프로젝트에서 제거됨!
}
```

---

#### 1-2. 구체적인 에러 타입 처리

```dart
// ✅ 올바른 구체적 에러 처리
Future<GameSession> createSession(CreateSessionRequest request) async {
  try {
    final session = await api.createSession(request);
    return session;
  } on DioException catch (e) {
    // HTTP 에러 처리
    if (e.response?.statusCode == 400) {
      debugPrint('❌ API Error (400): ${e.response?.data}');
      throw ValidationException('잘못된 요청입니다');
    } else if (e.response?.statusCode == 500) {
      debugPrint('❌ API Error (500): Server Error');
      throw ServerException('서버 에러가 발생했습니다');
    }
    throw NetworkException('네트워크 연결을 확인하세요');
  } on FormatException catch (e) {
    // JSON 파싱 에러
    debugPrint('❌ Format Error: $e');
    throw DataFormatException('데이터 형식이 잘못되었습니다');
  } catch (e) {
    // 기타 에러
    debugPrint('❌ Unknown Error: $e');
    throw UnknownException(e.toString());
  }
}
```

**에러 처리 규칙**:
1. **구체적인 에러 먼저** (`on DioException`, `on FormatException`)
2. **일반 catch 마지막** (`catch (e)`)
3. **에러 로깅 필수** (`debugPrint`)
4. **사용자 친화적 에러 메시지**

---

### 2. Custom Exception 정의

#### 2-1. Exception 클래스 생성

```dart
// ✅ 올바른 Custom Exception 정의
// lib/core/errors/exceptions.dart

/// 인증 관련 예외
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}

/// 네트워크 관련 예외
class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// 검증 실패 예외
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  const ValidationException(this.message, {this.errors});

  @override
  String toString() => 'ValidationException: $message';
}
```

---

#### 2-2. Exception 사용 예시

```dart
// ✅ 올바른 Custom Exception 사용
Future<String> signInWithGoogle() async {
  final account = await _googleSignIn.signIn();
  if (account == null) {
    throw AuthException('사용자가 로그인을 취소했습니다', code: 'CANCELLED');
  }

  final auth = await account.authentication;
  if (auth.idToken == null) {
    throw AuthException('ID Token을 가져올 수 없습니다', code: 'NO_TOKEN');
  }

  return auth.idToken!;
}

// 호출하는 쪽에서 처리
try {
  final token = await signInWithGoogle();
} on AuthException catch (e) {
  if (e.code == 'CANCELLED') {
    // 사용자 취소는 조용히 처리
    debugPrint('⚠️ 사용자가 로그인을 취소했습니다');
  } else {
    // 다른 에러는 UI에 표시
    showErrorDialog(e.message);
  }
}
```

---

### 3. UI 에러 처리

#### 3-1. Riverpod AsyncValue 에러 처리

```dart
// ✅ 올바른 Riverpod 에러 처리
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<UserEntity?> build() async {
    // 초기화...
    return null;
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final usecase = ref.read(googleSignInUsecaseProvider);
      final user = await usecase.execute();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      // 에러 상태로 변경 (UI에서 처리)
      state = AsyncValue.error(e, stack);
    }
  }
}

// UI에서 에러 표시
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (user) => HomeScreen(user: user),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) {
        // 에러 타입별 처리
        if (error is AuthException) {
          return ErrorWidget(message: error.message);
        }
        return ErrorWidget(message: '알 수 없는 오류가 발생했습니다');
      },
    );
  }
}
```

---

## 디버그 및 로깅

### 1. debugPrint vs print

```dart
// ✅ 올바른 로깅 - debugPrint 사용
debugPrint('✅ FCM 토큰 가져오기 성공');
debugPrint('⚠️ 토큰 없음 (시뮬레이터)');
debugPrint('❌ 에러 발생: $error');

// ❌ 잘못된 예시 - print 사용 금지
print('Success');  // Flutter에서 출력 누락 가능성
```

**사용 기준**:
- ✅ **debugPrint**: 항상 사용 (Flutter 최적화)
- ❌ **print**: 사용 금지

---

### 2. 이모지 로깅 패턴

**프로젝트 표준 이모지**:

| 이모지 | 의미 | 사용 시기 | 예시 |
|--------|------|----------|------|
| ✅ | 성공 | 정상 완료 | `debugPrint('✅ 로그인 성공')` |
| ❌ | 에러 | 에러 발생 | `debugPrint('❌ API 호출 실패: $e')` |
| ⚠️ | 경고 | 주의 필요 | `debugPrint('⚠️ 토큰 없음')` |
| 🔄 | 진행 중 | 작업 진행 | `debugPrint('🔄 토큰 갱신 중...')` |
| 📱 | 기기 정보 | 디바이스 정보 | `debugPrint('📱 Device: $name')` |
| 🔍 | 디버깅 | 상세 정보 | `debugPrint('🔍 Response: $data')` |
| 💡 | 안내 | 도움말 | `debugPrint('💡 시뮬레이터에서는 토큰 없음')` |

---

### 3. 로그 레벨 구분

```dart
// ✅ 올바른 로그 레벨 구분
void fetchData() async {
  // INFO: 일반 정보
  debugPrint('🔍 데이터 가져오기 시작');

  try {
    final data = await api.fetchData();

    // SUCCESS: 성공
    debugPrint('✅ 데이터 가져오기 성공: ${data.length}건');
  } catch (e) {
    // ERROR: 에러
    debugPrint('❌ 데이터 가져오기 실패: $e');

    // WARNING: 경고
    if (e is NetworkException) {
      debugPrint('⚠️ 네트워크 연결을 확인하세요');
    }
  }
}
```

---

### 4. kDebugMode 조건부 로깅

```dart
// ✅ 올바른 조건부 로깅
import 'package:flutter/foundation.dart';

void printDeviceInfo() async {
  final deviceName = await DeviceInfoService.getDeviceName();
  debugPrint('📱 Device Name: $deviceName');

  // 개발 환경에서만 상세 정보 출력
  if (kDebugMode) {
    final fullDeviceInfo = await DeviceInfoService.getFullDeviceInfo();
    debugPrint('📱 Full Device Info: $fullDeviceInfo');
  }
}

// ❌ 잘못된 예시
void printDeviceInfo() async {
  final fullDeviceInfo = await DeviceInfoService.getFullDeviceInfo();
  debugPrint('📱 Full Device Info: $fullDeviceInfo');  // 프로덕션에서도 출력됨
}
```

**kDebugMode 사용 규칙**:
- ✅ 상세 디버깅 정보는 `kDebugMode` 안에서만
- ✅ 프로덕션에 영향 없는 정보만 출력

---

## 위젯 작성 규칙

### 1. StatelessWidget vs StatefulWidget

#### 1-1. 선택 기준

| 위젯 타입 | 사용 시기 | 예시 |
|----------|----------|------|
| `StatelessWidget` | 상태가 없는 위젯 | 텍스트, 아이콘, 레이아웃 |
| `StatefulWidget` | 상태가 변경되는 위젯 | 입력 폼, 애니메이션, 타이머 |
| `ConsumerWidget` | Riverpod Provider 구독 | Provider 데이터 사용 |

---

#### 1-2. StatelessWidget 작성

```dart
// ✅ 올바른 StatelessWidget
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Google 로그인'),
    );
  }
}

// ❌ 잘못된 예시
class GoogleSignInButton extends StatelessWidget {
  GoogleSignInButton({required this.onPressed});  // const, super.key 누락

  final VoidCallback onPressed;
  // ...
}
```

**StatelessWidget 규칙**:
- ✅ `const` 생성자 사용
- ✅ `super.key` 전달
- ✅ `final` 필드만 사용

---

#### 1-3. StatefulWidget 작성

```dart
// ✅ 올바른 StatefulWidget
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  void dispose() {
    // 리소스 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('증가'),
        ),
      ],
    );
  }
}
```

**StatefulWidget 규칙**:
- ✅ `dispose()`에서 리소스 정리
- ✅ Private State 클래스 (`_CounterWidgetState`)
- ✅ `setState()` 안에서만 상태 변경

---

### 2. const 생성자

```dart
// ✅ 올바른 const 사용
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('제목'),           // const 위젯
        SizedBox(height: 16),  // const 위젯
      ],
    );
  }
}

// ❌ 잘못된 예시 - const 누락
class MyWidget extends StatelessWidget {
  MyWidget();  // const 누락

  @override
  Widget build(BuildContext context) {
    return Column(  // const 누락
      children: [
        Text('제목'),  // const 누락
      ],
    );
  }
}
```

**const 사용 이유**:
- ✅ 성능 최적화 (위젯 재사용)
- ✅ 불필요한 rebuild 방지

---

### 3. Key 사용

```dart
// ✅ 올바른 Key 사용
class UserListItem extends StatelessWidget {
  const UserListItem({
    super.key,  // 항상 전달
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(user.id),  // 고유 Key
      title: Text(user.name),
    );
  }
}

// 리스트에서 Key 사용
ListView.builder(
  itemCount: users.length,
  itemBuilder: (context, index) {
    final user = users[index];
    return UserListItem(
      key: ValueKey(user.id),  // 고유 Key 전달
      user: user,
    );
  },
)
```

**Key 사용 시기**:
- ✅ 리스트 아이템 (재정렬, 삭제 시)
- ✅ 동적 위젯 (조건부 렌더링)
- ✅ 애니메이션 위젯

---

### 4. BuildContext 사용

```dart
// ✅ 올바른 BuildContext 사용
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaQuery 사용
    final screenWidth = MediaQuery.of(context).size.width;

    // Theme 사용
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Navigator 사용
    return ElevatedButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NextPage()),
      ),
      child: const Text('다음'),
    );
  }
}

// ❌ 잘못된 예시
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  void _navigate(BuildContext context) {
    // async 후 BuildContext 사용 (위험)
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).push(...);  // 위젯이 dispose된 후 접근 가능
    });
  }
}

// ✅ 올바른 비동기 후 BuildContext 사용
void _navigate(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 1));

  // mounted 체크 (StatefulWidget)
  if (!mounted) return;

  Navigator.of(context).push(...);
}
```

---

## 테스트 코드 규칙

### 1. Unit Test 작성

#### 1-1. 테스트 파일 구조

```
test/
├── unit/
│   ├── services/
│   │   └── firebase_messaging_service_test.dart
│   └── utils/
│       └── validators_test.dart
├── widget/
│   └── widgets/
│       └── google_sign_in_button_test.dart
└── integration/
    └── auth_flow_test.dart
```

---

#### 1-2. Unit Test 예시

```dart
// test/unit/utils/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/core/utils/validators.dart';

void main() {
  group('Validators.validateNickname', () {
    test('정상 케이스: 유효한 닉네임은 null 반환', () {
      // Arrange
      const nickname = '홍길동';

      // Act
      final result = Validators.validateNickname(nickname);

      // Assert
      expect(result, isNull);
    });

    test('에러 케이스: 빈 문자열은 에러 메시지 반환', () {
      // Arrange
      const nickname = '';

      // Act
      final result = Validators.validateNickname(nickname);

      // Assert
      expect(result, '닉네임을 입력하세요');
    });

    test('에러 케이스: 2자 미만은 에러 메시지 반환', () {
      expect(Validators.validateNickname('a'), '닉네임은 2~10자 이내로 입력하세요');
    });

    test('에러 케이스: 10자 초과는 에러 메시지 반환', () {
      expect(
        Validators.validateNickname('12345678901'),
        '닉네임은 2~10자 이내로 입력하세요',
      );
    });

    test('에러 케이스: 특수문자 포함은 에러 메시지 반환', () {
      expect(
        Validators.validateNickname('홍길동!'),
        '한글, 영문, 숫자만 사용 가능합니다',
      );
    });
  });

  group('Validators.validateInviteCode', () {
    test('정상 케이스: 6자리 코드는 null 반환', () {
      expect(Validators.validateInviteCode('ABC123'), isNull);
    });

    test('에러 케이스: 5자리는 에러 반환', () {
      expect(Validators.validateInviteCode('ABC12'), '초대 코드는 6자리입니다');
    });
  });
}
```

---

### 2. Widget Test 작성

```dart
// test/widget/widgets/google_sign_in_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/features/auth/presentation/widgets/google_sign_in_button.dart';

void main() {
  group('GoogleSignInButton Widget', () {
    testWidgets('버튼이 정상적으로 렌더링된다', (tester) async {
      // Arrange
      var pressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Google 로그인'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('버튼 탭 시 onPressed 콜백 호출', (tester) async {
      // Arrange
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(pressed, true);
    });
  });
}
```

---

### 3. Mock 사용

```dart
// test/unit/services/firebase_messaging_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Mock 클래스 생성
@GenerateMocks([FirebaseMessaging])
import 'firebase_messaging_service_test.mocks.dart';

void main() {
  group('FirebaseMessagingService', () {
    late MockFirebaseMessaging mockFirebaseMessaging;

    setUp(() {
      mockFirebaseMessaging = MockFirebaseMessaging();
    });

    test('getFcmToken: 토큰이 있으면 반환', () async {
      // Arrange
      const expectedToken = 'test-token-123';
      when(mockFirebaseMessaging.getToken())
          .thenAnswer((_) async => expectedToken);

      // Act
      final token = await mockFirebaseMessaging.getToken();

      // Assert
      expect(token, expectedToken);
      verify(mockFirebaseMessaging.getToken()).called(1);
    });

    test('getFcmToken: 토큰이 없으면 null 반환', () async {
      // Arrange
      when(mockFirebaseMessaging.getToken()).thenAnswer((_) async => null);

      // Act
      final token = await mockFirebaseMessaging.getToken();

      // Assert
      expect(token, isNull);
    });
  });
}
```

---

## 코드 리뷰 체크리스트

### 기본 규칙
- [ ] **파일명**: snake_case 사용 (`user_profile.dart`)
- [ ] **클래스명**: PascalCase 사용 (`UserProfile`)
- [ ] **변수/메서드명**: camelCase 사용 (`userName`, `fetchUser()`)
- [ ] **상수명**: lowerCamelCase 또는 UPPER_SNAKE_CASE (`maxPlayers` 또는 `MAX_PLAYERS`)

### 변수 선언
- [ ] `final` vs `const` 적절히 사용
- [ ] Public API는 타입 명시
- [ ] Nullable 타입 (`?`) 명확히 표시

### 문서화
- [ ] Public API에 DartDoc (`///`) 주석 작성
- [ ] 복잡한 로직에 설명 주석 추가
- [ ] 한글/영문 병행 주석 (영문 먼저, 한글 후행)
- [ ] 사용 예시 코드 포함 (복잡한 API의 경우)

### 에러 처리
- [ ] try-catch로 에러 처리
- [ ] 구체적인 에러 타입 먼저 처리 (`on DioException`)
- [ ] 의미 있는 에러 메시지
- [ ] debugPrint로 에러 로깅

### 위젯
- [ ] StatelessWidget에 `const` 생성자 사용
- [ ] `super.key` 전달
- [ ] 리스트 아이템에 `key` 사용
- [ ] `dispose()`에서 리소스 정리 (StatefulWidget)

### 로깅
- [ ] debugPrint 사용 (print 금지)
- [ ] 이모지 로깅 패턴 사용 (✅, ❌, ⚠️)
- [ ] kDebugMode로 상세 로그 제한

### 테스트
- [ ] Unit Test 작성 (핵심 로직)
- [ ] Widget Test 작성 (UI 컴포넌트)
- [ ] Mock 사용 (외부 의존성)
- [ ] Edge Case 테스트

### 성능
- [ ] 불필요한 rebuild 방지 (`const` 위젯)
- [ ] StreamController `dispose()` 호출
- [ ] 메모리 누수 방지

---

**문서 작성**: Development Team
**최종 업데이트**: 2025-12-30
**다음 리뷰 예정일**: 2026-01-30
