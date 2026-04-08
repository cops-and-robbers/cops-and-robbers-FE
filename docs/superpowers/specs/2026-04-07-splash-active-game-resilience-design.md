# 스플래시 활성 게임 자동 복귀 안정성 개선

## 배경

앱을 장시간 미사용 후 재실행 시, 참여 중인 게임이 있음에도 홈 화면으로 이동되는 간헐적 버그 발생.
서버는 활성 게임 참여 상태를 정상 인지하나(방 만들기/참여하기 시 "이미 참가 중" 에러), 클라이언트가 이를 감지하지 못함.

## 원인 분석

### 직접 원인: 콜드 스타트 네트워크 에러

스플래시의 `getMyActiveGame` API 호출(`GET /api/user/me/game`)이 앱의 **첫 번째 실제 네트워크 요청**이다.
`authNotifierProvider.build()`은 로컬 상태(Firebase currentUser, SecureStorage)만 확인하므로 auth 통과 ≠ 네트워크 정상.

장시간 백그라운드/종료 후 재실행 시:
- OS가 네트워크 소켓을 해제한 상태
- DNS 캐시 만료, TLS 핸드셰이크 재수행 필요
- 이 과정에서 Dio connectTimeout(10초) 초과 또는 일시적 연결 실패

→ DioException 발생 → 401이 아니므로 AuthInterceptor 통과 → `splash_page.dart:134` catch 블록 → 홈 fallback

### 구조적 문제: 홈 안전망 부재

활성 게임 체크가 스플래시와 로그인 직후(`_resolvePostLoginDestination`)에서만 수행됨.
홈 화면과 GoRouter redirect에 활성 게임 확인 분기가 없어, 스플래시 실패 시 복구 경로 전무.

### 잠재적 결함: QueuedInterceptor 재시도 데드락

`AuthInterceptor._retryRequest()`에서 토큰 재발급 후 `_dio.fetch()`로 재시도 시,
`QueuedInterceptor`의 순차 처리 큐에서 교착 상태 가능성. 현재 증상의 직접 원인은 아니나(데드락 시 스플래시 행, 홈 도달 불가), access token 만료 상태에서 앱이 영구 멈출 수 있는 잠재적 결함.

## 수정 범위

### 1. 스플래시 `getMyActiveGame` 재시도 로직

**파일**: `lib/features/auth/presentation/pages/splash_page.dart`

현재 `getMyActiveGame` 호출이 1회 실패 시 즉시 홈으로 fallback.
콜드 스타트 네트워크 안정화를 위해 **최대 2회 재시도** (총 3회 시도) 추가.

- 재시도 간격: 1초 (네트워크 스택 안정화 대기)
- 재시도 대상: DioException만 (파싱 에러 등 비네트워크 오류는 즉시 실패)
- 최종 실패 시 기존과 동일하게 홈 fallback

### 2. 홈 화면 활성 게임 체크 (안전망)

**파일**: `lib/features/session/presentation/pages/home_page.dart`

홈 화면 `build()` 진입 시 `getMyActiveGame` API를 호출하여 활성 게임 존재 시 자동 리다이렉트.

- 호출 시점: 홈 위젯 최초 빌드 시 1회 (`ref.listen` 또는 `initState` 패턴)
- 성공 + isParticipating=true → 대기실/게임으로 `context.go()`
- 실패 또는 isParticipating=false → 아무 동작 안 함 (홈 유지)
- 로딩 UI: 별도 표시 없음 (백그라운드 체크, UX 중단 최소화)

### 3. AuthInterceptor `_plainDio` 재시도

**파일**: `lib/core/network/auth_interceptor.dart`

`_retryRequest()`에서 `_dio.fetch()` → `_plainDio.fetch()`로 변경.
`QueuedInterceptor` 큐를 우회하여 잠재적 데드락 방지.

- 변경량: 1줄
- `_plainDio`는 인터셉터가 없으므로 재시도 요청에 수동 설정된 Authorization 헤더만 사용 (이미 `_retryRequest`에서 설정 중)

## 변경하지 않는 것

- GoRouter `redirect` 함수: 활성 게임 체크를 redirect에 넣으면 매 네비게이션마다 API 호출 발생 → 성능 문제. 홈 페이지에서 1회 체크로 충분.
- 스플래시 최소 표시 시간(2초): 유지
- auth timeout(5초): 유지
- Dio timeout(10초): 유지

## 영향 범위

- `splash_page.dart`: 재시도 로직 추가 (~15줄)
- `home_page.dart`: 활성 게임 체크 추가 (~20줄)
- `auth_interceptor.dart`: 1줄 변경
