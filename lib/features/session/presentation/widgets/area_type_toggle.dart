import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../game/data/models/game_area_model.dart';

/// 구역 설정 방식 토글 (거리로 설정 = 원형 / 핀으로 설정 = 폴리곤)
///
/// 선택 pill이 좌우로 이동할 때 물방울처럼 늘어났다 뭉치는 squash-stretch로
/// 다이나믹하게 전환한다. 늘어남을 위치 진행도(공간 중앙에서 최대)에 묶어,
/// 시간 커브(easeOut)와 무관하게 항상 "이동 중 늘어남"으로 읽힌다.
///
/// 타이밍은 Doherty 임계값(400ms) 안쪽의 300ms + 시작 빠른 easeOut으로 잡아
/// 반응성을 확보하되, squash-stretch가 읽힐 최소 시간은 확보한다. 선택 변경 시
/// 가장 약한 selectionClick 햅틱으로 시각·촉각을 교차 강화한다.
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
  static const double _stretchX = 0.34;
  static const double _squashY = 0.14;

  static double _targetX(GameAreaType type) =>
      type == GameAreaType.circle ? -1.0 : 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

  /// 위치 진행도 (시작 빠른 easeOut — 탭 직후 즉시 움직여 반응성 확보)
  double get _progress => Curves.easeOutCubic.transform(_controller.value);

  /// 현재 프레임의 pill x
  double get _currentX => _fromX + (_toX - _fromX) * _progress;

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
            // 물방울 pill — 공간 중앙에서 가장 늘어났다 도착 시 뭉침
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final p = _progress;
                // 늘어남 벨커브를 위치 진행도에 묶음 (공간 중앙=최대, 양끝=0)
                final stretch = math.sin(math.pi * p);
                return Align(
                  alignment: Alignment(_fromX + (_toX - _fromX) * p, 0),
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
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (isSelected) return;
            // 실제 변경 시에만 앱 공통 탭 햅틱 — AppButton과 동일(일관성)
            VibrationService.instance().buttonTap();
            widget.onChanged(type);
          },
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              style: AppTextStyles.paragraph_14.copyWith(
                color: isSelected ? AppColors.black800 : AppColors.black400,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
