import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '게임 진행 중',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Session ID: $sessionId',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 60),
              // TODO:
              // 게임 종료 시 결과 Dialog/Modal UI 표시 예정
              // - 라우팅 이동 없이 GamePage 위에서 표시
              // - 홈으로 이동 버튼 제공
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
