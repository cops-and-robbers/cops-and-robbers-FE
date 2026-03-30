# CLAUDE.md

**경찰과 도둑 (Cops and Robbers)**: 위치 기반 실시간 멀티플레이어 모바일 게임
- Flutter 3.9.2+ / Dart 3.9.2+ / Feature-First + Clean Architecture
- Riverpod, Freezed, Retrofit 코드 생성 패턴 / WebSocket STOMP 양방향 통신

---

## 금지 규칙

- **`git push` 절대 금지** — 어떤 상황에서도 원격에 push하지 않는다
- **커밋 시 Co-Authored-By 태그 금지** — 커밋 메시지에 절대 추가하지 않는다
- **파일 삭제 시 반드시 사용자 허락** — 확인 없이 파일을 삭제하지 않는다
- **모르면 모른다고 말하기** — 확실하지 않은 내용을 추측하지 않는다
- **답변은 항상 한국어로** — 코드/커맨드 제외 모든 응답은 한국어
- **코드 주석 필수** — 실무 수준의 간결한 한국어 주석 작성 (WHY 중심, 과하지 않게)

---

## 필수 명령어

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (Riverpod, Freezed, Retrofit) — 필수!
dart run build_runner build --delete-conflicting-outputs

# 테스트 / 린트
flutter test
flutter analyze
```

### 코드 생성이 필요한 시점
- `@riverpod`, `@freezed`, `@RestApi`, `@JsonSerializable` 어노테이션 추가/수정 후
- `.g.dart` 또는 `.freezed.dart` 파일 누락 시
- 빌드 에러 중 "generated file not found" 발생 시

---

## 참고 문서

| 문서 | 설명 |
|------|------|
| [QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) | 핵심 규칙 빠른 참조 |
| [01_ARCHITECTURE.md](docs/01_ARCHITECTURE.md) | Clean Architecture 3계층, 의존성 흐름 |
| [02_FOLDER_STRUCTURE.md](docs/02_FOLDER_STRUCTURE.md) | Feature-First 폴더 구조 및 파일 배치 |
| [03_CODE_CONVENTIONS.md](docs/03_CODE_CONVENTIONS.md) | 네이밍, 에러 처리, Null Safety 등 |
| [04_CODE_GENERATION_GUIDE.md](docs/04_CODE_GENERATION_GUIDE.md) | Riverpod/Freezed/Retrofit 코드 생성 |
| [06_API_INTEGRATION_GUIDE.md](docs/06_API_INTEGRATION_GUIDE.md) | API 연동 가이드 |
| [08_TIMER_ARCHITECTURE.md](docs/08_TIMER_ARCHITECTURE.md) | 타이머 아키텍처 |
| [09_WEBSOCKET_EVENT.md](docs/09_WEBSOCKET_EVENT.md) | WebSocket STOMP 이벤트 |
| [API_SPEC.md](docs/API_SPEC.md) | API 명세 |
| [경찰과도둑_PRD_2.md](docs/경찰과도둑_PRD_2.md) | 제품 요구사항 문서 |
