# Source-Available License 설계

> **작성일**: 2026-04-09
> **상태**: 승인됨

---

## 배경

- 프로젝트에 라이센스 파일이 없음
- GitHub public repo (`cops-and-robbers/cops-and-robbers-FE`)
- MIT는 너무 넓고, BSL은 오픈소스 전환이 필수라 부적합
- 소스 공개는 유지하되 상업적 도용을 방지하고 싶음

## 라이센스 모델

**Elastic License 2.0 기반 Source-Available License**

### 허용

- 소스 코드 열람 및 학습
- 포크 및 PR 기여
- 개인 비상업적 용도의 수정 및 실행

### 금지

- 이 코드를 사용한 상업적 서비스 운영
- 이 코드의 전체 또는 상당 부분을 재배포하여 경쟁 서비스 제공
- SaaS/호스팅 서비스로 제공

### 라이센서

cops-and-robbers organization

## 대안 검토

| 옵션 | 장점 | 단점 | 결정 |
|------|------|------|------|
| MIT | 간단, 널리 알려짐 | 상업적 사용 제한 불가 | 탈락 |
| BSL | 업계 검증됨 | Change Date 후 오픈소스 전환 필수 | 탈락 |
| CC BY-NC 4.0 | 비상업적 조건 명확 | 소프트웨어용 아님, 법적 보호 약함 | 탈락 |
| **Source-Available (ELv2 기반)** | 의도 정확히 반영, 검증된 문구 구조 | 오픈소스가 아님 (OSI 미인증) | **채택** |

## 구현 범위

1. `LICENSE` 파일 생성 (프로젝트 루트)
2. Elastic License 2.0 원문 기반, cops-and-robbers 프로젝트에 맞게 조정
3. `README.md`에 라이센스 섹션 추가는 별도 판단

## 포크/기여 정책

- 누구든 포크 및 PR 기여 가능
- 독립적으로 서비스를 운영하는 것만 금지
- GitHub의 포크 기능과 자연스럽게 호환
