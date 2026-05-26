import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/character_assets.dart';

/// 홈 화면용 경찰+도둑 캐릭터 Stack 위젯
///
/// 디자이너 명세: 경찰 180x200(앞), 도둑 160x145(뒤). 반응형(.w/.h) 적용.
/// 두 캐릭터를 좌우로 약간 겹치게 바닥선 기준으로 정렬한다.
class HomeCharacterStack extends StatelessWidget {
  const HomeCharacterStack({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // 도둑(160) + 경찰(180) 약 60.w 겹침을 가정한 영역 크기
      width: 280.w,
      height: 200.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 뒤: 도둑 (우측, 하단 정렬)
          Positioned(
            right: -16.w,
            bottom: 0,
            child: SvgPicture.asset(
              characterAssetPath(team: 'robber', state: 'home'),
              width: 160.w,
              height: 145.h,
              fit: BoxFit.contain,
            ),
          ),
          // 앞: 경찰 (좌측, 하단 정렬)
          Positioned(
            left: -12.w,
            bottom: 0,
            child: SvgPicture.asset(
              characterAssetPath(team: 'police', state: 'home'),
              width: 180.w,
              height: 200.h,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
