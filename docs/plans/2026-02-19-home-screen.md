# Home Screen Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Redesign the home screen UI to match the Figma design with logo, icon buttons, speech bubble, avatar placeholder, and action buttons.

**Architecture:** Modify existing `home_page.dart` (session feature). Pure UI redesign — no new data/domain layers needed. Reuse existing `AppButton`, `AppColors`, `AppTextStyles`, `SvgPicture` patterns.

**Tech Stack:** Flutter, flutter_svg, flutter_screenutil, Riverpod, GoRouter, existing design system constants

---

## Reference: Design Spec

```
┌──────────────────────────────┐
│ LOGO                     ⚙️  │  ← Row: Text("LOGO") + Settings IconButton
│                              │
│              [📢] [🎩]       │  ← Row(end): Loudspeaker + TopHat (56px containers)
│                              │
│    ┌──────────────────────┐  │
│    │ 너무 기대 돼          │  │  ← text_box.svg + Text overlay
│    │ 이번에는 어떤 역할을  │  │
│    │ 할까?          ▽     │  │
│    └──────────────────────┘  │
│                              │
│      ┌──────────────────┐    │
│      │                  │    │  ← 223x260 avatar placeholder (app_icon_512.png)
│      │   app_icon_512   │    │
│      │                  │    │
│      └──────────────────┘    │
│                              │
│  ┌──────────────────────────┐│
│  │      방 만들기            ││  ← AppButton (default: black bg, white text)
│  └──────────────────────────┘│
│  ┌──────────────────────────┐│
│  │      방 참여하기          ││  ← AppButton (black100 bg, black600 text)
│  └──────────────────────────┘│
└──────────────────────────────┘
```

## Key Design Values

| Element | Spec |
|---------|------|
| Settings icon | `icon_setting_1.svg`, colorFilter: `AppColors.black800` |
| Icon containers | 56w x 56w, radius: 16.r, shadow: offset(1,1) blur(8) spread(0) black 10% |
| Icon size | 32w x 32w |
| Speech bubble | `text_box.svg` (SVG has built-in shadow filter), NO container wrap |
| Bubble text | `paragraph_14` + `AppColors.black`, centered |
| Avatar | 223w x 260h, `app_icon_512.png`, fit: contain |
| "방 만들기" | AppButton default (black bg, white text) |
| "방 참여하기" | AppButton: backgroundColor=`black100`, foregroundColor=`black600` |

---

### Task 1: Redesign Home Page Layout Structure

**Files:**
- Modify: `lib/features/session/presentation/pages/home_page.dart`

**Step 1: Replace the entire home_page.dart with new design**

Replace the current `home_page.dart` content. Remove AppBar, use SafeArea + Column layout. Keep existing `_onCreateSession` and `_showJoinRoomDialog` methods intact.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../router/route_paths.dart';

/// 홈 화면
///
/// 게임 세션 생성 또는 참가를 선택할 수 있는 메인 화면입니다.
/// 디자인: LOGO + 설정, 공지/역할 아이콘, 말풍선, 아바타, 방만들기/참여하기 버튼
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// 방 만들기 버튼 클릭 시
  Future<void> _onCreateSession(BuildContext context) async {
    await SessionDraftStorageService().clearDraft();
    if (context.mounted) {
      context.go(RoutePaths.sessionCreationFlow);
    }
  }

  /// 방 참여 다이얼로그 표시
  void _showJoinRoomDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('방 참여하기'),
          content: TextField(
            controller: codeController,
            decoration: const InputDecoration(
              hintText: '초대 코드를 입력하세요',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final code = codeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  context.go(RoutePaths.waitingRoomWithId(code));
                }
              },
              child: const Text('참여'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),

              // ── Top Bar: LOGO + Settings ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LOGO',
                    style: AppTextStyles.heading_24.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: 설정 화면 네비게이션 (별도 이슈에서 구현)
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/icon_setting_1.svg',
                      width: 24.w,
                      height: 24.h,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black800,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Middle Content (Expandable) ──
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 24.h),

                    // ── Icon Buttons Row (aligned right) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 공지사항 (Loudspeaker)
                        _buildIconContainer(
                          assetPath: 'assets/icons/Loudspeaker.svg',
                          onTap: () {
                            // TODO: 공지사항 페이지 네비게이션 (별도 이슈에서 구현)
                          },
                        ),
                        SizedBox(width: 8.w),
                        // 역할/테마 (Top Hat)
                        _buildIconContainer(
                          assetPath: 'assets/icons/Top_hat.svg',
                          onTap: () {
                            // TODO: 역할 선택 또는 테마 관련 기능
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // ── Speech Bubble (text_box SVG + text overlay) ──
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/text_box.svg',
                          width: 198.w,
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Text(
                            '너무 기대 돼\n이번에는 어떤 역할을 할까?',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.paragraph_14.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // ── Avatar Placeholder ──
                    Image.asset(
                      'assets/app_icon_512.png',
                      width: 223.w,
                      height: 260.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              // ── Bottom Buttons ──
              AppButton(
                text: '방 만들기',
                onPressed: () => _onCreateSession(context),
              ),
              SizedBox(height: 12.h),
              AppButton(
                text: '방 참여하기',
                onPressed: () => _showJoinRoomDialog(context),
                backgroundColor: AppColors.black100,
                foregroundColor: AppColors.black600,
                showBorder: false,
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  /// 아이콘 컨테이너 빌더 (56x56, radius 16, shadow)
  Widget _buildIconContainer({
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              offset: const Offset(1, 1),
              blurRadius: 8,
              spreadRadius: 0,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            width: 32.w,
            height: 32.w,
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Verify build succeeds**

Run: `flutter analyze lib/features/session/presentation/pages/home_page.dart`
Expected: No issues found

**Step 3: Hot restart and visual check**

Run: `flutter run` (or hot restart if already running)
Expected: Home screen matches design layout

**Step 4: Commit**

```bash
git add lib/features/session/presentation/pages/home_page.dart
git commit -m "feat(home): redesign home screen UI to match Figma design

- Replace AppBar with custom LOGO + settings icon row
- Add Loudspeaker/TopHat icon containers with shadow
- Add speech bubble (text_box.svg) with text overlay
- Add avatar placeholder (app_icon_512.png, 223x260)
- Replace ElevatedButtons with AppButton components
- 방 만들기: default black style
- 방 참여하기: black100 bg + black600 text"
```

---

## Notes

- **Settings navigation**: `onPressed` is a TODO — will be implemented in the settings screen issue
- **Loudspeaker navigation**: TODO — will be implemented in the announcements issue
- **Top Hat functionality**: TODO — TBD
- **LOGO**: Placeholder text, will be replaced with actual logo asset later
- **Avatar**: Using `app_icon_512.png` temporarily — will be replaced with SVG/Lottie later
- **text_box.svg shadow**: The SVG already contains a drop shadow filter (`feOffset dx=1 dy=1`, `feGaussianBlur stdDeviation=4`, opacity 0.1). If flutter_svg doesn't render the filter correctly, consider replacing with a Flutter `CustomPaint` speech bubble widget.
- **"방 참여하기" font weight**: AppButton hardcodes `label_16` (SemiBold). User specified `label_16px_medium` but AppButton doesn't support custom text styles. The color (`black600`) is applied via `foregroundColor`. If Medium weight is strictly required, AppButton needs a `textStyle` parameter added later.
