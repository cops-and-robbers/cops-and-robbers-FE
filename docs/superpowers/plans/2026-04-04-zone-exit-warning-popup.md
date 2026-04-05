# 게임 구역 이탈 경고 팝업 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 플레이어가 게임 구역(플레이그라운드) 밖으로 이탈하면 경고 팝업을 자동 표시하고, 다시 복귀하면 자동으로 닫는다.

**Architecture:** `game_page.dart`의 기존 `_checkZoneExit` 메서드에 팝업 표시/닫기 로직을 추가한다. 팝업 콘텐츠 위젯은 별도 파일(`zone_exit_warning_content.dart`)로 분리하여 단일 책임 원칙을 유지한다. `AppPopup.show`를 사용하되 `barrierDismissible: false`로 설정하여 배경 터치로 닫히지 않게 한다.

**Tech Stack:** Flutter, Riverpod, AppPopup, AppTextStyles, AppColors

---

## File Structure

| 작업 | 파일 | 역할 |
|------|------|------|
| Create | `lib/features/game/presentation/widgets/zone_exit_warning_content.dart` | 이탈 경고 팝업 콘텐츠 위젯 (라이트/다크 모드 대응) |
| Modify | `lib/features/game/presentation/pages/game_page.dart` | `_checkZoneExit`에 팝업 표시/닫기 로직 추가 |

---

### Task 1: 이탈 경고 팝업 콘텐츠 위젯 생성

**Files:**
- Create: `lib/features/game/presentation/widgets/zone_exit_warning_content.dart`

- [ ] **Step 1: 콘텐츠 위젯 파일 생성**

```dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';

/// 플레이그라운드 이탈 경고 팝업 콘텐츠
///
/// 라이트 모드: heading_20 + red 타이틀
/// 다크 모드: robberHeading + red 타이틀
class ZoneExitWarningContent extends StatelessWidget {
  const ZoneExitWarningContent({super.key, required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '플레이그라운드를 벗어났어요!',
          style: (isDarkMode
                  ? AppTextStyles.robberHeading
                  : AppTextStyles.heading_20)
              .copyWith(color: AppColors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '구역 안으로 돌아와서 진행해 주세요',
          style: AppTextStyles.paragraph_14_100.copyWith(
            color: AppColors.red800,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: 커밋**

```bash
git add lib/features/game/presentation/widgets/zone_exit_warning_content.dart
git commit -m "feat: 구역 이탈 경고 팝업 콘텐츠 위젯 생성 #215"
```

---

### Task 2: game_page.dart에 팝업 표시/닫기 로직 추가

**Files:**
- Modify: `lib/features/game/presentation/pages/game_page.dart:107` (상태 변수 추가)
- Modify: `lib/features/game/presentation/pages/game_page.dart:514-538` (`_checkZoneExit` 수정)

- [ ] **Step 1: import 추가**

`game_page.dart` 상단 import 영역에 추가:

```dart
import '../widgets/zone_exit_warning_content.dart';
```

- [ ] **Step 2: 팝업 추적 상태 변수 추가**

`game_page.dart:107` 근처, `_isOutsideZone` 아래에 추가:

```dart
/// 영역 이탈 상태 (중복 진동 방지)
bool _isOutsideZone = false;

/// 이탈 경고 팝업 표시 중 여부 (중복 팝업 방지)
bool _isZoneExitPopupShown = false;
```

- [ ] **Step 3: 팝업 표시 헬퍼 메서드 추가**

`_checkZoneExit` 메서드 아래에 추가:

```dart
/// 구역 이탈 경고 팝업 표시
void _showZoneExitPopup() {
  if (_isZoneExitPopupShown || !mounted) return;
  _isZoneExitPopupShown = true;
  AppPopup.show(
    context: context,
    barrierDismissible: false,
    content: ZoneExitWarningContent(isDarkMode: _isDarkMode),
  ).then((_) {
    // 팝업이 닫히면 (pop 등) 플래그 초기화
    _isZoneExitPopupShown = false;
  });
}

/// 구역 이탈 경고 팝업 닫기
void _dismissZoneExitPopup() {
  if (!_isZoneExitPopupShown || !mounted) return;
  Navigator.of(context).pop();
}
```

- [ ] **Step 4: `_checkZoneExit` 메서드 수정**

기존 `_checkZoneExit` 메서드를 수정하여 팝업 표시/닫기 로직 추가:

```dart
/// 플레이그라운드 영역 이탈 여부 판단 → 이탈 시 진동 + 경고 팝업
void _checkZoneExit(Position pos) {
  // 게임 종료 또는 체포 상태에서는 불필요
  if (_gameOverDialogShown) return;
  final gameState = ref.read(gameEventNotifierProvider);
  if (gameState.arrestedParticipantIds.contains(widget.participantId)) return;

  final area = ref.read(gameAreaProvider(_gameId)).valueOrNull;
  if (area == null) return;

  final distance = Geolocator.distanceBetween(
    area.playgroundCenter.latitude,
    area.playgroundCenter.longitude,
    pos.latitude,
    pos.longitude,
  );

  final isOutside = distance > area.playgroundRadiusInMeters;

  // 안 → 밖 전환: 진동 + 팝업
  if (isOutside && !_isOutsideZone) {
    VibrationService.instance().zoneExit();
    _showZoneExitPopup();
  }

  // 밖 → 안 전환: 팝업 닫기
  if (!isOutside && _isOutsideZone) {
    _dismissZoneExitPopup();
  }

  _isOutsideZone = isOutside;
}
```

- [ ] **Step 5: 커밋**

```bash
git add lib/features/game/presentation/pages/game_page.dart
git commit -m "feat: 구역 이탈 시 경고 팝업 자동 표시/복귀 시 자동 닫기 #215"
```

---

## 동작 흐름 정리

```
위치 업데이트 → _checkZoneExit(pos)
  ├─ 안 → 밖 전환: VibrationService.zoneExit() + _showZoneExitPopup()
  ├─ 밖 → 안 전환: _dismissZoneExitPopup()
  └─ 동일 상태 유지: 아무 동작 없음

팝업 중복 방지:
  _isZoneExitPopupShown == true → _showZoneExitPopup() 조기 반환
  _isZoneExitPopupShown == false → _dismissZoneExitPopup() 조기 반환
```
