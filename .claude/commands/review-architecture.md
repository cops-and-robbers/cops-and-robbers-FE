# Review-Architecture: Architecture & Structure Quality

불필요한 구조, 아키텍처 위반, DRY 위반, 레이어 분리 문제를 찾아냅니다.

## 리뷰 범위 결정

**시작 전 반드시 실행:**
```bash
git diff --name-only main...HEAD -- '*.dart'
git log --oneline main...HEAD
```
변경 파일과 커밋 히스토리를 기반으로 리뷰합니다.

---

## 검사 항목

### 1. Clean Architecture 레이어 위반

**1-1. 의존성 방향 위반 (Critical)**
- `domain/` 파일이 `data/` 또는 `presentation/` 을 import
- `domain/` 파일이 Flutter SDK(`package:flutter/`)를 import (순수 Dart여야 함)
- `data/` 파일이 `presentation/`을 import

**검사 방법:**
```
domain/ 내 파일에서 import 패턴 확인:
  - ❌ import '../data/...'
  - ❌ import '../presentation/...'
  - ❌ import 'package:flutter/material.dart'
  - ✅ import 'package:freezed_annotation/...'
  - ✅ import '../domain/...' (같은 레이어)
```

**1-2. Repository 패턴 위반**
- Screen/Widget에서 DataSource를 직접 참조 (`ref.read(xxxDataSourceProvider)`)
- Provider에서 Repository를 거치지 않고 DataSource 직접 호출
- Repository 인터페이스(abstract class) 없이 구현체만 존재

**1-3. UseCase 패턴 위반**
- UseCase 없이 Provider에서 Repository 직접 호출 (프로젝트 규모에 따라 허용될 수 있음)
- UseCase가 여러 책임을 가짐 (Single Responsibility 위반)
- UseCase가 다른 UseCase를 호출하여 깊은 체인 형성

**출력 형식:**
```markdown
### 아키텍처 위반

| # | 파일:라인 | 위반 유형 | 설명 | 심각도 |
|---|----------|----------|------|--------|
| 1 | todo_entity.dart:3 | 레이어 위반 | domain에서 flutter import | Critical |
| 2 | home_screen.dart:45 | 패턴 위반 | DataSource 직접 참조 | Major |
```

---

### 2. DRY 위반 (중복 코드)

**2-1. 동일/유사 위젯 중복**
- 2개 이상의 파일에서 거의 동일한 위젯 구조 반복
- 같은 기능의 위젯이 feature별로 각각 존재 (공통 위젯으로 추출 대상)

**2-2. 동일 로직 중복**
- 같은 데이터 변환 로직이 여러 곳에 존재
- 동일한 유효성 검증 로직 반복
- 같은 에러 핸들링 패턴 copy-paste

**2-3. 동일 Provider 패턴 중복**
- 거의 동일한 구조의 StateNotifier/AsyncNotifier가 여러 개
- 같은 CRUD 패턴이 feature마다 반복 (공통 추상화 가능)

**출력 형식:**
```markdown
### DRY 위반

| # | 파일 A | 파일 B | 중복 유형 | 유사도 | 추출 제안 |
|---|-------|-------|----------|--------|----------|
| 1 | home_card.dart:20-45 | timer_card.dart:15-38 | 위젯 | ~85% | 공통 StatCard 위젯 |
| 2 | todo_provider.dart:30 | timer_provider.dart:25 | 에러 핸들링 | ~90% | 공통 mixin |
```

---

### 3. 불필요한 구조/과도한 추상화

**3-1. 불필요한 Wrapper/Bridge**
- 단순 위임만 하는 중간 레이어 (값을 전달만 하는 Repository)
- 한 곳에서만 사용되는 abstract class (인터페이스 분리가 불필요)
- 한 줄짜리 UseCase (Repository 메서드를 그대로 호출만)

**3-2. 과도한 파일 분리**
- 10줄 미만의 매우 작은 파일 (다른 파일에 합칠 수 있음)
- 빈 barrel export 파일 (실제로 사용되지 않는 `index.dart`)
- 별도 파일로 분리할 필요 없는 단순 enum, typedef

**3-3. 불필요한 Feature 분리**
- 하나의 Screen만 있는 Feature 폴더 (다른 Feature에 합칠 수 있음)
- 서로 강하게 결합된 Feature 간 경계 불명확

**출력 형식:**
```markdown
### 불필요한 구조

| # | 파일/폴더 | 유형 | 설명 | 제안 |
|---|----------|------|------|------|
| 1 | get_todo_usecase.dart | 불필요 wrapper | Repository 1줄 위임 | Provider에서 직접 호출 |
| 2 | constants/ | 과도 분리 | 3줄짜리 상수 파일 | 관련 파일에 합치기 |
```

---

### 4. Riverpod 구조 문제

**4-1. Provider 조직**
- 한 파일에 너무 많은 Provider (>5개) → 분리 필요
- Provider 간 의존성 그래프가 복잡 (순환 참조 위험)
- `ref.read` vs `ref.watch` 잘못된 사용 (build 내에서 read, 콜백에서 watch)

**4-2. 상태 관리 패턴**
- `StateProvider`로 충분한데 `StateNotifierProvider` 사용 (과도)
- 전역 Provider가 로컬 상태를 관리 (위젯 로컬 state로 충분)
- `autoDispose` 누락으로 메모리 잔류 가능

**4-3. 생성 코드 동기화**
- `.g.dart` 파일이 소스와 불일치 (build_runner 미실행)
- `@riverpod` 어노테이션 변경 후 생성 파일 미갱신

**출력 형식:**
```markdown
### Riverpod 구조

| # | 파일:라인 | 유형 | 현재 | 개선 | 심각도 |
|---|----------|------|------|------|--------|
| 1 | screen.dart:45 | watch/read 혼동 | build 내 ref.read | ref.watch 사용 | Major |
| 2 | provider.dart | 과도한 Provider | 8개 Provider | 파일 분리 | Minor |
```

---

### 5. 네이밍 & 컨벤션 위반

**5-1. Dart 네이밍 규칙**
- 파일명이 `snake_case`가 아닌 경우
- 클래스명이 `PascalCase`가 아닌 경우
- 상수가 `UPPER_CASE`인 경우 (Dart는 `lowerCamelCase` 사용)
- boolean 변수에 `is/has/can` prefix 누락

**5-2. 프로젝트 네이밍 패턴**
- 파일 네이밍 패턴 불일치:
  - Entity: `{name}_entity.dart`
  - Model: `{name}_model.dart`
  - Screen: `{name}_screen.dart`
  - Provider: `{name}_provider.dart`
- import 순서 규칙 위반 (Dart SDK → Flutter → External → Internal → Part)

**출력 형식:**
```markdown
### 네이밍 위반

| # | 파일:라인 | 유형 | 현재 | 올바른 형식 |
|---|----------|------|------|-----------|
| 1 | MyScreen.dart | 파일명 | PascalCase | my_screen.dart |
| 2 | file.dart:5 | 상수 | MAX_COUNT | maxCount |
```

---

## 실행 절차

1. 변경 파일 및 커밋 히스토리 확인
2. 레이어 위반 검사 (import 분석)
3. DRY 위반 검사 (유사 코드 탐지)
4. 불필요한 구조 검사
5. Riverpod 패턴 검사
6. 네이밍/컨벤션 검사
7. 결과 종합 출력

## 최종 출력

```markdown
# Review-3 결과: Architecture & Structure Quality

**대상 파일**: N개
**검사 일시**: YYYY-MM-DD

## 요약
- 아키텍처 위반: X건
- DRY 위반: Y건
- 불필요한 구조: Z건
- Riverpod 구조: W건
- 네이밍 위반: V건
- **총 이슈**: N건 (Critical: A, Major: B, Minor: C)

## 상세 결과
[위 카테고리별 테이블]

## 리팩토링 우선순위
1. [Critical 아키텍처 위반 수정]
2. [Major DRY 위반 공통화]
3. [Minor 네이밍 정리]

## 구조 개선 제안
[큰 그림에서의 구조 개선 방향 — 선택적 반영]
```
