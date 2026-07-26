---
name: folder-structure
description: 파일을 어디에 만들지 판단하는 기준 — core/ vs features/, Model vs Entity, 공통 위젯 vs feature 위젯, 파일 명명·접미사 규칙. 새 파일을 추가할 때 사용.
---

# 폴더 구조 판단 가이드

> 실제 디렉터리 트리는 `ls lib/`·`find lib -type d`로 확인한다. 이 문서는
> **어디에 둘지 결정하는 기준**만 담는다.

---

## 전체 구조 (개요)

```
lib/
├── core/          # 공통 인프라 (2개 이상 feature에서 사용)
├── features/      # 기능 중심 모듈 (각각 data/domain/presentation 3계층)
├── l10n/          # ARB 정본 + 자동 생성 AppLocalizations
├── router/        # 라우팅 설정
└── main.dart
```

각 feature는 예외 없이 동일한 3계층 구조를 갖는다:

```
features/[feature_name]/
├── data/          models/ · datasources/ · repositories/
├── domain/        entities/ · repositories/ · usecases/
└── presentation/  providers/ · pages/ · widgets/
```

---

## 파일 명명 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 파일명 | snake_case | `user_profile_page.dart` |
| 클래스명 | PascalCase | `UserProfilePage` |
| 변수/메서드 | camelCase | `userName`, `fetchUser()` |
| Private | `_` 시작 | `_privateMethod()` |

### 접미사

| 타입 | 접미사 | 예시 |
|------|--------|------|
| Data Model (DTO) | `_model` | `game_session_model.dart` |
| Entity | `_entity` | `session_entity.dart` |
| Data Source | `_datasource` | `session_remote_datasource.dart` |
| Repository 인터페이스 | `_repository` | `session_repository.dart` |
| Repository 구현체 | `_repository_impl` | `session_repository_impl.dart` |
| Use Case | `_usecase` | `create_session_usecase.dart` |
| Provider | `_provider` | `session_provider.dart` |
| Page | `_page` | `create_session_page.dart` |
| Widget | 없음 | `participant_list_item.dart` |

---

## 판단 기준 (FAQ)

### Q1. 파일을 어디에 만들어야 하나?

1. **모든 feature에서 사용하나?** → `lib/core/`
2. **특정 기능에만 사용하나?** → `lib/features/[기능명]/`
3. **API 호출인가?** → `data/datasources/`
4. **비즈니스 로직인가?** → `domain/usecases/`
5. **UI인가?** → `presentation/pages/` 또는 `widgets/`

### Q2. core/ vs features/ 판단 기준

| 구분 | core/ | features/ |
|------|-------|-----------|
| 사용 범위 | 앱 전체 | 특정 기능만 |
| 의존성 방향 | features → core (허용) | features → features (**금지**) |

```
✅ features/auth/ → core/network/dio_client.dart
❌ features/auth/ → features/session/       (Feature 간 직접 의존 금지)
❌ core/widgets/  → features/auth/          (Core는 Feature에 의존 불가)
```

**예외 상황** — Feature 간 데이터 공유가 필요하면 직접 import가 아니라
`ref.watch(sessionProvider)`처럼 Provider를 통해 참조한다.

**판단 한 줄**: 2개 이상 feature에서 쓰면 `core/`, 아니면 `features/`.

### Q3. Data Model과 Entity를 왜 분리하나?

| 구분 | Data Model (DTO) | Domain Entity |
|------|------------------|---------------|
| 위치 | `data/models/` | `domain/entities/` |
| 역할 | API 응답 JSON ↔ Dart 변환 | 앱 내부 비즈니스 데이터 |
| 의존성 | API 구조에 의존 (외부) | 순수 Dart |
| 변경 이유 | 백엔드 API 변경 시 | 비즈니스 요구사항 변경 시 |
| 어노테이션 | `@freezed` + `@JsonSerializable` | `@freezed` (JSON 없음) |

장점:

- 백엔드 API 변경 시 Model만 수정 → Entity 영향 없음
- 앱 내부에서 더 명확한 이름 사용 가능 (`sessionId` → `id`)
- Domain 계층이 외부 의존성 없이 독립 동작

```dart
// ❌ Entity에서 Data Model 참조 금지
class SessionEntity {
  final GameSessionModel session;  // 금지!
}
```

### Q4. Provider는 어디에?

```
✅ features/session/presentation/providers/session_provider.dart
❌ lib/providers/session_provider.dart          (core 레이어 배치 금지)
```

### Q5. 공통 위젯 vs feature 위젯?

- **공통** (`core/widgets/`): 2개 이상의 feature에서 사용
- **Feature 전용** (`features/[기능]/presentation/widgets/`): 단일 feature에서만 사용

### Q6. 코드 생성이 필요한 파일은?

`@freezed` · `@riverpod` · `@RestApi` · `@JsonSerializable` 중 하나라도 쓰면 필요하다.
자세한 절차는 `code-generation` 스킬 참조.

### Q7. 왜 이렇게 복잡하게 나눴나?

| 측면 | Clean Architecture | UI에 모든 로직 |
|------|--------------------|----------------|
| 테스트 | ✅ Domain 단독 테스트 (UI 없이) | ❌ UI와 함께 테스트 (느림) |
| API 변경 | ✅ `data/`만 수정 | ❌ UI 코드까지 수정 |
| UI 변경 | ✅ `presentation/`만 수정 | ❌ 로직과 섞여 위험 |
| 협업 | ✅ 계층별 병렬 작업 | ❌ 동일 파일 충돌 |

---

## 관련 스킬

- `flutter-architecture` — 계층 의존성 규칙과 설계 결정 근거
- `code-generation` — 코드 생성 실행 절차
- `code-conventions` — 코드 작성 규칙
