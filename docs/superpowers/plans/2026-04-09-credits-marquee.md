# 크레딧 마키 텍스트 (도움 준 사람들) 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 크레딧 페이지 하단에 도움 준 사람들의 `이름 (역할)` 마키 텍스트(우→좌 흐름)를 추가한다.

**Architecture:** `credit_member.dart`에 `CreditHelper` 모델과 하드코딩 리스트를 추가하고, `MarqueeWidget`을 생성하여 `credits_page.dart` 하단에 배치한다. Flutter의 `AnimationController` + `Transform.translate`로 무한 루프 마키를 구현한다.

**Tech Stack:** Flutter AnimationController, Transform.translate

---

## Task 1: CreditHelper 데이터 모델 추가

**Files:**
- Modify: `lib/features/credits/domain/credit_member.dart`

- [ ] **Step 1: CreditHelper 모델 추가**

파일 하단 (`creditMembers` 리스트 아래)에 추가:

```dart
/// 도움 준 사람 정보
class CreditHelper {
  const CreditHelper({
    required this.name,
    required this.role,
  });

  final String name;
  final String role;
}

/// 도움 준 사람들 목록
///
/// TODO: 실제 이름/역할로 교체 필요
const List<CreditHelper> creditHelpers = [
  CreditHelper(name: '서창희', role: '멘토'),
  CreditHelper(name: '김영수', role: 'QA'),
  CreditHelper(name: '이지은', role: '기획 자문'),
  CreditHelper(name: '박준혁', role: '인프라'),
  CreditHelper(name: '최민정', role: 'QA'),
];
```

- [ ] **Step 2: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 3: 커밋**

```bash
git add lib/features/credits/domain/credit_member.dart
git commit -m "feat : CreditHelper 데이터 모델 추가 #238"
```

---

## Task 2: MarqueeWidget 생성

**Files:**
- Create: `lib/features/credits/presentation/widgets/marquee_widget.dart`

- [ ] **Step 1: MarqueeWidget 구현**

```dart
import 'package:flutter/material.dart';

/// 무한 우→좌 마키 위젯
///
/// 자식 위젯을 두 벌 복제하여 이어붙이고,
/// AnimationController로 좌측 이동 → 절반 지점에서 리셋하여 무한 루프 구현.
class MarqueeWidget extends StatefulWidget {
  const MarqueeWidget({
    required this.child,
    this.speed = 30.0,
    super.key,
  });

  /// 스크롤할 콘텐츠 위젯
  final Widget child;

  /// 초당 이동 픽셀 (기본 30px/s)
  final double speed;

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  double _contentWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // 레이아웃 완료 후 스크롤 시작
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 무한 스크롤 루프
  ///
  /// 콘텐츠 너비의 절반(원본 1벌 분량)을 speed 기반 duration으로 스크롤.
  /// 절반 도달 시 offset 0으로 점프 → 시각적 끊김 없이 반복.
  Future<void> _startScroll() async {
    // 전체 스크롤 가능 범위 = 콘텐츠 두 벌 중 한 벌 너비
    _contentWidth = _scrollController.position.maxScrollExtent / 2;
    if (_contentWidth <= 0) return;

    while (mounted) {
      final remaining = _contentWidth - _scrollController.offset;
      final duration = Duration(
        milliseconds: (remaining / widget.speed * 1000).toInt(),
      );
      await _scrollController.animateTo(
        _contentWidth,
        duration: duration,
        curve: Curves.linear,
      );
      if (!mounted) return;
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      // 유저 직접 스크롤 방지
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: [
          // 콘텐츠 두 벌 이어붙이기 — 무한 루프 효과
          widget.child,
          widget.child,
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 3: 커밋**

```bash
git add lib/features/credits/presentation/widgets/marquee_widget.dart
git commit -m "feat : MarqueeWidget — 무한 우→좌 마키 위젯 #238"
```

---

## Task 3: credits_page에 마키 텍스트 배치

**Files:**
- Modify: `lib/features/credits/presentation/pages/credits_page.dart`

- [ ] **Step 1: import 추가**

```dart
import '../widgets/marquee_widget.dart';
```

`credit_member.dart`는 이미 import되어 있으므로 `creditHelpers`에 바로 접근 가능.

- [ ] **Step 2: body Column에 마키 섹션 추가**

기존 `SizedBox(height: 240.h)` (카드 ListView) 아래에 추가:

```dart
// 카드 ListView 닫는 괄호 아래에
const Spacer(),
// 도움 준 사람들 마키
Padding(
  padding: EdgeInsets.only(bottom: AppSpacing.vertical32),
  child: Column(
    children: [
      Text(
        'Special Thanks',
        style: AppTextStyles.tag_12.copyWith(
          color: AppColors.black600,
        ),
      ),
      SizedBox(height: AppSpacing.vertical12),
      MarqueeWidget(
        speed: 30,
        child: Row(
          children: creditHelpers.map((helper) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontal16,
              ),
              child: Text(
                '${helper.name} (${helper.role})',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.black500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  ),
),
```

- [ ] **Step 3: SizedBox(height: AppSpacing.vertical40) 조정**

카드 위 상단 여백(`SizedBox(height: AppSpacing.vertical40)`)을 `vertical24`로 줄여서 하단 마키에 공간 확보:

기존:
```dart
SizedBox(height: AppSpacing.vertical40),
// 타이틀
```

변경:
```dart
SizedBox(height: AppSpacing.vertical24),
// 타이틀
```

- [ ] **Step 4: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 5: 수동 테스트**

1. 설정 > 앱 버전 5탭 → 크레딧 페이지 진입
2. 상단: 개발자 카드 가로 스크롤 정상 동작 확인
3. 하단: "Special Thanks" 라벨 아래 이름(역할)이 우→좌로 흐르는지 확인
4. 마키 끊김 없이 무한 루프 반복 확인
5. 카드 탭 → Hero 상세 페이지 이동 여전히 정상 확인

- [ ] **Step 6: 커밋**

```bash
git add lib/features/credits/presentation/pages/credits_page.dart
git commit -m "feat : 크레딧 페이지 하단 Special Thanks 마키 텍스트 추가 #238"
```
