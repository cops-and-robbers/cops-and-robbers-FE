import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';

/// 화면 가장자리 빨간 펄스 보더
///
/// 구역 이탈 중 시각적 경고 신호. IgnorePointer로 감싸 터치는 차단하지 않고
/// 시각 효과만 제공한다. 1.5초 주기로 페이드 인/아웃을 반복하여
/// 사용자가 구역 밖에 있음을 무시하기 어렵게 한다.
class ZoneExitPulseBorder extends StatefulWidget {
  const ZoneExitPulseBorder({super.key});

  @override
  State<ZoneExitPulseBorder> createState() => _ZoneExitPulseBorderState();
}

class _ZoneExitPulseBorderState extends State<ZoneExitPulseBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.25,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, child) {
          // 색상 알파 직접 조작 대신 위젯 레벨 Opacity로 투명도 적용
          // (UI_Design_System: withOpacity/withValues(alpha:) 금지)
          return Opacity(
            opacity: _opacity.value,
            child: Container(
              decoration: BoxDecoration(
                // 모든 변에 동일 두께를 적용하므로 가로(.w)·세로(.h) 어느 한쪽
                // 기준이 아닌 반응형 반올림(.r)을 사용한다.
                border: Border.all(color: AppColors.red, width: 6.r),
                // 화면 모서리 곡률에 맞춰 둥글게 처리
                // (사각 모서리는 폰 화면 곡률과 어긋나 어색함)
                borderRadius: AppRadius.xxlarge,
              ),
            ),
          );
        },
      ),
    );
  }
}
