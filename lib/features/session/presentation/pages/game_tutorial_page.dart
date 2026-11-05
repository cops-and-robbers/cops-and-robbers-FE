import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/storage/tutorial_prefs.dart';
import '../../../../core/widgets/tutorial/tutorial_player.dart';
import '../../../../core/widgets/tutorial/tutorial_script.dart';
import '../../../../l10n/app_localizations.dart';

/// 방에 들어왔을 때 보여 주는 게임 규칙 튜토리얼.
///
/// 대기방 위에 push 된다. 게임 시작·강퇴로 대기방이 context.go 하면 함께 사라진다.
/// 열리는 순간 본 것으로 저장한다. 처음 볼 때는 건너뛸 수 없고 다시 볼 때부터 건너뛸 수 있다.
class GameTutorialPage extends StatefulWidget {
  const GameTutorialPage({
    required this.mode,
    this.tiltStream = deviceTiltStream,
    super.key,
  });

  final TutorialMode mode;
  final Stream<Offset> Function() tiltStream;

  @override
  State<GameTutorialPage> createState() => _GameTutorialPageState();
}

class _GameTutorialPageState extends State<GameTutorialPage> {
  bool _canSkip = false;

  @override
  void initState() {
    super.initState();
    _enter();
  }

  Future<void> _enter() async {
    final seen = await TutorialPrefs.seen(widget.mode);
    await TutorialPrefs.markSeen(widget.mode);
    if (seen && mounted) setState(() => _canSkip = true);
  }

  @override
  Widget build(BuildContext context) {
    return TutorialPlayer(
      scenes: tutorialScenes(widget.mode),
      copyOf: _copy,
      finishLabel: (l10n) => l10n.buttonConfirm,
      onFinished: () {
        if (context.canPop()) context.pop();
      },
      canSkip: _canSkip,
      tiltStream: widget.tiltStream,
    );
  }

  TutorialCopy _copy(AppLocalizations l10n, TutorialScene scene) {
    final isTag = widget.mode == TutorialMode.tag;
    return switch (scene) {
      TutorialScene.zoneIn => TutorialCopy(
        l10n.tutorialZoneTitle,
        l10n.tutorialZoneBody,
      ),
      TutorialScene.flat => TutorialCopy(
        l10n.tutorialMapTitle,
        isTag ? l10n.tutorialMapBodyTag : l10n.tutorialMapBodyClassic,
      ),
      TutorialScene.chase =>
        isTag
            ? TutorialCopy(
                l10n.tutorialChaseTitleTag,
                l10n.tutorialChaseBodyTag,
              )
            : TutorialCopy(
                l10n.tutorialChaseTitleClassic,
                l10n.tutorialChaseBodyClassic,
              ),
      TutorialScene.showQr => TutorialCopy(
        l10n.tutorialShowQrTitle,
        l10n.tutorialShowQrBody,
      ),
      TutorialScene.scan => TutorialCopy(
        l10n.tutorialScanTitle,
        l10n.tutorialScanBody,
      ),
      TutorialScene.jail => TutorialCopy(
        l10n.tutorialJailTitle,
        l10n.tutorialJailBody,
      ),
      TutorialScene.rescue => TutorialCopy(
        l10n.tutorialRescueTitle,
        l10n.tutorialRescueBody,
      ),
      TutorialScene.escape => TutorialCopy(
        l10n.tutorialEscapeTitle,
        l10n.tutorialEscapeBody,
      ),
      TutorialScene.out => TutorialCopy(
        l10n.tutorialOutTitle,
        l10n.tutorialOutBody,
      ),
      TutorialScene.shrink => TutorialCopy(
        l10n.tutorialShrinkTitle,
        isTag ? l10n.tutorialShrinkBodyTag : l10n.tutorialShrinkBodyClassic,
      ),
      // 이미 방에 들어온 사람이 보는 화면이라 같이 할 사람을 구하는 안내는 하지 않는다
      TutorialScene.community => TutorialCopy(l10n.tutorialFinishTitle, ''),
      // 온보딩 전용 장면은 이 화면에 나오지 않는다
      _ => TutorialCopy(l10n.tutorialZoneTitle, l10n.tutorialZoneBody),
    };
  }
}
