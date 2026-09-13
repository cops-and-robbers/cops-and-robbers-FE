import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

/// 수감 상태 지도 위에 덮는 전면 철창 오버레이 (DEC-0074).
///
/// 지도 스타일은 교체하지 않고 이 오버레이만으로 "갇힌 시야"를 표현한다.
/// 창살은 앱바 아래부터 화면 바닥까지 끊김 없이 내려가고, 암부는 위아래에만 두어
/// 감옥·내 위치가 놓이는 화면 중앙은 가장 밝게 남긴다.
///
/// 게임 상태를 받지 않는 순수 비주얼이며 터치도 먹지 않는다(IgnorePointer) —
/// 지도 조작과 액션 버튼은 그대로 동작한다. 디자이너 시안(PNG/SVG 프레임)이
/// 나오면 아래 [CustomPaint]를 `Image.asset`으로 갈아끼우면 끝이고, 호출부
/// (`game_page.dart`)와 지도·게임 로직은 건드릴 일이 없다.
class JailBarsOverlay extends StatelessWidget {
  const JailBarsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        bottom: false,
        child: Padding(
          // 앱바(타이머)는 가리지 않는다.
          padding: const EdgeInsets.only(top: kToolbarHeight),
          // 출력이 바뀌지 않는 정적 레이어 — 타이머 갱신에 딸려 다시 그리지 않게 경계를 둔다.
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _JailBarsPainter(
                barWidth: 8.w,
                barSpacing: 50.w,
                railHeight: 12.h,
                hazeHeight: 150.h,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JailBarsPainter extends CustomPainter {
  const _JailBarsPainter({
    required this.barWidth,
    required this.barSpacing,
    required this.railHeight,
    required this.hazeHeight,
  });

  final double barWidth;
  final double barSpacing;
  final double railHeight;
  final double hazeHeight;

  @override
  void paint(Canvas canvas, Size size) {
    _paintHaze(canvas, size);
    _paintBars(canvas, size);
    _paintRails(canvas, size);
  }

  /// 상하 암부 — 창살 뒤에 깔려 위아래로 갈수록 어두워진다.
  void _paintHaze(Canvas canvas, Size size) {
    // 분할 화면처럼 캔버스가 낮으면 위아래 암부가 겹쳐 중앙까지 어두워지므로 절반으로 제한한다.
    final height = min(hazeHeight, size.height / 2);
    final top = Rect.fromLTWH(0, 0, size.width, height);
    final bottom = Rect.fromLTWH(0, size.height - height, size.width, height);
    const colors = [AppColors.blackAlpha60, AppColors.blackAlpha0];
    canvas.drawRect(
      top,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(top),
    );
    canvas.drawRect(
      bottom,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: colors,
        ).createShader(bottom),
    );
  }

  /// 세로 창살 — 가운데 밝은 띠로 금속 질감을 낸다.
  void _paintBars(Canvas canvas, Size size) {
    final body = Paint()..color = AppColors.black;
    final highlight = Paint()..color = AppColors.black800;
    for (var x = (barSpacing - barWidth) / 2; x < size.width; x += barSpacing) {
      canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), body);
      canvas.drawRect(
        Rect.fromLTWH(x + barWidth * 0.3, 0, barWidth * 0.4, size.height),
        highlight,
      );
    }
  }

  /// 위아래 가로 레일 — 창살이 프레임에 박혀 있다는 인상을 준다.
  void _paintRails(Canvas canvas, Size size) {
    final height = min(railHeight, size.height / 2);
    final top = Rect.fromLTWH(0, 0, size.width, height);
    final bottom = Rect.fromLTWH(0, size.height - height, size.width, height);
    for (final rail in [top, bottom]) {
      canvas.drawRect(
        rail,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.black800, AppColors.black],
          ).createShader(rail),
      );
    }
  }

  @override
  bool shouldRepaint(_JailBarsPainter oldDelegate) =>
      barWidth != oldDelegate.barWidth ||
      barSpacing != oldDelegate.barSpacing ||
      railHeight != oldDelegate.railHeight ||
      hazeHeight != oldDelegate.hazeHeight;
}
