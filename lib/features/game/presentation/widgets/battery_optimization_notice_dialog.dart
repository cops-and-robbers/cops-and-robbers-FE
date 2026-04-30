import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/background/background_service_provider.dart';

/// Android 첫 게임 진입 시 배터리 최적화 제외 안내 다이얼로그 (1회만 표시)
///
/// 샤오미·삼성·화웨이 등 일부 제조사는 Foreground Service라도 절전 정책으로
/// 백그라운드 프로세스를 강제 종료할 수 있음.
///
/// [설정 열기] 버튼은 사용자 명시적 탭에 의해서만 동작 (App Store Guideline 5.1.1(iv) 준수).
/// 자동 리다이렉트가 아닌 사용자 선택이므로 정책 위반 아님.
class BatteryOptimizationNoticeDialog extends ConsumerWidget {
  const BatteryOptimizationNoticeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('끊김 없는 게임을 위해'),
      content: const Text(
        '일부 단말은 절전 모드에서 게임을 멈출 수 있습니다.\n\n'
        '"앱 설정 → 배터리"에서 "제한 없음" 또는\n'
        '"배터리 사용 제한 안 함"을 선택해주세요.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('나중에'),
        ),
        TextButton(
          onPressed: () async {
            // 다이얼로그 먼저 닫고 설정 열기 — 사용자 명시적 탭에 의한 호출
            Navigator.of(context).pop();
            await ref.read(backgroundServiceProvider).openAppSettings();
          },
          child: const Text('설정 열기'),
        ),
      ],
    );
  }
}
