## 제목

❗ [버그][게임][게임종료] 백그라운드 중 게임 종료 후 결과 모달 버튼 클릭 시 ref disposed 에러로 크래시

## 본문

## 🗒️ 설명

- 게임 진행 중 앱이 백그라운드 상태였다가 게임이 종료되는 케이스에서, 결과 모달(GameOverResultDialog)의 "홈으로" 또는 "한 번 더" 버튼을 누르면 ref disposed 런타임 에러가 발생함
- 백그라운드에서 GAME_OVER 이벤트가 도착해 결과 모달이 큐잉됨
- 포그라운드 복귀 시점에 서버 상태가 이미 게임 진행 중이 아닌 다른 상태(예: WAITING)로 바뀐 경우, 게임 화면이 곧바로 대기방으로 자동 이동됨
- 그런데 결과 모달은 별도 모달 라우트라 화면에 그대로 남아있고, 모달의 콜백은 이미 사라진 게임 화면의 ref/context를 참조하고 있어 클릭 시 폭발
- 이 흐름이 발생할 때 가끔 강제 로그아웃이 같이 동작하는 케이스도 보고됨 (별개 경로 추정, 본 이슈에는 포함하지 않음)

## 🔄 재현 방법

1. 게임을 시작하고 진행 중인 상태로 둠
2. 게임이 끝나기 직전 또는 끝나는 시점에 앱을 백그라운드로 보냄
3. 백그라운드 동안 서버에서 GAME_OVER 이벤트가 발행됨 (시간 종료 또는 전원 체포)
4. 다시 앱을 포그라운드로 복귀시킴
5. 게임 화면이 자동으로 대기방으로 이동되는 모습을 확인
6. 그 뒤로도 화면 위에 떠있는 결과 모달에서 "홈으로" 또는 "한 번 더" 버튼을 누름
7. 콘솔에 ref disposed 에러가 출력되고 동작이 멈춤

## 📸 참고 자료

핵심 로그 스니펫:

```
flutter: [GameEventNotifier] ✅ GAME_OVER 이벤트 → winner: ROBBER
flutter: 📡 *** Response *** /api/game-results/226 → 결과 정상 수신
flutter: 📡 *** DioException *** /api/games/214/participants → 400 "게임 진행 중 아님"
flutter: 🔄 AppLifecycleState: resumed
flutter: [GamePage] API 응답: isParticipating=true, gameStatus=WAITING
flutter: [GamePage] WAITING 감지 → 로비 이동
[GoRouter] going to /waiting-room/214
... (이후 사용자가 모달 버튼 클릭)
flutter: 🔥 Flutter Error: Bad state: Cannot use "ref" after the widget was disposed.
flutter: #2  _GamePageState._showGameOverDialog.<anonymous closure>
            (package:cops_and_robbers/features/game/presentation/pages/game_page.dart:1056:13)
```

관련 위치:

- 결과 모달 호출 지점: `lib/features/game/presentation/pages/game_page.dart` _showGameOverDialog
- 결과 모달 위젯: `lib/features/game/presentation/widgets/game_over_result_dialog.dart`
- 자동 라우팅 지점: `lib/features/game/presentation/pages/game_page.dart` _checkGameStatusOnResume

## ✅ 예상 동작

- 결과 모달이 떠있는 동안에는 포그라운드 복귀 시 자동 라우팅으로 게임 화면이 사라지지 않아야 함
- 사용자가 "홈으로" 또는 "한 번 더"를 명시적으로 눌렀을 때 그 콜백을 통해서만 다음 화면으로 이동해야 함
- 어떤 경로로든 게임 화면이 이미 사라진 상태에서 모달 버튼이 눌려도 런타임 에러로 폭발하지 않아야 함
- 게임 종료 후에는 STOMP 재연결로 인한 게임 상태 동기화 API(`/api/games/{id}/participants`) 호출이 발생하지 않아야 하며, 400 응답에 따른 로그 노이즈도 사라져야 함

## ⚙️ 환경 정보

- **OS**: iOS (재현 로그 기준)
- **브라우저**:
- **기기**:

## 🙋‍♂️ 담당자

- **백엔드**: 이름
- **프론트엔드**: 이름
- **디자인**: 이름
