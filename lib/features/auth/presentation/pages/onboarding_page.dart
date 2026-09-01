import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../router/route_paths.dart';
import '../../../../core/utils/url_launcher_util.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../l10n/app_localizations.dart';

/// 앱 소개 — 설치 후 최초 1회, 스플래시와 로그인 사이에 뜬다.
///
/// 노출 여부는 스플래시가 `OnboardingPrefs`로 판정하고, 이 화면은 본 것으로
/// 기록하지 않는다 — 완료·건너뛰기·뒤로가기 어느 경로로 닫히든 스플래시가
/// `push` 복귀 시점에 한 번만 기록한다.
///
/// 화면별 조작 안내를 하지 않는다. 로그인 이전이라 보는 사람에게는 계정도
/// 방도 없고, 그 사람의 질문은 "이게 뭐고 나 혼자인데 되나" 둘뿐이다.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  /// 마지막 장에서 두 번째 버튼이 드러나는 전체 시간
  static const _buttonRevealDuration = Duration(milliseconds: 420);

  /// 그 시간을 자리 열기 / 버튼 드러내기로 가르는 지점.
  /// 앞 55%는 높이만 열고, 나머지 45%에 버튼이 나타난다.
  static const _revealSplit = 0.55;

  /// 마지막 장에 도착하고 두 번째 버튼이 나오기까지 기다리는 시간.
  ///
  /// 넘기자마자 버튼이 하나 더 생기면 방금 누른 자리가 움직여서 이질감이 든다.
  /// 화면이 멈춘 걸 본 뒤에 조용히 하나가 더 생기게 한다.
  static const _secondaryButtonDelay = Duration(milliseconds: 550);

  final _controller = PageController();
  int _index = 0;

  /// 두 번째 버튼을 드러낼지. 마지막 장 도착 후 [_secondaryButtonDelay] 뒤에 켠다.
  bool _showSecondaryButton = false;
  Timer? _revealTimer;

  @override
  void dispose() {
    _revealTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// 장이 바뀔 때마다 두 번째 버튼의 예약을 다시 잡는다.
  ///
  /// 마지막 장에서 되돌아가면 예약을 취소한다 — 그러지 않으면 이미 떠난
  /// 장의 타이머가 뒤늦게 터져 엉뚱한 장에서 버튼이 뜬다.
  void _onPageChanged(int index, int lastIndex) {
    setState(() => _index = index);
    _revealTimer?.cancel();

    if (index != lastIndex) {
      if (_showSecondaryButton) {
        setState(() => _showSecondaryButton = false);
      }
      return;
    }
    _revealTimer = Timer(_secondaryButtonDelay, () {
      if (mounted) setState(() => _showSecondaryButton = true);
    });
  }

  /// 온보딩을 닫는 유일한 경로.
  ///
  /// 들어온 길이 둘이라 나가는 길도 둘이다 —
  /// 마이페이지에서 다시 보기로 왔으면 그 위에 얹혀 있으니 되돌아가고,
  /// 설치 후 최초 1회로 스플래시가 위치를 옮겨 보낸 경우엔 밑에 아무것도
  /// 없으니 스플래시로 돌려보내 원래 절차(딥링크·인증·활성 게임)를 잇는다.
  void _finish() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(RoutePaths.splash);
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
                          onPressed: isLast ? null : _finish,
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
                onPageChanged: (i) => _onPageChanged(i, slides.length - 1),
                itemBuilder: (context, i) => _buildSlide(slides[i]),
              ),
            ),

            Padding(
              padding: AppPadding.horizontal20,
              child: Column(
                children: [
                  AppButton(
                    text: isLast ? l10n.onboardingGuideButton : l10n.buttonNext,
                    onPressed: isLast
                        ? _openGameGuide
                        : () => _next(slides.length - 1),
                  ),
                  // 마지막 장에서만 두 번째 버튼이 생긴다. 자리를 여는 것과
                  // 버튼이 나타나는 것을 동시에 하면 툭 끼어드는 것처럼 보여서
                  // 순서를 나눈다 — 앞 구간에 높이가 열리며 위 내용이 밀려
                  // 올라가고, 자리가 다 잡힌 뒤에 버튼이 서서히 드러난다.
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _showSecondaryButton ? 1 : 0),
                    duration: _buttonRevealDuration,
                    builder: (context, t, child) {
                      final open = Curves.easeOut.transform(
                        (t / _revealSplit).clamp(0.0, 1.0),
                      );
                      final fade = ((t - _revealSplit) / (1 - _revealSplit))
                          .clamp(0.0, 1.0);
                      return ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: open,
                          child: Opacity(opacity: fade, child: child),
                        ),
                      );
                    },
                    child: _showSecondaryButton
                        ? Padding(
                            padding: EdgeInsets.only(top: AppSpacing.vertical8),
                            child: AppButton(
                              text: l10n.onboardingEnterButton,
                              onPressed: _finish,
                              showBorder: true,
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.blue,
                              borderColor: AppColors.blue,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.vertical20),
          ],
        ),
      ),
    );
  }

  /// 사이트의 게임 소개 페이지를 외부 브라우저로 연다.
  ///
  /// 앱 안에 같은 분량을 다시 만들지 않는다 — 규칙·FAQ 정본은 사이트에 있고,
  /// 거기서 고치면 앱 배포 없이 반영된다.
  Future<void> _openGameGuide() async {
    final language = Localizations.localeOf(context).languageCode;
    await launchExternalUrl(AppUrls.gameGuide(language));
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
