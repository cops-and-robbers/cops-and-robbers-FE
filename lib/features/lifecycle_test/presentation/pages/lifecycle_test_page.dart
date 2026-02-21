import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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
  bool _isTrackingLocation = false;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 생명주기 감지 시작
    Future.microtask(() {
      ref.read(appLifecycleServiceProvider).activate();
      // 자동으로 백그라운드 위치 추적 시작
      _startBackgroundLocationTest();
    });
  }

  /// 백그라운드 위치 추적 테스트 시작
  Future<void> _startBackgroundLocationTest() async {
    // 이미 추적 중이면 중복 실행 방지
    if (_isTrackingLocation) {
      debugPrint('⚠️ 이미 백그라운드 위치 추적이 실행 중입니다');
      return;
    }

    try {
      // 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('위치 권한이 거부되었습니다')));
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('설정에서 위치 권한을 허용해주세요')));
        }
        return;
      }

      // 플랫폼별 백그라운드 설정
      late LocationSettings locationSettings;

      if (Platform.isIOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          allowBackgroundLocationUpdates: true, // 🔑 백그라운드 허용
          showBackgroundLocationIndicator: true, // 🔑 파란 바 표시
        );
      } else if (Platform.isAndroid) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: '경찰과 도둑',
            notificationText: '게임 위치 추적 중...', // 🔑 알림 표시
            notificationIcon: AndroidResource(name: 'ic_launcher'),
          ),
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        );
      }

      // 기존 구독이 있으면 먼저 취소
      await _positionSubscription?.cancel();

      // 위치 스트림 시작 (실제 위치 업데이트는 무시, 백그라운드 표시만 확인)
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position position) {
              debugPrint(
                '📍 위치 업데이트: ${position.latitude}, ${position.longitude}',
              );
            },
            onError: (error) {
              debugPrint('❌ 위치 추적 에러: $error');
              // 에러 발생 시 상태 복원
              if (mounted) {
                setState(() {
                  _isTrackingLocation = false;
                });
              }
            },
          );

      setState(() {
        _isTrackingLocation = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Platform.isIOS
                  ? '백그라운드 위치 추적 시작\n상단 파란 바를 확인하세요'
                  : '백그라운드 위치 추적 시작\n알림을 확인하세요',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 백그라운드 위치 추적 시작 실패: $e');
      // 에러 발생 시 상태 복원
      if (mounted) {
        setState(() {
          _isTrackingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Platform.isIOS
                  ? '위치 추적을 시작할 수 없습니다. 설정에서 위치 권한을 확인해주세요.'
                  : '위치 추적을 시작할 수 없습니다. 위치 서비스를 활성화하고 권한을 허용해주세요.',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // 위치 스트림 구독 취소 (메모리 누수 방지)
    _positionSubscription?.cancel();
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
        centerTitle: true,
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

          // 백그라운드 위치 추적 테스트 버튼
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '백그라운드 표시 테스트',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _isTrackingLocation
                      ? null
                      : _startBackgroundLocationTest,
                  icon: Icon(
                    _isTrackingLocation
                        ? Icons.check_circle
                        : Icons.location_on,
                  ),
                  label: Text(
                    _isTrackingLocation ? '추적 중 (백그라운드 확인)' : '백그라운드 추적 시작',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTrackingLocation
                        ? Colors.green
                        : Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Platform.isIOS
                      ? 'iOS: 상단 파란 바 표시 확인'
                      : 'Android: 알림 바에 알림 표시 확인',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

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
                Text('1. 위 버튼 눌러 백그라운드 추적 시작', style: TextStyle(fontSize: 12)),
                Text(
                  '2. 홈 버튼 누르기 → inactive → hidden → paused',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '3. iOS: 파란 바 / Android: 알림 확인',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  '4. 앱 복귀하기 → hidden → inactive → resumed',
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
