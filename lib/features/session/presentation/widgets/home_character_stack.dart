import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/character_assets.dart';
import '../../../../core/constants/game_team.dart';

/// 홈 화면용 경찰+도둑 캐릭터 Stack 위젯
///
/// 디자이너 명세: 경찰 135x150(앞), 도둑 122x110(뒤). 반응형(.w/.h) 적용.
/// 두 캐릭터를 좌우로 약간 겹치게 바닥선 기준으로 정렬한다.
class HomeCharacterStack extends StatelessWidget {
  const HomeCharacterStack({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // 경찰(135) + 도둑(122) 약 60.w 겹침을 가정한 영역 크기
      width: 197.w,
      height: 150.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 뒤: 도둑 (우측, 하단 정렬)
          Positioned(
            right: 0,
            bottom: 0,
            child: SvgPicture.asset(
              characterAssetPath(
                team: GameTeam.toLowerKey(GameTeam.robber),
                state: 'home',
              ),
              width: 122.w,
              height: 110.h,
              fit: BoxFit.contain,
            ),
          ),
          // 앞: 경찰 (좌측, 하단 정렬)
          Positioned(
            left: 0,
            bottom: 0,
            child: SvgPicture.asset(
              characterAssetPath(
                team: GameTeam.toLowerKey(GameTeam.police),
                state: 'home',
              ),
              width: 135.w,
              height: 150.h,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
