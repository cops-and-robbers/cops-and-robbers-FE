import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// 구역 이탈 비네트 오버레이
///
/// 화면 4면 가장자리에서 안쪽으로 자연스럽게 페이드하는 빨강 그라데이션.
/// 중앙은 완전 투명하게 유지해 지도·플레이그라운드 원·내 위치를 가리지 않는다.
///
/// 강도 정책:
/// - 진동·배너와 함께 동작하는 보조 신호이므로 은은하게 유지한다.
/// - 1.5초 주기로 전체 강도(0.3 ↔ 0.55)를 페이드해 무시하기 어렵게 한다.
/// - 팀 테마 분기: 경찰=AppColors.red / 도둑=AppColors.red900 (명도만 차별화)
///
/// 구현:
/// - LayoutBuilder로 부모 크기를 받아 Positioned에 명시적 픽셀 폭/높이를 주입한다.
///   (Align + FractionallySizedBox 조합은 일부 컨텍스트에서 0×0이 될 수 있어 회피)
/// - 4면 각각을 LinearGradient로 그려 가장자리→안쪽으로 페이드한다.
/// - 모서리는 두 면이 자연스럽게 겹쳐 약간 더 진해진다.
class ZoneExitVignette extends StatefulWidget {
  const ZoneExitVignette({super.key, required this.isDarkMode});

  /// 도둑(다크) 테마 여부
  final bool isDarkMode;

  @override
  State<ZoneExitVignette> createState() => _ZoneExitVignetteState();
}

class _ZoneExitVignetteState extends State<ZoneExitVignette>
    with SingleTickerProviderStateMixin {
  /// 좌/우 면이 차지하는 화면 너비 비율
  static const double _sideWidthRatio = 0.12;

  /// 상/하 면이 차지하는 화면 높이 비율
  static const double _verticalHeightRatio = 0.07;

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
      begin: 0.3,
      end: 0.55,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = widget.isDarkMode ? AppColors.red900 : AppColors.red;
    // 페이드 끝점은 같은 RGB의 알파 0 색을 사용한다.
    // Colors.transparent(=0x00000000)를 쓰면 빨강→검정 RGB 보간이 일어나
    // 중간 구간에 회색/갈색 띠가 보이는 문제(특히 라이트 모드)를 방지한다.
    final fadeColor = fillColor.withAlpha(0);

    return IgnorePointer(
      child: FadeTransition(
        opacity: _opacity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sideWidth = constraints.maxWidth * _sideWidthRatio;
            final verticalHeight = constraints.maxHeight * _verticalHeightRatio;
            return Stack(
              children: [
                // 좌측: 좌→우 빨강→투명 페이드
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: sideWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [fillColor, fadeColor],
                      ),
                    ),
                  ),
                ),
                // 우측: 우→좌 빨강→투명 페이드
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: sideWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [fillColor, fadeColor],
                      ),
                    ),
                  ),
                ),
                // 상단: 위→아래 빨강→투명 페이드
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: verticalHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [fillColor, fadeColor],
                      ),
                    ),
                  ),
                ),
                // 하단: 아래→위 빨강→투명 페이드
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: verticalHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [fillColor, fadeColor],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
