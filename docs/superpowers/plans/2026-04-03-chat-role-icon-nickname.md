# 채팅 닉네임 옆 직업 아이콘 표시 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 채팅 메시지 버블에서 닉네임 좌측에 직업(경찰/도둑) 아이콘을 12×12 크기로 표시한다.

**Architecture:** `ChatMessageBubble`의 닉네임 영역(`_buildMyMessage`, `_buildOtherMessage`)을 `Text` → `Row(icon + spacing4 + nickname)` 구조로 변경. 기존 SVG 아이콘 에셋(`icon_police_*.svg`, `mdi_robber_*.svg`)을 재사용하며, 다크모드에 따라 아이콘을 분기한다.

**Tech Stack:** Flutter, flutter_svg, flutter_screenutil

---

## File Map

| 작업 | 파일 | 책임 |
|------|------|------|
| 수정 | `lib/features/chat/presentation/widgets/chat_message_bubble.dart` | 닉네임 Row에 직업 아이콘 추가 |

## 기존 리소스 (수정 없이 재사용)

- `assets/icons/icon_police_lightmode.svg` — 경찰 아이콘 (라이트)
- `assets/icons/icon_police_darkmode.svg` — 경찰 아이콘 (다크)
- `assets/icons/mdi_robber_lightmode.svg` — 도둑 아이콘 (라이트)
- `assets/icons/mdi_robber_darkmode.svg` — 도둑 아이콘 (다크)
- `ChatSenderDto.team` — `'POLICE'` / `'ROBBER'` / `'SYSTEM'` 값
- `ChatTeam.police`, `ChatTeam.robber` — 상수

---

### Task 1: 직업 아이콘 경로 헬퍼 getter 추가

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_message_bubble.dart:43-45` (getter 영역)

- [ ] **Step 1: 아이콘 경로 반환 getter 추가**

`_isSystemMessage` getter 아래에 직업 아이콘 경로를 반환하는 getter를 추가한다.
시스템 메시지는 직업 아이콘을 표시하지 않으므로 nullable로 처리한다.

```dart
/// 발신자 직업 아이콘 경로 (시스템 메시지는 null)
String? get _roleIconPath {
  final team = message.sender.team.toUpperCase();
  if (team == ChatTeam.police) {
    return isDarkMode
        ? 'assets/icons/icon_police_darkmode.svg'
        : 'assets/icons/icon_police_lightmode.svg';
  }
  if (team == ChatTeam.robber) {
    return isDarkMode
        ? 'assets/icons/mdi_robber_darkmode.svg'
        : 'assets/icons/mdi_robber_lightmode.svg';
  }
  return null;
}
```

삽입 위치: `_isSystemMessage` getter(`line 43-45`) 바로 아래, `_formattedTime` getter 위.

---

### Task 2: 닉네임 영역을 Row(아이콘 + 닉네임)으로 변경

**Files:**
- Modify: `lib/features/chat/presentation/widgets/chat_message_bubble.dart:158-170` (`_buildMyMessage` 닉네임)
- Modify: `lib/features/chat/presentation/widgets/chat_message_bubble.dart:229-241` (`_buildOtherMessage` 닉네임)

- [ ] **Step 1: `_buildMyMessage` 닉네임 영역 수정**

기존 닉네임 `Text` 위젯을 `Row`로 감싸고, 좌측에 직업 아이콘을 추가한다.
`_buildMyMessage()` 내 `if (showNickname)` 블록(line 158-170)을 아래로 교체:

```dart
if (showNickname)
  Padding(
    padding: EdgeInsets.only(
      bottom: AppSpacing.vertical8,
      right: AppSpacing.horizontal4,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_roleIconPath != null) ...[
          SvgPicture.asset(
            _roleIconPath!,
            width: 12.w,
            height: 12.w,
          ),
          SizedBox(width: AppSpacing.horizontal4),
        ],
        Text(
          message.sender.nickname,
          style: AppTextStyles.tag_12.copyWith(
            color: isDarkMode ? AppColors.black400 : AppColors.black600,
          ),
        ),
      ],
    ),
  ),
```

- [ ] **Step 2: `_buildOtherMessage` 닉네임 영역 수정**

동일한 패턴으로 `_buildOtherMessage()` 내 `if (showNickname)` 블록(line 229-241)을 교체:

```dart
if (showNickname)
  Padding(
    padding: EdgeInsets.only(
      bottom: AppSpacing.vertical8,
      left: AppSpacing.horizontal4,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_roleIconPath != null) ...[
          SvgPicture.asset(
            _roleIconPath!,
            width: 12.w,
            height: 12.w,
          ),
          SizedBox(width: AppSpacing.horizontal4),
        ],
        Text(
          message.sender.nickname,
          style: AppTextStyles.tag_12.copyWith(
            color: isDarkMode ? AppColors.black400 : AppColors.black600,
          ),
        ),
      ],
    ),
  ),
```

- [ ] **Step 3: 빌드 확인**

```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/chat/presentation/widgets/chat_message_bubble.dart
```

Expected: No issues found!

- [ ] **Step 4: 커밋**

```bash
git add lib/features/chat/presentation/widgets/chat_message_bubble.dart
git commit -m "feat: 채팅 닉네임 좌측에 직업 아이콘(12×12) 표시 #214"
```

---

## 사용자 확인 사항

- 아이콘 크기 12×12 가시성 → 사용자가 직접 시뮬레이터/기기에서 확인
- 필요 시 아이콘 크기 조정 (`12.w` → `14.w` 등)
