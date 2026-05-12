import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';

/// 화면 전체 빨간 펄스 오버레이
///
/// 구역 이탈 중 시각적 경고 신호. [ZoneExitPulseBorder]가 가장자리에서 강한
/// 경고선 역할을 하는 동안, 본 위젯은 화면 전체에 옅은 빨강 워시를 깔아
/// 주변 시야로도 이탈 상태를 인지할 수 있게 한다.
///
/// 가독성 정책:
/// - 진동·배너·가장자리 펄스가 이미 강한 신호를 주므로, fill은 옅게(0.08~0.18)
///   유지해 지도/내 위치/구역 경계의 가독성을 해치지 않는다.
/// - 가장자리 펄스와 동일한 1.5초 주기로 두 레이어를 시각적으로 동기화한다.
class ZoneExitPulseOverlay extends StatefulWidget {
  const ZoneExitPulseOverlay({super.key, required this.isDarkMode});

  /// 도둑(다크) 테마 여부 — 색상 명도 분기에 사용
  final bool isDarkMode;

  @override
  State<ZoneExitPulseOverlay> createState() => _ZoneExitPulseOverlayState();
}

class _ZoneExitPulseOverlayState extends State<ZoneExitPulseOverlay>
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
      begin: 0.08,
      end: 0.18,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 팀 테마 분기: 동일한 빨강 토큰 내에서 명도만 차별화
    // (UI_Design_System: 의미 = 빨강으로 통일, 분기는 명도로)
    final fillColor = widget.isDarkMode ? AppColors.red900 : AppColors.red;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value,
            // 가장자리 펄스 보더와 동일한 곡률로 모서리를 맞춰 시각적 일관성 유지
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: AppRadius.xxlarge,
              ),
            ),
          );
        },
      ),
    );
  }
}
