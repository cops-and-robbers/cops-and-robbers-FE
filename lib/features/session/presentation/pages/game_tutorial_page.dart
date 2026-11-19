import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/storage/tutorial_prefs.dart';
import '../../../../core/widgets/tutorial/tutorial_player.dart';
import '../../../../core/widgets/tutorial/tutorial_script.dart';
import '../../../../l10n/app_localizations.dart';

/// 방에 들어왔을 때 보여 주는 게임 규칙 튜토리얼.
///
/// 대기방 위에 push 된다. 게임 시작·강퇴로 대기방이 context.go 하면 함께 사라진다.
/// 열리는 순간 본 것으로 저장한다. 처음 볼 때는 필수 규칙(축소까지)을 건너뛸 수 없고
/// 추가 기능(무전·좌표)부터 건너뛸 수 있다. 다시 볼 때는 처음부터 건너뛸 수 있다 (#719).
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
  late int _skipFrom = tutorialFirstExtraIndex(widget.mode);

  @override
  void initState() {
    super.initState();
    _enter();
  }

  Future<void> _enter() async {
    final seen = await TutorialPrefs.seen(widget.mode);
    await TutorialPrefs.markSeen(widget.mode);
    if (seen && mounted) setState(() => _skipFrom = 0);
  }

  @override
  Widget build(BuildContext context) {
    return TutorialPlayer(
      scenes: tutorialScenes(widget.mode),
      mode: widget.mode,
      copyOf: _copy,
      finishLabel: (l10n) => l10n.buttonConfirm,
      onFinished: () {
        if (context.canPop()) context.pop();
      },
      skipFrom: _skipFrom,
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
      TutorialScene.showQr =>
        isTag
            ? TutorialCopy(
                l10n.tutorialShowQrTitleTag,
                l10n.tutorialShowQrBodyTag,
              )
            : TutorialCopy(l10n.tutorialShowQrTitle, l10n.tutorialShowQrBody),
      TutorialScene.scan =>
        isTag
            ? TutorialCopy(l10n.tutorialScanTitleTag, l10n.tutorialScanBodyTag)
            : TutorialCopy(l10n.tutorialScanTitle, l10n.tutorialScanBody),
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
      // 튜토리얼은 역할을 모르고 열려 도둑도 본다. 문구로 "경찰만"을 알린다
      TutorialScene.radio => TutorialCopy(
        isTag ? l10n.tutorialRadioTitleTag : l10n.tutorialRadioTitle,
        l10n.tutorialRadioBody,
      ),
      TutorialScene.grid => TutorialCopy(
        l10n.tutorialGridTitle,
        l10n.tutorialGridBody,
      ),
      // 이미 방에 들어온 사람이 보는 화면이라 같이 할 사람을 구하는 안내는 하지 않는다
      TutorialScene.community => TutorialCopy(l10n.tutorialFinishTitle, ''),
      // 온보딩 전용 장면은 이 화면에 나오지 않는다
      _ => TutorialCopy(l10n.tutorialZoneTitle, l10n.tutorialZoneBody),
    };
  }
}
