import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '대기실',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Session ID: $sessionId',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.gameWithId(sessionId)),
                child: const Text('시작하기'),
              ),
              const SizedBox(height: 20),
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
