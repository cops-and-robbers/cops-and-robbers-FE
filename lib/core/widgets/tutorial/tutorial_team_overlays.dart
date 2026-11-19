import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_shadows.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import 'tutorial_camera.dart';
import 'tutorial_script.dart';
import 'tutorial_stage.dart';

/// 무전·좌표 장면(#719)의 앱 화면 표시. 무대 좌표(393×486)로 그린다.
///
/// 무대는 화면에 맞춰 통째로 늘어나므로 `.w`를 쓰는 실제 위젯 대신 같은 값으로 따라 그린다
/// (QR 체포 장면의 플로팅 메뉴와 같은 방식).
abstract final class TutorialTeamOverlays {
  /// 지도 화면 플로팅 버튼의 중심. QR 체포 장면의 + 버튼과 같은 자리다.
  static const Offset fabCenter = Offset(196.5, 438);

  static final List<String> svgAssets = [
    AppIcons.mic,
    AppIcons.plus,
    AppIcons.grid,
    AppIcons.headcount,
    AppIcons.comment,
    AppIcons.qrScan,
    _pingFoundSelect,
    _pingSuspectSelect,
    _pingPin,
    _pingFoundMarker,
    _policeIcon,
  ];

  static final String _pingFoundSelect = AppIcons.pingSelect(
    type: 'found',
    isDark: false,
  );
  static final String _pingSuspectSelect = AppIcons.pingSelect(
    type: 'suspect',
    isDark: false,
  );
  static final String _pingPin = AppIcons.pingPin(isDark: false);
  static final String _pingFoundMarker = AppIcons.pingMarker(
    type: 'found',
    isDark: false,
  );
  static final String _policeIcon = AppIcons.role(
    isPolice: true,
    isDark: false,
  );

  /// 좌표 격자 — 메뉴 아래(어두운 막 아래)에 깔린다.
  static List<Widget> belowMenu(TutorialStage stage) => [
    if (stage.view['grid'] > 0)
      Positioned.fill(
        child: Opacity(
          opacity: stage.view['grid'].clamp(0.0, 1.0),
          child: CustomPaint(painter: _GridPainter(stage)),
        ),
      ),
    if (stage.q['ping'] > 0) _pingMarker(stage),
  ];

  /// 펼친 메뉴 항목과 무전·핑 카드·채팅 미리보기 — 어두운 막 위에 그린다.
  static List<Widget> aboveMenu(TutorialStage stage, AppLocalizations l10n) {
    final q = stage.q;
    return [
      if (q['gmenu'] > 0) ..._menuItems(stage, l10n),
      if (q['radio'] > 0) _radioButton(stage),
      if (q['pill'] > 0) _radioPill(stage, l10n),
      if (q['pcard'] > 0) _pingCard(stage, l10n),
      if (q['chat'] > 0) _chatPreview(stage, l10n),
    ];
  }

  // 게임 화면 무전 버튼(RadioPttButton)과 같은 모습 — 오른쪽 아래, 누르면 파랗게 차고 커진다
  static Widget _radioButton(TutorialStage stage) {
    final q = stage.q;
    final press = q['ptt'].clamp(0.0, 1.0);
    final icon = q['lock'] > .5
        ? AppColors.black200
        : Color.lerp(AppColors.blue, AppColors.white, press)!;
    return Positioned(
      left: tutorialStageWidth - 20 - 56,
      top: tutorialStageHeight - 20 - 56,
      child: Opacity(
        opacity: q['radio'].clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 1 + .08 * press,
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color.lerp(AppColors.white, AppColors.blue, press),
              borderRadius: AppRadius.xlarge,
              boxShadow: AppShadows.softThemed(false),
            ),
            child: SvgPicture.asset(
              AppIcons.mic,
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(icon, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }

  // 게임 화면 "OO 무전 중" 알약(RadioSpeakerPill)과 같은 모습 — 무전 버튼 바로 위
  static Widget _radioPill(TutorialStage stage, AppLocalizations l10n) =>
      Positioned(
        right: 20,
        bottom: 20 + 56 + 8,
        child: Opacity(
          opacity: stage.q['pill'].clamp(0.0, 1.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: AppRadius.pill,
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                SvgPicture.asset(
                  AppIcons.mic,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.radioSpeaking(l10n.tutorialRadioSampleName),
                  style: AppTextStyles.paragraph14Semibold.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // 경찰이 무전을 켠 지도 메뉴(gameMenuEntries): 좌표, 참가자, 체포, 채팅.
  // GameFabMenu처럼 반지름 132의 호(1.19π~1.81π)에 펼친다.
  static List<Widget> _menuItems(TutorialStage stage, AppLocalizations l10n) {
    final items = [
      (l10n.gameMenuGrid, AppIcons.grid, true),
      (l10n.gameMenuParticipants, AppIcons.headcount, false),
      (
        stage.tag ? l10n.gameMenuArrestTag : l10n.gameMenuArrest,
        AppIcons.qrScan,
        false,
      ),
      (l10n.gameChatTitle, AppIcons.comment, false),
    ];
    final open = stage.q['gmenu'].clamp(0.0, 1.0);
    final press = stage.q['gpress'].clamp(0.0, 1.0);
    return [
      for (final (i, (label, icon, isGrid)) in items.indexed)
        _menuItem(
          center:
              fabCenter +
              Offset.fromDirection(
                math.pi * (1.19 + .62 * i / (items.length - 1)),
                132 * open,
              ),
          opacity: open,
          label: label,
          icon: icon,
          press: isGrid ? press : 0,
        ),
    ];
  }

  static Widget _menuItem({
    required Offset center,
    required double opacity,
    required String label,
    required String icon,
    required double press,
  }) => Positioned(
    left: center.dx - 44,
    top: center.dy - 24,
    width: 88,
    child: Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 눌리면 QR 체포 장면의 내 QR처럼 살짝 작아지고 팀 색으로 찬다
          Transform.scale(
            scale: 1 - .1 * press,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(AppColors.white, AppColors.blue, press),
                boxShadow: AppShadows.soft,
              ),
              child: SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                // 참가자 아이콘은 두 색이라 원래 색으로 그린다
                colorFilter: icon == AppIcons.headcount
                    ? null
                    : ColorFilter.mode(
                        Color.lerp(AppColors.blue, AppColors.white, press)!,
                        BlendMode.srcIn,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.paragraph14Semibold.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    ),
  );

  // 게임 화면 핑 선택 카드(PingSelectionCard)와 같은 모습 — 핀 끝이 길게 누른 자리에 온다
  static Widget _pingCard(TutorialStage stage, AppLocalizations l10n) {
    final at = tutorialPingPoint(stage);
    Widget cell(String icon, String label) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(icon, width: 24, height: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.tag_12.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
    return Positioned(
      left: at.dx - 100,
      width: 200,
      bottom: tutorialStageHeight - at.dy,
      child: Opacity(
        opacity: stage.q['pcard'].clamp(0.0, 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: AppRadius.medium,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  cell(_pingFoundSelect, l10n.pingFound),
                  Container(
                    width: 2,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.blue800,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  cell(_pingSuspectSelect, l10n.pingSuspect),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SvgPicture.asset(_pingPin, width: 20, height: 32),
          ],
        ),
      ),
    );
  }

  static Widget _pingMarker(TutorialStage stage) {
    final at = tutorialPingPoint(stage);
    return Positioned(
      left: at.dx - 12,
      top: at.dy - 12,
      child: Opacity(
        opacity: stage.q['ping'].clamp(0.0, 1.0),
        child: SvgPicture.asset(_pingFoundMarker, width: 24, height: 24),
      ),
    );
  }

  // 게임 화면 채팅 미리보기(ChatPreviewCard)와 같은 모습 — 플로팅 버튼 위 오른쪽
  static Widget _chatPreview(TutorialStage stage, AppLocalizations l10n) {
    // 핑 문장은 실제 자동 채팅 문구 그대로다. 가운데 칸이 C3다
    final message = stage.tag
        ? l10n.pingChatFoundRobberTag(_GridPainter.centerLabel)
        : l10n.pingChatFoundRobber(_GridPainter.centerLabel);
    return Positioned(
      right: 20,
      bottom: tutorialStageHeight - (fabCenter.dy - 28) + 8,
      child: Opacity(
        opacity: stage.q['chat'].clamp(0.0, 1.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(_policeIcon, width: 12, height: 12),
                  const SizedBox(width: 4),
                  Text(
                    l10n.tutorialRadioSampleName,
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.black600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '· ${l10n.chatPreviewTagTeam}',
                    style: AppTextStyles.tag_12.copyWith(color: AppColors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 구역을 덮는 5×5 좌표 격자. 게임 화면처럼 칸 가운데에 이름을 쓴다(A~E 열, 1~5 행).
///
/// 게임은 지도 북쪽 기준이지만 튜토리얼 지도는 돌아가 있어, 읽기 쉽게 화면 기준으로 놓는다.
class _GridPainter extends CustomPainter {
  _GridPainter(this.stage);

  final TutorialStage stage;

  static const int _cells = 5;
  static const String _columns = 'ABCDE';
  static const String centerLabel = 'C3';

  @override
  void paint(Canvas canvas, Size size) {
    final frame = stage.cameraFrame();
    final view = stage.view;
    final c = frame.project(view['px'], view['py']);
    final edge = frame.project(view['px'] + view['play'], view['py']);
    final radius = (Offset(edge.x, edge.y) - Offset(c.x, c.y)).distance;
    final cell = radius * 2 / _cells;
    final left = c.x - radius;
    final top = c.y - radius;

    final line = Paint()
      ..color = AppColors.black400
      ..strokeWidth = 1;
    for (var i = 0; i <= _cells; i++) {
      canvas
        ..drawLine(
          Offset(left + i * cell, top),
          Offset(left + i * cell, top + radius * 2),
          line,
        )
        ..drawLine(
          Offset(left, top + i * cell),
          Offset(left + radius * 2, top + i * cell),
          line,
        );
    }

    // GridLabelMarkerFactory처럼 흰 테두리를 두른 진회색 글자
    final style = AppTextStyles.tag12Semibold;
    for (var col = 0; col < _cells; col++) {
      for (var row = 0; row < _cells; row++) {
        final label = '${_columns[col]}${row + 1}';
        final center = Offset(
          left + (col + .5) * cell,
          top + (row + .5) * cell,
        );
        for (final s in [
          style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = AppColors.white,
          ),
          style.copyWith(color: AppColors.black700),
        ]) {
          final text = TextPainter(
            text: TextSpan(text: label, style: s),
            textDirection: TextDirection.ltr,
          )..layout();
          text.paint(canvas, center - Offset(text.width / 2, text.height / 2));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => true;
}
