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

### 설치 및 실행

```bash
# 1. 저장소 클론
git clone https://github.com/your-org/cops_and_robbers.git
cd cops_and_robbers

# 2. 의존성 설치
flutter pub get

# 3. 코드 생성 (Freezed, Riverpod, Retrofit)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. 앱 실행
flutter run
```

### 환경 변수 설정

프로젝트 루트에 `.env` 파일 생성:

```env
API_BASE_URL=http://localhost:8080
WEBSOCKET_URL=ws://localhost:8080/ws
ENVIRONMENT=development
```

---

## 🏗️ 기술 스택

### 핵심 프레임워크
- **Flutter 3.9.2+** - 크로스 플랫폼 UI 프레임워크
- **Dart 3.9.2+** - 프로그래밍 언어

### 상태 관리
- **Riverpod 2.6.1** - 선언적 상태 관리
- **Riverpod Generator** - 코드 생성 기반 Provider

### 데이터 모델
- **Freezed 2.5.7** - 불변 데이터 클래스
- **json_serializable 6.9.2** - JSON 직렬화

### 네트워킹
- **Dio 5.9.0** - HTTP 클라이언트
- **Retrofit 4.7.2** - REST API 인터페이스
- **STOMP** - WebSocket 실시간 통신

### 위치 서비스
- **Geolocator** - GPS 위치 추적
- **Google Maps Flutter** - 지도 표시

### 알림
- **Firebase Cloud Messaging** - 푸시 알림
- **Flutter Local Notifications** - 로컬 알림

---

## 📂 프로젝트 구조

```
lib/
├── core/                          # 공통 인프라
│   ├── constants/                 # 앱 전역 상수
│   ├── network/                   # 네트워크 레이어
│   ├── services/                  # 범용 서비스 (FCM, Storage)
│   ├── utils/                     # 유틸리티 함수
│   └── widgets/                   # 공통 UI 위젯
│
├── features/                      # 기능 중심 모듈
│   ├── session/                   # 세션 관리
│   ├── map/                       # 지도 및 위치
│   ├── game/                      # 게임 로직
│   ├── chat/                      # 팀 채팅
│   └── notification/              # 알림 시스템
│
├── router/                        # 라우팅
└── main.dart                      # 앱 진입점
```

**상세 구조**: [FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md)

---

## 🎯 아키텍처

**Feature-First + Clean Architecture Hybrid**

각 feature는 3계층 구조:
- **Data 레이어**: API 호출, 로컬 저장소
- **Domain 레이어**: 비즈니스 로직 (Use Case)
- **Presentation 레이어**: UI (Provider, Widget)

```
presentation → domain ← data
```

**상세 설명**: [ARCHITECTURE.md](docs/ARCHITECTURE.md)

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

## 📖 문서

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - 아키텍처 상세 설명
- **[FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md)** - 폴더 구조 가이드
- **[CONTRIBUTING.md](docs/CONTRIBUTING.md)** - 개발 가이드
- **[경찰과도둑_PRD_2.md](docs/경찰과도둑_PRD_2.md)** - 제품 요구사항 문서

---

## 🤝 기여하기

프로젝트에 기여하고 싶으시다면 [CONTRIBUTING.md](docs/CONTRIBUTING.md)를 참고하세요.

### 브랜치 전략
- `main` - 프로덕션 배포
- `develop` - 개발 통합
- `feature/[기능명]` - 기능 개발

### Commit 규칙
```bash
feat(session): 게임 세션 생성 API 연동
fix(map): 구역 이탈 감지 로직 수정
docs(architecture): 아키텍처 문서 업데이트
```

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
## 최신 버전 : v1.0.15 (2025-12-30)

[전체 버전 기록 보기](CHANGELOG.md)
<!-- END-AUTO-VERSION-SECTION -->

---

**Built with ❤️ by Development Team**
