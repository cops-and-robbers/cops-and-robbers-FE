import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../router/route_paths.dart';

/// 대기실 화면
///
/// 게임 시작 전 참가자들이 팀을 선택하고 준비 완료를 표시합니다.
class WaitingRoomPage extends StatelessWidget {
  const WaitingRoomPage({required this.sessionId, super.key});

  /// 게임 세션 ID
  final String sessionId;

  /// 지도 선택 및 게임 시작
  void _startGame(BuildContext context, String mapType) {
    final route = '${RoutePaths.gameWithId(sessionId)}?mapType=$mapType';
    debugPrint('========================================');
    debugPrint('🎮 게임 시작 버튼 클릭');
    debugPrint('지도 타입: $mapType');
    debugPrint('이동 경로: $route');
    debugPrint('========================================');

    try {
      context.go(route);
    } catch (e, stack) {
      debugPrint('❌ 게임 시작 네비게이션 실패: $e');
      debugPrint('Stack: $stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('대기실')),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('대기실', style: AppTextStyles.heading_24),
              SizedBox(height: AppSpacing.vertical20),
              Text('Session ID: $sessionId', style: AppTextStyles.label_16),
              SizedBox(height: AppSpacing.vertical64),

              // 지도 선택 안내
              Text('지도를 선택하세요', style: AppTextStyles.paragraph_14),
              SizedBox(height: AppSpacing.vertical20),

              // Google Map 버튼
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _startGame(context, 'google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Google Map'),
                ),
              ),
              SizedBox(height: AppSpacing.vertical16),

              // Naver Map 버튼
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _startGame(context, 'naver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Naver Map'),
                ),
              ),

              SizedBox(height: AppSpacing.vertical64),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                child: const Text('나가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
