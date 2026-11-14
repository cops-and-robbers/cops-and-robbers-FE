import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_mode.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/mode_select_step.dart';

/// 대기실 게임 설정 → 모드 변경 화면
///
/// 설정 수정·구역 수정처럼 전체 화면으로 들어온다. 고른 모드를 pop 값으로 돌려주고
/// 저장(경찰과 도둑이면 감옥 그리기부터)은 설정 페이지가 맡는다. 뒤로 가면 null.
/// 모드 카드가 라이트 전용이라 역할 테마와 무관하게 밝은 화면으로 둔다 (이전 바텀시트와 같음).
class ModeChangePage extends StatefulWidget {
  const ModeChangePage({super.key, required this.current});

  /// 방의 지금 모드 — 처음 선택값이며, 이 값 그대로면 버튼을 막는다
  final GameMode current;

  @override
  State<ModeChangePage> createState() => _ModeChangePageState();
}

class _ModeChangePageState extends State<ModeChangePage> {
  late GameMode _selected = widget.current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final changed = _selected != widget.current;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppTopBar(
        title: l10n.pageModeChangeTitle,
        isDarkMode: false,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: AppSpacing.vertical20),
          child: ModeSelectStep(
            selected: _selected,
            onSelected: (m) => setState(() => _selected = m),
            // 경찰과 도둑은 감옥을 그려야 끝나므로 "다음", 술래잡기는 바로 "저장"
            buttonText: _selected.usesJail ? l10n.buttonNext : l10n.buttonSave,
            onNext: changed ? () => context.pop(_selected) : null,
          ),
        ),
      ),
    );
  }
}
