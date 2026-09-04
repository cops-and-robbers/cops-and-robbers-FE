import 'dart:async';

import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_status.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/locale_brand_assets.dart';
import '../../../../core/deeplink/deeplink_event.dart';
import '../../../../core/deeplink/deeplink_service.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/services/fcm/push_navigation_event.dart';
import '../../../../core/services/fcm/push_navigation_service.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/services/storage/onboarding_prefs.dart';
import '../../../../core/network/network_failure_detector.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/loading/loading_page.dart';
import '../../../../core/widgets/pages/server_error_page.dart';
import '../../../../router/route_paths.dart';
import '../../../community/presentation/providers/pending_community_post_provider.dart';
import '../../../session/domain/entities/user_game_status_entity.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../providers/auth_provider.dart';
import '../../../session/presentation/providers/session_provider.dart';
import '../../../../core/services/ads/ad_service.dart';
import '../../../../core/services/remote_config/remote_config_service.dart';
import '../../../../core/services/remote_config/app_version_checker.dart';
import '../../../../core/services/remote_config/update_dialog_helper.dart';

/// 스플래시가 진행을 멈추고 재시도 화면을 띄우는 사유
enum _BlockReason { offline, serverError }

/// 앱 시작 시 초기 화면
///
/// 최소 2초 스플래시를 표시한 후 인증 상태 및 게임 참여 상태에 따라
/// 자동으로 적절한 화면으로 이동합니다.
///
/// - 비인증 → 로그인 화면
/// - 인증 + 참여 중인 게임 없음 → 홈 화면
/// - 인증 + `WAITING` → 대기실 자동 복귀
/// - 인증 + `IN_PROGRESS` → 게임 화면 자동 복귀
/// - 기기 오프라인 / 서버 장애(5xx·연결 불가) → 차단 화면 + 재시도
/// - 그 외 API 실패(파싱 등) → 홈 화면 (fallback)
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _isReconnecting = false;
  // 실제 값은 LoadingMessageService.getMessage()로 채워지므로 nullable 초기화
  // (build() 시 l10n.splashReturningToScene으로 폴백)
  String? _reconnectMessage;

  /// 차단 화면 사유. null이면 정상 진행 중.
  ///
  /// 두 사유 모두 수동 재시도 + 연결 복구 자동 재시도를 받는다. 서버 장애를 홈으로
  /// 흘리지 않는 이유: 홈의 활성 게임 안전망도 같은 API를 부르므로 서버가 내려간
  /// 동안은 복구가 안 되고, 게임 중이던 사용자가 홈에 갇힌다.
  _BlockReason? _block;

  bool get _isOffline => _block == _BlockReason.offline;

  /// `_navigateToNextScreen` 동시 실행 방지 플래그
  /// 리스너/재시도 버튼/initState가 중복으로 진입하는 것을 막는다.
  bool _isNavigating = false;

  /// 연결 상태 변화 스트림 구독 핸들
  /// 차단 상태에서만 구독되며, 복구 재진입 시 cancel 후 재구독된다.
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
          setState(() => _block = _BlockReason.offline);
          _subscribeConnectivity();
          return;
        }
      }

      // 복구 경로에서 진입한 경우 차단 해제
      if (_block != null && mounted) {
        setState(() => _block = null);
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
          await _returnToBlocked();
          return;
        }
        debugPrint('⚠️ SplashPage: Remote Config 체크 실패, 앱 진행: $e');
        // Remote Config 실패 시 앱 정상 진행 (fail-open)
      }

      // ================================================================
      // AdMob SDK 초기화 (UMP 동의 → SDK init)
      // UMP 동의 폼은 첫 프레임 이후에만 표시 가능하므로 main()이 아닌 여기서 수행.
      // fire-and-forget — 광고 초기화가 스플래시 진행을 막지 않는다 (fail-open)
      // ================================================================
      unawaited(ref.read(adServiceProvider).initialize());

      if (!mounted) return;

      // ================================================================
      // 콜드 스타트 딥링크 양보 (cold-start 네비게이션 경합 방지)
      // 초기 딥링크(초대)가 있으면 DeepLinkJoinPage 가 join + 대기방 이동을 단독
      // 담당한다. splash 가 여기서 home/활성게임으로 이동하면, 토큰 만료로 join API
      // 가 지연될 때 splash 의 go(home) 이 딥링크 페이지를 언마운트시켜, 뒤늦게 끝난
      // go(대기방) 이 !mounted 로 폐기되고 사용자가 home 에 갇힌다.
      // → 초대가 있으면 splash 는 네비게이션을 양보한다.
      // coldStartDeeplinkProvider 는 deeplinkEvents 의 emit 과 동일한 dedup 을
      // 공유하므로, 양보했는데 딥링크가 스킵돼 splash 에 갇히는 불일치는 없다.
      // ================================================================
      // 모집글 딥링크는 양보하지 않는다 — 아래에서 홈 대신 상세를 목적지로 삼는다
      // (푸시 알림의 콜드 스타트와 같은 방식).
      //
      // 프로브 대기는 4초 — 설치 직후 첫 콜드 스타트는 플러그인 채널 초기화와
      // prefs 첫 로드가 겹쳐 2초를 넘길 수 있고, 그때 링크가 통째로 유실됐다
      // (#558). 링크 없는 일반 실행은 getInitialLink 가 즉시 null 을 반환하므로
      // 이 값이 커도 시작이 느려지지 않는다 — 대기가 실제로 발생하는 건
      // 딥링크 실행에서 프로브가 밀린 경우뿐이고, 그때는 기다리는 게 맞다.
      DeeplinkEvent? coldDeeplink;
      var deeplinkProbeTimedOut = false;
      try {
        coldDeeplink = await ref
            .read(coldStartDeeplinkProvider.future)
            .timeout(const Duration(seconds: 4));
        if (coldDeeplink is InviteJoinEvent) {
          debugPrint('🔗 SplashPage: 콜드 스타트 딥링크 감지 → 네비게이션 양보');
          return;
        }
      } on TimeoutException {
        // 여기서 링크를 버리면 목적지가 유실된다(#558) — 포기하지 않고
        // 아래 auth 대기가 끝난 시점에 프로브를 한 번 더 확인한다.
        deeplinkProbeTimedOut = true;
        debugPrint('⚠️ SplashPage: 콜드 딥링크 프로브 타임아웃, auth 대기 후 재확인');
      } catch (e) {
        debugPrint('⚠️ SplashPage: 콜드 스타트 딥링크 확인 실패, 정상 진행 - $e');
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
          await _returnToBlocked();
          return;
        }
        // AuthNotifier는 서버 조회 실패를 안에서 삼키므로, 여기 오는 타임아웃은
        // 서버가 응답을 안 주는 경우다(connectTimeout 10초 × 2 > 5초). 로그인
        // 화면으로 보내면 로그인된 사용자가 같은 죽은 서버에 다시 부딪힌다.
        debugPrint('⚠️ SplashPage: auth 초기화 타임아웃, 서버 장애로 차단');
        await _waitRemaining(startTime, minDelay);
        if (mounted) _showBlock(_BlockReason.serverError);
        return;
      } on NetworkException {
        if (isRecovery) {
          await _returnToBlocked();
          return;
        }
        // 연결 사전 체크는 통과했는데 서버에 못 닿았다 → 서버 장애로 차단.
        await _waitRemaining(startTime, minDelay);
        if (mounted) _showBlock(_BlockReason.serverError);
        return;
      }
      if (!mounted) return;

      // ================================================================
      // 늦게 완료된 콜드 스타트 프로브 회수 (#558)
      //
      // 프로브가 4초를 넘겼어도 auth 대기(최대 5초)를 거친 지금은 대부분
      // 끝나 있다. 완료된 결과가 있으면 이번 실행에서 그대로 쓴다 —
      // 타임아웃이라고 버리면 사용자는 링크를 눌렀는데 홈만 보게 되고,
      // dedup(last-handled) 때문에 같은 링크 재클릭도 스킵될 수 있다.
      // ================================================================
      if (deeplinkProbeTimedOut && coldDeeplink == null) {
        coldDeeplink = ref.read(coldStartDeeplinkProvider).valueOrNull;
        if (coldDeeplink is InviteJoinEvent) {
          // 초대는 프로브 완료 시점에 deeplinkEvents 가 emit 해 리스너가
          // join 페이지를 이미 띄웠거나 곧 띄운다. 여기서 home 으로 가면
          // 그 페이지가 언마운트되므로 원래 규칙대로 네비게이션을 양보한다.
          debugPrint('🔗 SplashPage: 늦게 완료된 초대 딥링크 → 네비게이션 양보');
          return;
        }
        if (coldDeeplink != null) {
          debugPrint('🔗 SplashPage: 늦게 완료된 콜드 딥링크 회수 - $coldDeeplink');
        } else {
          // 최후 안전망 — 여기까지도 프로브가 안 끝난 극단 케이스.
          // 모집글은 완료되는 대로 pending 으로 보존한다. 진입 절차가 남은
          // 사용자는 절차 완료 시점에, 이미 로그인된 사용자는 늦어도 다음
          // 실행에서 소비된다(유실 대신 지연). 초대는 emit 경로가 처리하므로
          // 여기서 다루지 않는다. splash 가 dispose 된 뒤 완료될 수 있어
          // ref 대신 앱 수명의 container 로 저장한다.
          final container = ProviderScope.containerOf(context, listen: false);
          unawaited(
            container.read(coldStartDeeplinkProvider.future).then((event) {
              if (event case CommunityPostEvent(:final postId)) {
                unawaited(
                  container
                      .read(pendingCommunityPostProvider.notifier)
                      .save(postId),
                );
              }
            }),
          );
        }
      }

      // 인증되지 않은 경우 → 남은 딜레이 후 로그인
      if (authUser == null) {
        // 콜드 스타트 모집글 링크는 보존해 두고, 진입 절차가 끝나면 소비된다
        if (coldDeeplink case CommunityPostEvent(:final postId)) {
          await ref.read(pendingCommunityPostProvider.notifier).save(postId);
        }
        await _waitRemaining(startTime, minDelay);
        if (!mounted) return;

        // ================================================================
        // 앱 소개(온보딩) — 이 기기에서 최초 1회, 로그인 화면 앞
        //
        // 로그인보다 먼저 오는 이유: 계정을 요구하기 전에 왜 필요한지 먼저
        // 말한다. 가입 마찰이 이탈의 최대 원인이고, 우리 온보딩은 계정에 붙일
        // 데이터를 받는 개인화형이 아니라 "이게 무슨 앱인지"를 말하는 가치
        // 설명형이다.
        //
        // "로그인으로 간다"가 확정된 이 지점에 두는 이유: 온보딩이 닫힐 때
        // 스플래시를 다시 거치지 않고 로그인으로 직행할 수 있다 (중간에
        // 스플래시가 한 번 더 번쩍이던 문제). 점검·강제 업데이트 게이트와
        // 초대 딥링크 양보, 인증 복원(재설치로 세션이 살아 있는 기기)은 모두
        // 이 위에서 이미 빠져나갔으므로 온보딩이 그 흐름들을 가로막지 않는다.
        //
        // ⚠️ `push` 후 future 대기 금지 — 라우터 refreshListenable 이 스택을
        // 재계산하며 imperative push 가 떨어져 나가 무한 대기가 된다(LSN-0041).
        //
        // 기록은 노출 전에 한다 — 온보딩 도중 앱이 죽어도 영구 재노출은 막는다.
        // ================================================================
        if (!await OnboardingPrefs.seen()) {
          await OnboardingPrefs.markSeen();
          if (!mounted) return;
          context.go(RoutePaths.onboarding);
          return;
        }

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
          context.go(
            await _coldStartPushDestination() ??
                _coldStartDeeplinkDestination(coldDeeplink) ??
                RoutePaths.home,
          );
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

        if (info.gameStatus == GameStatus.waiting) {
          context.go(RoutePaths.waitingRoomWithId(info.gameId.toString()));
          return;
        }

        if (info.gameStatus == GameStatus.inProgress) {
          context.go(
            '${RoutePaths.gameWithId(info.gameId.toString())}'
            '?team=${info.team}&pid=${info.participantId}',
          );
          return;
        }

        context.go(RoutePaths.home);
      } catch (e) {
        switch (classifyFailure(e)) {
          case FailureKind.network:
            if (isRecovery) {
              await _returnToBlocked();
              return;
            }
            // 연결 사전 체크는 통과했는데 서버에 못 닿았다 → 서버 장애로 차단.
            debugPrint('⚠️ SplashPage: 게임 상태 조회 실패 (Network), 차단 - $e');
            await _waitRemaining(startTime, minDelay);
            if (mounted) _showBlock(_BlockReason.serverError);
          case FailureKind.server:
            // 서버가 내려간 동안 홈으로 보내면 홈 안전망도 같은 API라 복구가 안 된다.
            debugPrint('⚠️ SplashPage: 게임 상태 조회 실패 (5xx), 차단 - $e');
            await _waitRemaining(startTime, minDelay);
            if (mounted) _showBlock(_BlockReason.serverError);
          case FailureKind.client:
          case FailureKind.other:
            // 재시도해도 같은 결과 (파싱·거절) → 기존대로 홈 fallback
            debugPrint('⚠️ SplashPage: 게임 상태 조회 실패, 홈으로 이동 - $e');
            await _waitRemaining(startTime, minDelay);
            if (mounted) context.go(RoutePaths.home);
        }
      }
    } finally {
      _isNavigating = false;
    }
  }

  /// 복구 시도가 네트워크성 실패로 끝났을 때 차단 화면으로 되돌린다.
  ///
  /// 재시도는 연결 사전 체크를 건너뛰므로 여기서 기기 연결을 본다 — 연결돼
  /// 있는데도 실패했으면 서버 쪽 문제다. 폭주 방지를 위해 1초 delay 후 전환한다.
  Future<void> _returnToBlocked() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    bool connected;
    try {
      connected = await ref.read(connectivityServiceProvider).isConnected();
    } catch (e) {
      // 플랫폼 채널 실패 — 판정 불가면 재시도 버튼이 있는 쪽으로 둔다
      debugPrint('⚠️ SplashPage: 연결 확인 실패, 서버 장애로 간주 - $e');
      connected = true;
    }
    if (!mounted) return;
    _showBlock(connected ? _BlockReason.serverError : _BlockReason.offline);
  }

  /// 차단 화면을 띄우고 연결 복구를 구독한다.
  ///
  /// 서버 장애로 판정했어도 구독한다 — connectivity_plus의 보고값이 stale해
  /// 실제로는 오프라인인 경우가 있어, 연결이 돌아오면 자동 재시도가 살아야 한다.
  void _showBlock(_BlockReason reason) {
    setState(() => _block = reason);
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
    if (_block == null) return;
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
      // 예기치 못한 예외 시에도 차단 UI로 되돌린다.
      if (isNetworkFailure(e) && mounted && _block == null) {
        await _returnToBlocked();
      }
    }

    // 복구 이후에도 여전히 차단 상태면 사용자에게 명시적 피드백 제공
    if (mounted && _block != null) {
      final l10n = AppLocalizations.of(context);
      AppSnackbar.show(
        context,
        message: _isOffline
            ? l10n.errorNetworkNotConnected
            : l10n.errorServerUnreachable,
        backgroundColor: AppColors.red,
      );
    }
  }

  /// 시작 시각 기준 최소 딜레이가 남아있으면 대기
  /// 콜드 스타트가 푸시 알림 탭이었으면 홈 대신 갈 곳. 아니면 null.
  ///
  /// 인증·활성 게임 확인을 모두 통과한 "홈으로 갈 자리"에서만 부른다 — 진행
  /// 중인 게임 복구가 알림 탭보다 우선이고, 비로그인·약관 미동의는 라우터
  /// redirect가 어차피 다른 곳으로 보낸다(그때 목적지는 버려진다).
  /// 딥링크(초대)와 달리 스플래시가 직접 `go` 한다 — 중간 페이지가 없어
  /// "양보"만 하면 상세 아래 스플래시가 남아 뒤로가기에 갇힌다.
  Future<String?> _coldStartPushDestination() async {
    try {
      final event = await ref
          .read(coldStartPushNavigationProvider.future)
          .timeout(const Duration(seconds: 2));
      return switch (event) {
        CommunityPostPushEvent(:final postId) =>
          RoutePaths.communityDetailWithId(postId),
        null => null,
      };
    } catch (e) {
      // 프로브 실패는 홈으로 가면 그만이다 — 알림 탭 한 번을 잃을 뿐이다.
      debugPrint('⚠️ SplashPage: 콜드 스타트 푸시 확인 실패, 홈으로 진행 - $e');
      return null;
    }
  }

  /// 콜드 스타트 모집글 딥링크의 이동 목적지 (없으면 null).
  ///
  /// 초대 딥링크는 전용 페이지가 단독 담당하므로(위의 네비게이션 양보) 여기 오지
  /// 않는다. 상세 라우트는 커뮤니티 탭의 중첩 라우트라 go 만으로 뒤로 가기가
  /// 목록으로 떨어진다.
  String? _coldStartDeeplinkDestination(DeeplinkEvent? event) {
    if (event case CommunityPostEvent(:final postId)) {
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .logCommunityPostDeeplink(entry: 'cold'),
      );
      return RoutePaths.communityDetailWithId(postId);
    }
    return null;
  }

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
    // 서버 장애는 점검·강제 업데이트와 같은 전면 안내 페이지, 오프라인은 기존 인라인 뷰.
    if (_block == _BlockReason.serverError) {
      return ServerErrorPage(onRetry: _onManualRetry);
    }
    if (_isOffline) {
      return _buildOfflineView(context);
    }
    if (_isReconnecting) {
      return LoadingPage(
        message: _reconnectMessage ?? l10n.splashReturningToScene,
        subtitle: l10n.splashPleaseWait,
      );
    }
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SvgPicture.asset(
                  localizedAppSplash(Localizations.localeOf(context)),
                  width: 302.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Text(
              l10n.splashCreditTag,
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
                        l10n.splashOfflineTitle,
                        style: AppTextStyles.heading_20,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.vertical16),
                      Text(
                        l10n.splashOfflineMessage,
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.black600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              AppButton(text: l10n.buttonRetry, onPressed: _onManualRetry),
            ],
          ),
        ),
      ),
    );
  }
}
