# 앱 전체 진동 피드백 시스템 설계

> **이슈**: #156 — 앱 전체 진동 피드백 추가
> **브랜치**: `20260331_#156_앱_전체_진동_피드백_추가`
> **작성일**: 2026-04-01

---

## 1. 개요

앱 전체에서 주요 이벤트 발생 시 진동 피드백을 제공하여 체감 UX를 개선한다.
이벤트마다 고유한 진동 패턴(duration, amplitude, pattern, intensities)을 정의하고,
상수로 중앙 관리하여 피드백 후 수정이 용이하도록 한다.

## 2. 패키지

- `vibration: ^3.1.8`
- 기존 `HapticFeedback` (Flutter 내장) 사용 코드는 제거하고 vibration으로 통일

## 3. 진동 제어 정책

| 구분 | 제어 |
|------|------|
| UI (버튼 탭) | 항상 켜짐 |
| 인게임 이벤트 | 항상 켜짐 |
| 대기방 이벤트 | 항상 켜짐 |
| **채팅 수신** | **유저 on/off 가능** (로직만 구현, UI는 디자인 확정 후 추가) |

- OS 레벨 진동 설정과 무관하게 앱 자체 기능으로 동작
- 채팅 진동 설정값은 로컬 저장소(SharedPreferences)에 저장

## 4. 상수 정의

### 4.1 단일 진동 (duration + amplitude)

| 카테고리 | 이벤트 | duration (ms) | amplitude (0~255) |
|---------|--------|--------------|-------------------|
| UI | buttonTap | 50 | 100 |
| 채팅 | messageReceived | 100 | 80 |
| 대기방 | playerJoinLeave | 80 | 60 |
| 인게임 | arrested | 500 | 255 |
| 인게임 | locationRevealed | 250 | 150 |

### 4.2 패턴 진동 (pattern + intensities)

| 카테고리 | 이벤트 | pattern (ms) | intensities (0~255) |
|---------|--------|-------------|---------------------|
| 대기방 | gameStart | [0, 200, 100, 200, 100, 400] | [0, 200, 0, 200, 0, 255] |
| 인게임 | escaped | [0, 200, 100, 200] | [0, 200, 0, 200] |
| 인게임 | zoneExit | [0, 300, 200, 300, 200, 300] | [0, 255, 0, 255, 0, 255] |
| 인게임 | gameEnd | [0, 150, 100, 150, 100, 500] | [0, 150, 0, 150, 0, 255] |

> amplitude 미지원 기기(Android 8 미만, iOS 13 미만)에서는 duration만으로 폴백

## 5. 파일 구조

```
lib/core/
├── constants/
│   └── vibration_patterns.dart    ← duration, amplitude, pattern, intensities 상수
└── services/
    └── vibration_service.dart     ← 디바이스 지원 체크 + 진동 실행 유틸리티
```

## 6. VibrationService 설계

- 초기화 시 `hasVibrator()`, `hasAmplitudeControl()`, `hasCustomVibrationsSupport()` 체크
- amplitude 미지원 → duration만으로 폴백
- custom pattern 미지원 → 단일 진동으로 폴백
- 상수 기반 호출: `VibrationService.play(VibrationPatterns.arrested)`

## 7. 호출 지점

### 7.1 UI (버튼 탭)

| 위치 | 트리거 |
|------|--------|
| 게임 시작 버튼 | 탭 |
| 준비 완료 버튼 | 탭 |
| 채팅 전송 버튼 | 탭 |
| 초대코드 복사 | 탭 |
| 방 생성 / 방 참가 | 탭 |
| 다이얼로그 확인 버튼 | 탭 |

### 7.2 채팅

| 위치 | 트리거 |
|------|--------|
| ChatOverlay / ChatProvider | 새 메시지 수신 시 (on/off 설정 확인 후) |

### 7.3 대기방

| 위치 | 트리거 |
|------|--------|
| WaitingRoomPage | 게임 시작 이벤트 수신 |
| WaitingRoomPage | 플레이어 입장/퇴장 이벤트 수신 |

### 7.4 인게임

| 위치 | 트리거 |
|------|--------|
| GameEventProvider | 체포 이벤트 (arrested) |
| GameEventProvider | 탈옥 이벤트 (escaped) |
| GameEventProvider | 위치 공개 이벤트 (locationRevealed) |
| GameEventProvider | 게임 종료 이벤트 (gameEnd) |
| 위치 업데이트 콜백 | 플레이그라운드 영역 이탈 감지 (zoneExit) |

## 8. 채팅 진동 on/off 로직

- `SharedPreferences` 키: `chat_vibration_enabled` (기본값: `true`)
- 채팅 메시지 수신 시 설정값 확인 후 진동 실행 여부 결정
- UI는 디자인 확정 후 별도 추가
