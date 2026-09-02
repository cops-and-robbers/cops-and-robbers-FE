# 기능 개선 보고서 — AppButton 기본 텍스트 label 18 상향

## 📌 작업 개요

- **이슈**: #540 AppButton 기본 텍스트 스타일을 label 18로 상향 (프론트 팀 결정 사항)
- **수정 파일**: `lib/core/constants/text_styles.dart`, `lib/core/widgets/buttons/app_button.dart`

## ✅ 수정 내용

| 파일 | 변경 내용 | 이유 |
|---|---|---|
| `text_styles.dart` | `label_18` 신설 - 18sp, Pretendard-SemiBold, height 1.0, letterSpacing -0.36 | 기존에 없던 스타일. 자간은 label_16(-0.32 = -2%)과 같은 -2% 문법을 유지 |
| `app_button.dart` | 기본 텍스트 스타일 `label_16` → `label_18` (단일 텍스트·2줄 텍스트의 메인 줄 두 곳) + 문서 주석 갱신 | `textStyle` 미지정 버튼 전체에 일괄 적용. 오버라이드한 버튼(다크 robberLabel 등)은 영향 없음 |

## 🧪 테스트 및 검증

에뮬레이터(Android API 36.1) 디버그 빌드로 기본 스타일 버튼이 쓰이는 대표 화면을 돌면서 줄바꿈·높이 깨짐이 없는지 확인했다.

- 홈 - 게임 생성하기 / 게임 참여하기 (반폭 2버튼, 아이콘+텍스트)
- 방 참여하기 다이얼로그 - 닫기 / 참여하기 (다이얼로그 2버튼, 가장 좁은 케이스)
- 방 생성 최종 확인 - 게임 생성하기 (전폭)
- 닉네임 설정 - 확인 (전폭) / 중복 확인 (텍스트필드 suffix의 좁은 버튼)

모두 한 줄 유지, 버튼 높이(48/56) 변화 없음. `dart format` 변경 없음, `flutter analyze` 두 파일 No issues.

## 📌 참고사항

- `KeypadCtaButton`(키패드 위 CTA)은 `AppButton`이 아닌 별도 컴포넌트로 `label_16`을 직접 쓴다. 팀 결정이 "AppButton 기본값"이라 이번 범위에서 제외했다 - 키패드 CTA도 키울지는 디자인 확인 필요.
- 다크(도둑) 테마 버튼은 대부분 `robberLabel`(Moneygraphy)을 명시해 이번 변경의 영향이 없다.
