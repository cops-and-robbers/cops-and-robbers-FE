import 'package:flutter/material.dart';

/// 첫 게임 진입 시 배터리 영향 안내 다이얼로그 (1회만 표시)
///
/// 게임 중 GPS와 통신이 지속 동작하여 평소보다 배터리 소모가 빠를 수 있음을 알림.
/// "배터리 빨리 닳는다" 부정 피드백을 사전에 차단하기 위한 목적.
class BatteryImpactNoticeDialog extends StatelessWidget {
  const BatteryImpactNoticeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('게임 중 배터리 사용'),
      content: const Text(
        '게임 중에는 GPS와 통신을 계속 사용해서\n'
        '평소보다 배터리가 빠르게 소모됩니다.\n\n'
        '게임이 끝나면 자동으로 중단됩니다.',
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
