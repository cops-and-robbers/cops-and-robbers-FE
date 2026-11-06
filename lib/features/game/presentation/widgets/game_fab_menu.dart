import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
import '../../../../l10n/app_localizations.dart';

/// 플로팅 메뉴에 펼쳐지는 항목
class GameFabMenuItem {
  const GameFabMenuItem({
    required this.label,
    required this.icon,
    this.iconColor,
    this.iconColorMapper,
    this.toggled,
    this.onTap,
  });

  final String label;

  /// SVG 에셋 경로
  final String icon;

  /// 없으면 SVG 원래 색으로 그린다. 캐릭터 아이콘은 색을 입히지 않는다.
  final Color? iconColor;

  /// 여러 색 아이콘의 원래 색을 하나씩 바꿔 그린다. [iconColor]와 같이 쓰지 않는다.
  final ColorMapper? iconColorMapper;

  /// 좌표처럼 켜고 끄는 항목의 현재 상태. 스크린리더가 읽는다.
  final bool? toggled;

  /// 메뉴가 닫힌 뒤 실행한다.
  final VoidCallback? onTap;
}

/// 누르면 화면이 어두워지고 항목이 부채꼴로 펼쳐지는 플로팅 버튼 (#656)
///
/// [stacksUp]이면 오른쪽 아래 버튼 위로 항목을 한 줄로 쌓는다(시작 장면, #674).
class GameFabMenu extends StatelessWidget {
  const GameFabMenu({
    super.key,
    required this.items,
    required this.isDarkMode,
    this.stacksUp = false,
  });

  /// 부채꼴은 왼쪽부터, [stacksUp]은 위에서부터 놓는 순서다.
  final List<GameFabMenuItem> items;

  /// 부채꼴은 가운데 기준이라 화면 가장자리 버튼에서 펼치면 항목이 화면 밖으로 나간다.
  final bool stacksUp;

  /// 도둑(다크) 화면 여부. 경찰은 파랑, 도둑은 초록을 쓴다.
  final bool isDarkMode;

  Future<void> _open(BuildContext context) async {
    // 열린 메뉴의 X 버튼을 플로팅 버튼과 정확히 겹치려고 현재 위치를 넘긴다.
    final box = context.findRenderObject()! as RenderBox;
    final center = box.localToGlobal(box.size.center(Offset.zero));

    final selected = await showGeneralDialog<GameFabMenuItem>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      // 장면은 순수 검정 20%만 덮는다(흐림은 끊겨 보여 뺐다, #674). 지도는 뛰는 중 핀이
      // 보여야 해 기존 배리어를 쓴다.
      barrierColor: stacksUp
          ? AppColors.pureBlack.withValues(alpha: 0.2)
          : DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (dialogContext, animation, _) => _OpenMenu(
        items: items,
        center: center,
        animation: animation,
        isDarkMode: isDarkMode,
        stacksUp: stacksUp,
      ),
    );
    selected?.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _RoundButton(
      angle: 0,
      isDarkMode: isDarkMode,
      semanticLabel: AppLocalizations.of(context).gameMenuOpen,
      onTap: () => _open(context),
    );
  }
}

class _OpenMenu extends StatelessWidget {
  const _OpenMenu({
    required this.items,
    required this.center,
    required this.animation,
    required this.isDarkMode,
    required this.stacksUp,
  });

  final List<GameFabMenuItem> items;
  final Offset center;
  final Animation<double> animation;
  final bool isDarkMode;
  final bool stacksUp;

  /// 항목이 놓이는 호. 양 끝이 왼쪽·오른쪽 위를 향한다.
  static const double _startAngle = pi * 1.19;
  static const double _endAngle = pi * 1.81;

  @override
  Widget build(BuildContext context) {
    // 원(48)이 예전(64)보다 작지만 라벨끼리 여유를 두려고 호를 덜 좁힌다
    final radius = 132.w;
    // 펼친 항목이 가운데 버튼(56)보다 작아야 위계가 맞는다 — 장면 메뉴와 같은 48
    final circleSize = _itemCircle;
    final count = items.length;

    return Stack(
      children: [
        if (stacksUp)
          for (var i = 0; i < count; i++)
            _buildStackedItem(
              context,
              item: items[i],
              // 버튼에 가까운 아래 항목부터 차례로 올라온다.
              rise:
                  _RoundButton.size / 2 +
                  _stackFirstGap +
                  _itemCircle / 2 +
                  (count - 1 - i) * (_itemCircle + _stackGap),
              curve: CurvedAnimation(
                parent: animation,
                curve: Interval(
                  0.15 * (count - 1 - i) / count,
                  0.85 + 0.15 * (count - 1 - i) / count,
                  curve: Curves.easeOutBack,
                ),
                reverseCurve: Curves.easeIn,
              ),
            )
        else
          for (var i = 0; i < count; i++)
            _buildItem(
              context,
              item: items[i],
              target: Offset.fromDirection(
                count == 1
                    ? pi * 1.5
                    : _startAngle + (_endAngle - _startAngle) * i / (count - 1),
                radius,
              ),
              circleSize: circleSize,
              // 왼쪽 항목부터 차례로 펼쳐진다.
              curve: CurvedAnimation(
                parent: animation,
                curve: Interval(
                  0.15 * i / count,
                  0.85 + 0.15 * i / count,
                  curve: Curves.easeOutBack,
                ),
                reverseCurve: Curves.easeIn,
              ),
            ),
        Positioned(
          left: center.dx - _RoundButton.size / 2,
          top: center.dy - _RoundButton.size / 2,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) => _RoundButton(
              angle: animation.value * pi / 4,
              isDarkMode: isDarkMode,
              semanticLabel: AppLocalizations.of(context).gameMenuClose,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ],
    );
  }

  /// 시안: 항목 원 48 · 아이콘 24 — 장면(위로 쌓기)과 지도(부채꼴)가 같다
  static double get _itemCircle => 48.w;
  static double get _itemIcon => 24.w;

  /// 시안: 버튼과 첫 항목 사이 16, 항목끼리 8
  static double get _stackFirstGap => 16.w;
  static double get _stackGap => 8.w;

  /// 위로 쌓는 항목. 원은 버튼과 같은 세로줄에, 라벨은 원 왼쪽에 둔다.
  Widget _buildStackedItem(
    BuildContext context, {
    required GameFabMenuItem item,
    required double rise,
    required Animation<double> curve,
  }) {
    final right =
        MediaQuery.sizeOf(context).width - center.dx - _itemCircle / 2;
    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) => Positioned(
        right: right,
        top: center.dy - rise * curve.value - _itemCircle / 2,
        child: Opacity(opacity: curve.value.clamp(0.0, 1.0), child: child),
      ),
      child: _tapTarget(
        context,
        item,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _label(item),
            SizedBox(width: AppSpacing.horizontal8),
            _circle(item, _itemCircle, _itemIcon),
          ],
        ),
      ),
    );
  }

  Widget _tapTarget(BuildContext context, GameFabMenuItem item, Widget child) =>
      Semantics(
        button: true,
        toggled: item.toggled,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            VibrationService.instance().buttonTap();
            Navigator.of(context).pop(item);
          },
          child: child,
        ),
      );

  Widget _circle(GameFabMenuItem item, double size, double iconSize) =>
      Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode ? AppColors.black : AppColors.white,
          // 피그마 `shadow`: 두 팀·장면·지도 모두 검정 10%
          boxShadow: AppShadows.soft,
        ),
        child: SvgPicture(
          SvgAssetLoader(item.icon, colorMapper: item.iconColorMapper),
          width: iconSize,
          height: iconSize,
          colorFilter: item.iconColor == null
              ? null
              : ColorFilter.mode(item.iconColor!, BlendMode.srcIn),
        ),
      );

  Widget _label(GameFabMenuItem item) => Material(
    type: MaterialType.transparency,
    child: Text(
      item.label,
      style:
          (isDarkMode
                  ? AppTextStyles.robberParagraph
                  : AppTextStyles.paragraph14Semibold)
              .copyWith(color: AppColors.white),
    ),
  );

  Widget _buildItem(
    BuildContext context, {
    required GameFabMenuItem item,
    required Offset target,
    required double circleSize,
    required Animation<double> curve,
  }) {
    final width = 88.w;
    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) {
        final position = center + target * curve.value;
        return Positioned(
          left: position.dx - width / 2,
          top: position.dy - circleSize / 2,
          width: width,
          child: Opacity(
            opacity: curve.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: curve.value.clamp(0.0, 1.2),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
      child: _tapTarget(
        context,
        item,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _circle(item, circleSize, _itemIcon),
            SizedBox(height: AppSpacing.vertical6),
            _label(item),
          ],
        ),
      ),
    );
  }
}

/// 플로팅 버튼. 위치·채팅 버튼과 구분되도록 원형이고, 안쪽 아이콘만 돌아 X가 된다.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.angle,
    required this.isDarkMode,
    required this.semanticLabel,
    required this.onTap,
  });

  /// 게임 화면 좌우 버튼(SvgIconButton)과 같은 크기
  static double get size => 56.w;

  final double angle;
  final bool isDarkMode;

  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: () {
        VibrationService.instance().buttonTap();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          // 도둑(다크)은 검정 원에 초록 +, 경찰은 파란 원에 흰 + (#674 시안)
          color: isDarkMode ? AppColors.black : AppColors.blue,
          shape: BoxShape.circle,
          boxShadow: AppShadows.soft,
        ),
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: angle,
          child: SvgPicture.asset(
            AppIcons.plus,
            width: 24.w,
            height: 24.w,
            colorFilter: ColorFilter.mode(
              isDarkMode ? AppColors.green : AppColors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(child: button),
    );
  }
}
