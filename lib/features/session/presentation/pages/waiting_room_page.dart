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
              Text('대기실', style: AppTextStyles.heading01),
              SizedBox(height: AppSpacing.vertical20),
              Text('Session ID: $sessionId', style: AppTextStyles.label),
              SizedBox(height: AppSpacing.vertical64),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.gameWithId(sessionId)),
                child: const Text('시작하기'),
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
