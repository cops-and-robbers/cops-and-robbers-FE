import 'package:flutter/material.dart';
import '../../../../core/services/lifecycle/lifecycle_log.dart';
import '../../../../core/widgets/dividers/solid_divider.dart';

/// 생명주기 상태 변화 이력을 표시하는 리스트
///
/// 최근 상태 변화 기록을 시간 순으로 표시하며,
/// 각 항목은 아이콘, 상태명, 설명, 시간을 포함합니다.
class LifecycleLogList extends StatelessWidget {
  const LifecycleLogList({super.key, required this.logs});

  final List<LifecycleLog> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '아직 상태 변화가 없습니다',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                '홈 버튼을 눌러 앱을 백그라운드로 이동해보세요',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 최근 항목이 위로 오도록 역순 정렬
    final reversedLogs = logs.reversed.toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reversedLogs.length,
      separatorBuilder: (context, index) => const SolidDivider(),
      itemBuilder: (context, index) {
        final log = reversedLogs[index];

        return ListTile(
          // 상태 아이콘
          leading: Icon(log.stateIcon, color: log.stateColor, size: 32),
          // 상태 이름 (영문 대문자)
          title: Text(
            log.state.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          // 상태 설명 (한글)
          subtitle: Text(
            log.stateDescription,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          // 시간
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                log.formattedTime,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '#${logs.length - index}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
        );
      },
    );
  }
}
