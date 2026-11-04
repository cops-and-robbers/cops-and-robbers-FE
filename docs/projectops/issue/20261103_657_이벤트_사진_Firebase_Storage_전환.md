📝 현재 문제점
---

- 이벤트 게임의 증거 사진 2장이 앱에 들어 있어, 행사마다 사진을 바꾸려면 앱을 새로 배포해야 합니다.
- 체포 성공 팝업과 결과 보드가 같은 사진을 씁니다. 두 파일을 합치면 약 1.3 MB입니다.

🛠️ 해결 방안 / 제안 기능
---

- 사진을 Firebase Storage에 올리고, 홈 배너처럼 Remote Config의 주소로 불러옵니다.
- 사진 주소만 콘솔에서 바꾸면 배포 없이 교체됩니다.
- 새 패키지는 넣지 않습니다. 앱은 주소로 이미지를 받기만 하면 됩니다.

⚙️ 작업 내용
---

- Firebase Storage에 사진 업로드, Remote Config에 증거 사진 주소 등록
- 체포 성공 팝업과 결과 보드를 원격 이미지로 교체
- 게임 진입 때 미리 받아 두기, 로딩과 실패 화면 처리
- 관련 테스트 수정

❓ 확인 필요
---

| 안건 | 제안 | 이유 |
|---|---|---|
| 사진을 못 받을 때 | 앱에 기본 사진을 남겨 대신 보여 줌 | 현장 네트워크가 나쁘면 체포 팝업의 사진 자리가 비어 버림. 홈 배너는 실패하면 숨기면 되지만 증거는 숨길 수 없음 |
| 미리 받기 | 이벤트 게임 입장 때 2장 모두 받기 | 체포 순간에 받으면 늦게 뜸 |
| 사진 수 | 2장 고정 유지 | 지금 코드와 보드 배치가 2장 기준 |
| Firebase Storage | 콘솔에서 사용 설정과 공개 읽기 규칙 확인 | 앱에 Storage 패키지가 없고, 이 저장소에서 콘솔 설정은 확인할 수 없음 |

📌 참고
---

- 홈 배너: `lib/features/session/presentation/widgets/home_banner.dart`, `lib/core/services/remote_config/remote_config_keys.dart`
- 증거 사진: `lib/features/game/presentation/widgets/event_arrest_success_dialog.dart`, `lib/features/game/presentation/widgets/event_result_board.dart`, `assets/events/`

🙋‍♂️ 담당자
---

- 프론트엔드: 찬빈
