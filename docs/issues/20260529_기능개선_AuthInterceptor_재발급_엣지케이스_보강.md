## 제목

🚀 [기능개선][인증][AuthInterceptor] 토큰 재발급 엣지 케이스 분기 보강 및 관측성 추가

## 본문

## 📝 현재 문제점

`AuthInterceptor.onError`의 reissue 실패 처리에서 `_isRefreshTokenRejected`로 401/403만 강제 로그아웃하고 나머지를 모두 "일시 실패"로 분류하도록 개선했지만, 분기되지 않은 엣지 케이스가 남아 있다.

- 200 응답이지만 `response.data`가 Map이 아닌 경우 (`as Map<String, dynamic>?` 캐스팅 실패) TypeError가 catch로 빠져 transient로 처리됨. 백엔드 응답이 영구적으로 깨져 있어도 매 요청마다 재발급을 다시 시도하게 됨.
- 400 / 404 / 410 같은 명시적 4xx 응답이 모두 transient로 분류됨. refresh token 형식 오류나 엔드포인트 변경처럼 영구적인 실패도 무한 재시도 루프에 진입할 수 있음.
- transient 실패 시 호출자에게 reissue 호출의 DioException을 그대로 전달하기 때문에 `e.requestOptions.path`가 원래 요청 경로가 아니라 `/api/auth/reissue`로 표시됨. 로깅·에러 리포팅에서 어떤 API가 실패했는지 추적이 꼬임.
- transient 실패 로그가 `kDebugMode` 분기에만 있어서 프로덕션에서는 reissue 실패 빈도/원인을 관측할 수 없음.
- 403의 reissue 시 의미가 백엔드 스펙에서 확정되지 않음. "토큰 폐기"인지 "권한 없음"인지에 따라 로그아웃 여부가 달라져야 함.

## 🛠️ 해결 방안 / 제안 기능

- reissue 응답 처리에서 파싱 실패(TypeError 등 비-DioException)를 별도 분기로 식별. 영구 실패로 간주할지 transient로 둘지 결정하고 분기 처리한다.
- 4xx 중 명시적 거부 코드(401, 403)와 일반 4xx(400, 404, 410 등)를 분리한다. 백엔드 스펙 확인 후 영구 실패로 봐야 하는 코드를 명시적으로 화이트리스트에 추가한다.
- transient 실패 시 호출자에게 전달하는 DioException의 `requestOptions`를 원본 요청 기준으로 유지하거나, 별도 필드에 원본 path를 보존해 로깅에서 식별 가능하도록 한다.
- 프로덕션 환경에서도 reissue 실패 사유와 원본 요청 path를 `AppLogger.warning` 수준으로 기록한다.
- 백엔드와 `/api/auth/reissue` 응답 스펙을 정렬한다. 어떤 상태 코드에 어떤 의미를 부여하는지 docs/API_SPEC.md에 명시한다.

## ⚙️ 작업 내용

- /api/auth/reissue 응답 스펙 백엔드 확인 및 docs/API_SPEC.md 갱신
- _isRefreshTokenRejected 분기 매트릭스 재설계 (401/403 외 영구 실패 코드 식별)
- 파싱 실패(비-DioException) 별도 핸들러 추가
- transient 실패 시 호출자에게 전달되는 DioException의 path 정보 보존 방안 적용
- 프로덕션 로깅 보강 (AppLogger.warning)
- 테스트 보강
  - reissue 200 + malformed body (data 타입 불일치)
  - reissue 403
  - reissue 400 / 404 / 410
  - reissue 500
  - transient 실패 시 호출자가 받는 DioException의 path가 원본인지 확인

## 🙋‍♂️ 담당자

- 백엔드: 이름
- 프론트엔드: 이름
- 디자인: 이름
