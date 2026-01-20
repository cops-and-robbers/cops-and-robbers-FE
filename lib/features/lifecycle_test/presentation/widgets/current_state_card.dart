import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 생명주기 상태를 크게 표시하는 카드
///
/// 상태별로 색상을 다르게 표시:
/// - resumed: 녹색 (포그라운드)
/// - inactive: 주황색 (전환 중)
/// - paused: 회색 (백그라운드)
/// - detached: 빨간색 (앱 종료 직전)
class CurrentStateCard extends StatelessWidget {
  const CurrentStateCard({super.key, required this.stateAsync});

  final AsyncValue<AppLifecycleState> stateAsync;

  @override
  Widget build(BuildContext context) {
    return stateAsync.when(
      data: (state) {
        final color = _getColorForState(state);
        final description = _getDescriptionForState(state);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          color: color.withValues(alpha: 0.1),
          child: Column(
            children: [
              // 상태 아이콘
              Icon(_getIconForState(state), size: 48, color: color),
              const SizedBox(height: 12),
              // 상태 이름 (영문 대문자)
              Text(
                state.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              // 상태 설명 (한글)
              Text(description, style: TextStyle(fontSize: 16, color: color)),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('생명주기 상태를 감지하는 중...'),
          ],
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(24),
        color: Colors.red.shade50,
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('에러 발생: $e'),
          ],
        ),
      ),
    );
  }

  /// 상태에 대한 색상 반환
  Color _getColorForState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return Colors.green;
      case AppLifecycleState.inactive:
        return Colors.orange;
      case AppLifecycleState.hidden:
        return Colors.blue;
      case AppLifecycleState.paused:
        return Colors.grey;
      case AppLifecycleState.detached:
        return Colors.red;
    }
  }

  /// 상태에 대한 한글 설명 반환
  String _getDescriptionForState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return '포그라운드 (화면에 보임)';
      case AppLifecycleState.inactive:
        return '전환 중 (잠깐)';
      case AppLifecycleState.hidden:
        return '숨김 상태 (백그라운드 전환)';
      case AppLifecycleState.paused:
        return '백그라운드 진입';
      case AppLifecycleState.detached:
        return '앱 종료 직전';
    }
  }

  /// 상태에 대한 아이콘 반환
  IconData _getIconForState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return Icons.check_circle;
      case AppLifecycleState.inactive:
        return Icons.change_circle;
      case AppLifecycleState.hidden:
        return Icons.visibility_off;
      case AppLifecycleState.paused:
        return Icons.pause_circle;
      case AppLifecycleState.detached:
        return Icons.cancel;
    }
  }
}
