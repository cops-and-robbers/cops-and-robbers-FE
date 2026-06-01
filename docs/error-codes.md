# 에러코드 목록

모든 실패 응답에 `errorCode` 필드가 포함됩니다. `errorCode` 기준으로 분기하고, `detail`은 fallback으로만 사용하세요.

## 응답 구조

```json
{
  "errorCode": "INVALID_INVITE_CODE",
  "title": "초대 코드 오류",
  "status": 400,
  "detail": "입력하신 초대 코드가 유효하지 않습니다.",
  "instance": "/api/games/1/participants"
}
```

---

## CommonException

| errorCode | status | title | detail |
|-----------|--------|-------|--------|
| `MISSING_REQUEST_PART` | 400 | 필수 요청 파트 누락 | 요청에 필요한 파트가 누락되었습니다. |
| `INVALID_REQUEST_BODY` | 400 | 잘못된 요청 본문 | 요청 본문의 형식이 잘못되었습니다. |
| `INVALID_QUERY_PARAMETER` | 400 | 잘못된 쿼리 파라미터 | 쿼리 파라미터의 형식이 잘못되었습니다. |
| `QUERY_PARAMETER_TYPE_MISMATCH` | 400 | 쿼리 파라미터 타입 불일치 | 요청 파라미터의 타입이 잘못되었습니다. |
| `INVALID_INPUT_VALUE` | 400 | 유효하지 않은 입력값 | 입력값이 유효성 검사를 통과하지 못했습니다. |
| `INVALID_DESTINATION` | 400 | 잘못된 경로 요청 | 요청하신 STOMP 경로가 올바르지 않습니다. 주소를 다시 확인해주세요. |
| `UNSUPPORTED_MEDIA_TYPE` | 415 | 지원하지 않는 미디어 타입 | 서버에서 지원하지 않는 Content-Type 입니다. |
| `METHOD_NOT_ALLOWED` | 405 | 지원하지 않는 메소드 | 해당 엔드 포인트는 서버에서 지원하지 않는 HTTP 메소드 입니다. |
| `ENDPOINT_NOT_FOUND` | 404 | 요청 경로를 찾을 수 없음 | 요청한 URL에 해당하는 API를 찾을 수 없습니다. |
| `INVALID_SOCKET_SESSION` | 401 | 소켓 연결 오류 | 세션 정보를 찾을 수 없습니다. 다시 연결해주세요. |
| `UNAUTHORIZED_SUBSCRIPTION` | 403 | 구독 권한 없음 | 해당 팀 전용 채널을 구독할 권한이 없습니다. |
| `INTERNAL_SERVER_ERROR` | 500 | 알 수 없는 오류 | 서버 내부에 알 수 없는 오류가 발생했습니다. 관리자에게 문의 하세요. |
| `FIREBASE_INIT_ERROR` | 500 | 파이어베이스 SDK 오류 | 파이어베이스 SDK 초기화 중 알 수 없는 오류가 발생했습니다. |
| `FIREBASE_CONFIG_NOT_FOUND` | 500 | 설정 파일 누락 | 지정된 경로에서 파이어베이스 서비스 계정 키(JSON)를 찾을 수 없습니다. |
| `ENCRYPTION_FAILED` | 500 | 암호화 실패 | 데이터 암호화 중 오류가 발생했습니다. |
| `DECRYPTION_FAILED` | 500 | 복호화 실패 | 데이터 복호화 중 오류가 발생했습니다. |
| `INVALID_ENCRYPTION_KEY` | 500 | 잘못된 암호화 키 | 암호화 키는 256bit(32바이트)여야 합니다. |

## AuthException

| errorCode | status | title | detail |
|-----------|--------|-------|--------|
| `SOCIAL_LOGIN_FAILED` | 401 | 로그인 실패 | 소셜 로그인에 실패하였습니다. |
| `ACCESS_TOKEN_EXPIRED` | 401 | 인증 만료 | 인증 정보가 만료되었습니다. |
| `REFRESH_TOKEN_EXPIRED` | 401 | 로그인 만료 | 로그인이 만료되었습니다. 다시 로그인해주세요. |
| `INVALID_TOKEN` | 401 | 유효하지 않은 인증 정보 | 인증 정보가 올바르지 않습니다. 다시 로그인해주세요. |
| `UNAUTHENTICATED_REQUEST` | 401 | 인증되지 않은 요청 | 로그인이 필요합니다. |
| `EXPIRED_FIREBASE_TOKEN` | 401 | Firebase 인증 만료 | Firebase 토큰이 만료되었습니다. 다시 인증해주세요. |
| `INVALID_FIREBASE_TOKEN` | 401 | Firebase 인증 실패 | 유효하지 않은 Firebase 토큰입니다. |
| `UNSUPPORTED_SOCIAL_TYPE` | 400 | 지원하지 않는 로그인 방식 | 지원하지 않는 소셜 로그인 방식입니다. |
| `FORBIDDEN_ADMIN_ONLY` | 403 | 권한 없음 | 관리자 권한이 필요합니다. |
| `NICKNAME_GENERATION_FAILED` | 500 | 회원가입 실패 | 랜덤 닉네임 생성에 실패했습니다. 잠시 후 다시 시도해주세요. |
| `FIREBASE_SERVER_ERROR` | 500 | Firebase 통신 오류 | Firebase 서버 통신 중 알 수 없는 오류가 발생했습니다. |

## UserException

| errorCode | status | title | detail |
|-----------|--------|-------|--------|
| `USER_NOT_FOUND` | 401 | 존재하지 않는 회원 | 해당 유저를 찾을 수 없습니다. |
| `DUPLICATED_NICKNAME` | 409 | 닉네임 중복 | 이미 사용 중인 닉네임입니다. 다른 닉네임을 선택해주세요. |
| `CANNOT_WITHDRAW` | 409 | 회원 탈퇴 불가 | 진행 중인 게임 세션이 있어 탈퇴할 수 없습니다. |
| `REQUIRED_TERMS_NOT_AGREED` | 400 | 필수 약관 미동의 | 필수 약관은 모두 동의해야 합니다. |

## GameException

| errorCode | status | title | detail |
|-----------|--------|-------|--------|
| `GAME_NOT_FOUND` | 404 | 게임을 찾을 수 없음 | 요청하신 게임 정보가 존재하지 않습니다. |
| `GAME_NOT_IN_PROGRESS` | 400 | 게임 진행 중 아님 | 게임이 진행 중인 상태가 아닙니다. |
| `GAME_NOT_ACTIVE` | 400 | 비활성 게임 | 대기 중이거나 진행 중인 게임에서만 조회할 수 있습니다. |
| `GAME_NOT_WAITING` | 400 | 대기 중인 게임이 아님 | 대기 중인 게임에서만 설정을 변경할 수 있습니다. |
| `INVALID_LOCATION_INTERVAL` | 400 | 유효하지 않은 위치 공개 주기 | 위치 공개 주기는 라운드 시간보다 짧아야 합니다. |
| `INVALID_POLICE_WAIT_TIME` | 400 | 유효하지 않은 경찰 대기 시간 | 경찰 대기 시간은 라운드 시간보다 짧아야 합니다. |
| `INVITE_CODE_GENERATION_FAILED` | 500 | 초대 코드 생성 실패 | 고유한 초대 코드를 생성하지 못했습니다. 잠시 후 다시 시도해주세요. |

## GameAreaException

| errorCode | status | title | detail |
|-----------|--------|-------|--------|
| `INVALID_JAIL_RADIUS` | 400 | 유효하지 않은 감옥 반지름 | 감옥의 반지름이 플레이그라운드의 반지름보다 크거나 같을 수 없습니다. |
| `JAIL_OUTSIDE_PLAYGROUND` | 400 | 감옥 영역 벗어남 | 감옥은 플레이그라운드 내부에 완전히 포함되어야 합니다. |
| `GAME_AREA_NOT_FOUND` | 404 | 게임 구역을 찾을 수 없음 | 해당 게임 구역을 찾을 수 없습니다. |

## GameParticipantException

| errorCode | status | title | detail |
|-----------|--------|-------|--------|
| `ALREADY_PARTICIPATING` | 409 | 이미 참가 중인 게임 | 이미 해당 게임에 참가하고 있습니다. |
| `GAME_ALREADY_STARTED` | 400 | 이미 시작된 게임 | 이미 시작된 게임에는 참여할 수 없습니다. |
| `GAME_FULL` | 400 | 게임 인원 초과 | 게임에 참가할 수 있는 최대 인원을 초과했습니다. |
| `INVALID_INVITE_CODE` | 400 | 초대 코드 오류 | 입력하신 초대 코드가 유효하지 않습니다. |
| `PARTICIPANT_NOT_FOUND` | 404 | 참가자를 찾을 수 없음 | 해당 게임에 참가하지 않은 사용자입니다. |
| `NOT_A_PARTICIPANT` | 403 | 참여 권한 없음 | 해당 게임의 참가자가 아닙니다. |
| `CANNOT_LEAVE_DURING_GAME` | 400 | 게임 진행 중 퇴장 불가 | 게임이 시작된 이후에는 방을 나갈 수 없습니다. |
| `LOBBY_ACTION_NOT_ALLOWED` | 400 | 로비 조작 불가 | 게임이 시작된 이후에는 로비 상태를 변경할 수 없습니다. |
| `NOT_HOST` | 403 | 호스트 권한 필요 | 게임을 시작할 수 있는 권한이 없습니다. 방장만 게임을 시작할 수 있습니다. |
| `INVALID_TEAM_COMPOSITION` | 400 | 팀 구성 오류 | 게임을 시작하려면 경찰과 도둑 팀에 각각 최소 1명 이상의 참가자가 필요합니다. |
| `NOT_ALL_READY` | 400 | 준비 미완료 | 모든 참가자가 준비 상태여야 게임을 시작할 수 있습니다. |
| `NOT_ROBBER_TEAM` | 400 | 도둑 팀이 아님 | 도둑 팀만 위치를 전송할 수 있습니다. |
| `HOST_CANNOT_UNREADY` | 400 | 방장 레디 해제 불가 | 방장은 항상 준비 상태여야 합니다. |
| `PARTICIPANT_GAME_MISMATCH` | 400 | 참가자 게임 불일치 | 경찰과 도둑이 서로 다른 게임에 참여하고 있습니다. |
| `ONLY_POLICE_CAN_ARREST` | 400 | 경찰만이 체포 가능 | 경찰 팀만 도둑을 체포할 수 있습니다. |
| `ONLY_ROBBER_CAN_BE_ARRESTED` | 400 | 도둑만을 체포 가능 | 도둑 팀만 체포될 수 있습니다. |
| `ONLY_ROBBER_CAN_ESCAPE` | 400 | 도둑만 탈옥 가능 | 도둑 팀만 탈옥할 수 있습니다. |
| `ALREADY_ARRESTED` | 400 | 이미 체포됨 | 이미 수감된 도둑입니다. |
| `NOT_JAILED` | 400 | 수감되지 않음 | 수감된 상태에서만 탈옥할 수 있습니다. |
| `POLICE_WAITING_TIME` | 400 | 경찰 대기 시간 | 경찰은 대기 시간 동안 도둑을 체포할 수 없습니다. |
| `CANNOT_KICK_YOURSELF` | 400 | 자기 자신 강퇴 불가 | 방장은 자기 자신을 강퇴할 수 없습니다. |

## NoticeException

| errorCode | status | title | detail |
|-----------|--------|-------|--------|
| `NOTICE_NOT_FOUND` | 404 | 공지사항을 찾을 수 없음 | 해당 공지사항을 찾을 수 없습니다. |
| `FORBIDDEN_ADMIN_ONLY` | 403 | 권한 없음 | 관리자 권한이 필요합니다. |

## GameResultException

| errorCode | status | title | detail |
|-----------|--------|-------|--------|
| `GAME_RESULT_NOT_FOUND` | 404 | 게임 결과를 찾을 수 없음 | 해당 게임 결과를 찾을 수 없습니다. |

## ReportException

| errorCode | status | title | detail |
|-----------|--------|-------|--------|
| `ETC_REASON_REQUIRED` | 400 | 기타 사유를 입력해주세요. | 신고 유형이 기타일 때 사유를 입력해야 합니다. |
| `SELF_REPORT` | 400 | 본인을 신고할 수 없습니다. | 본인을 신고할 수 없습니다. |
| `DUPLICATE_REPORT` | 409 | 이미 신고한 사용자입니다. | 해당 게임에서 이미 신고한 사용자입니다. |
| `REPORT_NOT_FOUND` | 404 | 신고 내역을 찾을 수 없습니다. | 해당 신고 내역이 존재하지 않습니다. |
| `REPORT_TARGET_NOT_FOUND` | 404 | 신고 대상을 찾을 수 없습니다. | 해당 게임에 존재하지 않는 참가자입니다. |

