import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 축소로 새 경계 밖에 놓인 사람의 위치에서 빨간 링이 두 번 퍼진다 (#668).
///
/// 튜토리얼 경고 링과 같은 값: 반지름 24 → 54, 520ms, 3px. 두 번째는 450ms 뒤.
/// 색 투명도 대신 [Opacity]로 사라지게 한다 (디자인 시스템: withValues 금지).
class ShrinkPulseRings extends StatefulWidget {
  const ShrinkPulseRings({super.key});

  @override
  State<ShrinkPulseRings> createState() => _ShrinkPulseRingsState();
}

class _ShrinkPulseRingsState extends State<ShrinkPulseRings>
    with SingleTickerProviderStateMixin {
  static const _ring = 520;
  static const _gap = 450;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _gap + _ring),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _ringAt(double startMs) {
    final ms = _c.value * (_gap + _ring) - startMs;
    if (ms < 0 || ms > _ring) return const SizedBox.shrink();
    final t = ms / _ring;
    final radius = 24 + 30 * t;
    return Opacity(
      opacity: 1 - t,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.red, width: 3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, _) => SizedBox(
        width: 108,
        height: 108,
        child: Stack(
          alignment: Alignment.center,
          children: [_ringAt(0), _ringAt(_gap.toDouble())],
        ),
      ),
    ),
  );
}
