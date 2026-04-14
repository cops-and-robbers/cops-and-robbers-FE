# 히든 크레딧 페이지 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 설정 페이지 앱 버전 5회 탭으로 진입하는 히든 크레딧 페이지 구현 (카드 가로 스크롤 → Hero 애니메이션 상세 페이지)

**Architecture:** credits feature 폴더에 데이터 모델, 크레딧 페이지, 상세 페이지를 생성한다. 설정 페이지의 `_buildVersionItem`에 탭 카운터를 추가하여 5회 탭 시 크레딧 페이지로 네비게이션한다. 상세 페이지는 Hero 애니메이션으로 전환하며, 소셜 링크는 `url_launcher`로 외부 브라우저 열기를 지원한다.

**Tech Stack:** Flutter, go_router, url_launcher, Hero animation

---

## Task 1: 크레딧 멤버 데이터 모델 + 하드코딩 데이터

**Files:**
- Create: `lib/features/credits/domain/credit_member.dart`

- [ ] **Step 1: CreditMember 모델 생성**

```dart
/// 크레딧 멤버 데이터 모델
class CreditMember {
  const CreditMember({
    required this.name,
    required this.role,
    required this.profileAsset,
    this.links = const [],
  });

  final String name;
  final String role;

  /// assets/images/credits/ 내 이미지 경로
  final String profileAsset;

  /// 소셜 링크 목록 (GitHub, Instagram 등)
  final List<SocialLink> links;
}

/// 소셜 링크
class SocialLink {
  const SocialLink({required this.type, required this.url});

  final SocialType type;
  final String url;
}

/// 소셜 링크 타입
enum SocialType {
  github,
  instagram,
  email,
  linkedin;

  /// 표시용 라벨
  String get label => switch (this) {
    SocialType.github => 'GitHub',
    SocialType.instagram => 'Instagram',
    SocialType.email => 'Email',
    SocialType.linkedin => 'LinkedIn',
  };

  /// 아이콘 에셋 경로 (assets/icons/ 내)
  String get iconAsset => switch (this) {
    SocialType.github => 'assets/icons/social_github.svg',
    SocialType.instagram => 'assets/icons/social_instagram.svg',
    SocialType.email => 'assets/icons/social_email.svg',
    SocialType.linkedin => 'assets/icons/social_linkedin.svg',
  };
}
```

- [ ] **Step 2: 하드코딩 멤버 데이터 추가**

같은 파일 하단에 추가:

```dart
/// 크레딧 멤버 목록 (6명)
///
/// 프로필 이미지는 assets/images/credits/ 에 배치
/// TODO: 실제 멤버 정보로 교체 필요
const List<CreditMember> creditMembers = [
  CreditMember(
    name: '멤버1',
    role: 'Backend',
    profileAsset: 'assets/images/credits/member1.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/member1'),
    ],
  ),
  CreditMember(
    name: '멤버2',
    role: 'Backend',
    profileAsset: 'assets/images/credits/member2.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/member2'),
    ],
  ),
  CreditMember(
    name: '멤버3',
    role: 'Flutter',
    profileAsset: 'assets/images/credits/member3.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/member3'),
    ],
  ),
  CreditMember(
    name: '멤버4',
    role: 'Flutter',
    profileAsset: 'assets/images/credits/member4.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/member4'),
    ],
  ),
  CreditMember(
    name: '멤버5',
    role: 'Design',
    profileAsset: 'assets/images/credits/member5.png',
    links: [
      SocialLink(type: SocialType.instagram, url: 'https://instagram.com/member5'),
    ],
  ),
  CreditMember(
    name: '멤버6',
    role: 'PM',
    profileAsset: 'assets/images/credits/member6.png',
    links: [
      SocialLink(type: SocialType.github, url: 'https://github.com/member6'),
    ],
  ),
];
```

- [ ] **Step 3: 프로필 이미지 placeholder 생성**

`assets/images/credits/` 디렉토리 생성. 실제 이미지는 나중에 교체하므로, 빈 디렉토리만 만들고 `pubspec.yaml`에 에셋 경로 등록:

```yaml
# pubspec.yaml의 flutter > assets 섹션에 추가
- assets/images/credits/
```

- [ ] **Step 4: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 5: 커밋**

```bash
git add lib/features/credits/domain/credit_member.dart pubspec.yaml
git commit -m "feat : 크레딧 멤버 데이터 모델 및 하드코딩 데이터 추가 #238"
```

---

## Task 2: 크레딧 페이지 (카드 가로 스크롤)

**Files:**
- Create: `lib/features/credits/presentation/pages/credits_page.dart`
- Create: `lib/features/credits/presentation/widgets/credit_card_widget.dart`

- [ ] **Step 1: CreditCardWidget 생성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/credit_member.dart';

/// 크레딧 카드 위젯
///
/// 가로 스크롤 목록에서 각 멤버를 카드로 표시.
/// 탭 시 Hero 애니메이션으로 상세 페이지 전환.
class CreditCardWidget extends StatelessWidget {
  const CreditCardWidget({
    required this.member,
    required this.onTap,
    super.key,
  });

  final CreditMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200.w,
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xlarge,
          border: Border.all(color: AppColors.black100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 프로필 이미지 (Hero 애니메이션 대상)
            Hero(
              tag: 'credit_${member.name}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.r),
                child: Image.asset(
                  member.profileAsset,
                  width: 100.w,
                  height: 100.w,
                  fit: BoxFit.cover,
                  // 이미지 없을 때 fallback
                  errorBuilder: (_, __, ___) => Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: AppColors.black100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 48.w,
                      color: AppColors.black400,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.vertical16),
            // 이름
            Text(
              member.name,
              style: AppTextStyles.heading_20.copyWith(
                color: AppColors.black,
              ),
            ),
            SizedBox(height: AppSpacing.vertical4),
            // 역할
            Text(
              member.role,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: CreditsPage 생성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/credit_member.dart';
import '../widgets/credit_card_widget.dart';
import 'credit_detail_page.dart';

/// 크레딧 페이지 — 히든 이스터에그
///
/// 설정 > 앱 버전 5회 탭으로 진입.
/// 멤버 카드를 가로 스크롤로 표시하고, 탭 시 Hero 상세 페이지로 전환.
class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: AppSpacing.vertical40),
          // 타이틀
          Text(
            'Made with ❤️',
            style: AppTextStyles.heading_24.copyWith(
              color: AppColors.white,
            ),
          ),
          SizedBox(height: AppSpacing.vertical8),
          Text(
            '경찰과 도둑을 만든 사람들',
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black400,
            ),
          ),
          SizedBox(height: AppSpacing.vertical48),
          // 카드 가로 스크롤
          SizedBox(
            height: 240.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontal16,
              ),
              itemCount: creditMembers.length,
              itemBuilder: (context, index) {
                final member = creditMembers[index];
                return CreditCardWidget(
                  member: member,
                  onTap: () => Navigator.of(context).push(
                    PageRouteBuilder<void>(
                      pageBuilder: (_, __, ___) =>
                          CreditDetailPage(member: member),
                      transitionDuration:
                          const Duration(milliseconds: 300),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 300),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음 (CreditDetailPage는 다음 Task에서 생성하므로, import 에러가 나면 빈 파일로 stub 생성)

- [ ] **Step 4: 커밋**

```bash
git add lib/features/credits/presentation/pages/credits_page.dart lib/features/credits/presentation/widgets/credit_card_widget.dart
git commit -m "feat : 크레딧 페이지 — 카드 가로 스크롤 목록 #238"
```

---

## Task 3: 상세 페이지 (Hero 애니메이션 + 소셜 링크)

**Files:**
- Create: `lib/features/credits/presentation/pages/credit_detail_page.dart`

- [ ] **Step 1: CreditDetailPage 생성**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/credit_member.dart';

/// 크레딧 상세 페이지
///
/// Hero 애니메이션으로 프로필 이미지 확장.
/// 이름, 역할, 소셜 링크 표시.
class CreditDetailPage extends StatelessWidget {
  const CreditDetailPage({required this.member, super.key});

  final CreditMember member;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero 프로필 이미지
            Hero(
              tag: 'credit_${member.name}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(70.r),
                child: Image.asset(
                  member.profileAsset,
                  width: 140.w,
                  height: 140.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 140.w,
                    height: 140.w,
                    decoration: BoxDecoration(
                      color: AppColors.black800,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 64.w,
                      color: AppColors.black400,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.vertical24),
            // 이름
            Text(
              member.name,
              style: AppTextStyles.heading_24.copyWith(
                color: AppColors.white,
              ),
            ),
            SizedBox(height: AppSpacing.vertical8),
            // 역할
            Text(
              member.role,
              style: AppTextStyles.label_16.copyWith(
                color: AppColors.black400,
              ),
            ),
            SizedBox(height: AppSpacing.vertical32),
            // 소셜 링크 버튼
            if (member.links.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: member.links.map((link) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontal8,
                    ),
                    child: _SocialButton(link: link),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

/// 소셜 링크 버튼
class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.link});

  final SocialLink link;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openUrl(link.url),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal16,
          vertical: AppSpacing.vertical12,
        ),
        decoration: BoxDecoration(
          color: AppColors.black800,
          borderRadius: AppRadius.medium,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              link.type.iconAsset,
              width: 20.w,
              height: 20.w,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: AppSpacing.horizontal8),
            Text(
              link.type.label,
              style: AppTextStyles.label_14.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
```

- [ ] **Step 2: url_launcher 의존성 확인**

`pubspec.yaml`에 `url_launcher`가 이미 있는지 확인. 없으면 추가:

```bash
flutter pub add url_launcher
```

- [ ] **Step 3: 소셜 아이콘 SVG 에셋 추가**

`assets/icons/` 에 소셜 아이콘 SVG 파일 추가 필요:
- `social_github.svg`
- `social_instagram.svg`
- `social_email.svg`
- `social_linkedin.svg`

아이콘이 아직 없으면 Flutter Icons로 대체하고 나중에 SVG로 교체.

- [ ] **Step 4: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 5: 커밋**

```bash
git add lib/features/credits/presentation/pages/credit_detail_page.dart
git commit -m "feat : 크레딧 상세 페이지 — Hero 애니메이션 + 소셜 링크 #238"
```

---

## Task 4: 라우터에 크레딧 페이지 등록

**Files:**
- Modify: `lib/router/route_paths.dart`
- Modify: `lib/router/app_router.dart`

- [ ] **Step 1: RoutePaths에 크레딧 경로 추가**

`route_paths.dart`의 settings 아래에:

```dart
/// 크레딧 화면 (히든 이스터에그)
static const String credits = '/home/settings/credits';

/// 라우트 이름
static const String creditsName = 'credits';
```

- [ ] **Step 2: app_router.dart에 라우트 등록**

settings 라우트 아래에 크레딧 페이지 라우트 추가:

```dart
GoRoute(
  path: RoutePaths.credits,
  name: RoutePaths.creditsName,
  builder: (context, state) => const CreditsPage(),
),
```

import 추가:

```dart
import '../features/credits/presentation/pages/credits_page.dart';
```

- [ ] **Step 3: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 4: 커밋**

```bash
git add lib/router/route_paths.dart lib/router/app_router.dart
git commit -m "feat : 크레딧 페이지 라우터 등록 #238"
```

---

## Task 5: 설정 페이지에 5탭 트리거 추가

**Files:**
- Modify: `lib/features/settings/presentation/pages/settings_page.dart`

- [ ] **Step 1: _WaitingRoomPageState 대신 _SettingsPageState에 탭 카운터 추가**

State 클래스에 필드 추가:

```dart
/// 크레딧 이스터에그 — 버전 탭 카운터
int _versionTapCount = 0;
DateTime? _lastVersionTap;
```

- [ ] **Step 2: `_buildVersionItem` 메서드에 GestureDetector 래핑**

기존 `_buildVersionItem()`의 반환 위젯을 `GestureDetector`로 감싸기:

```dart
Widget _buildVersionItem() {
  return GestureDetector(
    onTap: _onVersionTap,
    child: Padding(
      // 기존 Padding 코드 그대로
      ...
    ),
  );
}
```

- [ ] **Step 3: `_onVersionTap` 메서드 추가**

```dart
/// 앱 버전 5회 탭 → 히든 크레딧 페이지
void _onVersionTap() {
  final now = DateTime.now();
  // 2초 이내 연속 탭만 인정
  if (_lastVersionTap != null &&
      now.difference(_lastVersionTap!).inSeconds > 2) {
    _versionTapCount = 0;
  }
  _lastVersionTap = now;
  _versionTapCount++;

  if (_versionTapCount >= 5) {
    _versionTapCount = 0;
    GoRouter.of(context).push(RoutePaths.credits);
  }
}
```

GoRouter import가 없으면 추가.

- [ ] **Step 4: 빌드 확인**

Run: `flutter analyze`
Expected: 에러 없음

- [ ] **Step 5: 수동 테스트**

1. 설정 페이지 진입 → 앱 버전 영역 5회 빠르게 탭 → 크레딧 페이지 진입 확인
2. 3회 탭 후 3초 대기 → 다시 5회 탭 → 리셋 후 5회째에 진입 확인
3. 크레딧 페이지에서 카드 가로 스크롤 확인
4. 카드 탭 → Hero 애니메이션으로 상세 페이지 전환 확인
5. 소셜 링크 탭 → 외부 브라우저 열기 확인
6. 뒤로가기 → Hero 역방향 애니메이션 확인

- [ ] **Step 6: 커밋**

```bash
git add lib/features/settings/presentation/pages/settings_page.dart
git commit -m "feat : 설정 페이지 앱 버전 5탭 → 히든 크레딧 페이지 트리거 #238"
```
