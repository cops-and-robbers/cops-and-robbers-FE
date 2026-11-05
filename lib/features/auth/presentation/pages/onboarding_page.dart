import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/tutorial/tutorial_player.dart';
import '../../../../core/widgets/tutorial/tutorial_script.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';

/// 앱 소개 — 설치 후 최초 1회, 스플래시와 로그인 사이에 뜬다.
///
/// 노출 여부는 스플래시가 `OnboardingPrefs`로 판정해 노출 전에 기록한다.
/// 이 화면은 본 것으로 기록하지 않는다.
///
/// 로그인 전이라 어떤 게임 모드를 할지 모른다. 그래서 앱이 뭔지만 보여 주고,
/// 규칙은 방에 들어왔을 때 나오는 튜토리얼에 맡긴다.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  /// 온보딩을 닫는 유일한 경로.
  ///
  /// 들어온 길이 둘이라 나가는 길도 둘이다 —
  /// 마이페이지에서 다시 보기로 왔으면 그 위에 얹혀 있으니 되돌아가고,
  /// 설치 후 최초 1회로 온 경우엔 로그인으로 직행한다 — 스플래시가
  /// "로그인으로 간다"를 확정한 뒤에야 온보딩을 띄우므로 되돌아갈 절차가 없다.
  void _finish(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    return TutorialPlayer(
      scenes: onboardingScenes,
      copyOf: _copy,
      finishLabel: (l10n) => l10n.onboardingStartButton,
      onFinished: () => _finish(context),
    );
  }

  TutorialCopy _copy(AppLocalizations l10n, TutorialScene scene) =>
      switch (scene) {
        TutorialScene.zoneIn => TutorialCopy(
          l10n.onboardingRunTitle,
          l10n.onboardingRunBody,
        ),
        TutorialScene.pick => TutorialCopy(
          l10n.onboardingPickTitle,
          l10n.onboardingPickBody,
        ),
        TutorialScene.friends => TutorialCopy(
          l10n.onboardingFriendsTitle,
          l10n.onboardingFriendsBody,
        ),
        TutorialScene.guide => TutorialCopy(
          l10n.onboardingGuideTitle,
          l10n.onboardingGuideBody,
        ),
        TutorialScene.record => TutorialCopy(
          l10n.onboardingRecordTitle,
          l10n.onboardingRecordBody,
        ),
        _ => TutorialCopy(
          l10n.onboardingCommunityTitle,
          l10n.onboardingCommunityBody,
        ),
      };
}
