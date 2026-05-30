# AGENTS.md

경찰과 도둑 (Cops and Robbers)  
Flutter 3.9.2+ / Feature-First + Clean Architecture / Riverpod·Freezed·Retrofit / WebSocket STOMP

---

## 절대 규칙

- git push 금지
- 사용자가 명시하지 않으면 커밋 금지
- 커밋 메시지에 Co-Authored-By 금지
- 파일 삭제는 반드시 사용자 확인 후 진행
- 답변은 코드/커맨드를 제외하고 항상 한국어
- 모르면 추측하지 말고 모른다고 말하기
- 관련 파일을 읽기 전에는 수정하지 않기

---

## 프로젝트 규칙

- UI 텍스트 하드코딩 금지  
  사용자에게 보이는 문자열은 lib/l10n/app\_\*.arb에 추가 후 AppLocalizations.of(context).keyName 사용
- lib/l10n/app_localizations\*.dart 직접 편집 금지  
  ARB 수정 후 flutter gen-l10n으로 재생성
- 에러 처리는 try-catch + Custom Exception 사용
- Either 패턴 금지
- 색상/타이포는 AppColors, AppTextStyles 직접 사용
- Theme.of(context) 사용 금지
- 팀 테마는 roleThemeProvider + isDarkMode 흐름 유지
- Retrofit 버전은 retrofit: 4.7.3 유지

---

## 필수 명령어

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter test && flutter analyze
```

코드 생성은 `@riverpod`, `@freezed`, `@RestApi`, `@JsonSerializable` 수정 후 실행한다.
i18n은 `lib/l10n/app_*.arb` 수정 후 `flutter gen-l10n`을 실행한다.

---

## 참고 문서

작업 범위와 관련된 문서만 읽는다.

- .claude/rules/00_QUICK_REFERENCE.md
- .claude/rules/01_ARCHITECTURE.md
- .claude/rules/02_FOLDER_STRUCTURE.md
- .claude/rules/03_CODE_CONVENTIONS.md
- .claude/rules/04_CODE_GENERATION_GUIDE.md
- .claude/rules/10_I18N_GUIDE.md
- .claude/rules/Agents.md
- .claude/rules/UI_Design_System.md
- docs/api-docs.json
- docs/경찰과도둑\_PRD_2.md

---

## Codex 작업 방식

- 단순 작업은 바로 처리한다
- 여러 파일 수정, 구조 변경, 새 기능은 먼저 계획을 제시한다
- 수정 범위는 요청과 직접 관련된 파일로 제한한다
- 불필요한 리팩토링/포맷 변경/주석 정리는 하지 않는다
- 기존 코드 스타일과 아키텍처를 우선 따른다
- 완료 전 가능한 검증 명령을 실행한다
- 검증을 못 했으면 못 한 이유를 말한다

---

## Superpowers 사용 기준

Superpowers가 활성화되어 있으면 필요할 때만 사용한다.

- 새 기능: brainstorming → writing-plans → 구현
- 버그: systematic-debugging → 필요 시 test-driven-development
- 테스트: 프로젝트의 .claude/rules/Agents.md 규칙을 최우선 적용
- 완료 전: verification-before-completion 기준으로 검증

---

## 완료 보고

작업 완료 시 한국어로 짧게 보고한다.

- 변경 내용
- 수정 파일
- 실행한 검증
- 남은 이슈
- 필요 시 커밋 메시지 제안

커밋 메시지에는 절대 Co-Authored-By를 넣지 않는다.
