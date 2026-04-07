import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
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
      debugPrint('⚠️ SplashPage: auth 초기화 타임아웃, 로그인으로 이동');
      await _waitRemaining(startTime, minDelay);
      if (mounted) context.go(RoutePaths.login);
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
    } catch (e) {
      debugPrint('⚠️ SplashPage: 게임 상태 조회 실패, 홈으로 이동 - $e');
      await _waitRemaining(startTime, minDelay);
      if (mounted) context.go(RoutePaths.home);
    }
  }

  /// 시작 시각 기준 최소 딜레이가 남아있으면 대기
  Future<void> _waitRemaining(DateTime startTime, Duration minDelay) async {
    final elapsed = DateTime.now().difference(startTime);
    final remaining = minDelay - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
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
    if (_isReconnecting) {
      return LoadingPage(message: _reconnectMessage, subtitle: '잠시만 기다려주세요');
    }
    return const Scaffold(body: Center(child: Text('Splash')));
  }
}
