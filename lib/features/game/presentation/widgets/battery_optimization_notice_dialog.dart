import 'package:flutter/material.dart';

/// Android 첫 게임 진입 시 배터리 최적화 제외 안내 다이얼로그 (1회만 표시)
///
/// 샤오미·삼성·화웨이 등 일부 제조사는 Foreground Service라도 절전 정책으로
/// 백그라운드 프로세스를 강제 종료할 수 있음.
/// permission_handler 없이 사용자가 직접 설정에서 처리하도록 안내만 제공.
class BatteryOptimizationNoticeDialog extends StatelessWidget {
  const BatteryOptimizationNoticeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('끊김 없는 게임을 위해'),
      content: const Text(
        '일부 단말은 절전 모드에서 게임을 멈출 수 있습니다.\n\n'
        '"설정 → 앱 → 경찰과 도둑 → 배터리"에서\n'
        '"제한 없음" 또는 "배터리 사용 제한 안 함"을 선택해주세요.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
