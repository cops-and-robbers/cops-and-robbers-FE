import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_icons.dart';

/// 대기·설명 장면 바닥을 지나가는 경찰차. 왼쪽 화면 밖에서 들어와 오른쪽 밖으로
/// 나가기를 되풀이하며 위아래로 통통 튄다. 움직임 줄이기 설정이면 시안 자리에 멈춰 있다.
class PoliceCarDrive extends StatefulWidget {
  const PoliceCarDrive({super.key, required this.scale});

  /// 시안 1px → 화면 px (화면 폭 / 393)
  final double scale;

  /// 시안의 차 크기(SVG 원본 그대로)
  static const Size carSize = Size(192, 141);

  /// 화면을 한 번 가로지르는 시간
  static const crossDuration = Duration(seconds: 7);

  /// 통통 튀는 한 번의 시간과 높이(시안 px)
  static const bounceDuration = Duration(milliseconds: 360);
  static const bounceHeight = 3.0;

  /// 움직임 줄이기에서 멈춰 둘 왼쪽 위치 — 도둑 시안의 차 자리
  static const restLeft = 184.0;

  /// 지나는 동안 차의 왼쪽 끝. 화면 밖([-차 폭])에서 출발해 화면 밖([화면 폭])에서 끝난다.
  static double leftAt(
    double t, {
    required double screenWidth,
    required double carWidth,
  }) => -carWidth + (screenWidth + carWidth) * t;

  @override
  State<PoliceCarDrive> createState() => _PoliceCarDriveState();
}

class _PoliceCarDriveState extends State<PoliceCarDrive>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PoliceCarDrive.crossDuration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final width = PoliceCarDrive.carSize.width * s;
    final height = PoliceCarDrive.carSize.height * s;
    final car = SvgPicture.asset(
      AppIcons.policeCar,
      width: width,
      height: height,
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: height + PoliceCarDrive.bounceHeight * s,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            final left = reduceMotion
                ? PoliceCarDrive.restLeft * s
                : PoliceCarDrive.leftAt(
                    t,
                    screenWidth: constraints.maxWidth,
                    carWidth: width,
                  );
            // 지나는 7초 동안 튀는 횟수를 정수로 맞춰 한 바퀴가 이어질 때 튀지 않는다
            final bounces =
                (PoliceCarDrive.crossDuration.inMilliseconds /
                        PoliceCarDrive.bounceDuration.inMilliseconds)
                    .round();
            final lift = reduceMotion
                ? 0.0
                : math.sin(t * bounces * math.pi).abs() *
                      PoliceCarDrive.bounceHeight *
                      s;
            return Stack(
              clipBehavior: Clip.none,
              children: [Positioned(left: left, bottom: lift, child: child!)],
            );
          },
          child: car,
        ),
      ),
    );
  }
}
