# + 버튼 카드 (팀 변경 UI 개선) 설계

## 개요

대기실 팀 섹션에서 빈 슬롯(EmptySlotCard) 탭으로 팀 변경하던 방식을 개선한다.
각 팀 첫 번째 칸에 **+ 버튼 카드(AddSlotCard)**를 고정 배치하여, 이 카드만 팀 변경 트리거 역할을 한다.

### 문제

- 참가자가 많아지면 빈 슬롯이 아래로 밀려 스크롤해야 팀 변경 가능
- 어떤 빈 슬롯이든 탭하면 팀 변경 → 의도치 않은 탭 가능성

### 해결

- 각 팀 첫 번째 칸 = AddSlotCard (+ 아이콘, 항상 표시)
- 나머지 빈 슬롯은 탭 비활성화

---

## 변경 파일

| 파일 | 변경 내용 |
|------|----------|
| `participant_card.dart` | `AddSlotCard` 위젯 추가, `ParticipantCard`에 `isDarkMode` 파라미터 추가 |
| `team_section.dart` | index 0 = AddSlotCard, `onAddSlotTap` 콜백 추가, `onEmptySlotTap` 제거 |
| `waiting_room_page.dart` | `onEmptySlotTap` → `onAddSlotTap`으로 변경 |
| `participant_overlay.dart` | `onEmptySlotTap` 제거 대응 (사용 여부 확인) |

---

## 상세 설계

### 1. AddSlotCard 위젯 (participant_card.dart)

```dart
class AddSlotCard extends StatelessWidget {
  const AddSlotCard({this.onTap, this.isDarkMode = false, super.key});

  final VoidCallback? onTap;
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

**스펙:**
- 크기: 72x84 (기존 카드와 동일)
- 배경색: 라이트 `AppColors.black100`, 다크 `AppColors.black800`
- BorderRadius: `8.r`
- 아이콘: `assets/icons/plus.svg` (17x17), 중앙 배치
- 아이콘 색상: 라이트 `AppColors.black300`, 다크 `AppColors.black400`
- 하단: 닉네임 영역 높이 맞춤용 빈 SizedBox

### 2. ParticipantCard 다크모드 닉네임 색상

```dart
// 기존
color: AppColors.black800

// 변경
color: isDarkMode ? AppColors.black300 : AppColors.black800
```

- `isDarkMode` 파라미터 추가 (기본값 `false`)
- 다크모드 시 닉네임: `AppColors.black300`

### 3. TeamSection 수정

```dart
// 변경 전
final VoidCallback? onEmptySlotTap;

// 변경 후
final VoidCallback? onAddSlotTap;
```

`_buildParticipants()` 로직:

```
index 0        → AddSlotCard(onTap: onAddSlotTap, isDarkMode: isDarkMode)
index 1~N      → ParticipantCard (members[index-1])
index N+1~max  → EmptySlotCard(onTap: null)  // 탭 비활성화
```

- 총 카드 수: `1(AddSlot) + maxPerTeam` (+ 카드가 추가되므로 슬롯 수 유지)
  - 또는: 총 카드 수 = `maxPerTeam`으로 유지 (AddSlot이 1칸 차지, 빈 슬롯 1개 감소)

**결정: 총 카드 수 = `maxPerTeam`으로 유지**
- AddSlotCard가 첫 번째 칸 차지
- 참가자 카드: index 1 ~ members.length
- 빈 슬롯: members.length+1 ~ maxPerTeam-1

### 4. WaitingRoomPage 수정

```dart
// 변경 전
onEmptySlotTap: !_isReady ? () => _changeTeam('POLICE') : null,

// 변경 후
onAddSlotTap: !_isReady ? () => _changeTeam('POLICE') : null,
```

동일한 `_changeTeam()` 로직 유지, 콜백 이름만 변경.

---

## 영향 범위

- **인게임 참가자 오버레이** (`participant_overlay.dart`): `onEmptySlotTap`을 사용하지 않으므로 영향 없음. `onAddSlotTap`도 전달하지 않으면 AddSlotCard가 표시되지 않도록 처리 필요.
- **EmptySlotCard**: 기존 위젯 유지, 탭 콜백만 null로 변경됨.
