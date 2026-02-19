# 공지사항 페이지 UI 구현 플랜

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 공지사항 페이지 UI만 구현 (더미 데이터 사용, API 연동은 엔드포인트 나오면 별도 작업)

**Architecture:** settings_page.dart와 동일한 패턴. 더미 데이터로 UI만 구현하고, 나중에 API 나오면 data/domain 레이어 추가.

**Tech Stack:** Flutter, AppColors, AppTextStyles, AppSpacing, go_router

---

### Task 1: 기존 불필요 파일 정리

이전에 만든 data/domain 레이어 파일들을 모두 삭제한다. UI만 구현할 것이므로 필요 없다.

**Step 1: 불필요 파일/폴더 삭제**

삭제 대상:
- `lib/features/notice/data/` (전체 폴더)
- `lib/features/notice/domain/` (전체 폴더)
- `lib/features/notice/presentation/providers/` (전체 폴더)
- `lib/core/constants/api_endpoints.dart` 변경분 되돌리기 (`git checkout`)
- `docs/plans/2026-02-19-notices-page-pagination.md` (이전 플랜)

Run:
```bash
rm -rf lib/features/notice/data lib/features/notice/domain lib/features/notice/presentation/providers
rm docs/plans/2026-02-19-notices-page-pagination.md
git checkout lib/core/constants/api_endpoints.dart
```

**Step 2: 확인**

Run: `ls lib/features/notice/`
Expected: `presentation/` 폴더만 남아 있고, 그 안에 `pages/` 만 존재

---

### Task 2: 공지사항 페이지 UI 구현

`settings_page.dart`와 동일한 패턴으로 구현한다. 더미 데이터는 페이지 내부에 직접 정의.

**Files:**
- 수정: `lib/features/notice/presentation/pages/notices_page.dart`

**디자인 스펙:**
- AppBar: `PreviousButton` + "공지사항" (heading_20, black)
- body: `SingleChildScrollView` + `Padding(horizontal24)`
- 각 공지 아이템:
  - 제목: `label_16`, `AppColors.black`
  - 제목 옆 드롭다운 아이콘: `keyboard_arrow_down/up`, size 20, `AppColors.black300`
  - 제목 아래 8px 간격 → 날짜: `tag_12`, `AppColors.black600`, yyyy.MM.dd 형식
  - 날짜 아래 16px 간격 → `Divider(color: AppColors.black100, height: 1)`
  - 펼침 시 내용: `paragraph_14`, `AppColors.black`
- 아코디언: 한 번에 하나만 펼침 (`_expandedIndex`)
- 페이지네이션: 하단 `PaginationBar` 위젯 사용

**더미 데이터 구조:**
```dart
// 페이지 내부에 직접 정의
final List<_NoticeItem> _dummyNotices = [
  _NoticeItem(title: '...', content: '...', date: DateTime(...)),
  // 10개 정도
];

class _NoticeItem {
  final String title;
  final String content;
  final DateTime date;
  _NoticeItem({required this.title, required this.content, required this.date});
}
```

**Step 1: notices_page.dart 작성**

settings_page.dart 패턴을 따라서:
- `StatefulWidget` (ConsumerStatefulWidget 불필요 → 그냥 `StatefulWidget`)
- Scaffold → AppBar → SingleChildScrollView → Column
- 더미 데이터 리스트로 아코디언 아이템 생성
- 하단에 PaginationBar

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/pagination_bar.dart';

class NoticesPage extends StatefulWidget {
  const NoticesPage({super.key});

  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> {
  int _expandedIndex = -1;
  int _currentPage = 0;

  // 더미 데이터 (총 15개, 페이지당 10개 → 2페이지)
  static final List<_NoticeItem> _allNotices = [
    _NoticeItem(
      title: '서비스 오픈 안내',
      content: '경찰과 도둑 서비스가 정식 오픈되었습니다. ...',
      date: DateTime(2026, 2, 19),
    ),
    // ... 총 15개
  ];

  static const int _pageSize = 10;

  List<_NoticeItem> get _currentNotices {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, _allNotices.length);
    return _allNotices.sublist(start, end);
  }

  int get _totalPages => (_allNotices.length / _pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final notices = _currentNotices;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: Text(
          '공지사항',
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: AppPadding.horizontal24,
                child: Column(
                  children: [
                    for (int i = 0; i < notices.length; i++)
                      _buildNoticeItem(notice: notices[i], index: i),
                  ],
                ),
              ),
            ),
          ),
          // 페이지네이션
          if (_totalPages > 1)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical16),
              child: PaginationBar(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                    _expandedIndex = -1;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoticeItem({required _NoticeItem notice, required int index}) {
    final isExpanded = _expandedIndex == index;

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expandedIndex = isExpanded ? -1 : index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 + 아이콘
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notice.title,
                        style: AppTextStyles.label_16.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.horizontal8),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.black300,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.vertical8),
                // 날짜
                Text(
                  _formatDate(notice.date),
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.black600,
                  ),
                ),
                // 내용 (펼침 시)
                if (isExpanded) ...[
                  SizedBox(height: AppSpacing.vertical16),
                  Text(
                    notice.content,
                    style: AppTextStyles.paragraph_14.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const Divider(color: AppColors.black100, height: 1),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}

class _NoticeItem {
  final String title;
  final String content;
  final DateTime date;
  const _NoticeItem({
    required this.title,
    required this.content,
    required this.date,
  });
}
```

**Step 2: 확인**

Run: `flutter analyze lib/features/notice/`
Expected: No issues found

---

### Task 3: 라우터 등록 + 홈 화면 버튼 연결

**Files:**
- 수정: `lib/router/route_paths.dart` (notices 경로 추가)
- 수정: `lib/router/app_router.dart` (GoRoute 등록)
- 수정: `lib/features/session/presentation/pages/home_page.dart` (Loudspeaker 버튼 연결)

**Step 1: route_paths.dart에 notices 경로 추가**

```dart
/// 공지사항 화면
static const String notices = '/home/notices';

// Route Names에 추가
static const String noticesName = 'notices';
```

**Step 2: app_router.dart에 GoRoute 등록**

home routes 안에 notices 추가 (settings와 동일 패턴):
```dart
import '../features/notice/presentation/pages/notices_page.dart';

// home의 routes 안에:
GoRoute(
  path: 'notices',
  name: RoutePaths.noticesName,
  pageBuilder: (context, state) => buildDirectionalSlide(
    key: state.pageKey,
    child: const NoticesPage(),
    isForward: true,
  ),
),
```

**Step 3: home_page.dart Loudspeaker 버튼 연결**

```dart
SvgIconButton(
  assetPath: 'assets/icons/Loudspeaker.svg',
  onPressed: () {
    context.push(RoutePaths.notices);
  },
),
```

**Step 4: 확인**

Run: `flutter analyze`
Expected: No issues found
