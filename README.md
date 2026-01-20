# 경찰과 도둑 (Cops and Robbers)

> 위치 기반 실시간 멀티플레이어 모바일 게임

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📱 프로젝트 소개

'경찰과 도둑'은 오프라인에서 진행되던 전통적인 술래잡기 게임을 **위치 기반 기술**과 **실시간 동기화**로 디지털화한 Flutter 모바일 애플리케이션입니다.

### 핵심 기능

- 🗺️ **실시간 위치 추적**: GPS 기반 30명 동시 참가자 위치 동기화
- ⚡ **WebSocket 실시간 통신**: 게임 이벤트 즉각 전달 (체포, 위치 공개 등)
- 👥 **팀별 전용 채팅**: 경찰/도둑 팀 전략 소통 채널
- 🎮 **자동화된 게임 진행**: 수동 개입 없이 규칙 기반 자동 판정
- 📍 **구역 이탈 감지**: 플레이그라운드/감옥 경계 자동 모니터링

---

## 🚀 빠른 시작

### 필수 요구사항

- **Flutter SDK**: 3.9.2 이상
- **Dart SDK**: 3.9.2 이상
- **Android Studio / Xcode** (플랫폼별)
- **백엔드 서버** (또는 Mock 모드로 개발 가능)

### 설치 및 실행

```bash
# 1. 저장소 클론
git clone https://github.com/your-org/cops_and_robbers.git
cd cops_and_robbers

# 2. 의존성 설치
flutter pub get

# 3. 환경 변수 설정 (.env 파일 생성)
cp .env.example .env

# 4. 코드 생성 (Freezed, Riverpod, Retrofit)
flutter pub run build_runner build --delete-conflicting-outputs

# 5. 앱 실행
flutter run
```

---

## ⚙️ 환경 설정

### .env 파일 생성

프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 입력하세요:

```env
# 백엔드 API URL
API_BASE_URL=http://localhost:8080

# WebSocket URL
WS_URL=ws://localhost:8080/ws

# Mock API 사용 (true: Mock 데이터, false: 실제 API)
USE_MOCK_API=true
```

### EnvConfig 초기화

`lib/main.dart`에서 반드시 환경 변수를 초기화해야 합니다:

```dart
import 'package:cops_and_robbers/core/config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ 환경 변수 초기화 (필수)
  await EnvConfig.initialize();

  runApp(const MyApp());
}
```

### 개발 모드 vs 프로덕션 모드

- **개발 모드**: `USE_MOCK_API=true` → Mock 데이터 사용 (백엔드 없이 개발 가능)
- **프로덕션 모드**: `USE_MOCK_API=false` → 실제 백엔드 API 연결

---

## 🏗️ 프로젝트 아키텍처

### Clean Architecture 3계층 구조

본 프로젝트는 **Feature-First + Clean Architecture**를 사용합니다.

각 feature는 다음 3계층으로 구성됩니다:

```
features/[기능]/
├── data/           # 데이터 레이어
│   ├── models/     # API 응답 DTO (JSON ↔ Dart 변환)
│   ├── datasources/  # 데이터 소스 (Remote API, Local DB)
│   └── repositories/ # Repository 구현체
│
├── domain/         # 도메인 레이어
│   ├── entities/   # 비즈니스 엔티티 (불변 객체)
│   ├── repositories/ # Repository 인터페이스 (추상)
│   └── usecases/   # 비즈니스 로직 (Use Case)
│
└── presentation/   # 프레젠테이션 레이어
    ├── pages/      # 화면 단위
    ├── widgets/    # 재사용 가능한 UI 컴포넌트
    └── providers/  # Riverpod 상태 관리
```

### 의존성 흐름

```
Presentation → Domain → Data
    (UI)      (비즈니스 로직)  (API/DB)
```

**핵심 원칙**:
- Presentation 레이어는 Domain의 Use Case를 호출
- Domain 레이어는 Repository 인터페이스만 알고 구현체는 모름
- Data 레이어는 Domain의 Repository 인터페이스를 구현

**상세 설명**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

---

## 📂 프로젝트 구조

```
lib/
├── core/                          # 공통 인프라
│   ├── constants/                 # 앱 전역 상수
│   ├── config/                    # 환경 설정 (EnvConfig)
│   ├── network/                   # 네트워크 레이어 (Dio)
│   ├── realtime/                  # 실시간 통신 (WebSocket, STOMP)
│   ├── logging/                   # 로깅 시스템 (Logger, ErrorReporter)
│   ├── services/                  # 범용 서비스 (FCM, Storage)
│   ├── utils/                     # 유틸리티 함수 및 Extension
│   ├── errors/                    # 에러 정의 (Exception, Failure)
│   └── widgets/                   # 공통 UI 위젯
│
├── features/                      # Feature 모듈 (기능 중심)
│   ├── auth/                      # Google 로그인 및 인증
│   ├── session/                   # F1: 게임 세션 관리
│   ├── game/                      # F2+F3: 게임 로직 + 지도/위치 (통합)
│   ├── chat/                      # F4: 팀별 채팅
│   └── notification/              # F4: 알림 시스템
│
├── router/                        # 라우팅 설정
└── main.dart                      # 앱 진입점
```

**참고**: `features/map/` 폴더는 `features/game/`로 통합되었습니다. 게임 로직과 지도/위치 기능이 밀접하게 연관되어 하나의 feature로 관리합니다.

**상세 구조**: [docs/FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md)

---

## 🛠️ 기술 스택

### 핵심 프레임워크

- **Flutter 3.9.2+** - 크로스 플랫폼 UI 프레임워크
- **Dart 3.9.2+** - 프로그래밍 언어

### 상태 관리

- **Riverpod 2.6.1** - 선언적 상태 관리
- **Riverpod Generator** - 코드 생성 기반 Provider

### 데이터 모델

- **Freezed 2.5.7** - 불변 데이터 클래스 생성
- **json_serializable 6.9.2** - JSON 직렬화/역직렬화

### 네트워킹

- **Dio 5.9.0** - HTTP 클라이언트
- **Retrofit 4.7.2** - REST API 인터페이스 생성
- **stomp_dart_client 2.0.0** - WebSocket STOMP 프로토콜
- **web_socket_channel 3.0.0** - WebSocket 채널 관리

### 위치 서비스

- **Geolocator** - GPS 위치 추적
- **Google Maps Flutter** - 지도 표시

### 로컬 저장소

- **flutter_secure_storage 9.2.4** - 민감 데이터 암호화 저장 (JWT 토큰 등)
- **shared_preferences 2.3.4** - 로컬 설정 저장

### 알림

- **Firebase Cloud Messaging** - 푸시 알림
- **Flutter Local Notifications** - 로컬 알림

### UI/UX

- **flutter_screenutil 5.9.3** - 반응형 화면 대응
- **google_fonts** - 폰트 관리
- **flutter_svg 2.2.1** - SVG 아이콘

### 개발 도구

- **build_runner** - 코드 생성 도구
- **flutter_lints** - Dart 코드 분석

---

## 👨‍💻 개발 워크플로우

### 새 기능 추가 방법

1. **폴더 생성**: `lib/features/[기능명]/`

2. **3계층 구조 생성**:
   ```
   features/[기능명]/
   ├── data/
   │   ├── models/          # Freezed 모델 (@freezed, @JsonSerializable)
   │   ├── datasources/
   │   │   └── remote/      # Retrofit API (@RestApi)
   │   └── repositories/    # Repository 구현
   ├── domain/
   │   ├── entities/        # Freezed Entity (@freezed)
   │   ├── repositories/    # Repository 인터페이스 (abstract)
   │   └── usecases/        # Use Case
   └── presentation/
       ├── providers/       # Riverpod Provider (@riverpod)
       ├── pages/           # 화면
       └── widgets/         # UI 컴포넌트
   ```

3. **코드 생성**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **테스트**:
   ```bash
   flutter test
   ```

**상세 가이드**: [docs/CODE_GENERATION_GUIDE.md](docs/CODE_GENERATION_GUIDE.md)

---

## 🔧 코드 생성 (Code Generation)

### 언제 코드 생성이 필요한가?

본 프로젝트는 다음 패키지에서 **코드 자동 생성**을 사용합니다:

- **Riverpod** (`@riverpod`) → `*.g.dart` 생성
- **Freezed** (`@freezed`) → `*.freezed.dart` 생성
- **Retrofit** (`@RestApi`) → `*.g.dart` 생성
- **json_serializable** (`@JsonSerializable`) → `*.g.dart` 생성

### 코드 생성 명령어

```bash
# 1회 생성 (개발 중 주로 사용)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch 모드 (파일 변경 시 자동 생성)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 코드 생성이 필요한 시점

- ✅ `@riverpod`, `@freezed`, `@RestApi` 어노테이션 추가/수정 후
- ✅ `.g.dart`, `.freezed.dart` 파일이 없거나 오래된 경우
- ✅ 빌드 에러 발생 시 (generated file not found)

**상세 사용법**: [docs/CODE_GENERATION_GUIDE.md](docs/CODE_GENERATION_GUIDE.md)

---

## 🧪 테스트

```bash
# 모든 테스트 실행
flutter test

# 커버리지 리포트 생성
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📖 개발 문서

### 문서 가이드

| 문서 | 설명 | 언제 읽어야 하나요? |
|------|------|---------------------|
| [⭐ QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) | 빠른 참조 가이드 (핵심 규칙만 간결하게) | 코드 작성 중 빠르게 참조할 때 |
| [01_ARCHITECTURE.md](docs/01_ARCHITECTURE.md) | 아키텍처 상세, 기술 스택, 계층 구조, 실시간 통신 | 프로젝트 전체 구조와 설계 이해가 필요할 때 |
| [02_FOLDER_STRUCTURE.md](docs/02_FOLDER_STRUCTURE.md) | 폴더 구조, 파일 네이밍 규칙, 실제 예시 | 새 파일을 어디에 만들어야 할지 모를 때 |
| [03_CODE_CONVENTIONS.md](docs/03_CODE_CONVENTIONS.md) | 코딩 규칙, 네이밍 컨벤션, 에러 처리 패턴 | 코드 작성 전 또는 코드 리뷰 전 |
| [04_CODE_GENERATION_GUIDE.md](docs/04_CODE_GENERATION_GUIDE.md) | Riverpod, Freezed, Retrofit 코드 생성 가이드 | 코드 생성 방법이나 패턴을 모를 때 |
| [경찰과도둑_PRD_2.md](docs/경찰과도둑_PRD_2.md) | 제품 요구사항 문서 (PRD) | 비즈니스 요구사항 확인이 필요할 때 |

### 신규 개발자 온보딩 순서

1. **README.md** (현재 문서) - 프로젝트 개요 및 환경 설정
2. **⭐ QUICK_REFERENCE.md** - 핵심 규칙 빠른 파악 (코드 작성 시 참고용)
3. **01_ARCHITECTURE.md** - 아키텍처와 Clean Architecture 3계층 이해
4. **04_CODE_GENERATION_GUIDE.md** - 코드 생성 실습 (Riverpod, Freezed)
5. **02_FOLDER_STRUCTURE.md** - 폴더 구조와 파일 위치 파악
6. **03_CODE_CONVENTIONS.md** - 코딩 규칙 상세 내용

---

## 🐛 문제 해결 (Troubleshooting)

### 1. Build Runner 충돌

**에러**: `Conflicting outputs were detected...`

**해결**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. 환경 변수 로드 실패

**에러**: `dotenv.env['API_BASE_URL'] is null` 또는 `.env` 파일을 찾을 수 없음

**해결**:
1. `.env` 파일이 프로젝트 루트에 있는지 확인
2. `pubspec.yaml`의 `assets`에 `.env` 포함 확인
3. `main.dart`에서 `await EnvConfig.initialize()` 호출 확인

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.initialize(); // ⭐ 이 줄 필수
  runApp(const MyApp());
}
```

### 3. Google Sign-in 오류

**Android**:
- `android/app/google-services.json` 파일 존재 확인
- SHA-1 인증서 지문이 Firebase Console에 등록되어 있는지 확인

**iOS**:
- `ios/Runner/GoogleService-Info.plist` 파일 존재 확인
- Xcode → Runner → Signing & Capabilities → Bundle ID 일치 확인

### 4. WebSocket 연결 실패

**해결**:
1. `.env` 파일의 `WS_URL` 확인 (예: `ws://localhost:8080/ws`)
2. 백엔드 서버가 실행 중인지 확인
3. 개발 중이라면 `USE_MOCK_API=true` 설정

### 5. 코드 생성 파일이 import되지 않음

**에러**: `Target of URI doesn't exist: '*.g.dart'` 또는 `*.freezed.dart`

**해결**:
```bash
# 기존 생성 파일 삭제 후 재생성
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🤝 기여하기

프로젝트에 기여하고 싶으시다면 다음 가이드를 참고하세요.

### 브랜치 전략

- `main` - 프로덕션 배포
- `develop` - 개발 통합
- `feature/[기능명]` - 기능 개발 (예: `feature/chat-system`)

### Commit 규칙

```bash
feat(session): 게임 세션 생성 API 연동
fix(map): 구역 이탈 감지 로직 수정
docs(architecture): 아키텍처 문서 업데이트
refactor(auth): Google 로그인 로직 리팩토링
test(game): 게임 로직 단위 테스트 추가
```

### 코드 작성 규칙

- **Clean Architecture 3계층 구조** 준수
- **코드 생성 패턴** 사용 (Riverpod, Freezed, Retrofit)
- **코딩 규칙** 준수: [docs/CODE_CONVENTIONS.md](docs/CODE_CONVENTIONS.md)
- **테스트 작성** 권장

---

## 📝 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

---

## 📧 연락처

- **이슈 제보**: [GitHub Issues](https://github.com/your-org/cops_and_robbers/issues)
- **프로젝트 관리자**: [your-email@example.com](mailto:your-email@example.com)

---

<!-- AUTO-VERSION-SECTION: DO NOT EDIT MANUALLY -->
<!-- 이 섹션은 .github/workflows/PROJECT-README-VERSION-UPDATE.yaml에 의해 자동으로 업데이트됩니다 -->
<!-- 수정하지마세요 자동으로 동기화 됩니다 -->
<!-- AUTO-VERSION-SECTION: DO NOT EDIT MANUALLY -->
## 최신 버전 : v1.1.5 (2026-01-20)

[전체 버전 기록 보기](CHANGELOG.md)
<!-- END-AUTO-VERSION-SECTION -->

---

**Built with ❤️ by Development Team**
