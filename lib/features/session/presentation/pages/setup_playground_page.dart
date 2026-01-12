import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 플레이그라운드 구역 설정 화면
///
/// 지도에서 게임이 진행될 플레이그라운드 범위를 지정합니다.
class SetupPlaygroundPage extends StatelessWidget {
  const SetupPlaygroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('플레이그라운드 설정')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '플레이그라운드 구역',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('지도에서 플레이그라운드 범위를 지정하세요'),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('설정 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
