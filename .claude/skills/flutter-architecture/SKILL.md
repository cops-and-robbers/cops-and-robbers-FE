---
name: flutter-architecture
description: Clean Architecture 3계층 구조와 의존성 방향 규칙, Feature-First를 택한 이유, try-catch 에러 처리로 전환한 결정 근거. 새 feature 설계·계층 배치 판단 시 사용.
---

# 아키텍처 결정 기록 (Architecture Decisions)

> 기술 스택과 버전은 `pubspec.yaml`이 정본이다. 폴더 배치는 `folder-structure` 스킬 참조.
> 이 문서는 **코드만 봐서는 알 수 없는 "왜"** 만 담는다.

---

## 아키텍처 전략: Feature-First + Clean Architecture

```
"기능별로 나누고, 계층별로 분리한다"
```

### Layer-First를 배제한 이유

❌ `lib/data/`, `lib/domain/`, `lib/presentation/` 구조

- 하나의 기능 수정 시 3개 폴더 탐색 필요
- 코드 리뷰 시 관련 파일들이 분산됨
- 기능 단위 재사용 어려움

### 두 전략을 섞은 이유

| 요구사항 | Feature-First | Clean Architecture |
|---------|---------------|-------------------|
| 기능별 병렬 개발 | ✅ 독립적인 feature 폴더 | - |
| 코드 탐색 편의성 | ✅ 관련 파일 한 곳에 집중 | - |
| 테스트 용이성 | - | ✅ 도메인 로직 격리 |
| 의존성 역전 | - | ✅ 인터페이스 기반 설계 |
| 확장성 | ✅ 새 feature 추가 용이 | ✅ 레이어 교체 가능 |

---

## 계층별 역할과 의존성 규칙

```
presentation (UI)
    ↓ (uses)
domain (Business Logic)
    ↑ (implements)
data (External Communication)
```

### 📦 Data — 외부 세계와의 통신

REST API(Retrofit), WebSocket(STOMP), 로컬 저장소, JSON 직렬화.
DTO → Entity 변환과 `DioExceptionHandler.handle(e)` 에러 변환을 **여기서만** 수행한다.

### 🧠 Domain — 비즈니스 로직

순수 Dart. **외부 의존성 0**. Repository 인터페이스 정의 + UseCase.

UseCase는 **복잡한 비즈니스 검증이 있을 때만** 만든다. 단순 CRUD는 Provider에서
Repository를 직접 호출해도 된다 — 통과만 하는 UseCase는 계층 낭비다.

### 🎨 Presentation — UI

Widget, Riverpod Provider, UI 로직(포맷팅·유효성 표시).

### 절대 규칙

1. ✅ presentation → domain
2. ✅ data → domain (인터페이스 구현)
3. ❌ **domain → data (절대 금지)**
4. ❌ **domain → presentation (절대 금지)**
5. ❌ **features/A → features/B 직접 의존 금지** — Provider를 통해서만 참조

---

## 결정 이력

### 1. 에러 처리: Either 패턴 → try-catch (2025-12-30 변경)

**이전**: `Either<Failure, Success>` (dartz)
**현재**: try-catch + Custom Exception

변경 이유:

1. **학습 곡선 감소** — Dart 네이티브 에러 처리로 신규 개발자 진입 장벽 낮춤
2. **번들 사이즈 감소** — dartz 제거 (~150KB)
3. **직관적인 비동기 코드** — async/await와 자연스러운 통합
4. **Riverpod 통합** — `AsyncValue.error()`와 자연스럽게 연동

> ⚠️ Either 패턴은 **다시 도입하지 않는다.** 오래된 예제에서 `dartz` import를 보면
> 그건 잔재이므로 따라 쓰지 말 것.

계층별 책임:

- **Repository**: `DioExceptionHandler.handle(e)`로 `AppException` 변환 후 throw
- **UseCase**: 비즈니스 검증 실패 시 `ValidationException` throw, 나머지는 전파
- **Provider**: try-catch로 받아 `AsyncValue.error(e, stack)`로 저장

Custom Exception 체계는 `lib/core/errors/app_exception.dart`가 정본
(`NetworkException` / `AuthException` / `ValidationException` / `ServerException` 등).

### 2. features/map을 features/game으로 통합

지도·위치 기능은 게임 로직과 분리가 불가능하다:

- 체포 버튼 활성화 = "상대가 50m 이내" + "게임 진행 중" 동시 판정
- 구역 이탈 감지 = "현재 위치" + "게임 상태(플레이그라운드 좌표)" 동시 필요

분리하면 `game_provider`와 `map_provider`가 서로 watch해야 해서 **순환 참조 위험**이
생긴다. 하나의 feature로 관리해 상태 일관성을 보장한다.

### 3. Riverpod 코드 생성 + `keepAlive`

`@riverpod`는 기본 autoDispose다. 긴 비동기 작업(401 토큰 재발급 등) 중
Provider가 dispose되면 crash가 난다.

- 앱 생애주기 동안 유지할 서비스(Dio, SecureTokenStorage, 인증)는 `@Riverpod(keepAlive: true)`
- 그 외에는 **UI의 `build()`에서 `ref.watch()`로 구독을 유지**해야 안전하다

### 4. 강제 로그아웃 콜백 (core → feature 의존성 역전)

`AuthInterceptor`(core)가 로그아웃 로직(feature)을 호출해야 하지만 core가 feature에
의존하면 안 된다. → `StateProvider`로 콜백 슬롯을 core에 두고, feature가 등록한다.

### 5. 401 재발급 Lock (QueuedInterceptor)

여러 요청이 동시에 401을 받으면 토큰 재발급이 중복된다. 첫 401이 재발급을 시작하고
나머지는 대기 → 완료 후 일괄 재시도. 무한 루프 방지를 위해 재시도 헤더를 체크한다.

---

## 관련 스킬

- `folder-structure` — 폴더 배치와 파일 네이밍
- `code-conventions` — 주석·로깅·에러 처리 작성 규칙
- `code-generation` — Riverpod/Freezed/Retrofit 코드 생성
- `design-patterns` — 실제 사용 중인 패턴 카탈로그
- `realtime-spec` — WebSocket STOMP 이벤트 명세
- `api-integration` — 새 API 연동 절차
