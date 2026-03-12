# AddSlotCard (+ 버튼 팀 변경) 구현 계획

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 각 팀 첫 번째 칸에 + 버튼 카드를 고정 배치하여 팀 변경 진입점으로 사용하고, 기존 빈 슬롯 탭 팀 변경을 제거한다.

**Architecture:** `participant_card.dart`에 `AddSlotCard` 위젯 추가, `TeamSection`에서 index 0에 AddSlotCard 배치, `ParticipantCard`에 다크모드 닉네임 색상 지원 추가.

**Tech Stack:** Flutter, flutter_screenutil, flutter_svg

---

## 파일 구조

| 파일 | 변경 | 역할 |
|------|------|------|
| `lib/features/session/presentation/widgets/participant_card.dart` | 수정 | `AddSlotCard` 추가, `ParticipantCard`에 `isDarkMode` 파라미터 추가 |
| `lib/features/session/presentation/widgets/team_section.dart` | 수정 | `onEmptySlotTap` → `onAddSlotTap`, index 0 = AddSlotCard |
| `lib/features/session/presentation/pages/waiting_room_page.dart` | 수정 | `onEmptySlotTap` → `onAddSlotTap` |

---

## Task 1: ParticipantCard에 isDarkMode 추가 + 닉네임 다크모드 색상

**Files:**
- Modify: `lib/features/session/presentation/widgets/participant_card.dart:14-87`

- [ ] **Step 1: ParticipantCard에 isDarkMode 파라미터 추가**

`participant_card.dart` 수정:

```dart
class ParticipantCard extends StatelessWidget {
  const ParticipantCard({
    required this.participant,
    this.isHost = false,
    this.onTap,
    this.isDarkMode = false,
    super.key,
  });

  final LobbyParticipantInfo participant;
  final bool isHost;
  final VoidCallback? onTap;
  final bool isDarkMode;
```

닉네임 색상 변경 (line 68-70):

```dart
// 변경 전
style: AppTextStyles.tag_10.copyWith(
  color: AppColors.black800,
),

// 변경 후
style: AppTextStyles.tag_10.copyWith(
  color: isDarkMode ? AppColors.black300 : AppColors.black800,
),
```

- [ ] **Step 2: 빌드 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/session/presentation/widgets/participant_card.dart`
Expected: No issues found

---

## Task 2: AddSlotCard 위젯 추가

**Files:**
- Modify: `lib/features/session/presentation/widgets/participant_card.dart`

- [ ] **Step 1: AddSlotCard 위젯을 participant_card.dart 하단에 추가**

`EmptySlotCard` 아래에 추가:

```dart
/// + 버튼 슬롯 카드 위젯
///
/// 대기실 팀 섹션 첫 번째 칸에 표시되며, 탭 시 해당 팀으로 변경합니다.
class AddSlotCard extends StatelessWidget {
  const AddSlotCard({this.onTap, this.isDarkMode = false, super.key});

  /// 카드 탭 콜백 (팀 변경 트리거)
  final VoidCallback? onTap;

  /// 다크 모드 여부
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 72.w,
            height: 84.h,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.black800 : AppColors.black100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/plus.svg',
                  width: 17.w,
                  height: 17.w,
                  colorFilter: ColorFilter.mode(
                    isDarkMode ? AppColors.black400 : AppColors.black300,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.vertical4),
          // 닉네임 영역 높이 맞춤용
          SizedBox(width: 72.w, height: AppTextStyles.tag_10.fontSize),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 빌드 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/session/presentation/widgets/participant_card.dart`
Expected: No issues found

---

## Task 3: TeamSection 수정 — onEmptySlotTap → onAddSlotTap + index 0 = AddSlotCard

**Files:**
- Modify: `lib/features/session/presentation/widgets/team_section.dart:14-183`

- [ ] **Step 1: onEmptySlotTap → onAddSlotTap 변경 + _buildParticipants 로직 수정**

**생성자 변경:**

```dart
// 변경 전 (line 22)
this.onEmptySlotTap,

// 변경 후
this.onAddSlotTap,
```

```dart
// 변경 전 (line 47-48)
/// 빈 슬롯 탭 콜백 (더미 모드 팀 변경용)
final VoidCallback? onEmptySlotTap;

// 변경 후
/// + 버튼 카드 탭 콜백 (팀 변경용)
final VoidCallback? onAddSlotTap;
```

**_buildParticipants() 로직 변경 (line 162-182):**

```dart
Widget _buildParticipants() {
  return Padding(
    padding: EdgeInsets.only(left: 29.w, right: 24.w, bottom: 20.h),
    child: Wrap(
      spacing: 16.w,
      runSpacing: 16.h,
      children: [
        // 첫 번째 칸: + 버튼 카드 (onAddSlotTap이 있을 때만 표시)
        if (onAddSlotTap != null)
          AddSlotCard(onTap: onAddSlotTap, isDarkMode: isDarkMode),
        // 참가자 카드
        ...members.map((member) => ParticipantCard(
              participant: member,
              isHost: member.participantId == hostParticipantId,
              isDarkMode: isDarkMode,
              onTap: onMemberTap != null ? () => onMemberTap!(member) : null,
            )),
        // 나머지 빈 슬롯 (탭 비활성화)
        ...List.generate(
          maxPerTeam - members.length - (onAddSlotTap != null ? 1 : 0),
          (_) => const EmptySlotCard(),
        ),
      ],
    ),
  );
}
```

**핵심 로직:**
- `onAddSlotTap != null` → AddSlotCard 표시 (대기실에서만 사용)
- `onAddSlotTap == null` → AddSlotCard 미표시 (인게임 오버레이에서는 기존과 동일)
- 빈 슬롯 수 = `maxPerTeam - members.length - (AddSlotCard가 있으면 1)`
- EmptySlotCard에 `onTap` 전달하지 않음 (탭 비활성화)

- [ ] **Step 2: 빌드 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/session/presentation/widgets/team_section.dart`
Expected: No issues found

---

## Task 4: WaitingRoomPage — onEmptySlotTap → onAddSlotTap 변경

**Files:**
- Modify: `lib/features/session/presentation/pages/waiting_room_page.dart:636-672`

- [ ] **Step 1: 경찰팀 TeamSection 수정**

```dart
// 변경 전 (line 645-647)
onEmptySlotTap: !_isReady
    ? () => _changeTeam('POLICE')
    : null,

// 변경 후
onAddSlotTap: !_isReady
    ? () => _changeTeam('POLICE')
    : null,
```

- [ ] **Step 2: 도둑팀 TeamSection 수정**

```dart
// 변경 전 (line 668-670)
onEmptySlotTap: !_isReady
    ? () => _changeTeam('ROBBER')
    : null,

// 변경 후
onAddSlotTap: !_isReady
    ? () => _changeTeam('ROBBER')
    : null,
```

- [ ] **Step 3: 전체 빌드 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze`
Expected: No issues found

- [ ] **Step 4: 커밋**

```bash
git add lib/features/session/presentation/widgets/participant_card.dart \
        lib/features/session/presentation/widgets/team_section.dart \
        lib/features/session/presentation/pages/waiting_room_page.dart
git commit -m "feat: 팀 변경 + 버튼 카드(AddSlotCard) 추가 및 다크모드 닉네임 색상 적용 #115"
```
