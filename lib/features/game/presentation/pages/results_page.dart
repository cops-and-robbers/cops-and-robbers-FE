import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/route_paths.dart';

/// 게임 종료 결과 화면
///
/// 게임 종료 후 승패 결과, 통계, MVP 등을 표시합니다.
class ResultsPage extends StatelessWidget {
  const ResultsPage({required this.sessionId, super.key});

  /// 게임 세션 ID
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게임 결과')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '게임 종료',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Session ID: $sessionId',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                '게임 결과 통계',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                child: const Text('홈으로 나가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
