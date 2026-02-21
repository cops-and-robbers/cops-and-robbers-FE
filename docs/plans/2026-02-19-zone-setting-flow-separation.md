# 플레이그라운드/감옥 구역 설정 플로우 단계 분리 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 구역 설정 Step 0에서 플레이그라운드 설정이 완료된 후에만 감옥 구역 설정 버튼이 노출되도록 조건부 렌더링을 적용한다.

**Architecture:** `Step0SelectAreaContent` 위젯에서 `playgroundCenter`/`playgroundRadiusMeters` null 여부를 기반으로 감옥 버튼을 조건부 렌더링한다. 플레이그라운드 미설정 시 감옥 자리에 비활성 힌트 컨테이너를 표시하여 UX 흐름을 안내한다.

**Tech Stack:** Flutter, flutter_screenutil, go_router

**Issue:** https://github.com/cops-and-robbers/cops-and-robbers-FE/issues/90
**Branch:** `20260214_#90_플레이그라운드_감옥_구역_설정_플로우_단계_분리_및_노출_조건_변경`
**Commit prefix:** `플레이그라운드/감옥 구역 설정 플로우 단계 분리 및 노출 조건 변경 : feat :`

---

## 현재 구조 분석

### 현재 문제
- `Step0SelectAreaContent`에서 플레이그라운드/감옥 버튼이 **동시에** 노출됨
- 플레이그라운드 설정이 선행되어야 하는 구조적 관계가 UI에 드러나지 않음
- 초기 진입 시 정보 과다 노출 → 인지적 부담

### 변경 대상 파일
| 파일 | 변경 내용 |
|------|----------|
| `lib/features/session/presentation/widgets/session_creation_steps/step_0_select_area_content.dart` | 감옥 버튼 조건부 렌더링 + 비활성 힌트 UI 추가 |

### 변경하지 않는 파일
- `session_creation_flow_page.dart` — `_isNextButtonEnabled` Step 0 로직은 이미 양쪽 모두 설정 필요로 정확함
- `zone_setting_button.dart` — 기존 버튼 컴포넌트 변경 불필요 (숨김 처리이므로)
- `setup_playground_page.dart`, `setup_prison_page.dart` — 각 설정 페이지는 변경 없음

---

## Task 1: Step0SelectAreaContent 조건부 렌더링 구현

**Files:**
- Modify: `lib/features/session/presentation/widgets/session_creation_steps/step_0_select_area_content.dart`

**Step 1: 감옥 버튼을 조건부 렌더링으로 변경**

`build()` 메서드의 Column children을 아래와 같이 수정:

```dart
@override
Widget build(BuildContext context) {
  final isPlaygroundSet =
      playgroundCenter != null && playgroundRadiusMeters != null;

  return Column(
    children: [
      // 플레이그라운드 버튼 (항상 노출)
      ZoneSettingButton(
        zoneType: ZoneType.playground,
        title: '플레이그라운드',
        radiusMeters: playgroundRadiusMeters,
        onPressed: () => _onPlaygroundPressed(context),
      ),

      SizedBox(height: AppSpacing.vertical8),

      // 감옥 버튼: 플레이그라운드 설정 완료 시에만 노출
      if (isPlaygroundSet)
        ZoneSettingButton(
          zoneType: ZoneType.prison,
          title: '감옥',
          radiusMeters: prisonRadiusMeters,
          onPressed: () => _onPrisonPressed(context),
        )
      else
        _buildPrisonLockedHint(),
    ],
  );
}
```

**Step 2: 비활성 힌트 위젯 메서드 추가**

`_onPrisonPressed` 메서드 아래에 추가:

```dart
/// 감옥 구역 비활성 힌트 (플레이그라운드 미설정 시 표시)
Widget _buildPrisonLockedHint() {
  return Container(
    width: 353.w,
    height: 56.h,
    decoration: BoxDecoration(
      color: AppColors.black100,
      borderRadius: AppRadius.xlarge,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 18.w,
            color: AppColors.black400,
          ),
          SizedBox(width: AppSpacing.horizontal8),
          Text(
            '플레이그라운드 설정 후 감옥을 설정할 수 있어요',
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.black400,
            ),
          ),
        ],
      ),
    ),
  );
}
```

필요한 import 추가 (이미 있으면 스킵):
```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/text_styles.dart';
```

**Step 3: 빌드 확인**

Run: `flutter analyze lib/features/session/presentation/widgets/session_creation_steps/step_0_select_area_content.dart`
Expected: No issues found

**Step 4: 커밋**

```bash
git add lib/features/session/presentation/widgets/session_creation_steps/step_0_select_area_content.dart
git commit -m "플레이그라운드/감옥 구역 설정 플로우 단계 분리 및 노출 조건 변경 : feat : 감옥 구역 버튼 조건부 렌더링 및 비활성 힌트 UI 추가 https://github.com/cops-and-robbers/cops-and-robbers-FE/issues/90"
```

---

## 동작 시나리오 검증

### 시나리오 1: 초기 진입 (플레이그라운드 미설정)
1. 세션 생성 Step 0 진입
2. 플레이그라운드 버튼만 활성 상태로 노출
3. 감옥 위치에 잠금 힌트 표시: "플레이그라운드 설정 후 감옥을 설정할 수 있어요"
4. "다음" 버튼 비활성 (기존 로직 유지)

### 시나리오 2: 플레이그라운드 설정 완료
1. 플레이그라운드 설정 페이지에서 구역 설정 후 돌아옴
2. 플레이그라운드 버튼에 반경 표시 (예: "반경 500m")
3. 잠금 힌트가 사라지고 감옥 버튼이 노출됨
4. "다음" 버튼 여전히 비활성 (감옥 미설정)

### 시나리오 3: 양쪽 모두 설정 완료
1. 감옥 설정 페이지에서 구역 설정 후 돌아옴
2. 양쪽 버튼 모두 반경 표시
3. "다음" 버튼 활성화

### 시나리오 4: 임시 저장 복원 (Draft)
1. 이전에 플레이그라운드만 설정하고 나간 경우
2. 재진입 시 `_loadDraftData()`로 `playgroundCenter` 복원
3. 감옥 버튼 즉시 노출 (조건부 렌더링이 draft 데이터 반영)

### 시나리오 5: 플레이그라운드 재설정
1. 이미 양쪽 모두 설정된 상태에서 플레이그라운드 재설정
2. 플레이그라운드 버튼 눌러서 재설정 → 새로운 값 반환
3. 감옥 버튼은 계속 노출 (플레이그라운드가 여전히 설정된 상태)
4. 단, 감옥이 새 플레이그라운드 밖으로 벗어날 수 있음 → `SetupPrisonPage`의 기존 유효성 검증이 처리

---

## 변경 영향 범위

- **영향 있음**: `Step0SelectAreaContent` UI 렌더링만 변경
- **영향 없음**: 상태 관리 (`SessionCreationFlowPage`), API 요청, 로컬 저장, 라우팅, 다른 Step
- **기존 기능 보존**: "다음" 버튼 활성화 조건, Draft 저장/복원, 감옥-플레이그라운드 포함 검증
