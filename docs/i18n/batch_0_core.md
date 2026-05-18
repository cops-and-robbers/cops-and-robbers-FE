# Batch 0: core 공통 영역

> **범위**: `lib/core/` 전체 (공통 위젯, 에러, 다이얼로그, 시스템 채팅)
> **추출 건수**: 45건
> **상태**: 한국어 추출 완료 — LLM 번역 대기

## 번역 규칙

1. placeholder는 절대 번역/변형하지 말 것: `{nickname}`, `{count}`, `$minutes`, `$policeNickname` 등 그대로 유지
2. 아이콘 마커 `@icon_police`, `@icon_robber`도 그대로 유지
3. 문장 끝 마침표(`.` `。`) 찍지 말 것 — 문장 사이 마침표는 의미상 필요하면 유지
4. 물음표(`?`), 느낌표(`!`)는 의미상 필요하면 유지
5. en은 sentence case (Title Case 아님)
6. ja는 です/ます체 (정중체)
7. `glossary.md`의 용어 번역을 반드시 따를 것
8. 줄바꿈 `\n`은 원문 위치 그대로 유지
9. 표 구조 유지, `en`/`ja` 컬럼만 채워서 반환

---

## A. 시스템 채팅 메시지 (game_event_messages.dart)

| key | location | context | placeholders | ko | en | ja |
|---|---|---|---|---|---|---|
| chatSystemGameStartTime | game_event_messages.dart:11 | 게임 시작 시 제한 시간 안내 (시스템 채팅) | $minutes | 제한 시간은 $minutes분입니다 | TODO | TODO |
| chatSystemGameStartReady | game_event_messages.dart:14 | 게임 시작 직전 준비 안내 | - | 잠시 후 게임이 시작됩니다  모든 플레이어는 준비하세요! | TODO | TODO |
| chatSystemGameStartReportTip | game_event_messages.dart:17 | 게임 시작 시 신고 기능 안내 | - | 게임 중 채팅을 길게 눌러 불편한 유저를 신고 및 차단할 수 있습니다 | TODO | TODO |
| chatSystemGameStartGo | game_event_messages.dart:20 | 게임 시작 신호 | - | 게임 시작!  행운을 빕니다! | TODO | TODO |
| chatSystemPoliceMoveWarning | game_event_messages.dart:25 | 경찰 출동 임박 경고 | - | 경찰이 곧 출동합니다  도둑은 서둘러 이동하세요! | TODO | TODO |
| chatSystemPoliceMove | game_event_messages.dart:28 | 경찰 출동 시작 알림 | - | 경찰 출동!  도둑은 도망치세요! | TODO | TODO |
| chatSystemLocationReveal | game_event_messages.dart:33 | 도둑 위치 공개 알림 | - | 현재 도둑의 위치가 공개됩니다! | TODO | TODO |
| chatSystemRemainingRobbers | game_event_messages.dart:36 | 남은 도둑 수 안내 | $count | 현재 $count명 도주 중! | TODO | TODO |
| chatSystemArrest | game_event_messages.dart:42 | 체포 발생 알림 (아이콘 마커 포함) | $policeNickname, $robberNickname | @icon_police [$policeNickname]님이 @icon_robber [$robberNickname]님을 체포했습니다! | TODO | TODO |
| chatSystemEscape | game_event_messages.dart:47 | 도둑 탈옥 알림 | - | 도둑이 탈옥했습니다! 지금 바로 체포하세요! | TODO | TODO |
| chatSystemFiveMinutesLeft | game_event_messages.dart:52 | 게임 종료 5분 전 경고 | - | 게임 종료까지 5분 남았습니다 마지막 기회를 놓치지 마세요! | TODO | TODO |

## B. API/네트워크 에러 (dio_exception_handler.dart)

| key | location | context | placeholders | ko | en | ja |
|---|---|---|---|---|---|---|
| errorNetworkTimeout | dio_exception_handler.dart:41 | 서버 응답 시간 초과 (DioException timeout) | - | 서버 연결 시간이 초과되었습니다 | TODO | TODO |
| errorNetworkOffline | dio_exception_handler.dart:49 | 네트워크 연결 끊김 (DioException connectionError) | - | 네트워크 연결을 확인하세요 | TODO | TODO |
| errorServerInternal | dio_exception_handler.dart:63 | 서버 5xx 에러 기본 메시지 | - | 서버에 문제가 발생했습니다 | TODO | TODO |
| errorBadRequest | dio_exception_handler.dart:71 | 400 Bad Request 기본 메시지 | - | 잘못된 요청입니다 | TODO | TODO |
| errorUnauthorized | dio_exception_handler.dart:76 | 401 Unauthorized 기본 메시지 | - | 인증에 실패했습니다 | TODO | TODO |
| errorForbidden | dio_exception_handler.dart:81 | 403 Forbidden 기본 메시지 | - | 접근 권한이 없습니다 | TODO | TODO |
| errorNotFound | dio_exception_handler.dart:86 | 404 Not Found 기본 메시지 | - | 요청한 리소스를 찾을 수 없습니다 | TODO | TODO |
| errorConflict | dio_exception_handler.dart:91 | 409 Conflict 기본 메시지 | - | 요청이 현재 상태와 충돌합니다 | TODO | TODO |
| errorNetworkUnknown | dio_exception_handler.dart:96 | 알 수 없는 네트워크 에러 | - | 네트워크 연결을 확인하세요 | TODO | TODO |

## C. 인증 예외 (app_exception.dart)

| key | location | context | placeholders | ko | en | ja |
|---|---|---|---|---|---|---|
| errorAuthLoginCancelled | app_exception.dart:57 | 사용자가 로그인 흐름을 취소했을 때 (AuthCancelledException 기본 메시지) | - | 로그인이 취소되었습니다 | TODO | TODO |

## D. 공통 버튼 (social_login_button.dart)

| key | location | context | placeholders | ko | en | ja |
|---|---|---|---|---|---|---|
| buttonGoogleSignIn | social_login_button.dart:39 | Google 소셜 로그인 버튼 | - | Google로 시작하기 | TODO | TODO |
| buttonAppleSignIn | social_login_button.dart:86 | Apple 소셜 로그인 버튼 | - | Apple로 시작하기 | TODO | TODO |

## E. 공통 다이얼로그 기본 라벨 (app_dialog.dart)

| key | location | context | placeholders | ko | en | ja |
|---|---|---|---|---|---|---|
| buttonConfirm | app_dialog.dart:79,197,266 | 다이얼로그 긍정 버튼 기본값 | - | 확인 | TODO | TODO |
| buttonCancel | app_dialog.dart:267 | 다이얼로그 부정 버튼 기본값 | - | 취소 | TODO | TODO |

## F. 재연결 모달 (reconnect_modal.dart)

| key | location | context | placeholders | ko | en | ja |
|---|---|---|---|---|---|---|
| dialogReconnectMessage | reconnect_modal.dart:158 | WebSocket 연결 끊김 안내 모달 본문 | - | 연결이 끊어졌어요 재연결이 필요해요 | TODO | TODO |
| dialogReconnectButtonConnecting | reconnect_modal.dart:169 | 재연결 버튼 (연결 시도 중) | - | 연결 중... | TODO | TODO |
| dialogReconnectButtonRetry | reconnect_modal.dart:169 | 재연결 버튼 (시도 가능 상태) | - | 재연결 | TODO | TODO |

## G. 강제 업데이트 페이지 (force_update_page.dart)

| key | location | context | placeholders | ko | en | ja |
|---|---|---|---|---|---|---|
| pageForceUpdateTitle | force_update_page.dart:41 | 강제 업데이트 페이지 제목 | - | 업데이트 필요 | TODO | TODO |
| pageForceUpdateMessage | force_update_page.dart:49 | 강제 업데이트 페이지 본문 (줄바꿈 포함) | - | 새로운 버전이 출시되었어요\n업데이트 후 이용해 주세요! | TODO | TODO |
| pageForceUpdateButton | force_update_page.dart:60 | 강제 업데이트 페이지 버튼 | - | 업데이트 | TODO | TODO |

## H. 점검 페이지 (maintenance_page.dart)

| key | location | context | placeholders | ko | en | ja |
|---|---|---|---|---|---|---|
| pageMaintenanceTitle | maintenance_page.dart:39 | 서버 점검 페이지 제목 | - | 서버 점검 중 | TODO | TODO |
| pageMaintenanceMessage | maintenance_page.dart:47 | 서버 점검 페이지 본문 (줄바꿈 포함) | - | 더 나은 서비스를 위해 점검 중이에요\n잠시 후 다시 접속해 주세요! | TODO | TODO |

## I. 업데이트 다이얼로그 (update_dialog_helper.dart)

| key | location | context | placeholders | ko | en | ja |
|---|---|---|---|---|---|---|
| dialogUpdateOptionalTitle | update_dialog_helper.dart:53 | 선택적 업데이트 다이얼로그 제목 | - | 새 버전 안내 | TODO | TODO |
| dialogUpdateOptionalMessage | update_dialog_helper.dart:54 | 선택적 업데이트 다이얼로그 본문 (줄바꿈 포함) | - | 더 좋아진 새 버전이 있어요\n업데이트하시겠어요? | TODO | TODO |
| dialogUpdateOptionalConfirm | update_dialog_helper.dart:55 | 선택적 업데이트 - 업데이트 버튼 | - | 업데이트 | TODO | TODO |
| dialogUpdateOptionalCancel | update_dialog_helper.dart:56 | 선택적 업데이트 - 나중에 버튼 | - | 나중에 | TODO | TODO |
| dialogUpdateMandatoryTitle | update_dialog_helper.dart:68 | 권장 업데이트 다이얼로그 제목 | - | 업데이트 안내 | TODO | TODO |
| dialogUpdateMandatoryMessage | update_dialog_helper.dart:69 | 권장 업데이트 다이얼로그 본문 (줄바꿈 포함) | - | 새로운 버전이 출시되었어요\n업데이트하시겠어요? | TODO | TODO |

## J. 로딩 메시지 (loading_message_service.dart)

| key | location | context | placeholders | ko | en | ja |
|---|---|---|---|---|---|---|
| loadingDefault | loading_message_service.dart:49 | 로딩 fallback 메시지 (카테고리별 메시지 없을 때) | - | 처리 중... | TODO | TODO |

## K. 위치 권한 폴백 (location_permission_messages.dart)

> 참고: `assets/messages/location_permission_messages.json`의 컨텍스트별 메시지는 **Batch 6**에서 ARB로 통합 예정. 본 배치에는 폴백 텍스트만 포함

| key | location | context | placeholders | ko | en | ja |
|---|---|---|---|---|---|---|
| permissionLocationFallbackTitle | location_permission_messages.dart:48 | 위치 권한 다이얼로그 제목 (JSON 로드 실패 시 폴백) | - | 위치 권한 안내 | TODO | TODO |
| permissionLocationFallbackMessage | location_permission_messages.dart:49 | 위치 권한 다이얼로그 본문 (JSON 로드 실패 시 폴백) | - | 위치 권한을 허용해주세요 | TODO | TODO |

## L. 구역 설정 위젯 (zone_setting_button.dart, zone_setting_widget.dart)

| key | location | context | placeholders | ko | en | ja |
|---|---|---|---|---|---|---|
| zoneRadiusKm | zone_setting_button.dart:129 | 반경 km 단위 표시 (1km 이상) | ${km} | 반경 ${km}km | TODO | TODO |
| zoneRadiusMeter | zone_setting_button.dart:131 | 반경 m 단위 표시 (1km 미만) | $radiusMeters | 반경 $radiusMeters m | TODO | TODO |
| zoneRadiusLabel | zone_setting_widget.dart:364,401 | 반경 슬라이더 라벨 / prefix | - | 반경 | TODO | TODO |

---

## 메모 / 확인 사항

- `chatSystemArrest` 메시지의 `@icon_police`, `@icon_robber` 마커는 채팅 렌더러에서 아이콘으로 치환됨 — 번역 시 위치/순서 유지 필수
- `game_event_messages.dart` 원문에 일부 마침표가 있으나 번역 시 모두 제거 (컨벤션 적용)
- `loadingDefault`의 말줄임표(`...`)는 로딩 인디케이터 관용 표현 — 영어/일본어 번역 시 `...` 유지 권장
- `pageForceUpdateMessage` 등 줄바꿈 `\n` 포함 메시지는 원문 위치 그대로 유지 (한국어 길이 ≠ 영어/일본어 길이지만 줄바꿈 위치는 원문 기준)
- `zoneRadiusLabel`의 "반경"은 `prefix`로도 쓰이고 `label`로도 쓰임 — 단독 단어로 자연스러운 번역 필요
