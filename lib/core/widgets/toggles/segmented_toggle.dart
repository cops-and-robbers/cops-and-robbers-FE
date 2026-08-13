import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../services/vibration_service.dart';

/// 세그먼트 인덱스 → 선택 pill의 [Alignment] x 좌표 (-1 = 왼쪽 끝, 1 = 오른쪽 끝).
///
/// 세그먼트가 하나뿐이면 분모(count-1)가 0이 되므로 중앙을 돌려준다.
double segmentAlignmentX(int index, int count) =>
    count <= 1 ? 0 : -1.0 + 2.0 * index / (count - 1);

/// N개 세그먼트 pill 토글
///
/// 선택 pill이 좌우로 이동할 때 물방울처럼 늘어났다 뭉치는 squash-stretch로
/// 다이나믹하게 전환한다. 늘어남을 위치 진행도(공간 중앙에서 최대)에 묶어,
/// 시간 커브(easeOut)와 무관하게 항상 "이동 중 늘어남"으로 읽힌다.
///
/// 타이밍은 Doherty 임계값(400ms) 안쪽의 300ms + 시작 빠른 easeOut으로 잡아
/// 반응성을 확보하되, squash-stretch가 읽힐 최소 시간은 확보한다. 선택 변경 시
/// 앱 공통 탭 햅틱으로 시각·촉각을 교차 강화한다.
///
/// 디자인 스펙: h40, pill radius, 트랙 배경 black100(다크 black800),
/// 선택 세그먼트는 내부 5 인셋의 white pill.
///
/// [isDarkMode]는 다크 배경 위에 얹힐 때의 분기다. 트랙을 라이트 그대로 두면
/// white pill과 대비가 1.09:1 밖에 안 나와 선택 위치가 읽히지 않는다.
class SegmentedToggle extends StatefulWidget {
  // labels.isNotEmpty가 상수 표현식이 아니라 assert가 있는 한 const 생성자로 둘 수 없다
  // (기존 호출부도 const SegmentedToggle(...)을 쓰지 않는다).
  SegmentedToggle({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.width,
    this.isDarkMode = false,
  }) : assert(labels.isNotEmpty, 'SegmentedToggle needs at least one segment');

  /// 세그먼트 라벨 — 이미 로컬라이즈된 문자열을 받는다.
  final List<String> labels;

  final int selectedIndex;

  /// 선택이 실제로 바뀔 때만 호출된다 (같은 세그먼트 재탭은 무시).
  final ValueChanged<int> onChanged;

  /// 고정 폭. null이면 부모가 준 폭을 채운다.
  final double? width;

  /// 다크 테마 여부
  final bool isDarkMode;

  @override
  State<SegmentedToggle> createState() => _SegmentedToggleState();
}

class _SegmentedToggleState extends State<SegmentedToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// pill 가로 위치 (-1 = 왼쪽 끝 슬롯, 1 = 오른쪽 끝 슬롯)
  late double _fromX;
  late double _toX;

  /// 이동 중 최대 늘어남/수축 비율
  static const double _stretchX = 0.34;
  static const double _squashY = 0.14;

  double _targetX(int index) => segmentAlignmentX(index, widget.labels.length);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1, // 초기엔 정지 상태(도착 완료)
    );
    _fromX = _toX = _targetX(widget.selectedIndex);
  }

  @override
  void didUpdateWidget(covariant SegmentedToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.labels.length != widget.labels.length) {
      // 현재 애니메이션 위치에서 새 목표로 이어서 이동 (연타 대응)
      _fromX = _currentX;
      _toX = _targetX(widget.selectedIndex);
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
    return Container(
      // null이면 부모 폭을 채운다 — Stack(fit: expand)가 경계 있는 제약을 요구한다.
      width: widget.width ?? double.infinity,
      height: 40.h,
      // 선택 pill 인셋 5 (디자인 스펙 — AppSpacing에 5 없음, ScreenUtil 직접 사용)
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppColors.black800 : AppColors.black100,
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
                    widthFactor: 1 / widget.labels.length,
                    heightFactor: 1,
                    child: Transform.scale(
                      scaleX: 1 + _stretchX * stretch,
                      scaleY: 1 - _squashY * stretch,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          // 다크에서 white pill은 트랙 대비 11:1로 화면에서 가장
                          // 밝은 덩어리가 된다. 선택 위치는 그대로 읽히면서 눈에
                          // 덜 튀도록 한 단계 낮춘다.
                          color: widget.isDarkMode
                              ? AppColors.black200
                              : AppColors.white,
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
                for (int i = 0; i < widget.labels.length; i++)
                  _buildSegment(widget.labels[i], i),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 세그먼트 선택 — 터치와 스크린 리더 액션이 같은 경로를 타게 한다
  void _select(int index) {
    if (widget.selectedIndex == index) return;
    // 실제 변경 시에만 앱 공통 탭 햅틱 — AppButton과 동일(일관성)
    VibrationService.instance().buttonTap();
    widget.onChanged(index);
  }

  Widget _buildSegment(String label, int index) {
    final isSelected = widget.selectedIndex == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        // 자식 Text가 라벨을 중복 announce하지 않도록 제외하되, 그 때문에
        // GestureDetector의 탭 액션도 접근성 트리에서 빠지므로 여기서 직접 노출한다.
        onTap: isSelected ? null : () => _select(index),
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isSelected ? null : () => _select(index),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              style: AppTextStyles.paragraph_14.copyWith(
                // 선택 라벨은 흰 pill 위라 분기 불필요. 비선택은 트랙 위에 얹히므로
                // 다크(black800 트랙)에서 black400은 4.33:1로 대비가 모자라 한 단계 밝힌다.
                color: isSelected
                    ? AppColors.black800
                    : (widget.isDarkMode
                          ? AppColors.black300
                          : AppColors.black400),
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
