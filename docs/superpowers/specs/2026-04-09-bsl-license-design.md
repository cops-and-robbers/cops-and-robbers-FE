# BSL 라이센스 추가 설계

> 작성일: 2026-04-09

## 목적

프로젝트 소스 코드를 공개하되, 복사/포크 후 상업적 사용 및 재배포를 금지한다.

## 라이센스 선택: BSL 1.1 (Business Source License)

소스 공개 + 사용 제한 목적에 가장 적합한 라이센스. Sentry, CockroachDB, MariaDB 등이 채택하여 법적으로 검증되었다.

### 대안 및 기각 사유

| 대안 | 기각 사유 |
|------|-----------|
| CC BY-NC-ND 4.0 | 소프트웨어용으로 설계되지 않아 소스 코드 사용에 대한 법적 해석이 모호 |
| 커스텀 Proprietary License | 자체 작성이라 법적 허점 가능, 개발자 신뢰도 낮음 |

## 핵심 설정값

| 항목 | 값 | 설명 |
|------|-----|------|
| Licensor | cops-and-robbers 팀 | 프로젝트 소유 조직 |
| Licensed Work | Cops and Robbers v1.3.34+ | 현재 버전 이상 전체 |
| Change Date | 2099-01-01 | 사실상 영구 보호 |
| Change License | Apache License 2.0 | BSL 표준 요구사항 충족용 |
| Additional Use Grant | 없음 | 상업적 사용 완전 금지 |

## 허용/금지 범위

| 행위 | 허용 여부 |
|------|-----------|
| 소스 코드 열람 | 허용 |
| 학습 목적 참고 | 허용 |
| 복사/포크 후 상업적 사용 | 금지 |
| 프로덕션 환경 배포 | 금지 (라이센서 본인 제외) |
| 수정 후 재배포 | 금지 |

## 적용 파일

1. **`LICENSE`** (프로젝트 루트) — BSL 1.1 전문. MariaDB BSL 1.1 표준 텍스트 기반으로 위 설정값 적용.
2. **`README.md`** — 라이센스 섹션에 한 줄 안내 추가 (BSL 1.1, 상업적 사용 금지 명시).

## 구현 범위

- LICENSE 파일 생성 (BSL 1.1 전문)
- README.md에 라이센스 안내 추가
- pubspec.yaml 변경 불필요 (`publish_to: "none"` 이미 설정됨)
