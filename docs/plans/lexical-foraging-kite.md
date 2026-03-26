# QR 코드 기반 체포 시스템 구현 계획

## Context

현재 체포는 경찰이 참가자 목록에서 도둑 카드를 탭하여 수행하는 UI 버튼 방식이다. 물리적 대면 여부를 검증할 수 없어 원격 체포가 가능하고, 실제 게임의 긴장감이 부족하다.

QR 코드 방식으로 변경하여 **도둑이 QR을 보여주고 경찰이 스캔하여 체포**하는 플로우로 전환한다. 아너시스템 기반이므로 별도 보안 토큰 없이 `participantId`만 QR에 인코딩한다.

**백엔드 변경 없음** — 기존 `POST /api/games/{gameId}/system/arrest` API를 그대로 사용한다.

---

## 패키지

| 패키지 | 용도 |
|--------|------|
| `qr_flutter` | 도둑 QR 코드 생성 |
| `mobile_scanner` | 경찰 QR 코드 스캔 |

---

## QR 데이터 포맷

```json
{"pid": 505}
```

`participantId`는 게임 세션 스코프이므로 게임 종료 시 자동으로 무효화된다.

---

## 구현 단계

### Step 1: 패키지 추가 및 플랫폼 설정

**파일:** `pubspec.yaml`
- `qr_flutter` 추가
- `mobile_scanner` 추가

**파일:** `android/app/src/main/AndroidManifest.xml`
- `<uses-permission android:name="android.permission.CAMERA" />` 추가

**파일:** `ios/Runner/Info.plist`
- `NSCameraUsageDescription` 키 추가: `"도둑을 체포하기 위해 QR코드를 스캔합니다"`

---

### Step 2: 도둑 QR 표시 다이얼로그 (신규)

**신규 파일:** `lib/features/game/presentation/widgets/qr_display_dialog.dart`

- `showDialog()`로 호출되는 `StatelessWidget`
- `participantId`를 받아 `QrImageView`로 `{"pid": <participantId>}` 렌더링
- 다크모드 지원 (도둑팀 = 다크모드)
- 닫기 버튼
- `ScreenUtil` 사용 (QR 크기 ~240.w)

---

### Step 3: 경찰 QR 스캐너 페이지 (신규)

**신규 파일:** `lib/features/game/presentation/widgets/qr_scanner_page.dart`

- `Navigator.push`로 풀스크린 진입 (Stack 인덱스 변경 없음)
- `MobileScanner` 위젯으로 카메라 뷰파인더
- QR 감지 시 JSON 파싱 → `pid` 추출 → `Navigator.pop(context, participantId)`
- 첫 번째 유효 스캔 후 자동 중지 (중복 pop 방지)
- 카메라 권한 거부 시 설정 안내 다이얼로그 (기존 위치 권한 다이얼로그 패턴 참고)
- 닫기 버튼 (좌상단)
- `MobileScannerController` dispose 처리

---

### Step 4: game_page.dart에 QR 버튼 추가

**파일:** `lib/features/game/presentation/pages/game_page.dart`

**index 5 우측 버튼 영역** (line 1001 Column)에 QR 버튼 추가:

- **경찰**: QR 스캔 버튼 → `_openQrScanner()` 호출
- **도둑**: QR 표시 버튼 → `_showMyQrCode()` 호출
- 기존 person 버튼과 location 버튼 사이에 배치

**새 메서드 `_openQrScanner()`:**
1. 경찰 대기 시간 가드 체크 (기존 `participant_overlay.dart`의 canArrest 로직 재사용)
2. 대기 시간 중이면 스낵바 표시 후 리턴
3. `Navigator.push<int>(QrScannerPage)` → participantId 수신
4. participantId가 null이면 리턴 (사용자 취소)
5. JAILED 상태 체크 → 이미 체포된 도둑이면 스낵바 표시
6. `GameActionModal.show()` 확인 모달 표시 (닉네임 조회 포함)
7. 확인 시 기존 `arrestRobber(gameId, participantId)` 호출

**새 메서드 `_showMyQrCode()`:**
1. `showDialog()` → `QrDisplayDialog(participantId: widget.participantId)`

**Stack 영향 없음** — QR 다이얼로그는 `showDialog`, 스캐너는 `Navigator.push` 사용. 8개 Stack children 유지, ChatOverlay index 7 고정.

---

### Step 5: 기존 탭 체포 로직 제거

**파일:** `lib/features/game/presentation/widgets/participant_overlay.dart`

- `_onRobberCardTap()` 메서드에서 체포 로직 제거
- `_onRobberTeamCardTap()`의 경찰 분기: 체포 대신 안내 스낵바 or no-op
- 탈옥 로직(도둑 분기)은 그대로 유지

---

### Step 6: canArrest 로직 공통화

**파일:** `lib/features/game/presentation/providers/game_event_provider.dart`

기존 `participant_overlay.dart`에 있던 경찰 대기시간 체크 로직을 `GameEventState`의 헬퍼 메서드로 추출:

```dart
bool canPoliceArrest({
  required GameParticipantInfo? participantInfo,
}) { ... }
```

`game_page.dart`와 (필요 시) 다른 곳에서 재사용.

---

### Step 7: SVG 아이콘 추가

**신규 파일:** `assets/icons/icon_qr_scan.svg` (경찰용 스캔 버튼)
**신규 파일:** `assets/icons/icon_qr_code.svg` (도둑용 QR 표시 버튼)

---

## 수정 파일 요약

| 파일 | 변경 내용 |
|------|----------|
| `pubspec.yaml` | qr_flutter, mobile_scanner 추가 |
| `android/app/src/main/AndroidManifest.xml` | CAMERA 권한 |
| `ios/Runner/Info.plist` | NSCameraUsageDescription |
| `game_page.dart` | QR 버튼 추가, _openQrScanner(), _showMyQrCode() |
| `participant_overlay.dart` | _onRobberCardTap() 체포 로직 제거 |
| `game_event_provider.dart` | canPoliceArrest 헬퍼 추출 (선택) |

## 신규 파일

| 파일 | 설명 |
|------|------|
| `qr_display_dialog.dart` | 도둑 QR 표시 다이얼로그 |
| `qr_scanner_page.dart` | 경찰 QR 스캐너 페이지 |
| `icon_qr_scan.svg` | 스캔 버튼 아이콘 |
| `icon_qr_code.svg` | QR 표시 버튼 아이콘 |

---

## 검증 방법

1. **도둑 QR 표시**: 게임 진입 → 도둑 역할 → QR 버튼 탭 → QR 다이얼로그 표시 → participantId 인코딩 확인
2. **경찰 QR 스캔**: 게임 진입 → 경찰 역할 → QR 스캔 버튼 → 카메라 뷰파인더 → 도둑 QR 스캔 → 확인 모달 → 체포 API 호출
3. **경찰 대기 시간 가드**: 대기 시간 중 스캔 버튼 탭 → 스낵바 표시
4. **이미 체포된 도둑**: JAILED 도둑 QR 스캔 → 스낵바 표시
5. **카메라 권한 거부**: 스캐너 진입 시 권한 거부 → 설정 안내 다이얼로그
6. **기존 탭 체포 제거**: 참가자 목록에서 도둑 탭 → 체포 모달 미표시
7. **채팅 오버레이**: 체포 플로우 중 ChatOverlay State 보존 확인
8. **레이스 컨디션**: 연속 스캔 시 _pendingArrestId 가드 동작 확인
