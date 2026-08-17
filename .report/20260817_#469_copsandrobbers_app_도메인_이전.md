### 📌 작업 개요

`copsnro66ers.site` -> `copsandrobbers.app` 도메인 이전에 맞춰 앱의 딥링크 host 와 API 주소를 신 도메인으로 교체. 딥링크 host 는 단일 소스 상수라 한 곳만 바꾸면 링크 생성·수신이 함께 따라가고, 네이티브 두 파일은 빌드타임 설정이라 별도로 맞춤.

**보고서 파일**: `.report/20260817_#469_copsandrobbers_app_도메인_이전.md`

### 🎯 구현 목표

- 앱이 바라보는 API·WebSocket 주소를 신 도메인으로 교체
- App Links(Android) / Universal Links(iOS) 를 신 도메인으로 교체
- 도메인이 다시 바뀌어도 테스트가 함께 깨지지 않도록 정리

### ✅ 구현 내용

#### 딥링크 host 상수 교체

- **파일**: `lib/core/deeplink/deeplink_constants.dart`
- **변경 내용**: `host = 'copsnro66ers.site'` -> `'copsandrobbers.app'`
- **이유**: 이 상수를 `share_util`(공유 링크 생성), 대기방 QR 파서, `deeplink_event`(수신 host 화이트리스트)가 모두 참조. 상수 한 곳만 바꾸면 링크를 만드는 쪽과 받는 쪽이 동시에 따라간다

#### 네이티브 딥링크 설정 동기화

- **파일**: `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Runner.entitlements`
- **변경 내용**: App Links `android:host`, Universal Links `applinks:` 를 신 도메인으로
- **이유**: 빌드타임 설정이라 Dart 상수를 읽지 못한다. 상수와 어긋나면 링크 생성은 신 도메인인데 OS 가 앱을 열지 못하는 상태가 되므로 반드시 함께 바꾼다

#### 테스트의 하드코딩 도메인 제거

- **파일**: `test/core/deeplink/deeplink_event_test.dart`
- **변경 내용**: URL 문자열에 적혀 있던 도메인을 `DeeplinkConstants.host` 참조로 교체
- **이유**: 이 테스트가 검증하는 것은 URI 파싱 규칙이지 host 값이 아니다. 도메인을 적어두면 host 가 바뀔 때마다 검증 로직과 무관하게 테스트가 깨진다. `허용되지 않은 host` 케이스는 의도적으로 다른 값이어야 하므로 그대로 유지

#### 주석 예시 주소 갱신

- **파일**: `lib/core/utils/share_util.dart`
- **변경 내용**: 공유 링크 형식을 설명하는 주석의 예시 주소
- **이유**: 동작에는 영향이 없으나, 실제와 다른 예시가 남아 있으면 이 코드를 다음에 보는 사람이 구 도메인을 기준으로 판단할 수 있다

### 🔧 주요 변경사항 상세

#### 환경변수는 커밋에 포함되지 않음

`API_BASE_URL` 과 `WS_URL` 은 `.env` 에 있고 이 파일은 형상관리 대상이 아니다. CI 가 저장된 환경변수로 `.env` 를 생성하므로, **스토어 빌드에 반영하려면 CI 환경변수도 함께 갱신해야 한다.** 로컬 파일만 바꾸면 빌드는 통과하고 구 주소를 바라본다.

WebSocket 경로는 `/game-connection` 이다. 코드의 기본값(`/ws`)은 환경변수 미설정 시에만 쓰이는 폴백이므로 혼동하지 않는다.

**특이사항**:

- 구·신 도메인이 같은 서버를 가리키고 TLS 인증서 SAN 에 두 이름이 함께 있어, 코드 배포와 환경변수 갱신 순서가 달라도 양쪽 모두 정상 동작한다
- 커스텀 스킴 `copsandrobbers://join` 은 앱 스킴이라 웹 도메인과 무관하며 변경하지 않았다

#### 신 도메인 딥링크 검증 파일 상태

앱 변경이 동작하려면 신 도메인에 검증 파일이 HTTPS 로 서빙되어야 한다. 확인 결과 준비 완료 상태다.

- `.well-known/assetlinks.json`, `.well-known/apple-app-site-association` 정상 응답
- Google Digital Asset Links 검증에서 패키지명과 서명 지문 3종 모두 인식
- Apple CDN 이 신 도메인 AASA 수집 완료

`assetlinks.json` 의 지문 3종은 디버그 키 / 업로드 키 / Play 앱 서명 키다. Play App Signing 을 쓰므로 세 번째가 빠지면 스토어 배포본에서 딥링크가 동작하지 않는다. 파일이 구 도메인과 동일해 신 도메인에도 그대로 유효하다.

### 🧪 테스트 및 검증

- `flutter analyze --no-fatal-infos` 통과
- 딥링크 파싱 테스트는 상수 참조로 바뀌었을 뿐 검증 대상과 케이스는 동일

딥링크는 OS 가 링크를 가로채는 동작이라 실기기에서만 확인된다. 스토어 배포 전 아래를 확인한다.

- Android·iOS 각각에서 초대 링크로 앱이 열리는지
- 대기방 QR 스캔 동작
- 공유 시트로 만든 링크의 도메인

### 📌 참고사항

- 구 도메인은 갱신하지 않을 예정이다. 이미 설치된 앱은 구 API 주소가 빌드에 포함되어 있어, 도메인 만료 시 딥링크뿐 아니라 모든 API 호출이 실패한다. 배포 후 버전 보급률을 확인하고 Remote Config `minimum_version` 으로 잔여 구버전을 정리해야 한다
- 보급률이 낮은 상태에서 최소 버전을 올리면 신규 유입 사용자가 업데이트 화면만 보게 되므로, 보급률이 충분히 오른 뒤에 적용한다
- `docs/DEEPLINK.md` 에 구 도메인 참조가 다수 남아 있다. 팀 딥링크 기준 문서라 별도로 정리가 필요하다
- 앞으로 제작하는 QR·인쇄물은 신 도메인으로 만든다
