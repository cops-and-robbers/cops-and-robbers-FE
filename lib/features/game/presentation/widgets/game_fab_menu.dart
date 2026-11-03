import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
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
    this.toggled,
    this.onTap,
  });

  final String label;

  /// SVG 에셋 경로
  final String icon;

  /// 없으면 SVG 원래 색으로 그린다. 캐릭터 아이콘은 색을 입히지 않는다.
  final Color? iconColor;

  /// 좌표처럼 켜고 끄는 항목의 현재 상태. 스크린리더가 읽는다.
  final bool? toggled;

  /// 메뉴가 닫힌 뒤 실행한다.
  final VoidCallback? onTap;
}

/// 누르면 화면이 어두워지고 항목이 부채꼴로 펼쳐지는 플로팅 버튼 (#656)
class GameFabMenu extends StatelessWidget {
  const GameFabMenu({super.key, required this.items, required this.isDarkMode});

  final List<GameFabMenuItem> items;

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
      barrierColor: DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (dialogContext, animation, _) => _OpenMenu(
        items: items,
        center: center,
        animation: animation,
        isDarkMode: isDarkMode,
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
  });

  final List<GameFabMenuItem> items;
  final Offset center;
  final Animation<double> animation;
  final bool isDarkMode;

  /// 항목이 놓이는 호. 양 끝이 왼쪽·오른쪽 위를 향한다.
  static const double _startAngle = pi * 1.19;
  static const double _endAngle = pi * 1.81;

  @override
  Widget build(BuildContext context) {
    final radius = 150.w;
    final circleSize = 64.w;
    final count = items.length;

    return Stack(
      children: [
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
      child: Semantics(
        button: true,
        toggled: item.toggled,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            VibrationService.instance().buttonTap();
            Navigator.of(context).pop(item);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? AppColors.black : AppColors.white,
                  boxShadow: AppShadows.softThemed(isDarkMode),
                ),
                child: SvgPicture.asset(
                  item.icon,
                  width: 32.w,
                  height: 32.w,
                  colorFilter: item.iconColor == null
                      ? null
                      : ColorFilter.mode(item.iconColor!, BlendMode.srcIn),
                ),
              ),
              SizedBox(height: AppSpacing.vertical6),
              Material(
                type: MaterialType.transparency,
                child: Text(
                  item.label,
                  style:
                      (isDarkMode
                              ? AppTextStyles.robberParagraph
                              : AppTextStyles.paragraph14Semibold)
                          .copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
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
          color: isDarkMode ? AppColors.green : AppColors.blue,
          shape: BoxShape.circle,
          boxShadow: AppShadows.softThemed(isDarkMode),
        ),
        child: Transform.rotate(
          angle: angle,
          child: Icon(
            Icons.add,
            color: isDarkMode ? AppColors.black : AppColors.white,
            size: 32.w,
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
