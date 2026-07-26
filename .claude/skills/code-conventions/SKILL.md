---
name: code-conventions
description: 이 프로젝트 고유의 코드 작성 규칙 — 주석 언어·DartDoc 형식, 이모지 로깅 패턴, try-catch 에러 처리 순서, 메모리 누수 주의점. Dart 코드를 쓰거나 고칠 때 사용.
---

# 코드 컨벤션

> Dart 언어 문법(`final`/`const`, Null Safety, async/await, Collections)은 여기 없다 —
> 언어 기본이라 이 문서가 가르칠 이유가 없다. 이 문서는 **이 프로젝트에서만 통하는 규칙**만 담는다.
> 네이밍·파일 배치는 `folder-structure` 스킬 참조.

---

## 1. 주석

### 언어: 한국어 우선

`CLAUDE.md`의 "실무 수준 한국어 주석 — WHY 중심, 과하지 않게"가 정본이다.
실제 코드도 한국어 우선이다.

```dart
/// JWT 인증 인터셉터
///
/// 모든 API 요청에 Access Token을 자동으로 주입하고,
/// 401 응답 시 Refresh Token으로 자동 재발급을 시도합니다.
///
/// [QueuedInterceptor]를 사용하여 async 작업이 완료될 때까지 후속 요청을 큐에 대기시킵니다.
/// 일반 [Interceptor]는 async void 문제로 토큰 주입 전에 요청이 전송될 수 있습니다.
```

영문 병기는 **선택**이다. `app_exception.dart`처럼 외부 공개성이 높은 core 타입에만
한/영 병기를 쓰고, 나머지는 한국어만으로 충분하다.

### WHAT이 아니라 WHY

```dart
// ❌ 코드를 그대로 읽은 주석
// 토큰을 저장한다
await _storage.saveAccessToken(token);

// ✅ 코드가 설명 못 하는 것
// 재발급 성공 직후에만 저장한다. 실패 응답에도 body가 오는 경우가 있어
// 상태코드 확인 없이 저장하면 만료 토큰을 덮어쓴다.
await _storage.saveAccessToken(token);
```

### DartDoc (`///`) — Public API 필수

1. 첫 줄: 한 줄 요약
2. 빈 줄 후 상세 설명
3. 주의사항은 `**주의**:` 볼드
4. 반환값은 `Returns:` 섹션

### 복잡한 로직은 단계 번호로

```dart
// 1. 먼저 기기 정보 수집 (시뮬레이터에서도 항상 실행됨)
// 2. FCM 토큰 시도 (iOS 시뮬레이터에서는 실패할 수 있음)
// 3. 토큰이 있으면 갱신 리스너 등록
```

### 섹션 구분자

```dart
// ============================================
// Heading Styles (제목)
// ============================================
```

### TODO / FIXME / HACK

항상 **이유**를 함께 쓴다. 이유 없는 `// TODO`는 금지.

- **TODO**: 미래에 추가할 기능
- **FIXME**: 버그 또는 개선 필요
- **HACK**: 임시 해결책 (반드시 대안과 조건 명시)

---

## 2. 에러 처리

### 구체적인 타입 먼저, 일반 catch 마지막

```dart
try {
  final response = await _dataSource.someApi(request);
  return SomeEntity(...);
} on DioException catch (e) {
  throw DioExceptionHandler.handle(e);   // Repository는 이 한 줄이 전부
} on FirebaseAuthException catch (e) {
  throw AuthException(message: e.message ?? '...');
} catch (e) {
  if (e is AppException) rethrow;         // 이미 변환된 건 그대로 통과
  throw AuthException(message: '알 수 없는 오류', originalException: e);
}
```

### 계층별 책임

| 계층 | 하는 일 |
|------|---------|
| Repository | `DioExceptionHandler.handle(e)`로 변환 후 throw |
| UseCase | 비즈니스 검증 실패만 `ValidationException`, 나머지는 전파 |
| Provider | try-catch → `AsyncValue.error(e, stack)` |
| Widget | `state.when(error: ...)`에서 사용자 문구 표시 |

> ⚠️ `Either`/`dartz`는 2025-12-30에 제거됐다. 예전 예제에서 보이면 따라 쓰지 말 것.

### 사용자 문구와 디버그 문구는 채널이 다르다

- **UI 노출**: `messageKey` → ARB 조회 → 친화적 문구 (개발자 용어 금지)
- **디버그**: `.message` + `code`로 실제 원인 보존

---

## 3. 로깅

### `print` 금지, `debugPrint` 사용

`print`는 Flutter에서 출력이 누락될 수 있다.

### 이모지 규약

| 이모지 | 의미 | 예시 |
|--------|------|------|
| ✅ | 성공 | `debugPrint('[FCM] ✅ 토큰 가져오기 성공')` |
| ❌ | 에러 | `debugPrint('❌ API 호출 실패: $e')` |
| ⚠️ | 경고 | `debugPrint('⚠️ 토큰 없음 (시뮬레이터)')` |
| 🔄 | 진행 중 | `debugPrint('🔄 토큰 갱신 중...')` |
| 📱 | 기기 정보 | `debugPrint('📱 Device: $name')` |
| 🔍 | 디버깅 | `debugPrint('🔍 Response: $data')` |
| 💡 | 안내 | `debugPrint('💡 시뮬레이터에서는 토큰 없음')` |

### 상세 로그는 `kDebugMode` 안에서만

프로덕션에 흘리면 안 되는 정보는 반드시 감싼다.

> debugPrint / AppLogger / 주석 / assert 메시지는 **한국어 허용**이다.
> i18n 대상은 사용자에게 보이는 문자열뿐이다.

---

## 4. 위젯

- `StatelessWidget`은 **`const` 생성자 + `super.key`** — rebuild 최적화
- 리스트 아이템에는 `ValueKey(item.id)` 부여
- `StatefulWidget`의 `dispose()`에서 리소스 정리 필수

### 메모리 누수 주의점 (실제로 물린 것들)

```dart
// StreamController는 broadcast로 만들고 반드시 close
final _controller = StreamController<T>.broadcast();

@override
void dispose() {
  _controller.close();   // ⚠️ 빠뜨리면 누수
  _sub?.cancel();
  super.dispose();
}
```

```dart
// async 후 BuildContext 사용 전 mounted 체크
await someAsyncWork();
if (!mounted) return;      // ⚠️ 없으면 dispose된 위젯에 접근
Navigator.of(context).push(...);
```

---

## 5. 코드 리뷰 체크리스트

- [ ] Public API에 DartDoc, WHY 중심 한국어 주석
- [ ] 구체적 에러 타입 먼저 처리, Repository는 `DioExceptionHandler.handle(e)`
- [ ] `debugPrint` + 이모지 규약, 상세 로그는 `kDebugMode`
- [ ] `const` 생성자 / `super.key` / 리스트 `key`
- [ ] `dispose()`에서 StreamController·Subscription 정리
- [ ] async 후 `mounted` 체크
- [ ] UI 문자열은 ARB 경유 (한국어 하드코딩 금지)
- [ ] 계층 의존성 위반 없음 (domain → data 금지)

---

## 관련 스킬

- `folder-structure` — 네이밍·파일 배치
- `flutter-architecture` — 계층 의존성과 결정 근거
- `code-generation` — 코드 생성 절차
- 테스트 작성 규칙은 `.claude/rules/Agents.md` (항상 로드됨)가 정본
