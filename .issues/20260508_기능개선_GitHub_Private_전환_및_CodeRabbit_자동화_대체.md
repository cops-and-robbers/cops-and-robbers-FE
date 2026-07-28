## 제목

🚀 [기능개선][CICD] GitHub Private 전환 및 CodeRabbit 자동화 대체

## 본문

## 📝 현재 문제점

- 사업자등록증을 보유한 서비스 자산이지만 GitHub 저장소가 public 상태로 유지되고 있어, 사업체 자산 보호 측면에서 부적절함
- 현재 CodeRabbit이 public 저장소 무료 정책에 의존하고 있어, private 전환 시 자동 리뷰와 PR Summary 기능이 정상 동작하지 않음
- CHANGELOG 자동 갱신 워크플로우(PROJECT-COMMON-AUTO-CHANGELOG-CONTROL.yaml)가 CodeRabbit Summary 댓글에 강하게 결합돼 있어, CodeRabbit이 빠지면 deploy 자동 배포 흐름 자체가 끊김
- CodeRabbit Summary가 도착할 때까지 최대 10분 폴링하는 단계가 있어, 배포 시간도 길어지는 부작용이 있음

## 🛠️ 해결 방안 / 제안 기능

- GitHub 저장소를 public에서 private으로 전환
- CodeRabbit을 제거하고, 로컬 /rp 커맨드 출력을 deploy PR 본문에 그대로 붙여넣어 기존 changelog 파서가 처리할 수 있도록 워크플로우를 단순화
- /pr-description 커맨드 출력 규약을 강화해 changelog 파서가 기대하는 카테고리/항목 구조 섹션이 항상 PR 본문에 포함되도록 함
- 폴링 단계 제거로 배포 자동화 응답 시간 단축

## ⚙️ 작업 내용

- GitHub 저장소 visibility를 Private으로 전환 (Settings → Danger Zone)
- .coderabbit.yaml 삭제
- PROJECT-COMMON-AUTO-CHANGELOG-CONTROL.yaml에서 CodeRabbit 의존 단계 제거
  - PR 본문 초기화 단계
  - CodeRabbit Summary 요청 댓글 단계
  - 10분 polling 단계
- 위 자리에 PR 본문 즉시 읽기 단계 추가, Summary 섹션 누락 시 워크플로우 fail 시키는 가드 포함
- .claude/commands/pr-description.md 출력 규약에 changelog 파서 호환 섹션 강제 포함 지시문 추가
- GitHub 저장소 Integrations에서 CodeRabbit App 권한 명시적 정리

## 🔍 사전 검증 결과

배포 트리거 동작 여부

- pull_request_target / push / workflow_run / workflow_dispatch 트리거는 모두 private 저장소에서 그대로 동작함
- deploy 브랜치 머지 → CHANGELOG 워크플로우 완료 → iOS TestFlight 및 Android Play Store CICD 트리거 흐름은 visibility 변경과 무관하게 유지됨
- 외부 의존성 점검 결과 CodeRabbit 외에 별도로 끊기는 통합은 없음

GitHub 비용 영향 (지식 기준일 2026-01 시점 정책)

- Private 저장소 자체는 GitHub Free 플랜에서도 무제한 무료
- 다만 private 저장소부터 GitHub Actions 무료 사용량 한도가 적용됨
  - Free 플랜 월 2,000분
  - Pro 플랜 월 3,000분
  - Team 플랜 월 3,000분
- 러너 종류별 사용량 배수
  - Linux (ubuntu-latest) 1배 → Android Play Store 워크플로우
  - macOS (macos-15, macos-26) 10배 → iOS TestFlight 워크플로우
- 1회 배포 추정 소비량 약 200-300분 환산
  - iOS TestFlight 빌드 약 20-30분 실시간 × 10배 = 200-300분 차감
  - Android Play Store 빌드 약 15-25분 실시간 × 1배 = 15-25분 차감
- Free 플랜 기준 월 6-8회 배포까지 무료 사용 가능, 그 이상은 macOS 분당 0.08달러 과금
- 배포 빈도가 잦거나 한 달에 10회 이상 deploy 머지가 예상되면 Pro 플랜(월 4달러) 또는 Team 플랜 업그레이드 검토 필요
- 비용 절감 대안으로 self-hosted macOS 러너 구축 가능 (Mac 한 대 보유 시 무료, 다만 운영 부담 발생)

추가 확인 필요 항목

- 현재 계정 플랜이 Free인지 Pro인지 확인 필요
- 최근 3개월 deploy 머지 횟수 기준으로 월 사용 분 추정 필요

## 🙋‍♂️ 담당자

- 백엔드: 이름
- 프론트엔드: 이름
- 디자인: 이름
