import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../router/route_paths.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../l10n/app_localizations.dart';

/// 앱 소개 — 설치 후 최초 1회, 스플래시와 로그인 사이에 뜬다.
///
/// 노출 여부는 스플래시가 `OnboardingPrefs`로 판정해 노출 전에 기록한다.
/// 이 화면은 본 것으로 기록하지 않는다.
///
/// 화면별 조작 안내를 하지 않는다. 로그인 이전이라 보는 사람에게는 계정도
/// 방도 없고, 그 사람의 질문은 "이게 뭐고 나 혼자인데 되나" 둘뿐이다.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 온보딩을 닫는 유일한 경로.
  ///
  /// 들어온 길이 둘이라 나가는 길도 둘이다 —
  /// 마이페이지에서 다시 보기로 왔으면 그 위에 얹혀 있으니 되돌아가고,
  /// 설치 후 최초 1회로 온 경우엔 로그인으로 직행한다 — 스플래시가
  /// "로그인으로 간다"를 확정한 뒤에야 온보딩을 띄우므로 되돌아갈 절차가 없다.
  void _finish() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(RoutePaths.login);
  }

  void _next(int lastIndex) {
    if (_index >= lastIndex) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = _slides(l10n);
    final isLast = _index == slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 진행 표시는 상단 — 첫 프레임부터 "네 장 중 몇 번째"가 보여야
            // 사용자가 얼마나 남았는지 알고 넘긴다.
            //
            // 건너뛰기는 항상 자리를 지킨다 — 마지막 장에서 사라지면 같은 줄의
            // 진행 표시가 밀려 보인다. 마지막 장에서는 투명 처리만 한다.
            Padding(
              padding: AppPadding.horizontal20,
              child: Row(
                children: [
                  // 좌우를 같은 폭(flex 1)으로 나눠 진행 표시를 정가운데에 둔다.
                  // 건너뛰기 폭이 변해도 가운데가 흔들리지 않는다.
                  const Spacer(),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: slides.length,
                    effect: ExpandingDotsEffect(
                      dotWidth: 8.w,
                      dotHeight: 8.w,
                      expansionFactor: 3,
                      spacing: 6.w,
                      dotColor: AppColors.black200,
                      activeDotColor: AppColors.blue,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: isLast ? 0 : 1,
                        child: TextButton(
                          // 같은 화면의 다음/시작(AppButton)은 햅틱 내장 —
                          // raw TextButton이라 직접 준다.
                          onPressed: isLast
                              ? null
                              : () {
                                  VibrationService.instance().buttonTap();
                                  _finish();
                                },
                          child: Text(
                            l10n.buttonSkip,
                            style: AppTextStyles.paragraph_14.copyWith(
                              color: AppColors.black500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _buildSlide(slides[i]),
              ),
            ),

            Padding(
              padding: AppPadding.horizontal20,
              child: AppButton(
                text: isLast ? l10n.onboardingStartButton : l10n.buttonNext,
                onPressed: () => _next(slides.length - 1),
              ),
            ),
            SizedBox(height: AppSpacing.vertical20),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_OnboardingSlide slide) {
    return Padding(
      padding: AppPadding.horizontal20,
      child: Column(
        children: [
          Expanded(child: Center(child: _illustration(slide))),
          Text(
            slide.title,
            style: AppTextStyles.heading_24,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.vertical12),
          Text(
            slide.body,
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.vertical32),
        ],
      ),
    );
  }

  /// 장별 일러스트.
  ///
  /// 대부분 한 장이고, 경찰이 도둑을 뒤쫓는 장만 두 장으로 온다.
  ///
  /// 폭을 장마다 따로 준다 — 원본 치수가 140부터 337까지 벌어져 있어
  /// 한 기준으로 그리면 어떤 장은 점처럼 작고 어떤 장은 화면을 꽉 채운다.
  /// 그림끼리의 크기 균형은 원본 치수가 아니라 화면에서 정한다.
  Widget _illustration(_OnboardingSlide slide) {
    return SizedBox(
      width: slide.illustrationWidth.w,
      child: FittedBox(
        fit: BoxFit.contain,
        child: slide.assets.length == 1
            ? SvgPicture.asset(slide.assets.single)
            : Row(
                // 두 그림의 높이가 달라 가운데 정렬이면 발끝이 어긋난다.
                // 바닥선을 맞춰 같은 땅에서 쫓고 쫓기게 한다.
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SvgPicture.asset(slide.assets.first),
                  SizedBox(width: AppSpacing.horizontal16),
                  SvgPicture.asset(slide.assets.last),
                ],
              ),
      ),
    );
  }

  List<_OnboardingSlide> _slides(AppLocalizations l10n) => [
    _OnboardingSlide(
      title: l10n.onboardingOutdoorTitle,
      body: l10n.onboardingOutdoorBody,
      assets: const ['assets/onboarding/onboarding1.svg'],
      illustrationWidth: 260,
    ),
    _OnboardingSlide(
      title: l10n.onboardingWinTitle,
      body: l10n.onboardingWinBody,
      // 경찰(2_1)이 도둑(2_2)을 뒤쫓는 구도라 쫓는 쪽을 왼쪽에 둔다.
      assets: const [
        'assets/onboarding/onboarding2_1.svg',
        'assets/onboarding/onboarding2_2.svg',
      ],
      illustrationWidth: 280,
    ),
    _OnboardingSlide(
      title: l10n.onboardingRefereeTitle,
      body: l10n.onboardingRefereeBody,
      assets: const ['assets/onboarding/onboarding3.svg'],
      illustrationWidth: 220,
    ),
    _OnboardingSlide(
      title: l10n.onboardingCommunityTitle,
      body: l10n.onboardingCommunityBody,
      assets: const ['assets/onboarding/onboarding4.svg'],
      illustrationWidth: 255,
    ),
  ];
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.body,
    required this.assets,
    required this.illustrationWidth,
  });

  final String title;
  final String body;

  /// 이 장의 일러스트. 대부분 한 장이고, 쫓고 쫓기는 장만 두 장이다.
  final List<String> assets;

  /// 화면에 그릴 목표 폭(논리 px). 원본 치수와 무관하게 여기로 맞춘다.
  final double illustrationWidth;
}
