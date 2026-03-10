# Review-Safety: Dead Code & Runtime Safety

Dead Code, Dead Lock, 불필요한 리빌드를 찾아냅니다.

## 리뷰 범위 결정

**시작 전 반드시 실행:**
```bash
git diff --name-only main...HEAD
```
변경된 파일 목록을 기준으로 리뷰합니다. 변경된 파일이 없으면 전체 `lib/` 대상.

---

## 검사 항목

### 1. Dead Code 탐지

변경된 파일과 그 파일이 import하는 파일들을 대상으로 검사:

**1-1. 사용되지 않는 import**
- `import` 문이 있지만 해당 파일에서 실제로 사용하지 않는 심볼
- `flutter analyze` 결과의 `unused_import` 워닝 확인

**1-2. 사용되지 않는 변수/함수/클래스**
- 선언만 되고 어디서도 참조되지 않는 로컬 변수, 파라미터
- `_`로 시작하는 private 함수/메서드 중 같은 파일 내에서 호출되지 않는 것
- public 함수/클래스 중 프로젝트 전체에서 참조되지 않는 것

**1-3. 사용되지 않는 Provider**
- `@riverpod`로 생성된 Provider 중 `ref.watch()` 또는 `ref.read()`로 소비되지 않는 것
- `.g.dart` 파일에 생성되었지만 실제 사용처가 없는 Provider

**1-4. 도달 불가능한 코드**
- `return` 이후의 코드
- 항상 `true`/`false`인 조건문 분기
- `throw` 이후 코드

**출력 형식:**
```markdown
### Dead Code 발견

| # | 파일:라인 | 유형 | 대상 | 제거 안전성 |
|---|----------|------|------|------------|
| 1 | file.dart:23 | unused import | 'package:foo' | 안전 |
| 2 | file.dart:45 | unused method | _oldHelper() | 확인 필요 |
```

---

### 2. Dead Lock / Race Condition 탐지

**2-1. async/await 관련**
- `Future`를 `await` 없이 호출하여 fire-and-forget 되는 곳 (의도적이 아닌 경우)
- 여러 `await`가 순차 실행되지만 서로 독립적인 경우 (`Future.wait` 대상)
- `Completer`가 complete 되지 않을 가능성

**2-2. StateNotifier / AsyncNotifier 관련**
- `state = AsyncLoading()` 후 에러 경로에서 state 복구 안 되는 경우
- `ref.read()` 사용 시 Provider가 아직 초기화되지 않았을 가능성
- 여러 Provider가 서로를 `ref.watch()`/`ref.read()` 하면서 순환 참조 발생

**2-3. Stream / Timer 관련**
- `StreamSubscription`이 `dispose()`에서 cancel 되지 않는 경우
- `Timer.periodic`이 cancel 되지 않는 경우
- `StreamController`가 close 되지 않는 경우

**출력 형식:**
```markdown
### Runtime Safety 이슈

| # | 파일:라인 | 유형 | 설명 | 심각도 |
|---|----------|------|------|--------|
| 1 | timer_screen.dart:89 | stream leak | StreamSubscription 미cancel | Critical |
| 2 | todo_provider.dart:34 | state recovery | error 시 loading 상태 유지 | Major |
```

---

### 3. 불필요한 리빌드 탐지

**3-1. Riverpod 리빌드**
- `ref.watch(provider)` 를 `build()` 밖에서 사용 (올바른 위치인지 확인)
- 넓은 범위의 Provider를 watch하는 경우 (전체 리스트 watch → 개별 아이템 select 가능)
- `ref.watch(provider.notifier)` vs `ref.watch(provider)` 혼동

**3-2. Widget 리빌드**
- `const` 가능한 위젯에 `const` 누락
- `StatefulWidget` 내 `setState()`가 불필요하게 넓은 범위를 리빌드
- `ListView.builder`에서 `itemBuilder` 내 무거운 연산
- `AnimatedBuilder` / `ValueListenableBuilder` 로 범위를 좁힐 수 있는 경우

**3-3. 불필요한 `setState` / `state =` 호출**
- 값이 변하지 않았는데 `setState` 호출
- 동일한 값으로 `state =` 재할당

**출력 형식:**
```markdown
### 불필요한 리빌드

| # | 파일:라인 | 유형 | 현재 | 개선 제안 | 영향도 |
|---|----------|------|------|----------|--------|
| 1 | home_screen.dart:67 | wide watch | `ref.watch(listProvider)` | `.select((s) => s.length)` 사용 | Medium |
| 2 | todo_item.dart:12 | missing const | `SizedBox(height: 16)` | `const SizedBox(height: 16)` | Low |
```

---

## 실행 절차

1. `flutter analyze` 실행하여 정적 분석 결과 수집
2. 변경 파일 목록 추출 (`git diff --name-only main...HEAD`)
3. 각 변경 파일에서 위 3개 카테고리 순서대로 검사
4. 변경 파일이 export하는 심볼의 사용처도 프로젝트 전체 검색
5. 결과를 심각도 순으로 정렬하여 출력

## 최종 출력

```markdown
# Review-1 결과: Dead Code & Runtime Safety

**대상 파일**: N개 (변경 파일 + 영향받는 파일)
**검사 일시**: YYYY-MM-DD

## 요약
- Dead Code: X건
- Runtime Safety: Y건
- 불필요한 리빌드: Z건
- **총 이슈**: N건 (Critical: A, Major: B, Minor: C)

## 상세 결과
[위 카테고리별 테이블]

## 자동 수정 가능 항목
[제거해도 안전한 dead code 목록 — 사용자 승인 후 일괄 제거 가능]
```
