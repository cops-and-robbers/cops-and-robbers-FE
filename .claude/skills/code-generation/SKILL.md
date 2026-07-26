---
name: code-generation
description: build_runner 코드 생성 — 언제 돌려야 하는지, retrofit 버전 고정 이유, generated file not found 등 실제로 겪은 에러 해결법. .g.dart/.freezed.dart 관련 빌드 실패 시 사용.
---

# 코드 생성 (build_runner)

> Riverpod/Freezed/Retrofit 사용법 자체는 각 패키지 공식 문서가 정본이다.
> 이 문서는 **이 프로젝트에서 실제로 막혔던 지점**만 담는다.

---

## 어떤 어노테이션이 무엇을 만드나

| 어노테이션 | 생성 파일 | 필수 `part` 선언 |
|-----------|-----------|-----------------|
| `@riverpod` | `*.g.dart` | `part 'x_provider.g.dart';` |
| `@freezed` | `*.freezed.dart` | `part 'x.freezed.dart';` |
| `@JsonSerializable()` / `fromJson` | `*.g.dart` | `part 'x.g.dart';` |
| `@RestApi()` | `*.g.dart` | `part 'x_api.g.dart';` |

Freezed 모델이 JSON 직렬화까지 하면 **`part` 두 줄이 모두** 필요하다.

---

## 실행

```bash
# 1회 생성 (기본)
dart run build_runner build --delete-conflicting-outputs

# 개발 중 자동 감지
dart run build_runner watch --delete-conflicting-outputs
```

### 언제 돌려야 하나

- `@riverpod` · `@freezed` · `@RestApi` · `@JsonSerializable` 추가/수정 후
- `.g.dart` / `.freezed.dart` 누락 시
- `generated file not found` 에러 시

> i18n은 별개다. `lib/l10n/app_*.arb` 수정 후에는 `flutter gen-l10n`을 돌려야 하며,
> hot reload로는 반영되지 않는다.

---

## ⚠️ retrofit 버전 고정

```yaml
retrofit: 4.7.3   # ^가 아니라 정확히 고정
```

`4.9.x`는 `ParseErrorLogger.logError` 시그니처가 바뀌었다. generator가 인자 3개를
넘기는데 `4.9.x`는 4개를 기대해서 생성 코드가 컴파일되지 않는다.
**캐럿(`^`)으로 풀지 말 것.**

---

## 문제 해결

### `Conflicting outputs were detected`

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### `The part 'x.g.dart' was not found`

코드 생성을 한 번도 실행하지 않았다. 위 build 명령 실행.

### `@riverpod annotation not found`

`pubspec.yaml`에 `riverpod_annotation`(dependencies) +
`riverpod_generator`(dev_dependencies)가 모두 있는지 확인 → `flutter pub get`.

### `Could not generate 'fromJson' code`

`json_annotation`(dependencies) + `json_serializable`(dev_dependencies) 누락.

### watch 모드가 변경을 감지 못 함

IDE 자동 저장이 꺼져 있다. 수동 저장(`Cmd+S`)하거나 자동 저장을 켠다.

### 그래도 안 되면

```bash
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs
```

---

## 체크리스트

**새 Provider**
- [ ] `import 'package:riverpod_annotation/riverpod_annotation.dart';`
- [ ] `part 'x_provider.g.dart';`
- [ ] 싱글턴이어야 하면 `@Riverpod(keepAlive: true)`
- [ ] 코드 생성 실행

**새 Freezed 모델**
- [ ] `part 'x.freezed.dart';` (+ JSON 필요 시 `part 'x.g.dart';`)
- [ ] JSON 필요 시 `factory X.fromJson(...)` 추가
- [ ] 코드 생성 실행

**새 Retrofit API**
- [ ] `part 'x_api.g.dart';`
- [ ] `factory XApi(Dio dio) = _XApi;`
- [ ] 토큰 헤더 **수동 주입 금지** — `AuthInterceptor`가 자동 처리
- [ ] 코드 생성 실행

---

## 관련 스킬

- `api-integration` — 새 API 연동 4단계 절차
- `flutter-architecture` — `keepAlive` / autoDispose 판단 근거
