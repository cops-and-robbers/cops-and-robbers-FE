# i18n 마이그레이션 워크플로우

> 인앱 메시지 외부화 + 다국어 지원(ko/en/ja) 작업 관리 문서
> 관련 이슈: `.issues/20260504_기능개선_다이얼로그_메시지_외부화_통일.md`

## 전체 흐름 (통합 파일 방식)

```
[1] dev: 한국어 일괄 추출 → docs/i18n/messages_all.md (ko 컬럼만 채워짐)
       ↓
[2] dev: messages_all.md + glossary.md를 LLM에 전달
       ↓
[3] LLM: en/ja 컬럼 채워서 messages_all_translated.md 반환
       ↓
[4] dev: 번역 검수 (특히 게임 도메인 용어 일관성)
       ↓
[5] Claude: messages_all_translated.md → ARB 파일 가공
            (app_ko.arb / app_en.arb / app_ja.arb 생성)
            + 임시 자동 키 → 의미 기반 키로 변환
       ↓
[6] Claude: 코드에서 하드코딩 → AppLocalizations 호출로 점진 교체
            (feature 단위로 PR 분할)
       ↓
[7] dev: feature별 PR 생성/머지
```

## 파일 구성

```
docs/i18n/
├── README.md                          # 본 문서
├── glossary.md                        # 도메인 용어집 (ko/en/ja) — LLM에 함께 전달
├── messages_all.md                    # 한국어 추출본 (LLM 입력)
├── messages_all_translated.md         # LLM 번역 결과 (en/ja 채워진 상태)
└── _extract.py                        # 추출 자동화 스크립트 (재실행 가능)
```

## 작업 단계

| 단계 | 내용 | 담당 | 상태 |
|---|---|---|---|
| 0 | 한국어 추출 → `messages_all.md` 생성 | dev (`python3 docs/i18n/_extract.py`) | 🟢 완료 (675건, 디버그 메시지 자동 제외) |
| 1 | LLM에 번역 의뢰 → `messages_all_translated.md` 저장 | dev + LLM | ⬜ 대기 |
| 2 | 번역 검수 (도메인 용어/톤/placeholder 보호) | dev | ⬜ 대기 |
| 3 | 검수본 → ARB 파일 3종 생성 | Claude | ⬜ 대기 |
| 4 | l10n 인프라 셋업 (pubspec, l10n.yaml, LocaleNotifier, MaterialApp 연동) | Claude | ⬜ 대기 |
| 5 | 코드 하드코딩 → AppLocalizations 교체 (feature 단위로 PR 분할) | Claude | ⬜ 대기 |
| 6 | 언어 전환 UI (settings_page에 언어 선택 추가) | Claude | ⬜ 대기 |
| 7 | 회귀 검증 + 스크린샷 검수 (ko/en/ja 모든 화면) | dev + 디자이너 | ⬜ 대기 |

## LLM 번역 요청 프롬프트 (템플릿)

```
첨부된 한국어 메시지들을 영어와 일본어로 번역해줘.

규칙:
1. placeholder는 절대 번역/변형하지 말 것: {nickname}, {count}, $minutes, ${response.gameId} 등 그대로 유지
2. 아이콘 마커도 그대로 유지: @icon_police, @icon_robber
3. 줄바꿈 \n은 원문 위치 그대로 유지
4. 문장 끝 마침표(. 또는 。)는 찍지 말 것 (원문에 있어도 제거)
5. 물음표(?), 느낌표(!)는 의미상 필요하면 유지
6. en은 sentence case (Title Case 아님), friendly but not overly casual
7. ja는 です/ます체 (정중체), 외래어는 카타카나
8. 첨부한 glossary.md의 번역을 반드시 따를 것 — 일관성이 최우선
9. 표 구조 유지, key/location/code/placeholders/ko 컬럼은 건드리지 말고 en/ja 컬럼만 채워서 반환
10. 만약 디버그/로그성 메시지가 보이면 (자동 필터로 대부분 제거됐지만 100%는 아님) en/ja에 `[SKIP - debug message]`로 표시

[glossary.md 내용 붙여넣기]

[messages_all.md 내용 붙여넣기]
```

## false positive 안내

`_extract.py`가 자동으로 다음 패턴은 제외함:

- `debugPrint(...)`, `AppLogger.xxx(...)`, `print(...)` 내부 문자열
- 멀티라인 `AppLogger.info(\n '...'` 형태 (괄호 균형 백트래킹으로 감지)
- 이모지 prefix 메시지 (✅ ❌ 🔄 📱 ⚠ 등)
- `[Service]`, `[Notifier]` 같은 대괄호 prefix 메시지
- `///`, `//` 주석 라인

⚠️ 디버그 메시지를 새로 추가할 때는 위 패턴(이모지/대괄호 prefix 또는 debugPrint/AppLogger 사용)을 따라야 자동 제외됨

## ARB 키 네이밍 컨벤션 (가공 단계에서 적용)

`messages_all.md`의 임시 키(`<feature>_<filename>_L<line>`)는 ARB 가공 시 의미 기반 키로 변환됨

| Prefix | 용도 | 예시 |
|---|---|---|
| `button` | 공통 버튼 라벨 | `buttonConfirm`, `buttonCancel`, `buttonGoogleSignIn` |
| `dialog` | 다이얼로그 (title/message/action) | `dialogUpdateOptionalTitle` |
| `snackbar` | 스낵바 | `snackbarCopySuccess`, `snackbarNicknameSaved` |
| `error` | 에러 메시지 (API, 인증, 검증 등) | `errorNetworkTimeout`, `errorAuthLoginCancelled` |
| `page` | 페이지 본문 (제목, 본문) | `pageForceUpdateTitle`, `pageMaintenanceTitle` |
| `chat` | 시스템 채팅 | `chatSystemGameStartReady` |
| `loading` | 로딩 인디케이터 | `loadingDefault`, `loadingLogin` |
| `permission` | 권한 안내 | `permissionLocationServiceDisabled` |
| `tutorial` | 튜토리얼 | `tutorialWelcome` |
| `field` | 입력 필드 라벨/hint | `fieldNicknameLabel`, `fieldNicknameHint` |
| `game` | 게임 UI 노출 용어 | `gameTeamPolice`, `gameStatusJailed` |

## 폴백 정책

- 사용자 선택 언어 → en → ko 순으로 폴백
- ARB 키 누락 시 `flutter gen-l10n` 빌드 경고 발생 → CI에서 catch

## 추출 스크립트 재실행

코드 변경으로 새 한국어 메시지가 추가되면 재추출 필요:

```bash
python3 docs/i18n/_extract.py
```

기존 `messages_all.md`를 덮어씀. 번역 진행 중이면 `messages_all_translated.md`와 diff 확인 후 신규 항목만 추가 번역 의뢰
