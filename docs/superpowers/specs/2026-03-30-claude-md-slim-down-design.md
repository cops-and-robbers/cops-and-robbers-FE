# CLAUDE.md 축소 설계

## 목표
- 524줄 → 60~70줄
- 매 대화 로드 시 토큰 절약
- 상세 내용은 docs/ 링크로 대체

## 최종 구조

### 1. 프로젝트 개요 (~5줄)
- 한 줄 설명 + 기술 스택 (Flutter, Riverpod, Freezed, Retrofit, STOMP)

### 2. 금지 규칙 (~10줄)
- `git push` 절대 금지
- 커밋 시 Co-Authored-By 태그 금지
- 파일 삭제 시 반드시 사용자 허락
- 모르면 모른다고 말하기 (추측 금지)

### 3. 필수 명령어 (~15줄)
- `flutter pub get`
- `flutter pub run build_runner build --delete-conflicting-outputs`
- `flutter test` / `flutter analyze`
- 코드 생성이 필요한 시점 요약 (3줄)

### 4. 참고 문서 링크 (~20줄)
- docs/ 내 문서별 한 줄 설명 테이블

## 제거 대상 (CLAUDE.md에서만 제거, docs/ 원본 유지)
- 아키텍처 원칙 상세 → `docs/01_ARCHITECTURE.md`
- 코드 컨벤션/네이밍 테이블 → `docs/03_CODE_CONVENTIONS.md`
- 코드 생성 패턴 + 모든 코드 예시 → `docs/04_CODE_GENERATION_GUIDE.md`
- 실시간 통신 아키텍처 → `docs/09_WEBSOCKET_EVENT.md`
- 환경 설정(.env), 공통 유틸리티, UI 가이드, 트러블슈팅 → `docs/QUICK_REFERENCE.md`
- 코드 리뷰 체크리스트 → 삭제 (docs 읽으면 됨)
- 리뷰 커맨드 테이블 → 삭제 (사용자가 수동 실행)
- 핵심 원칙 요약 → 삭제 (상위 섹션과 중복)
