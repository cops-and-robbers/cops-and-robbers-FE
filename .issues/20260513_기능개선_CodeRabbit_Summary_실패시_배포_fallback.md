## 제목

🚀 [기능개선][CICD] CodeRabbit Summary 실패 시 배포 라인이 멈추지 않도록 fallback 추가

## 본문

## 📝 현재 문제점

- deploy 브랜치로 PR이 생성되면 `AUTO UPDATE PROJECT CHANGELOG` 워크플로우가 트리거되어 CodeRabbit Summary를 받아 CHANGELOG를 갱신하고 deploy 브랜치에 머지/푸시한다.
- 그러나 CodeRabbit이 다음 상황에서 응답을 못 하면 워크플로우 전체가 막혀버린다.
  - 무료/유료 한도(rate limit, quota) 초과
  - CodeRabbit 서비스 장애 또는 봇 미설치
  - 단순 응답 지연으로 10분 폴링 타임아웃
- 결과적으로 CHANGELOG 갱신 Job뿐 아니라 deploy 머지·푸시 Job도 함께 스킵되어, deploy 브랜치 push에 의존하는 Android Play Store / iOS TestFlight 배포 워크플로우 전체가 발화되지 않는다.
- 운영자가 알아채기 전까지 릴리즈가 지연되는 구조이며, 수동 재시도 통로(workflow_dispatch)도 없다.

## 🛠️ 해결 방안 / 제안 기능

- 우선순위 기반 콘텐츠 소스 결정 로직을 도입해 CodeRabbit이 실패해도 CHANGELOG 입력 텍스트를 확보한다.
  1순위: CodeRabbit Summary (기존 동작 그대로)
  2순위: PR 작성자가 본문 마커 안에 직접 적어둔 텍스트
  3순위: PR 제목과 feat/fix 커밋 메시지를 조합한 자동 생성 텍스트
- deploy 머지·푸시 단계는 CHANGELOG 갱신과 분리하여, CHANGELOG가 실패해도 배포 라인은 항상 진행되도록 한다.
- CodeRabbit이 에러 댓글(rate limit, quota 등)을 남기면 10분 폴링을 끝까지 기다리지 않고 즉시 fallback 단계로 전환한다.
- fallback이 사용된 경우 PR에 알림 댓글을 자동으로 남겨 운영자가 사후 보완할 수 있도록 한다.
- 릴리즈 PR 전용 본문 템플릿을 분리하여 일반 feature PR과 작성 흐름을 구분한다.

## ⚙️ 작업 내용

- 릴리즈 PR 전용 본문 템플릿 신규 추가 (`<!-- changelog:start -->` 마커 포함)
- 워크플로우 시작 단계에 PR 본문 백업 Step 추가 (작성자 입력 텍스트 보존)
- CodeRabbit Summary 폴링 루프에 봇 댓글 기반 에러 키워드 조기 감지 로직 추가
- 우선순위 기반 콘텐츠 소스 결정 Step 추가 (coderabbit / manual / auto / none)
- CHANGELOG 갱신 Job 실행 조건을 `content_source != 'none'`으로 변경
- 머지/배포 Job 실행 조건을 `always()`로 변경하여 CHANGELOG 결과와 무관하게 진행
- 콘텐츠 소스에 따른 PR 알림 댓글 Step 추가 (manual / auto / none / CHANGELOG 실패)

## 🙋‍♂️ 담당자

- 백엔드: 이름
- 프론트엔드: 이름
- 디자인: 이름
