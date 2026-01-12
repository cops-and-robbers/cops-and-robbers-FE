import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/route_paths.dart';

/// 게임 설정 화면
///
/// 라운드 시간, 위치 공유 주기, 경찰 대기 시간 등을 설정합니다.
/// 구역 설정이 완료된 후에만 접근 가능합니다.
class SessionSettingsPage extends StatelessWidget {
  const SessionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기본 정보 설정')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '게임 기본 정보',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('라운드 시간: 10분'),
              const SizedBox(height: 12),
              const Text('위치 공유 주기: 5초'),
              const SizedBox(height: 12),
              const Text('경찰 대기 시간: 30초'),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.inviteCodePath),
                child: const Text('다음'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
