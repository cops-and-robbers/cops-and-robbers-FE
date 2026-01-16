import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../router/route_paths.dart';

/// 인게임 지도 화면
///
/// 실시간 위치 추적 및 게임 플레이가 진행되는 메인 게임 화면입니다.
/// GPS를 통해 3-5초 주기로 위치를 업데이트합니다.
class GamePage extends StatelessWidget {
  const GamePage({required this.sessionId, super.key});

  /// 게임 세션 ID
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게임')),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('게임 진행 중', style: AppTextStyles.heading01),
              SizedBox(height: AppSpacing.vertical20),
              Text('Session ID: $sessionId', style: AppTextStyles.label),
              SizedBox(height: AppSpacing.vertical64),
              ElevatedButton(
                onPressed: () =>
                    context.go(RoutePaths.resultsWithId(sessionId)),
                child: const Text('결과 화면 보기'),
              ),
              SizedBox(height: AppSpacing.vertical20),
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
