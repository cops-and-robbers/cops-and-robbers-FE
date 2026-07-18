import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/character_assets.dart';
import '../../constants/game_team.dart';

/// 로딩 화면 비주얼 — 파동 링 3겹 + 팀 캐릭터
///
/// **자산 교체 지점**: 디자이너 SVG/GIF/Lottie 수령 시 이 파일만 교체한다.
/// 현재는 기존 캐릭터 SVG + 코드 모션으로 만든 플레이스홀더다.
///
/// 팀 테마는 상위에서 prop으로 받는다(하위 위젯 직접 watch 금지).
class LoadingVisual extends StatefulWidget {
  const LoadingVisual({super.key, required this.isDarkMode});

  /// true = 도둑(다크), false = 경찰(라이트)
  final bool isDarkMode;

  @override
  State<LoadingVisual> createState() => _LoadingVisualState();
}

class _LoadingVisualState extends State<LoadingVisual>
    with SingleTickerProviderStateMixin {
  /// 링 3겹의 스태거 시작 지점 (0.0 → 0.33 → 0.66)
  static const List<double> _ringOffsets = [0.0, 0.33, 0.66];

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 팀별 링 색상 — 투명도 대신 명도 계단 상수를 쓴다(withOpacity 금지 규칙)
  List<Color> get _ringColors => widget.isDarkMode
      ? const [AppColors.green800, AppColors.green500, AppColors.green100]
      : const [AppColors.blue800, AppColors.blue500, AppColors.blue100];

  String get _characterAsset => characterAssetPath(
    // 팀 문자열은 다른 호출부와 동일하게 GameTeam 상수로 중앙화 (리터럴 금지)
    team: GameTeam.toLowerKey(
      widget.isDarkMode ? GameTeam.robber : GameTeam.police,
    ),
    state: 'home',
  );

  @override
  Widget build(BuildContext context) {
    final size = 160.w;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        // 캐릭터는 애니메이션마다 재빌드할 필요가 없어 child로 전달한다
        child: SvgPicture.asset(_characterAsset, width: size * 0.45),
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < _ringOffsets.length; i++) _buildRing(i, size),
            if (child != null) child,
          ],
        ),
      ),
    );
  }

  /// 링 하나 — 진행도(t)에 따라 확산하며 사라진다.
  ///
  /// 페이드는 색상 알파가 아니라 [Opacity] 위젯으로 처리해 팔레트를 오염시키지 않는다.
  Widget _buildRing(int index, double size) {
    final t = (_controller.value + _ringOffsets[index]) % 1.0;
    final diameter = size * (0.5 + t * 0.5);

    return Opacity(
      opacity: 1.0 - t,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _ringColors[index], width: 2.w),
        ),
      ),
    );
  }
}
