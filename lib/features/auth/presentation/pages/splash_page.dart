import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/network_failure_detector.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/loading/loading_page.dart';
import '../../../../router/route_paths.dart';
import '../../../session/domain/entities/user_game_status_entity.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../providers/auth_provider.dart';
import '../../../session/presentation/providers/session_provider.dart';
import '../../../../core/services/remote_config/remote_config_service.dart';
import '../../../../core/services/remote_config/app_version_checker.dart';
import '../../../../core/services/remote_config/update_dialog_helper.dart';

/// 앱 시작 시 초기 화면
///
/// 최소 2초 스플래시를 표시한 후 인증 상태 및 게임 참여 상태에 따라
/// 자동으로 적절한 화면으로 이동합니다.
///
/// - 비인증 → 로그인 화면
/// - 인증 + 참여 중인 게임 없음 → 홈 화면
/// - 인증 + `WAITING` → 대기실 자동 복귀
/// - 인증 + `IN_PROGRESS` → 게임 화면 자동 복귀
/// - API 실패 → 홈 화면 (fallback)
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _isReconnecting = false;
  String _reconnectMessage = '다시 현장으로 복귀 중...';

  /// 오프라인 차단 상태
  /// 네트워크 미연결 감지 시 true가 되며, 외부 API 호출을 차단한다.
  bool _isOffline = false;

  /// `_navigateToNextScreen` 동시 실행 방지 플래그
  /// 리스너/재시도 버튼/initState가 중복으로 진입하는 것을 막는다.
  bool _isNavigating = false;

  /// 연결 상태 변화 스트림 구독 핸들
  /// 오프라인 상태에서만 구독되며, 복구 재진입 시 cancel 후 재구독된다.
  StreamSubscription<bool>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
    super.dispose();
  }

  Future<void> _navigateToNextScreen({bool isRecovery = false}) async {
    // 재진입 가드 — 리스너/재시도/initState가 동시에 호출해도 한 번만 진행
    if (_isNavigating) return;
    _isNavigating = true;

    // 기존 구독은 진입 직전에 확실히 해제 (중복 콜백 방지)
    await _connectivitySub?.cancel();
    _connectivitySub = null;

    try {
      // ================================================================
      // 선제 연결 체크 (콜드 스타트 오프라인 차단)
      // ================================================================
      final connectivity = ref.read(connectivityServiceProvider);
      final connected = await connectivity.isConnected();
      if (!connected) {
        if (!mounted) return;
        setState(() => _isOffline = true);
        _subscribeConnectivity();
        return;
      }

      // 복구 경로에서 진입한 경우 오프라인 플래그 해제
      if (_isOffline && mounted) {
        setState(() => _isOffline = false);
      }

      final startTime = DateTime.now();
      const minDelay = Duration(seconds: 2);

      // ================================================================
      // Remote Config: 점검 모드 및 앱 버전 체크
      // ================================================================
      try {
        await RemoteConfigService.instance.initialize();
        final versionResult = await AppVersionChecker.check();

        if (!mounted) return;

        final canProceed = await UpdateDialogHelper.handleResult(
          context,
          versionResult,
        );

        if (!mounted || !canProceed) return; // 점검/강제 업데이트 → 앱 차단
      } catch (e) {
        // 복구 경로에서의 네트워크성 실패는 오프라인 UI로 복귀
        if (isRecovery && isNetworkFailure(e)) {
          await _returnToOffline();
          return;
        }
        debugPrint('⚠️ SplashPage: Remote Config 체크 실패, 앱 진행: $e');
        // Remote Config 실패 시 앱 정상 진행 (fail-open)
      }

      if (!mounted) return;

      // auth 초기화 완료를 Riverpod future로 대기 (최대 5초)
      final AuthResultEntity? authUser;
      try {
        authUser = await ref
            .read(authNotifierProvider.future)
            .timeout(const Duration(seconds: 5));
      } on TimeoutException {
        if (isRecovery) {
          await _returnToOffline();
          return;
        }
        debugPrint('⚠️ SplashPage: auth 초기화 타임아웃, 로그인으로 이동');
        await _waitRemaining(startTime, minDelay);
        if (mounted) context.go(RoutePaths.login);
        return;
      } on NetworkException {
        if (isRecovery) {
          await _returnToOffline();
          return;
        }
        // 비복구 모드에서 Auth가 NetworkException을 던지는 경우 —
        // 기존 코드에선 해당 경로가 정의돼 있지 않아 generic catch로 빠졌으므로
        // 동일하게 홈 fallback으로 이동한다.
        await _waitRemaining(startTime, minDelay);
        if (mounted) context.go(RoutePaths.home);
        return;
      }

      // 인증되지 않은 경우 → 남은 딜레이 후 로그인
      if (authUser == null) {
        await _waitRemaining(startTime, minDelay);
        if (!mounted) return;
        context.go(RoutePaths.login);
        return;
      }

      // 인증 확인 → 게임 상태 API 호출(재시도 포함)과 남은 딜레이를 병렬 실행
      try {
        final statusFuture = _fetchActiveGameWithRetry();
        await _waitRemaining(startTime, minDelay);
        final status = await statusFuture;

        if (!mounted) return;

        if (!status.isParticipating || status.participationInfo == null) {
          context.go(RoutePaths.home);
          return;
        }

        // 재참여 상황 → LoadingPage 전환 후 이동
        final message = await LoadingMessageService.getMessage(
          LoadingCategory.reconnect,
          fallback: '다시 현장으로 복귀 중...',
        );
        if (mounted) {
          setState(() {
            _reconnectMessage = message;
            _isReconnecting = true;
          });
        }
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;

        final info = status.participationInfo!;

        if (info.gameStatus == 'WAITING') {
          context.go(RoutePaths.waitingRoomWithId(info.gameId.toString()));
          return;
        }

        if (info.gameStatus == 'IN_PROGRESS') {
          context.go(
            '${RoutePaths.gameWithId(info.gameId.toString())}'
            '?team=${info.team}&pid=${info.participantId}',
          );
          return;
        }

        context.go(RoutePaths.home);
      } on NetworkException catch (e) {
        if (isRecovery) {
          await _returnToOffline();
          return;
        }
        // 비복구 모드 — 기존 동작 유지 (홈 fallback).
        debugPrint(
          '⚠️ SplashPage: 게임 상태 조회 실패 (Network), 홈으로 이동 - ${e.code}',
        );
        await _waitRemaining(startTime, minDelay);
        if (mounted) context.go(RoutePaths.home);
      } on DioException catch (e) {
        // 원시 DioException이 올라오는 경우에 대비해 유지
        if (isRecovery) {
          await _returnToOffline();
          return;
        }
        debugPrint('⚠️ SplashPage: 네트워크 에러, 재시도 모달 표시 - ${e.type}');
        await _waitRemaining(startTime, minDelay);
        if (mounted) await _showNetworkErrorDialog();
      } catch (e) {
        // 비네트워크 에러 (파싱 등) → 기존대로 홈 fallback
        if (isRecovery && isNetworkFailure(e)) {
          await _returnToOffline();
          return;
        }
        debugPrint('⚠️ SplashPage: 게임 상태 조회 실패, 홈으로 이동 - $e');
        await _waitRemaining(startTime, minDelay);
        if (mounted) context.go(RoutePaths.home);
      }
    } finally {
      _isNavigating = false;
    }
  }

  /// 오프라인 상태로 전환하고 연결 스트림을 재구독한다.
  ///
  /// 네트워크성 실패로 복구 루프에 진입할 때 호출한다.
  /// 폭주 방지를 위해 1초 delay 후 전환한다.
  Future<void> _returnToOffline() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isOffline = true);
    _subscribeConnectivity();
  }

  /// 연결 상태 변화 스트림을 구독한다.
  ///
  /// 기존 구독이 있으면 먼저 cancel한 뒤 새로 구독하여 중복 구독을 방지한다.
  void _subscribeConnectivity() {
    _connectivitySub?.cancel();
    final service = ref.read(connectivityServiceProvider);
    _connectivitySub = service.onConnectivityChanged
        .listen(_handleConnectivityChange);
  }

  /// 연결 상태 변화 콜백 — 자동 복구 시도.
  ///
  /// 현재 오프라인 상태이고 네비게이션이 진행 중이 아닐 때만 실제 복구를 트리거한다.
  void _handleConnectivityChange(bool isConnected) {
    if (!mounted) return;
    if (!isConnected) return;
    if (!_isOffline) return;
    if (_isNavigating) return;
    _navigateToNextScreen(isRecovery: true);
  }

  /// 수동 재시도 버튼 핸들러.
  ///
  /// 버튼 탭 시점에 연결 여부를 다시 확인해서,
  /// 연결되어 있으면 플로우 재진입, 아니면 UI 유지.
  Future<void> _onManualRetry() async {
    if (_isNavigating) return;
    final service = ref.read(connectivityServiceProvider);
    final connected = await service.isConnected();
    if (!mounted) return;
    if (!connected) return;
    _navigateToNextScreen(isRecovery: true);
  }

  /// 시작 시각 기준 최소 딜레이가 남아있으면 대기
  Future<void> _waitRemaining(DateTime startTime, Duration minDelay) async {
    final elapsed = DateTime.now().difference(startTime);
    final remaining = minDelay - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
  }

  /// 네트워크 에러 시 재시도 모달 표시
  ///
  /// 모달의 "재시도" 버튼을 누르면 [_navigateToNextScreen]을 처음부터 재실행합니다.
  Future<void> _showNetworkErrorDialog() async {
    await AppDialog.show(
      context: context,
      title: '네트워크 연결 실패',
      message: '인터넷 연결을 확인한 후\n다시 시도해주세요',
      confirmText: '재시도',
      barrierDismissible: false,
      onConfirm: () {
        if (mounted) _navigateToNextScreen();
      },
    );
  }

  /// 활성 게임 조회 (DioException 시 최대 [maxRetries]회 재시도)
  ///
  /// 콜드 스타트 시 네트워크 스택이 아직 준비되지 않아
  /// 첫 번째 API 호출이 실패할 수 있으므로 재시도로 보완합니다.
  Future<UserGameStatusEntity> _fetchActiveGameWithRetry({
    int maxRetries = 2,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await ref.read(getMyActiveGameUsecaseProvider).execute();
      } on DioException catch (e) {
        attempt++;
        if (attempt > maxRetries) rethrow;
        debugPrint(
          '⚠️ SplashPage: 게임 상태 조회 실패 ($attempt/$maxRetries), '
          '1초 후 재시도 - ${e.type}',
        );
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isOffline) {
      return _buildOfflineView(context);
    }
    if (_isReconnecting) {
      return LoadingPage(message: _reconnectMessage, subtitle: '잠시만 기다려주세요');
    }
    return const Scaffold(body: Center(child: Text('Splash')));
  }

  /// 오프라인 상태 인라인 UI.
  Widget _buildOfflineView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: AppPadding.horizontal24,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 72.w,
                  color: AppColors.black500,
                ),
                SizedBox(height: AppSpacing.vertical24),
                Text(
                  '인터넷 연결이 필요합니다',
                  style: AppTextStyles.heading_20,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.vertical16),
                Text(
                  '연결 상태를 확인한 후\n다시 시도해주세요',
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.black600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.vertical32),
                AppButton(
                  text: '다시 시도',
                  onPressed: _onManualRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
