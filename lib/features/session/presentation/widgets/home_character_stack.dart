import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/character_assets.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/theme/character_skin_provider.dart';
import '../../../../core/widgets/fade_skin_transition.dart';

/// 홈 화면용 경찰+도둑 캐릭터 Stack 위젯
///
/// 디자이너 명세: 경찰 180x200(앞), 도둑 160x145(뒤). 반응형(.w/.h) 적용.
/// 두 캐릭터를 좌우로 약간 겹치게 바닥선 기준으로 정렬한다.
///
/// **이스터에그**: 두 캐릭터 영역 어느 쪽이든 합산 5번을 2초 안에 탭하면
/// `characterSkinProvider` 가 토글되고 600ms 페이드 트랜지션이 재생된다.
/// `settings_page.dart:59` 의 `_onVersionTap` 카운터 패턴을 그대로 사용.
class HomeCharacterStack extends ConsumerStatefulWidget {
  const HomeCharacterStack({super.key});

  @override
  ConsumerState<HomeCharacterStack> createState() => _HomeCharacterStackState();
}

class _HomeCharacterStackState extends ConsumerState<HomeCharacterStack> {
  /// 클래식 이스터에그 탭 카운터
  int _tapCount = 0;
  DateTime? _lastTap;

  /// 두 캐릭터 영역 어느 쪽을 탭하든 호출.
  ///
  /// 마지막 탭으로부터 2초 초과 시 카운터 리셋, 5탭 도달 시 스킨 토글 + 페이드.
  void _onCharacterTap() {
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!) > const Duration(seconds: 2)) {
      _tapCount = 0;
    }
    _lastTap = now;
    _tapCount++;

    if (_tapCount >= 5) {
      _tapCount = 0;
      showFadeSkinTransition(
        context,
        onMidpoint: () {
          ref.read(characterSkinProvider.notifier).toggle();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final skinId = ref.watch(characterSkinProvider);

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
            right: -24.w,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onCharacterTap,
              child: SvgPicture.asset(
                characterAssetPath(
                  team: GameTeam.toLowerKey(GameTeam.robber),
                  skinId: skinId,
                  state: 'home',
                ),
                width: 160.w,
                height: 145.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // 앞: 경찰 (좌측, 하단 정렬)
          Positioned(
            left: -20.w,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onCharacterTap,
              child: SvgPicture.asset(
                characterAssetPath(
                  team: GameTeam.toLowerKey(GameTeam.police),
                  skinId: skinId,
                  state: 'home',
                ),
                width: 180.w,
                height: 200.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
