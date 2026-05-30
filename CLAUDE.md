# CLAUDE.md

**경찰과 도둑 (Cops and Robbers)**: 위치 기반 실시간 멀티플레이어 모바일 게임
Flutter 3.9.2+ / Feature-First + Clean Architecture / Riverpod·Freezed·Retrofit / WebSocket STOMP

---

## 금지 규칙

- **`git push` 절대 금지** — 원격 push는 어떤 상황에서도 하지 않는다
- **커밋 자동 생성 금지** — 사용자가 명시적으로 요청할 때만 커밋한다
- **Co-Authored-By 태그 금지** — 커밋 메시지에 절대 추가하지 않는다
- **파일 삭제 시 사용자 허락 필수** — 확인 없이 삭제하지 않는다
- **답변은 항상 한국어** — 코드/커맨드 제외 모두 한국어
- **모르면 모른다고** — 확실하지 않은 내용은 추측하지 않는다
- **실무 수준 한국어 주석** — WHY 중심, 과하지 않게
- **UI 텍스트 한국어 하드코딩 금지** — 사용자에게 보이는 모든 문자열은 `lib/l10n/app_*.arb`에 추가 후 `AppLocalizations.of(context).keyName`으로 사용한다. 단, debugPrint/AppLogger/주석/assert 메시지는 한국어 허용 — [10_I18N_GUIDE.md](.claude/rules/10_I18N_GUIDE.md)
- **자동 생성 i18n 파일 직접 편집 금지** — `lib/l10n/app_localizations*.dart`는 ARB에서 생성. 수정은 ARB만, 코드는 `flutter gen-l10n` 으로 재생성

---

## 필수 명령어

```bash
flutter pub get                                                  # 의존성
dart run build_runner build --delete-conflicting-outputs         # 코드 생성 (필수)
flutter gen-l10n                                                 # i18n ARB → AppLocalizations 생성
flutter test && flutter analyze                                  # 테스트 / 린트
```

**코드 생성 실행 시점**: `@riverpod`·`@freezed`·`@RestApi`·`@JsonSerializable` 추가/수정 후, `.g.dart`·`.freezed.dart` 누락 시, "generated file not found" 에러 시
**i18n 생성 실행 시점**: `lib/l10n/app_*.arb` 추가/수정 후 (hot reload로는 반영 안 됨)

---

## 참고 문서 (`.claude/rules/`)

- [00_QUICK_REFERENCE.md](.claude/rules/00_QUICK_REFERENCE.md) — 핵심 규칙 빠른 참조
- [01_ARCHITECTURE.md](.claude/rules/01_ARCHITECTURE.md) — Clean Architecture 3계층, 의존성 흐름
- [02_FOLDER_STRUCTURE.md](.claude/rules/02_FOLDER_STRUCTURE.md) — Feature-First 폴더 구조
- [03_CODE_CONVENTIONS.md](.claude/rules/03_CODE_CONVENTIONS.md) — 네이밍, 에러 처리(try-catch), Null Safety
- [04_CODE_GENERATION_GUIDE.md](.claude/rules/04_CODE_GENERATION_GUIDE.md) — Riverpod·Freezed·Retrofit 코드 생성
- [06_API_INTEGRATION_GUIDE.md](.claude/rules/06_API_INTEGRATION_GUIDE.md) — API 연동 절차
- [08_TIMER_ARCHITECTURE.md](.claude/rules/08_TIMER_ARCHITECTURE.md) — 타이머 아키텍처
- [09_REALTIME_COMMUNICATION_SPEC.md](.claude/rules/09_REALTIME_COMMUNICATION_SPEC.md) — WebSocket STOMP 이벤트
- [10_I18N_GUIDE.md](.claude/rules/10_I18N_GUIDE.md) — **i18n 워크플로 (필수)**: ARB 관리, AppLocalizations 사용, Notifier/Exception 패턴, gen-l10n
- [Agents.md](.claude/rules/Agents.md) — **테스트 작성 룰 (최우선)**: Classist 스타일, 시스템 경계만 모킹, PR Red Flags
- [Design.md](.claude/rules/Design.md) — 디자인 패턴 (아키텍처 레벨)
- [UI_Design_System.md](.claude/rules/UI_Design_System.md) — UI 시스템: AppColors·AppTextStyles·팀 테마
- [api-docs.json](docs/api-docs.json) — API 명세 (OpenAPI 3.0.1, 백엔드 자동 생성 정본)
- [경찰과도둑\_PRD_2.md](docs/경찰과도둑_PRD_2.md) — 제품 요구사항

---

## 핵심 원칙 요약

- **에러 처리**: try-catch + Custom Exception (Either 패턴 금지)
- **컬러/타이포**: `AppColors`·`AppTextStyles` 직접 참조, `Theme.of(context)` 미사용 — [UI_Design_System.md](.claude/rules/UI_Design_System.md)
- **팀 테마**: `roleThemeProvider` + `isDarkMode` prop 전파 (시스템 다크모드 아님)
- **Retrofit 버전 고정**: `retrofit: 4.7.3` (4.9.x는 `ParseErrorLogger` 시그니처 충돌)
- **i18n**: 지원 로케일 `ko/en/ja` (ISO 639-1). ARB 정본 (`lib/l10n/app_*.arb`), 코드 자동 생성. Widget은 `AppLocalizations.of(context).key`, Notifier·Exception은 `messageKey` + `lookupAppLocalizations(locale)` 패턴 — [10_I18N_GUIDE.md](.claude/rules/10_I18N_GUIDE.md)

---

## 워크플로우 (Superpowers + ECC)

- **새 기능 설계·구현** → Superpowers (브레인스톰 → 계획 → 실행)
- **코드 리뷰·보안 감사** → ECC (`code-reviewer`, `security-reviewer`)
- **버그 수정** → Superpowers(원인 분석) + ECC(TDD 수정)
- **리팩토링·배포 전 체크** → ECC (`refactor-clean`, `security-scan`, `e2e`)

### 테스트 워크플로우 우선순위

테스트 작성 시 룰이 충돌하면 다음 순서로 적용한다:

1. **[Agents.md](.claude/rules/Agents.md)** — 테스트 *내용* 게이트 **(최우선)**. 모킹 위치(시스템 경계만), Classist 스타일, 명명 규칙(`<subject>_<expected>_when_<condition>`), PR Red Flags
2. **`superpowers:test-driven-development`** — RED→GREEN→REFACTOR *순서* 강제. 코드 먼저 쓰면 삭제
3. **ECC `tdd-workflow`** — Test Type 분류(unit/integration/E2E)와 Git 체크포인트 발상만 차용. **예시 코드의 Mockist 패턴(`jest.mock` 내부 모듈, `toHaveBeenCalledWith` 단독 검증)은 무시한다** — Agents.md PR Red Flags 위반
