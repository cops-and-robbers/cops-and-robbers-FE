import 'dart:async';

import 'package:cops_and_robbers/l10n/app_localizations.dart';
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
import '../../../../core/widgets/snackbars/app_snackbar.dart';
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
  // 실제 값은 LoadingMessageService.getMessage()로 채워지므로 nullable 초기화
  // (build() 시 l10n.auth_splashPage_L48로 폴백)
  String? _reconnectMessage;

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

  Future<void> _navigateToNextScreen({
    bool isRecovery = false,
    bool skipConnectivityCheck = false,
  }) async {
    // 재진입 가드 — 리스너/재시도/initState가 동시에 호출해도 한 번만 진행
    if (_isNavigating) return;
    _isNavigating = true;

    // 기존 구독은 진입 직전에 확실히 해제 (중복 콜백 방지)
    await _connectivitySub?.cancel();
    _connectivitySub = null;

    try {
      // ================================================================
      // 선제 연결 체크 (콜드 스타트 오프라인 차단)
      // 수동 재시도(skipConnectivityCheck=true)에선 건너뛴다.
      // connectivity_plus의 보고값이 stale하거나 captive portal인 경우
      // 사전 체크에서 false가 나와 버튼이 먹통처럼 보이는 문제를 피하기 위함.
      // ================================================================
      if (!skipConnectivityCheck) {
        final connectivity = ref.read(connectivityServiceProvider);
        var connected = await connectivity.isConnected();
        // hot restart 직후 플랫폼 채널이 stale 값을 반환할 수 있으므로 재체크
        if (!connected) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
          connected = await connectivity.isConnected();
        }
        if (!connected) {
          if (!mounted) return;
          setState(() => _isOffline = true);
          _subscribeConnectivity();
          return;
        }
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
      // 복구 경로(수동 재시도 포함)에선 재시도를 생략해 피드백 지연을 줄인다.
      //
      // ⚠️ 주의: 과거엔 `final f = _fetchActiveGameWithRetry(); await _waitRemaining();
      //          await f;` 패턴을 썼는데, _waitRemaining 동안 f가 핸들러 없이
      //          reject되면 Dart가 "unhandled async error"로 먼저 처리해버려
      //          아래 `on NetworkException` 캐치가 기회를 잃는 문제가 있었다.
      //          Future.wait는 첫 에러 발생 시점에 await 중인 호출자로 전파하므로
      //          정상 catch 경로로 들어간다.
      try {
        final results = await Future.wait<Object?>([
          _fetchActiveGameWithRetry(maxRetries: isRecovery ? 0 : 2),
          _waitRemaining(startTime, minDelay),
        ]);
        final status = results[0] as UserGameStatusEntity;

        if (!mounted) return;

        if (!status.isParticipating || status.participationInfo == null) {
          context.go(RoutePaths.home);
          return;
        }

        // 재참여 상황 → LoadingPage 전환 후 이동
        if (!mounted) return;
        final message = LoadingMessageService.getMessage(
          context,
          LoadingCategory.reconnect,
        );
        setState(() {
          _reconnectMessage = message;
          _isReconnecting = true;
        });
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
        debugPrint('⚠️ SplashPage: 게임 상태 조회 실패 (Network), 홈으로 이동 - ${e.code}');
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
    _connectivitySub = service.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
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
  /// connectivity 사전 체크를 건너뛰고 실제 플로우(Remote Config / Auth /
  /// 게임 상태 조회)를 바로 시도한다. 실제 API가 성공하면 연결됨으로 간주하고,
  /// 네트워크성 실패가 나면 복구 루프가 오프라인 UI로 되돌리며 스낵바로 피드백한다.
  ///
  /// 어떤 예외가 나오더라도 사용자가 버튼을 눌렀는데 아무 피드백도 없는 상황을
  /// 만들지 않도록, 호출을 try-catch로 감싸고 최종적으로 `_isOffline`이 true이면
  /// 스낵바를 띄운다.
  Future<void> _onManualRetry() async {
    if (_isNavigating) return;
    try {
      await _navigateToNextScreen(
        isRecovery: true,
        skipConnectivityCheck: true,
      );
    } catch (e) {
      debugPrint('⚠️ SplashPage: 수동 재시도 중 예외 - $e');
      // 예기치 못한 예외 시에도 오프라인 UI로 되돌린다.
      if (isNetworkFailure(e) && mounted && !_isOffline) {
        await _returnToOffline();
      }
    }

    // 복구 이후에도 여전히 오프라인이면 사용자에게 명시적 피드백 제공
    if (mounted && _isOffline) {
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).dialogsplashPageMessage,
        backgroundColor: AppColors.red,
      );
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

  /// 네트워크 에러 시 재시도 모달 표시
  ///
  /// 모달의 "재시도" 버튼을 누르면 [_navigateToNextScreen]을 처음부터 재실행합니다.
  Future<void> _showNetworkErrorDialog() async {
    final l10n = AppLocalizations.of(context);
    await AppDialog.show(
      context: context,
      title: l10n.dialogsplashPageTitle,
      message: l10n.dialogsplashPageMessage665f,
      confirmText: l10n.dialogsplashPageConfirm,
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
      } catch (e) {
        // Repository는 DioException을 NetworkException 등 AppException으로 변환해
        // 던지므로, DioException 만으로 감지하면 실패 케이스를 놓치게 된다.
        // 네트워크성 실패만 재시도 대상이고, 그 외(5xx/파싱 등)는 즉시 전파한다.
        if (!isNetworkFailure(e)) rethrow;

        attempt++;
        if (attempt > maxRetries) rethrow;
        debugPrint(
          '⚠️ SplashPage: 게임 상태 조회 실패 ($attempt/$maxRetries), '
          '1초 후 재시도 - $e',
        );
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isOffline) {
      return _buildOfflineView(context);
    }
    if (_isReconnecting) {
      return LoadingPage(
        message: _reconnectMessage ?? l10n.auth_splashPage_L48,
        subtitle: l10n.auth_splashPage_L395,
      );
    }
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/splash.png',
                  width: 300.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Text(
              l10n.auth_splashPage_L412,
              style: AppTextStyles.tag_12.copyWith(color: AppColors.black400),
            ),
            SizedBox(height: AppSpacing.vertical24),
          ],
        ),
      ),
    );
  }

  /// 오프라인 상태 인라인 UI.
  Widget _buildOfflineView(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
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
                        l10n.auth_splashPage_L444,
                        style: AppTextStyles.heading_20,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.vertical16),
                      Text(
                        l10n.auth_splashPage_L450,
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.black600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              AppButton(
                text: l10n.auth_splashPage_L461,
                onPressed: _onManualRetry,
                showBorder: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
