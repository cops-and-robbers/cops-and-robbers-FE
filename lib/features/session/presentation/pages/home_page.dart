import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/deeplink/deeplink_constants.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../../core/utils/agreement_error_handler.dart';
import '../../../../core/utils/url_launcher_util.dart';
import '../../../../core/services/permission/game_entry_gate.dart';
import '../../../../core/services/permission/location_permission_messages.dart';
import '../../../../core/services/remote_config/remote_config_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/dev_flags.dart';
import '../../../../core/constants/game_status.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/services/tutorial/tutorial_keys.dart';
import '../../../../core/services/tutorial/tutorial_service.dart';
import '../../../../core/tutorial/app_tutorial_style.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
import '../../../../core/widgets/loading/app_loading.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/speech_bubble.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../../../test_widget_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../game/presentation/widgets/qr_scanner_page.dart';
import '../providers/game_participant_provider.dart';
import '../../data/models/join_game_response.dart';
import '../providers/session_provider.dart';
import '../widgets/home_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/home_profile_card.dart';

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

/// 홈 화면
///
/// 게임 세션 생성 또는 참가를 선택할 수 있는 메인 화면입니다.
/// 디자인: LOGO + 설정, 공지/역할 아이콘, 말풍선, 아바타, 방만들기/참여하기 버튼
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, this.skipActiveGameCheck = false});

  /// 게임 종료 후 "홈으로" 이탈 직후 진입이면 true.
  ///
  /// 퇴장 API(leave)가 아직 비행 중일 수 있어, 활성 게임 안전망이 stale
  /// WAITING 참가 상태를 보고 대기방으로 되돌리는 레이스를 1회 차단한다.
  final bool skipActiveGameCheck;

  /// 안전 안내 다이얼로그 상태 초기화 (로그아웃/강제 로그아웃 시 호출)
  static Future<void> resetSafetyNotice() async {
    _HomePageState._safetyNoticeShown = false;
    _HomePageState._activeGameChecked = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_HomePageState._safetyNoticePrefKey);
  }

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const _safetyNoticePrefKey = 'safety_notice_dismissed_date';

  // static으로 유지해야 앱 생명주기 동안 홈 재진입 시에도 값이 보존됨
  static bool _safetyNoticeShown = false;

  /// 홈 진입 시 활성 게임 체크 완료 여부 (세션당 1회)
  static bool _activeGameChecked = false;

  // 튜토리얼 대상(방 만들기 + 참여하기 버튼)을 한 영역으로 특정하기 위한 GlobalKey
  final _tutorialKeyGameButtons = GlobalKey();
  StreamSubscription<void>? _remoteConfigSubscription;

  @override
  void initState() {
    super.initState();
    _remoteConfigSubscription = RemoteConfigService.instance.onConfigUpdated
        .listen(
          (_) {
            if (mounted) setState(() {});
          },
          onError: (Object error) {
            debugPrint('⚠️ Remote Config 실시간 연결 실패: $error');
          },
        );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showTutorialIfNeeded();
      if (mounted) _showSafetyNoticeIfNeeded();
      if (mounted) _checkActiveGameAndRedirect();
    });
  }

  @override
  void dispose() {
    _remoteConfigSubscription?.cancel();
    super.dispose();
  }

  /// 홈 튜토리얼 표시 (최초 1회)
  Future<void> _showTutorialIfNeeded() async {
    final completed = await TutorialService.isCompleted(TutorialKeys.home);
    if (completed || !mounted) return;

    // 위젯 렌더링 완료 대기
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    AppTutorialStyle.show(
      context: context,
      targets: [
        AppTutorialStyle.target(
          keyTarget: _tutorialKeyGameButtons,
          description: l10n.homePageGameButtonsHint,
          align: TutorialAlign.top,
        ),
      ],
      onFinish: () => TutorialService.markCompleted(TutorialKeys.home),
    );
  }

  /// 안전 안내 다이얼로그 표시 (오늘 처음 홈 진입 시)
  Future<void> _showSafetyNoticeIfNeeded() async {
    if (_safetyNoticeShown) return;
    _safetyNoticeShown = true;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final dismissedDate = prefs.getString(_safetyNoticePrefKey);
    if (dismissedDate == today) return;
    if (!mounted) return;

    bool doNotShowToday = false;
    final l10n = AppLocalizations.of(context);

    AppDialog.show(
      context: context,
      title: l10n.dialogSafetyWarningTitle,
      message: l10n.dialogSafetyWarningMessage,
      confirmText: l10n.buttonAcknowledgedSurroundings,
      barrierDismissible: false,
      customContent: StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTap: () => setState(() => doNotShowToday = !doNotShowToday),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(top: AppSpacing.vertical8),
              child: Row(
                children: [
                  SvgPicture.asset(
                    doNotShowToday
                        ? 'assets/icons/check_circle_true.svg'
                        : 'assets/icons/check_circle_false.svg',
                    width: 16.w,
                    height: 16.w,
                  ),
                  SizedBox(width: AppSpacing.horizontal8),
                  Text(
                    l10n.homePageDontShowToday,
                    style: AppTextStyles.paragraph_14_100.copyWith(
                      color: AppColors.black600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      onConfirm: () {
        if (doNotShowToday) {
          prefs.setString(_safetyNoticePrefKey, today);
        }
      },
    );
  }

  /// 활성 게임 존재 시 자동 리다이렉트 (스플래시 실패 안전망)
  Future<void> _checkActiveGameAndRedirect() async {
    // 게임 종료 후 "홈으로" 이탈 직후엔 방금 떠난 세션의 WAITING 참가 상태가
    // (퇴장 API 완료 전까지) 서버에 남아 있어 대기방으로 되돌려질 수 있다 — 스킵
    if (widget.skipActiveGameCheck) {
      _activeGameChecked = true;
      return;
    }
    if (_activeGameChecked) return;
    _activeGameChecked = true;

    try {
      final status = await ref.read(getMyActiveGameUsecaseProvider).execute();

      if (!mounted) return;
      if (!status.isParticipating || status.participationInfo == null) return;

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
    } catch (e) {
      debugPrint('⚠️ HomePage: 활성 게임 체크 실패 (홈 유지) - $e');
    }
  }

  /// 409 "이미 참가 중인 게임" 에러 시 해당 게임으로 자동 이동
  ///
  /// `/api/user/me/game` 조회 → 게임 상태에 따라 대기실/게임 화면 이동.
  /// 조회 실패 시 fallback 스낵바를 표시합니다.
  Future<void> _redirectToActiveGame() async {
    try {
      final status = await ref.read(getMyActiveGameUsecaseProvider).execute();
      if (!mounted) return;

      if (!status.isParticipating || status.participationInfo == null) {
        // 서버 상태 불일치 — 참가 중인 게임이 없음
        final l10n = AppLocalizations.of(context);
        AppSnackbar.show(
          context,
          message: l10n.errorAlreadyInGame,
          backgroundColor: AppColors.red,
        );
        return;
      }

      final info = status.participationInfo!;

      if (info.gameStatus == GameStatus.waiting) {
        context.go(RoutePaths.waitingRoomWithId(info.gameId.toString()));
      } else if (info.gameStatus == GameStatus.inProgress) {
        context.go(
          '${RoutePaths.gameWithId(info.gameId.toString())}'
          '?team=${info.team}&pid=${info.participantId}',
        );
      } else {
        debugPrint(
          '⚠️ 알 수 없는 게임 상태: ${info.gameStatus} (gameId=${info.gameId})',
        );
        final l10n = AppLocalizations.of(context);
        AppSnackbar.show(
          context,
          message: l10n.errorUnknownGameState,
          backgroundColor: AppColors.red,
        );
      }
    } catch (_) {
      // 활성 게임 조회도 실패 → fallback 스낵바
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        AppSnackbar.show(
          context,
          message: l10n.errorAlreadyInGame,
          backgroundColor: AppColors.red,
        );
      }
    }
  }

  /// 방 만들기 버튼 클릭 시
  ///
  /// 위치 권한 + (Android) 배터리 최적화 게이트 통과 후 세션 생성 플로우로 이동.
  Future<void> _onCreateSession() async {
    final passed = await ref
        .read(gameEntryGateProvider)
        .ensure(
          context: context,
          locationContext: LocationPermissionContext.home,
        );
    // 미통과 시 헬퍼가 이미 안내 다이얼로그를 띄운 상태 → 홈에 머무름
    if (!passed || !mounted) return;

    await SessionDraftStorageService().clearDraft();
    if (mounted) {
      context.go(RoutePaths.sessionCreationFlow);
    }
  }

  /// 개발자 도구 메뉴 표시
  void _showDevMenu() {
    AppDialog.show(
      context: context,
      title: '개발자 도구',
      showButtons: false,
      customContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.pending_actions),
            title: Text('Lifecycle Test', style: AppTextStyles.paragraph_14),
            onTap: () {
              Navigator.pop(context);
              context.push(RoutePaths.lifecycleTest);
            },
          ),
          ListTile(
            leading: const Icon(Icons.widgets),
            title: Text('Test Widget', style: AppTextStyles.paragraph_14),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestWidgetPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 방 참여 다이얼로그 표시
  Future<void> _showJoinRoomDialog() async {
    final passed = await ref
        .read(gameEntryGateProvider)
        .ensure(
          context: context,
          locationContext: LocationPermissionContext.home,
        );
    if (!passed || !mounted) return;
    _showJoinRoomDialogInternal();
  }

  /// 초대 코드로 방 참여 (API 호출 → 대기실 이동)
  ///
  /// 다이얼로그 수동 입력과 QR 스캔 양쪽에서 공용으로 호출됩니다.
  Future<void> _joinRoom(String code) async {
    final dialogCloseStart = DateTime.now();

    final loading = AppLoading.show(context, LoadingCategory.joinRoom);

    JoinGameResponse? response;
    try {
      response = await ref.read(joinGameProvider(inviteCode: code).future);
      await loading.close();
    } on DioException catch (e) {
      await loading.close();
      // 필수 약관 미동의는 전역 인터셉터가 안내 + /agreement 리디렉트까지 처리한다.
      // 여기서는 일반 에러 스낵바가 겹치지 않도록 건너뛰기만 한다.
      if (isRequiredTermsMissingError(e)) {
        return;
      }
      // 409: 이미 참가 중인 게임 → 해당 게임으로 자동 이동 시도
      if (e.response?.statusCode == 409 && mounted) {
        await _redirectToActiveGame();
        return;
      }
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        // 백엔드 한국어 detail 대신 i18n 메시지 사용 (errorCode 기반)
        final ex = DioExceptionHandler.handle(e);
        final message = l10n.errorByException(ex);
        AppSnackbar.show(
          context,
          message: message,
          backgroundColor: AppColors.red,
        );
      }
      return;
    } catch (_) {
      await loading.close();
      // 예상치 못한 예외 (FormatException, StateError 등)
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        AppSnackbar.show(
          context,
          message: l10n.errorJoinRetry,
          backgroundColor: AppColors.red,
        );
      }
      return;
    }

    if (response != null && mounted) {
      // 방 참가 퍼널 이벤트 (코드 입력/QR 스캔 공용 경로)
      unawaited(ref.read(analyticsServiceProvider).logGameJoin(method: 'code'));
      final myNickname = ref.read(authNotifierProvider).value?.nickname ?? '';
      // joinGame 응답에는 gameId, participantId만 포함되며, maxParticipants /
      // locationRevealIntervalMinutes 등 나머지 정보는 대기실 진입 시
      // fetchLobbyInfoProvider + fetchGameSettingsProvider 로 보정한다.
      ref
          .read(gameParticipantNotifierProvider.notifier)
          .setGameInfo(
            gameId: response.gameId,
            nickname: myNickname,
            participantId: response.participantId,
            isHost: false,
            isEventGame: response.isEventGame || kEventGameDevOverride,
          );
      // 다이얼로그 닫힘 애니메이션 완료 + overlay cleanup frame 대기
      final elapsed = DateTime.now().difference(dialogCloseStart);
      final remaining =
          DialogAnimation.duration + const Duration(milliseconds: 32) - elapsed;
      if (remaining > Duration.zero) await Future.delayed(remaining);
      if (mounted) {
        if (response.isEventGame || kEventGameDevOverride) {
          // 이벤트 모드 — 로비 스킵, 경찰로 인게임 직행
          context.go(
            '${RoutePaths.gameWithId('${response.gameId}')}'
            '?team=${GameTeam.police}&pid=${response.participantId}',
          );
        } else {
          context.go(
            '${RoutePaths.waitingRoomWithId('${response.gameId}')}?inviteCode=$code',
          );
        }
      }
    }
  }

  /// 방 참여 다이얼로그 (권한 확인 후 호출)
  void _showJoinRoomDialogInternal() {
    final codeController = TextEditingController();
    final l10n = AppLocalizations.of(context);

    AppDialog.show(
      context: context,
      title: l10n.dialogJoinRoomTitle,
      customContent: AppTextField(
        controller: codeController,
        hintText: l10n.fieldInviteCodeHint,
        maxLength: 6,
        inputFormatters: [_UpperCaseFormatter()],
        suffixIcon: GestureDetector(
          onTap: () async {
            // 다이얼로그 닫기 → QR 스캐너 열기 → 코드 파싱 → 방 참여
            Navigator.of(context).pop();

            final inviteCode = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (_) => QrScannerPage<String>(
                  title: l10n.dialogScanInviteQrTitle,
                  onParse: (rawValue) {
                    // 1) 딥링크 URL 형식 (https://{host}/join/{code}) 우선 파싱.
                    // 경로는 정확히 /join/{code}만 허용하고, 결과는 대문자로 정규화해
                    // 수동 입력 경로(toUpperCase)와 동작을 일치시킨다.
                    final uri = Uri.tryParse(rawValue);
                    if (uri != null && uri.host == DeeplinkConstants.host) {
                      final segments = uri.pathSegments;
                      if (segments.length == 2 &&
                          segments[0] == 'join' &&
                          segments[1].length == 6) {
                        return segments[1].toUpperCase();
                      }
                    }
                    // 2) 레거시 JSON 형식 fallback (옛 QR 호환)
                    try {
                      final json = jsonDecode(rawValue) as Map<String, dynamic>;
                      final code = json['inviteCode'];
                      if (code is String && code.length == 6) return code;
                      return null;
                    } catch (_) {
                      return null;
                    }
                  },
                ),
              ),
            );

            if (inviteCode == null || !mounted) return;
            _joinRoom(inviteCode);
          },
          child: Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: SvgPicture.asset(
              'assets/icons/icon_camera.svg',
              width: 24.w,
              height: 24.w,
              colorFilter: const ColorFilter.mode(
                AppColors.black300,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
      cancelText: l10n.buttonClose,
      confirmText: l10n.buttonJoin,
      validator: () => codeController.text.trim().length == 6,
      onConfirm: () async {
        final code = codeController.text.trim().toUpperCase();
        await _joinRoom(code);
      },
    ).whenComplete(() {
      // 다이얼로그 닫힘 애니메이션(250ms) 완료 후 dispose
      // whenComplete는 pop() 직후 실행되므로 즉시 dispose하면
      // 아직 애니메이션 중인 AppTextField가 disposed controller를 참조해 에러 발생
      Future.delayed(
        DialogAnimation.duration + const Duration(milliseconds: 50),
        codeController.dispose,
      );
    });
  }

  /// 캐릭터 일러스트 카드
  ///
  /// 배경이 카드 크기를 정하고, 그 위에 말풍선(상단)과 경찰·도둑 캐릭터 쌍(하단)을
  /// Stack으로 얹는다. 배경과 캐릭터 쌍은 각각 독립적으로 교체 가능한 별도 에셋이다.
  ///
  /// Stack을 쓰는 이유: 캐릭터를 배경의 잔디선에 맞춰 독립적으로 배치할 수 있고,
  /// 말풍선이 시스템 글자 크기로 커져도 Flex 오버플로가 발생하지 않는다.
  Widget _buildIllustrationCard(AppLocalizations l10n) {
    // 배경 이미지는 BoxDecoration의 borderRadius만으로는 라운드로 잘리지 않아
    // (실기 확인 결과 모서리가 직각으로 렌더됨) ClipRRect로 명시적으로 감싼다.
    return ClipRRect(
      borderRadius: AppRadius.xxlarge,
      child: Stack(
        children: [
          // 배경 — 카드의 크기를 결정한다
          Image.asset(
            'assets/backgrounds/default.png',
            width: double.infinity,
            height: 330.h,
            fit: BoxFit.cover,
          ),

          // 말풍선 (상단 중앙)
          Positioned(
            top: AppSpacing.vertical50,
            left: 0,
            right: 0,
            child: Center(
              child: SpeechBubble(text: l10n.homePageWelcomeMessage),
            ),
          ),

          // 경찰+도둑 캐릭터 쌍 (하단 중앙, 잔디선 위)
          // 겹침·정렬이 에셋 한 장에 이미 확정돼 있다
          Positioned(
            bottom: AppSpacing.vertical28,
            left: AppSpacing.horizontal10,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                'assets/characters/home/default.svg',
                width: 249.w,
                height: 154.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 버튼에 ver2 쉐도우를 입히는 래퍼
  ///
  /// AppButton은 자체 boxShadow를 갖지 않아 외곽 Container로 그림자를 준다.
  Widget _withButtonShadow(Widget button) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.ver2,
      ),
      child: button,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remoteConfig = RemoteConfigService.instance;
    // 설정에서 튜토리얼 초기화 시 신호를 받아 재노출 (홈 인스턴스가 살아있어 initState 재실행 안 되는 문제 대응)
    ref.listen<int>(tutorialResetSignalProvider, (previous, next) {
      if (previous == null || previous == next) return;
      _showTutorialIfNeeded();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,

      // 개발자 도구 버튼 (디버그 모드에서만 표시)
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.black.withValues(alpha: 0.7),
              foregroundColor: AppColors.white,
              onPressed: _showDevMenu,
              child: const Icon(Icons.bug_report),
            )
          : null,

      // 헤더가 상태바를 포함한 높이(124)라 SafeArea 밖에 두고,
      // 그 아래 스크롤 영역만 좌우 패딩을 갖는다
      body: Column(
        children: [
          // ── [고정] 헤더: LOGO + 공지 ──
          HomeHeader(onNoticePressed: () => context.push(RoutePaths.notices)),

          // ── [스크롤] 프로필 카드 / 일러스트 / 버튼 ──
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: AppPadding.horizontal16,
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.vertical18),

                    const HomeProfileCard(),

                    SizedBox(height: AppSpacing.vertical10),

                    _buildIllustrationCard(l10n),

                    SizedBox(height: AppSpacing.vertical14),

                    // 코치마크가 두 버튼을 한 영역으로 하이라이트하도록
                    // Row에 단일 GlobalKey를 부여한다
                    Row(
                      key: _tutorialKeyGameButtons,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _withButtonShadow(
                          AppButton(
                            text: l10n.buttonCreateRoom,
                            onPressed: _onCreateSession,
                            width: 176.w,
                            backgroundColor: AppColors.blue,
                            foregroundColor: AppColors.white,
                            borderRadius: AppRadius.large,
                            showBorder: false,
                            icon: SvgPicture.asset(
                              'assets/icons/icon_default_light.svg',
                              height: AppSpacing.vertical20,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.horizontal8),
                        _withButtonShadow(
                          AppButton(
                            text: l10n.buttonJoinRoom,
                            onPressed: _showJoinRoomDialog,
                            width: 176.w,
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.black600,
                            borderRadius: AppRadius.large,
                            showBorder: false,
                            icon: SvgPicture.asset(
                              'assets/icons/icon_joining_game.svg',
                              height: AppSpacing.vertical20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (remoteConfig.bannerEnabled)
                      HomeBanner(
                        imageUrl: remoteConfig.bannerImageUrl,
                        onTap: remoteConfig.bannerLinkUrl.isEmpty
                            ? null
                            : () =>
                                  launchExternalUrl(remoteConfig.bannerLinkUrl),
                      ),

                    SizedBox(height: AppSpacing.vertical20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
