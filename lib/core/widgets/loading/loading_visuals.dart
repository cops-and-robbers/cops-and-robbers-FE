import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';

/// 로딩 화면 비주얼 — 파동 링 3겹 + 팀 캐릭터
///
/// **자산 교체 지점**: 로딩 전용 에셋은 `assets/loading/`에 격리되어 있다.
/// 디자이너가 실제 디자인/애니메이션(SVG·GIF·Lottie)을 주면 그 폴더의
/// [_assetPolice]·[_assetRobber] 파일만 교체하면 된다(포맷이 SVG면 코드 무변경,
/// GIF/Lottie면 이 파일의 로더만 교체). 공유 캐릭터 에셋과 의도적으로 분리한다.
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
  /// 로딩 전용 캐릭터 에셋 (공유 캐릭터와 분리 — 디자이너 자산 교체 지점)
  static const String _assetPolice = 'assets/loading/police.svg';
  static const String _assetRobber = 'assets/loading/robber.svg';

  /// 링 3겹의 스태거 시작 지점 (0.0 → 0.33 → 0.66)
  static const List<double> _ringOffsets = [0.0, 0.33, 0.66];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 팀별 링 색상 — 투명도 대신 명도 계단 상수를 쓴다(withOpacity 금지 규칙)
  List<Color> get _ringColors => widget.isDarkMode
      ? const [AppColors.green800, AppColors.green500, AppColors.green100]
      : const [AppColors.blue800, AppColors.blue500, AppColors.blue100];

  String get _characterAsset => widget.isDarkMode ? _assetRobber : _assetPolice;

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
