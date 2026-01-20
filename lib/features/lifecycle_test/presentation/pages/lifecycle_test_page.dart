import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/lifecycle/lifecycle_provider.dart';
import '../widgets/current_state_card.dart';
import '../widgets/lifecycle_log_list.dart';

/// WidgetsBindingObserver 생명주기 테스트 화면
///
/// 앱의 생명주기 상태 변화를 실시간으로 모니터링하고
/// 개발자가 상태 전환을 시각적으로 확인할 수 있습니다.
///
/// 주요 기능:
/// - 현재 생명주기 상태 실시간 표시
/// - 상태 변화 이력 로그 표시
/// - 로그 초기화 기능
///
/// 테스트 방법:
/// 1. 홈 버튼 누르기 → inactive → paused 확인
/// 2. 앱 스위처에서 복귀 → inactive → resumed 확인
/// 3. 앱 강제 종료 → detached 확인 (가능한 경우)
class LifecycleTestPage extends ConsumerStatefulWidget {
  const LifecycleTestPage({super.key});

  @override
  ConsumerState<LifecycleTestPage> createState() => _LifecycleTestPageState();
}

class _LifecycleTestPageState extends ConsumerState<LifecycleTestPage> {
  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 생명주기 감지 시작
    Future.microtask(() {
      ref.read(appLifecycleServiceProvider).activate();
    });
  }

  @override
  void dispose() {
    // ✅ Provider가 자동으로 deactivate 및 dispose 처리
    // ref.read() 호출 시 "ref after disposed" 에러 발생 방지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStateAsync = ref.watch(lifecycleStateProvider);
    final logs = ref.watch(lifecycleLogsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('생명주기 테스트'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          // 로그 초기화 버튼
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '로그 초기화',
            onPressed: () {
              ref.read(lifecycleLogsNotifierProvider.notifier).clearLogs();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('로그가 초기화되었습니다'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 현재 상태 표시
          CurrentStateCard(stateAsync: currentStateAsync),

          const Divider(height: 1),

          // 안내 메시지
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '테스트 방법',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '1. 홈 버튼 누르기 → inactive → hidden → paused',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '2. 앱 복귀하기 → hidden → inactive → resumed',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '3. 앱 스와이프 종료 → detached (일부 환경)',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 상태 변화 이력 로그
          Expanded(child: LifecycleLogList(logs: logs)),
        ],
      ),
    );
  }
}
