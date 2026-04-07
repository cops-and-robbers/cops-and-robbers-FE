# PRD & README.md 업데이트 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** PRD(v1.1 → v2.0)와 README.md를 현재 프로젝트 상태에 맞게 업데이트하여, 신규 개발자가 정확한 정보를 기반으로 온보딩할 수 있도록 한다.

**Architecture:** PRD는 MVP 기준 문서(2025-11)에서 현재 구현 완료된 기능들을 반영하여 v2.0으로 승격한다. README.md는 기술 스택 버전, 프로젝트 구조, 기능 목록, 문서 참조 링크를 현재 상태에 맞게 갱신한다. 두 문서는 독립적이므로 병렬 작업 가능하다.

**Tech Stack:** Markdown 문서 편집 (코드 변경 없음)

---

## 변경 대상 파일 요약

| 파일 | 작업 유형 | 설명 |
|------|-----------|------|
| `docs/경찰과도둑_PRD_2.md` | Modify | MVP 이후 구현된 기능 반영, 버전 v2.0 승격 |
| `README.md` | Modify | 기술 스택 버전, 프로젝트 구조, 기능 목록, 문서 링크 갱신 |

---

## Task 1: PRD 문서 헤더 및 버전 업데이트

**Files:**
- Modify: `docs/경찰과도둑_PRD_2.md:1-8`

- [ ] **Step 1: PRD 헤더 업데이트**

기존:
```markdown
# PRD V2

## 👮🏻‍♂️ '경찰과 도둑' 앱: 제품 요구사항 문서 (PRD)

- **문서 버전:** 1.1
- **최종 수정:** 2025년 11월 11일
- **작성자:** Gemini
```

변경:
```markdown
# PRD V2

## 👮🏻‍♂️ '경찰과 도둑' 앱: 제품 요구사항 문서 (PRD)

- **문서 버전:** 2.0
- **최종 수정:** 2026년 4월 7일
- **작성자:** Gemini (초안), Development Team (v2.0 업데이트)
```

- [ ] **Step 2: 변경 확인**

Run: `head -8 docs/경찰과도둑_PRD_2.md`
Expected: 버전 2.0, 최종 수정일 2026년 4월 7일 확인

---

## Task 2: PRD F1 (세션 관리) — QR 초대 기능 반영

**Files:**
- Modify: `docs/경찰과도둑_PRD_2.md` (F1.3 초대 코드 섹션)

- [ ] **Step 1: F1.3 초대 코드 항목에 QR 코드 기능 추가**

F1.3 테이블 셀의 **상세 요구사항** 끝에 다음 내용을 추가:

```markdown
4. **QR 코드:** 초대 코드를 QR 코드로 생성하여 표시할 수 있습니다. 참가자는 QR 스캔으로 즉시 입장 가능합니다. (2026-04 구현)
```

- [ ] **Step 2: 변경 확인**

Run: `grep -A5 "QR" docs/경찰과도둑_PRD_2.md`
Expected: QR 코드 관련 내용이 F1.3에 포함됨

- [ ] **Step 3: 커밋**

```bash
git add docs/경찰과도둑_PRD_2.md
git commit -m "docs: PRD F1.3 QR 초대 코드 기능 반영 #prd-update"
```

---

## Task 3: PRD F4 (UI/UX 및 소통) — 채팅 고도화 기능 반영

**Files:**
- Modify: `docs/경찰과도둑_PRD_2.md` (F4.3 팀 채팅 섹션)

- [ ] **Step 1: F4.3 팀 채팅 상세 요구사항 확장**

F4.3 테이블 셀의 기존 3개 항목 뒤에 다음 내용을 추가:

```markdown
4. **메시지 신고:** 부적절한 메시지를 신고할 수 있으며, 서버에 신고 사유와 함께 전송됩니다. (2026-04 구현)
5. **비속어 필터링:** 클라이언트 측 `ContentFilterService`를 통해 비속어를 자동 감지하고, 전송 전 경고를 표시합니다. (2026-03 구현)
6. **답장(Reply):** 특정 메시지를 인용하여 답장할 수 있습니다. 답장 대상 메시지의 미리보기가 함께 표시됩니다. (2026-04 구현)
7. **스크롤 FAB:** 새 메시지 도착 시 하단으로 이동하는 플로팅 버튼이 표시됩니다. (2026-04 구현)
8. **역할 아이콘:** 채팅 메시지에 경찰/도둑 역할 아이콘이 닉네임과 함께 표시됩니다. (2026-04 구현)
```

- [ ] **Step 2: 변경 확인**

Run: `grep -c "신고\|필터링\|Reply\|FAB\|역할 아이콘" docs/경찰과도둑_PRD_2.md`
Expected: 5 (5개 항목 모두 존재)

- [ ] **Step 3: 커밋**

```bash
git add docs/경찰과도둑_PRD_2.md
git commit -m "docs: PRD F4.3 채팅 고도화 기능 반영 (신고, 필터, 답장, FAB, 역할 아이콘) #prd-update"
```

---

## Task 4: PRD 신규 섹션 — MVP 이후 구현된 기능 (F5)

**Files:**
- Modify: `docs/경찰과도둑_PRD_2.md` (F4 뒤, "향후 고려 사항" 앞에 삽입)

- [ ] **Step 1: F5 섹션 추가**

"### F4: UI/UX 및 소통" 테이블 종료 후, "### 6. 향후 고려 사항" 앞에 다음 섹션을 삽입:

```markdown

### F5: 운영 및 안정성 (Post-MVP, 2026-03~04 구현)

MVP 이후 운영 안정성과 사용자 경험 개선을 위해 추가된 기능입니다.

| **기능 ID** | **기능** | **상세 요구사항** |
| --- | --- | --- |
| **F5.1** | **WebSocket 재연결** | 1. **자동 감지:** 네트워크 변경, 서버 문제 등으로 WebSocket 연결이 끊기면 자동으로 감지합니다.<br>2. **자동 재연결:** 최대 3회 자동 재연결을 시도합니다.<br>3. **수동 재연결 모달:** 자동 재연결 실패 시 사용자에게 "재연결" 버튼이 포함된 모달을 표시합니다.<br>4. **구독 복원:** 재연결 성공 시 기존 STOMP 구독(게임 이벤트, 채팅)을 자동으로 복원합니다. |
| **F5.2** | **Firebase Remote Config** | 1. **점검 모드:** 서버 점검 시 앱 접속을 차단하고 안내 메시지를 표시합니다.<br>2. **강제 업데이트:** 최소 지원 버전보다 낮은 앱 버전에 업데이트 안내를 표시합니다.<br>3. **실시간 반영:** 앱 포그라운드 복귀 시 Remote Config 값을 자동 갱신합니다. |
| **F5.3** | **구역 이탈 경고 팝업** | 1. **트리거:** 참가자가 플레이그라운드 경계를 벗어날 경우 즉시 발동합니다.<br>2. **UI:** 전체 화면 경고 팝업으로 표시되며, 구역 복귀를 유도합니다.<br>3. **자동 해제:** 구역 내부로 복귀하면 팝업이 자동으로 닫힙니다. |
| **F5.4** | **공지사항 시스템** | 1. **공지 목록:** 서버에서 관리하는 공지사항 목록을 앱 내에서 조회할 수 있습니다.<br>2. **공지 상세:** 공지 제목, 내용, 작성일을 표시합니다. |
| **F5.5** | **설정 페이지** | 1. **알림 설정:** 푸시 알림 수신 여부를 제어합니다.<br>2. **계정 관리:** 로그아웃 및 회원 탈퇴 기능을 제공합니다.<br>3. **앱 정보:** 현재 앱 버전, 이용약관, 개인정보처리방침 링크를 표시합니다. |
```

- [ ] **Step 2: 변경 확인**

Run: `grep "F5" docs/경찰과도둑_PRD_2.md`
Expected: F5.1~F5.5 항목 확인

- [ ] **Step 3: 커밋**

```bash
git add docs/경찰과도둑_PRD_2.md
git commit -m "docs: PRD F5 운영 및 안정성 섹션 추가 (WebSocket 재연결, Remote Config 등) #prd-update"
```

---

## Task 5: PRD "향후 고려 사항" 섹션 업데이트

**Files:**
- Modify: `docs/경찰과도둑_PRD_2.md` (섹션 6)

- [ ] **Step 1: 향후 고려 사항 업데이트**

기존 항목 중 부분 구현된 내용에 상태 표시를 추가하고, 새로운 향후 과제를 추가:

```markdown
### 6. 향후 고려 사항 (Out of Scope for MVP)

MVP 출시 후 우선적으로 고려할 기능입니다.

- **실시간 위치 공유 (경찰):** 경찰이 도둑의 위치를 실시간으로 추적하는 (패널티 또는 아이템 형태의) 기능. (서버 부하, 배터리 소모 고려 필요)
- ~~**고유번호 체포:**~~ → **QR 코드 체포로 대체 검토 중.** 도둑의 QR 코드를 경찰이 스캔하여 체포하는 오프라인 인증 강화 로직. (QR 표시/스캔 인프라 구현 완료)
- **음성 통신 (무전기):** 팀별 실시간 음성 대화(PTT) 기능.
- **다중 라운드 및 팀 스왑:** 여러 라운드를 진행하고 라운드마다 공수(팀)를 교대하는 기능.
- **게임 통계/리포트:** 게임 종료 후 상세 통계 (이동 경로 히트맵, 체포 시점 분석 등)
- **아이템 시스템:** 투명화, 속도 부스트, 감옥 탈출 키 등 전략적 아이템
```

- [ ] **Step 2: 변경 확인**

Run: `grep -A10 "향후 고려" docs/경찰과도둑_PRD_2.md | head -15`
Expected: QR 코드 대체 검토, 게임 통계, 아이템 시스템 항목 확인

- [ ] **Step 3: 커밋**

```bash
git add docs/경찰과도둑_PRD_2.md
git commit -m "docs: PRD 향후 고려 사항 업데이트 (QR 체포, 통계, 아이템) #prd-update"
```

---

## Task 6: README.md — 핵심 기능 목록 업데이트

**Files:**
- Modify: `README.md:15-22` (핵심 기능 섹션)

- [ ] **Step 1: 핵심 기능 목록 갱신**

기존:
```markdown
### 핵심 기능

- 🗺️ **실시간 위치 추적**: GPS 기반 30명 동시 참가자 위치 동기화
- ⚡ **WebSocket 실시간 통신**: 게임 이벤트 즉각 전달 (체포, 위치 공개 등)
- 👥 **팀별 전용 채팅**: 경찰/도둑 팀 전략 소통 채널
- 🎮 **자동화된 게임 진행**: 수동 개입 없이 규칙 기반 자동 판정
- 📍 **구역 이탈 감지**: 플레이그라운드/감옥 경계 자동 모니터링
```

변경:
```markdown
### 핵심 기능

- 🗺️ **실시간 위치 추적**: GPS 기반 30명 동시 참가자 위치 동기화
- ⚡ **WebSocket 실시간 통신**: STOMP 프로토콜 기반 게임 이벤트 즉각 전달 + 자동 재연결
- 👥 **팀별 전용 채팅**: 경찰/도둑 팀 전략 소통 채널 (답장, 신고, 비속어 필터링)
- 🎮 **자동화된 게임 진행**: 수동 개입 없이 규칙 기반 자동 판정
- 📍 **구역 이탈 감지**: 플레이그라운드/감옥 경계 자동 모니터링 + 경고 팝업
- 🔐 **소셜 로그인**: Google / Apple 로그인 + Firebase 인증 + JWT 토큰 관리
- 📲 **QR 초대 시스템**: QR 코드 생성·스캔으로 간편한 게임 참가
- 🔧 **원격 운영 관리**: Firebase Remote Config로 점검 모드 / 강제 업데이트 제어
```

- [ ] **Step 2: 변경 확인**

Run: `grep -c "QR\|소셜 로그인\|원격 운영\|자동 재연결" README.md`
Expected: 4

- [ ] **Step 3: 커밋**

```bash
git add README.md
git commit -m "docs: README 핵심 기능 목록 업데이트 (QR, 소셜 로그인, Remote Config) #readme-update"
```

---

## Task 7: README.md — 프로젝트 구조 갱신

**Files:**
- Modify: `README.md:139-167` (프로젝트 구조 섹션)

- [ ] **Step 1: features 디렉토리 구조 갱신**

기존 features 목록:
```
│   ├── auth/                      # Google 로그인 및 인증
│   ├── session/                   # F1: 게임 세션 관리
│   ├── game/                      # F2+F3: 게임 로직 + 지도/위치 (통합)
│   ├── chat/                      # F4: 팀별 채팅
│   └── notification/              # F4: 알림 시스템
```

변경:
```
│   ├── auth/                      # 소셜 로그인 (Google/Apple) + 인증
│   ├── user/                      # 사용자 프로필 (닉네임 설정/변경)
│   ├── session/                   # F1: 게임 세션 관리 (대기실, 팀 선택)
│   ├── game/                      # F2+F3: 게임 로직 + 지도/위치 (통합)
│   ├── chat/                      # F4: 팀별 채팅 (답장, 신고, 필터링)
│   ├── notification/              # F4: 알림 시스템 (FCM + 로컬)
│   ├── lobby/                     # 로비 화면
│   ├── notice/                    # 공지사항
│   ├── settings/                  # 설정 (알림, 계정, 앱 정보)
│   └── lifecycle_test/            # 개발용 테스트 페이지
```

core 디렉토리에도 누락된 항목 추가:
```
├── core/                          # 공통 인프라
│   ├── constants/                 # 앱 전역 상수 (색상, 설정값, URL)
│   ├── config/                    # 환경 설정 (EnvConfig)
│   ├── converters/                # 타입 변환 유틸리티
│   ├── network/                   # 네트워크 레이어 (Dio, AuthInterceptor)
│   │   └── websocket/             # WebSocket 관리 (연결, 재연결)
│   ├── realtime/                  # 실시간 통신 (STOMP 프로토콜)
│   ├── services/                  # 범용 서비스
│   │   ├── content_filter/        # 채팅 비속어 필터링
│   │   ├── device/                # 기기 정보
│   │   ├── fcm/                   # Firebase Cloud Messaging
│   │   ├── lifecycle/             # 앱 생명주기 관리
│   │   ├── location/              # GPS 위치 추적
│   │   ├── permission/            # 권한 관리
│   │   ├── remote_config/         # Firebase Remote Config
│   │   └── storage/               # 로컬 저장소
│   ├── storage/                   # SecureStorage (JWT 토큰)
│   ├── theme/                     # 테마, 색상, 타이포그래피
│   ├── errors/                    # 에러 정의 (Exception, AppException)
│   ├── utils/                     # 유틸리티 함수 및 Extension
│   └── widgets/                   # 공통 UI 위젯
```

- [ ] **Step 2: 변경 확인**

Run: `grep -c "user/\|lobby/\|notice/\|settings/\|lifecycle_test/\|content_filter/\|remote_config/" README.md`
Expected: 7 (모든 새 항목 존재)

- [ ] **Step 3: 커밋**

```bash
git add README.md
git commit -m "docs: README 프로젝트 구조 갱신 (user, lobby, notice, settings, core 서비스) #readme-update"
```

---

## Task 8: README.md — 기술 스택 버전 정정

**Files:**
- Modify: `README.md:171-220` (기술 스택 섹션)

- [ ] **Step 1: 잘못된 버전 정보 수정**

아래 항목들의 버전을 정정:

| 항목 | 기존 | 정정 |
|------|------|------|
| Retrofit | 4.7.2 | 4.7.3 (pinned) |
| stomp_dart_client | 2.0.0 | 3.0.1 |

그리고 인증 섹션을 추가:

```markdown
### 인증

- **Firebase Auth 6.1.3** - Firebase 기반 인증
- **Google Sign-In 6.2.3** - Google 소셜 로그인
- **Sign in with Apple 6.1.3** - Apple 소셜 로그인
```

Firebase 관련 섹션 추가:

```markdown
### Firebase 서비스

- **Firebase Auth** - 소셜 로그인 인증
- **Firebase Cloud Messaging** - 푸시 알림
- **Firebase Remote Config** - 점검 모드 / 강제 업데이트
- **Firebase Crashlytics** - 에러 리포팅 및 모니터링
```

- [ ] **Step 2: 변경 확인**

Run: `grep "4.7.3\|3.0.1\|Remote Config\|Crashlytics\|Google Sign-In\|Sign in with Apple" README.md`
Expected: 6개 항목 모두 존재

- [ ] **Step 3: 커밋**

```bash
git add README.md
git commit -m "docs: README 기술 스택 버전 정정 및 인증/Firebase 섹션 추가 #readme-update"
```

---

## Task 9: README.md — 빌드 명령어 현행화 + 문서 참조 링크 보강

**Files:**
- Modify: `README.md:36-52` (빠른 시작)
- Modify: `README.md:272-280` (코드 생성 명령어)
- Modify: `README.md:305-327` (개발 문서 섹션)

- [ ] **Step 1: `flutter pub run build_runner` → `dart run build_runner` 일괄 교체**

`flutter pub run build_runner`는 Flutter 3.x에서 deprecated 경고가 뜨므로 `dart run build_runner`로 교체:

빠른 시작 섹션:
```markdown
# 4. 코드 생성 (Freezed, Riverpod, Retrofit)
dart run build_runner build --delete-conflicting-outputs
```

코드 생성 섹션:
```markdown
# 1회 생성 (개발 중 주로 사용)
dart run build_runner build --delete-conflicting-outputs

# Watch 모드 (파일 변경 시 자동 생성)
dart run build_runner watch --delete-conflicting-outputs
```

- [ ] **Step 2: 개발 문서 테이블에 누락된 문서 추가**

기존 테이블 뒤에 추가:

```markdown
| [05_GOOGLE_MAPS_SETUP.md](docs/05_GOOGLE_MAPS_SETUP.md) | Google Maps 설정 가이드 | 지도 관련 설정이 필요할 때 |
| [06_API_INTEGRATION_GUIDE.md](docs/06_API_INTEGRATION_GUIDE.md) | API 연동 가이드 | 새 API 엔드포인트를 연동할 때 |
| [07_CICD_GUIDE.md](docs/07_CICD_GUIDE.md) | CI/CD 자동화 가이드 | 배포 파이프라인 이해 시 |
| [08_TIMER_ARCHITECTURE.md](docs/08_TIMER_ARCHITECTURE.md) | 타이머 아키텍처 | 게임 타이머 로직 수정 시 |
| [09_WEBSOCKET_EVENT.md](docs/09_WEBSOCKET_EVENT.md) | WebSocket STOMP 이벤트 | 실시간 통신 구조 파악 시 |
| [API_SPEC.md](docs/API_SPEC.md) | REST API 명세 | 백엔드 API 연동 시 |
```

- [ ] **Step 3: 변경 확인**

Run: `grep -c "dart run build_runner" README.md`
Expected: 3 이상 (`flutter pub run build_runner` 0개)

Run: `grep -c "API_SPEC\|TIMER_ARCHITECTURE\|WEBSOCKET_EVENT\|CICD_GUIDE\|GOOGLE_MAPS_SETUP\|API_INTEGRATION" README.md`
Expected: 6

- [ ] **Step 4: 커밋**

```bash
git add README.md
git commit -m "docs: README 빌드 명령어 현행화 및 문서 참조 링크 보강 #readme-update"
```

---

## Task 10: README.md — placeholder URL 제거

**Files:**
- Modify: `README.md:39` (클론 URL)
- Modify: `README.md:425-426` (연락처)

- [ ] **Step 1: placeholder URL 확인 및 실제 값으로 교체**

실제 GitHub 리포지토리 URL을 확인:
Run: `git remote -v`

확인된 URL로 교체. 만약 private repo라면 placeholder를 유지하되 주석 추가:

기존:
```markdown
git clone https://github.com/your-org/cops_and_robbers.git
```

→ 실제 remote URL로 교체 (또는 private repo 안내 주석)

기존:
```markdown
- **이슈 제보**: [GitHub Issues](https://github.com/your-org/cops_and_robbers/issues)
- **프로젝트 관리자**: [your-email@example.com](mailto:your-email@example.com)
```

→ 실제 값으로 교체

- [ ] **Step 2: 변경 확인**

Run: `grep "your-org\|your-email" README.md`
Expected: 0개 (placeholder 전부 제거됨)

- [ ] **Step 3: 커밋**

```bash
git add README.md
git commit -m "docs: README placeholder URL 제거, 실제 리포 주소 반영 #readme-update"
```

---

## Task 11: 최종 검증

- [ ] **Step 1: PRD 문서 전체 검증**

Run: `grep -c "F5\." docs/경찰과도둑_PRD_2.md`
Expected: 5 이상 (F5.1~F5.5)

Run: `grep "문서 버전: 2.0" docs/경찰과도둑_PRD_2.md`
Expected: 1

- [ ] **Step 2: README.md 전체 검증**

Run: `grep -c "flutter pub run build_runner" README.md`
Expected: 0 (모두 `dart run`으로 교체됨)

Run: `grep -c "your-org\|your-email" README.md`
Expected: 0

- [ ] **Step 3: 마크다운 렌더링 검증**

Run: `cat README.md | head -5`
Expected: 정상적인 마크다운 헤더

Run: `cat docs/경찰과도둑_PRD_2.md | head -8`
Expected: 버전 2.0 헤더

- [ ] **Step 4: 최종 커밋 (필요 시)**

미커밋 변경이 있다면:
```bash
git add README.md docs/경찰과도둑_PRD_2.md
git commit -m "docs: PRD v2.0 + README.md 최종 갱신 완료"
```
