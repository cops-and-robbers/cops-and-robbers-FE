import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../game/data/models/game_area_model.dart';

/// 구역 설정 방식 토글 (거리로 설정 = 원형 / 핀으로 설정 = 폴리곤)
///
/// 선택 pill이 좌우로 이동할 때 물방울처럼 늘어났다 뭉치는 squash-stretch로
/// 다이나믹하게 전환한다. 이동 중 pill이 가로로 넓어지며(세로 수축) 도착하면
/// 원래 캡슐로 되돌아온다. 위치는 easeInOutCubic, 늘어남은 sin 벨커브(양끝 0·
/// 중앙 최대)라 정지 상태에선 왜곡이 없다. ClipRRect로 늘어난 pill이 캡슐 안에서
/// 뭉치도록(gooey) 클립한다.
///
/// 디자인 스펙: w350×h40, radius 38(pill), 배경 black100, 선택 세그먼트는
/// 내부 5 인셋의 white pill.
class AreaTypeToggle extends StatefulWidget {
  const AreaTypeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final GameAreaType selected;
  final ValueChanged<GameAreaType> onChanged;

  @override
  State<AreaTypeToggle> createState() => _AreaTypeToggleState();
}

class _AreaTypeToggleState extends State<AreaTypeToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// pill 가로 위치 (-1 = 왼쪽 슬롯, 1 = 오른쪽 슬롯)
  late double _fromX;
  late double _toX;

  /// 이동 중 최대 늘어남/수축 비율
  static const double _stretchX = 0.30;
  static const double _squashY = 0.12;

  static double _targetX(GameAreaType type) =>
      type == GameAreaType.circle ? -1.0 : 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
      value: 1, // 초기엔 정지 상태(도착 완료)
    );
    _fromX = _toX = _targetX(widget.selected);
  }

  @override
  void didUpdateWidget(covariant AreaTypeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      // 현재 애니메이션 위치에서 새 목표로 이어서 이동 (연타 대응)
      _fromX = _currentX;
      _toX = _targetX(widget.selected);
      _controller.forward(from: 0);
    }
  }

  /// 현재 프레임의 pill x (easeInOutCubic 보간)
  double get _currentX {
    final t = Curves.easeInOutCubic.transform(_controller.value);
    return _fromX + (_toX - _fromX) * t;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: 350.w,
      height: 40.h,
      // 선택 pill 인셋 5 (디자인 스펙 — AppSpacing에 5 없음, ScreenUtil 직접 사용)
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: AppColors.black100,
        borderRadius: AppRadius.pill,
      ),
      child: ClipRRect(
        // 늘어난 pill이 캡슐 경계 안에서 뭉치도록 내부 클립
        borderRadius: AppRadius.pill,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 물방울 pill — 이동하며 늘어났다 도착 시 뭉침
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                // 이동 중 늘어남 벨커브 (양끝 0, 중앙 1) — 정지 시 왜곡 0
                final stretch = math.sin(math.pi * _controller.value);
                return Align(
                  alignment: Alignment(_currentX, 0),
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    heightFactor: 1,
                    child: Transform.scale(
                      scaleX: 1 + _stretchX * stretch,
                      scaleY: 1 - _squashY * stretch,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppRadius.pill,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // 라벨 (pill 위에 겹침 — 탭 처리도 여기서)
            Row(
              children: [
                _buildSegment(l10n.areaTypeSetByDistance, GameAreaType.circle),
                _buildSegment(l10n.areaTypeSetByPin, GameAreaType.polygon),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(String label, GameAreaType type) {
    final isSelected = widget.selected == type;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isSelected) widget.onChanged(type);
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: AppTextStyles.paragraph_14.copyWith(
              color: isSelected ? AppColors.black800 : AppColors.black400,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
