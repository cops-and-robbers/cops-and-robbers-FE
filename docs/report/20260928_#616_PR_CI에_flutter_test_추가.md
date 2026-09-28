### 📌 작업 개요
PR CI가 `flutter analyze`만 돌리던 것을 **`flutter test`까지 실행**하도록 확장. 이를 위해 기본 뷰포트(800×600)에서 가짜 오버플로우로 실패하던 커뮤니티 페이지 테스트 6개를 디자인 기준 뷰포트로 고정해 전체 테스트를 초록으로 만들었다.

**보고서 파일**: `docs/report/20260928_#616_PR_CI에_flutter_test_추가.md`

### 🔍 문제 분석
- `CLAUDE.md`·`AGENTS.md`의 표준 명령은 `flutter test && flutter analyze`인데, `PROJECT-FLUTTER-CI.yaml`은 `flutter analyze --no-fatal-infos`만 실행했다. 테스트가 깨져도 PR은 초록으로 머지될 수 있는 상태.
- 실제로 `main`(`642265ea`) 기준 `flutter test`는 **1352 통과 · 6 실패**였다. 실패는 전부 `community_page_test.dart`의 정렬 시트 관련 테스트.
- 원인은 앱이 아니라 테스트 뷰포트다. 실패 테스트들은 `_pumpCommunityPage`를 거치며 뷰포트를 지정하지 않아 Flutter 기본값 800×600에서 돈다. `CommunitySortSheet`의 높이(`community_sort_sheet.dart:90`, `300.h + androidExtra`)는 ScreenUtil `.h`라 화면 높이 비율(600/852)로 줄어들고, 항목 4개가 들어가지 않아 오버플로우가 났다.

| 뷰포트 | Android | iOS |
|---|---|---|
| 800×600 (테스트 기본값) | 37px 오버플로우 | 58px 오버플로우 |
| 393×852 (디자인 기준) | 정상 | 정상 |
| 375×667 (iPhone SE) | 정상 | 정상 |
| 360×640 (소형 Android) | 정상 | 정상 |

### ✅ 구현 내용

#### CI에 flutter test 스텝 추가
- **파일**: `.github/workflows/PROJECT-FLUTTER-CI.yaml`
- **변경 내용**: `analyze` job의 `Run Flutter Analyze` 뒤에 `Run Flutter Test`(`flutter test`) 스텝 추가. `if: github.event_name != 'push'`로 `main` 대상 PR과 수동 실행에서만 돈다
- **이유**: 같은 job에 두면 `.env` 생성·Flutter 설치·`pub get`·캐시를 재사용한다. 머지 직후 `push: main` 실행에서는 PR에서 이미 통과한 테스트를 다시 돌리지 않는다. `main → deploy` PR은 트리거(`pull_request: [main]`)에 걸리지 않아 원래 제외된다

#### 커뮤니티 페이지 테스트 뷰포트 고정
- **파일**: `test/features/community/presentation/pages/community_page_test.dart`
- **변경 내용**: `_pumpCommunityPage`에서 `tester.view.physicalSize = Size(393, 852)`, `devicePixelRatio = 1.0`, `addTearDown(tester.view.reset)` 설정
- **이유**: 같은 파일 `appends_the_next_page_when_scrolled_to_the_bottom`이 이미 쓰는 패턴. 앱 코드는 실제 폰 크기에서 문제가 없으므로 테스트 쪽을 실제 기기 비율에 맞춘다

### 📦 의존성 변경
- 없음

### 🧪 테스트 및 검증
- 로컬 `flutter test` 전체: 수정 전 1352 통과 · 6 실패 → 수정 후 **1358 전부 통과** (약 37초)
- 정렬 시트를 4개 뷰포트 × Android/iOS로 띄워 오버플로우 여부 확인 (위 표). 확인용 임시 테스트는 커밋하지 않음
- 워크플로 YAML 파싱 및 스텝 순서 확인
- `flutter analyze --no-fatal-infos`: 추적 파일 기준 신규 경고 없음. 로컬에서 나오는 warning 5개는 gitignore된 `docs/superpowers/sdd/task-4-test-fix.dart`에서만 발생해 CI 체크아웃에는 해당 없음

### 📌 참고사항
- 이번 범위에서 뺀 것: `main` 브랜치 보호(required check), codegen 드리프트 검사, 커버리지 게이트. 브랜치 보호가 없으면 CI 실패는 표시만 되고 머지를 막지 않는다
- 로컬 Flutter 3.35.3, CI Flutter 3.35.5
