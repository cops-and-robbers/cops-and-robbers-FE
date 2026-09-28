# 🚀 [기능개선][CI][테스트] PR CI에 flutter test 추가 및 커뮤니티 페이지 테스트 뷰포트 고정

## 🔥 구현 기능

| 대상 | 변경 |
|---|---|
| `.github/workflows/PROJECT-FLUTTER-CI.yaml` | `Run Flutter Analyze` 뒤에 `flutter test` 스텝 추가 — `main` 대상 PR에서만 실행 (`push` 제외) |
| `test/features/community/presentation/pages/community_page_test.dart` | `_pumpCommunityPage`에서 뷰포트를 디자인 기준 393×852로 고정 |

<br>

## 📝 현재 문제점

> [!WARNING]
> 테스트 1358개가 있지만 **CI는 `flutter analyze`만 돌린다.** 테스트가 깨져도 PR은 초록으로 머지된다.

- `CLAUDE.md:28`·`AGENTS.md:41`의 표준 명령은 `flutter test && flutter analyze`인데, `PROJECT-FLUTTER-CI.yaml`은 `flutter analyze --no-fatal-infos`만 실행한다.
- 실제로 `main`(`642265ea`) 기준 로컬 `flutter test` 결과는 **1352 통과 · 6 실패**다. 실패는 전부 `community_page_test.dart`의 정렬 시트 테스트이며, 아무도 모른 채 남아 있었다.

<br>

## 🛠️ 해결 방안 / 제안 기능

**실패 6건은 앱 버그가 아니라 테스트 뷰포트 문제다.** 뷰포트를 지정하지 않은 테스트가 Flutter 기본값 800×600에서 돌면서, `CommunitySortSheet`의 고정 높이(`community_sort_sheet.dart:90`, `300.h + 30.h`)가 화면 높이 비율로 줄어 가짜 오버플로우가 났다.

| 화면 | Android | iOS |
|---|---|---|
| 800×600 (테스트 기본값) | 37px 오버플로우 | 58px 오버플로우 |
| 393×852 (디자인 기준) | OK | OK |
| 375×667 (iPhone SE) | OK | OK |
| 360×640 (소형 Android) | OK | OK |

- 테스트: 같은 파일 `:460`이 이미 쓰는 패턴(`tester.view.physicalSize = Size(393, 852)` + `devicePixelRatio = 1.0` + `addTearDown(tester.view.reset)`)을 `_pumpCommunityPage`에 적용한다.
- CI: 기존 `analyze` job에 스텝 하나를 추가해 `.env` 생성·Flutter 설치·`pub get`·캐시를 재사용한다. `main → deploy` PR은 워크플로 트리거(`pull_request: [main]`)에 걸리지 않아 원래 제외된다.

<br>

## 🚧 작업목록

- [ ] `_pumpCommunityPage` 뷰포트 고정
- [ ] `PROJECT-FLUTTER-CI.yaml`에 `flutter test` 스텝 추가
- [ ] 로컬 `flutter test` 전체 통과 · `flutter analyze` 확인
- [ ] PR에서 `Run Flutter Test` 스텝 실행·성공 확인

<br>

## 📌 참고

일부러 범위에서 뺀 것: `main` 브랜치 보호(required check) · codegen 드리프트 검사 · 커버리지 게이트. CI에서 테스트가 안정적으로 돈 뒤 따로 판단한다.

## 🙋‍♂️ 담당자

- 프론트엔드: EM-H20
