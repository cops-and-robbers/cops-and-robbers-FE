import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
import '../../../../core/services/background/background_service_provider.dart';
import '../../../../core/services/permission/location_permission_messages.dart';
import '../../../../core/services/permission/location_permission_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_status.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/i18n/locale_brand_assets.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/services/tutorial/tutorial_keys.dart';
import '../../../../core/services/tutorial/tutorial_service.dart';
import '../../../../core/theme/character_skin_provider.dart';
import '../../../../core/tutorial/app_tutorial_style.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/flat_icon_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/dialogs/app_popup.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
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
import '../widgets/home_character_stack.dart';

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
  const HomePage({super.key});

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showTutorialIfNeeded();
      if (mounted) _showSafetyNoticeIfNeeded();
      if (mounted) _checkActiveGameAndRedirect();
    });
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

  /// 위치 권한 확인 후 [onGranted] 실행
  ///
  /// 권한이 이미 허용된 경우 즉시 콜백 실행.
  /// 미허용 시 안내 다이얼로그 → 확인 버튼으로 설정 이동.
  Future<void> _ensureLocationPermission({
    required VoidCallback onGranted,
  }) async {
    // 이미 권한 있으면 바로 진행
    final canAccess = await LocationPermissionService.canAccessLocation();
    if (canAccess) {
      onGranted();
      return;
    }

    // 권한 없음 → 상태별 다이얼로그 메시지 분기
    final serviceEnabled = await LocationPermissionService.isServiceEnabled();
    if (!mounted) return;

    final text = LocationPermissionMessages.getText(
      context: context,
      isServiceDisabled: !serviceEnabled,
      locationContext: LocationPermissionContext.home,
    );

    final l10n = AppLocalizations.of(context);
    AppDialog.show(
      context: context,
      title: text.title,
      message: text.message,
      confirmText: l10n.buttonGoToSettings,
      cancelText: l10n.buttonCancel,
      onConfirm: () async {
        if (!serviceEnabled) {
          await LocationPermissionService.openLocationSettings();
        } else {
          await LocationPermissionService.openAppSettings();
        }
      },
    );
  }

  /// 배터리 최적화 무시 권한 확인 후 [onGranted] 실행.
  ///
  /// Android만 체크. iOS는 즉시 onGranted 호출.
  /// Samsung 등 OEM에서 백그라운드에서 STOMP/위치가 끊기는 문제 방지.
  /// 위치 권한과 동일 패턴 (AppDialog 재사용, 신규 위젯 X).
  Future<void> _ensureBatteryOptimization({
    required VoidCallback onGranted,
  }) async {
    // iOS는 해당 사항 없음 → 바로 진행
    if (!Platform.isAndroid) {
      onGranted();
      return;
    }

    // 디버그 빌드에서는 테스트 편의를 위해 배터리 최적화 체크 생략
    if (kDebugMode) {
      onGranted();
      return;
    }

    // 이미 설정됨 → 바로 진행
    final isIgnoring = await ref
        .read(backgroundServiceProvider)
        .isIgnoringBatteryOptimizations();
    if (isIgnoring) {
      onGranted();
      return;
    }

    // 미설정 → 차단 다이얼로그 (위치 권한과 동일 패턴)
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    AppDialog.show(
      context: context,
      title: l10n.dialogBatteryGuideTitle,
      message:
          '${l10n.homePageBatteryGuideStep1}'
          '${l10n.homePageBatteryGuideStep2}',
      confirmText: l10n.buttonGoToSettings,
      cancelText: l10n.buttonCancel,
      onConfirm: () async {
        await ref.read(backgroundServiceProvider).openAppSettings();
      },
    );
  }

  /// 방 만들기 버튼 클릭 시
  ///
  /// 위치 권한 확인 후 세션 생성 플로우로 이동합니다.
  void _onCreateSession() {
    _ensureLocationPermission(
      onGranted: () => _ensureBatteryOptimization(
        onGranted: () async {
          await SessionDraftStorageService().clearDraft();
          if (mounted) {
            context.go(RoutePaths.sessionCreationFlow);
          }
        },
      ),
    );
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
  void _showJoinRoomDialog() {
    _ensureLocationPermission(
      onGranted: () => _ensureBatteryOptimization(
        onGranted: () => _showJoinRoomDialogInternal(),
      ),
    );
  }

  /// 초대 코드로 방 참여 (API 호출 → 대기실 이동)
  ///
  /// 다이얼로그 수동 입력과 QR 스캔 양쪽에서 공용으로 호출됩니다.
  Future<void> _joinRoom(String code) async {
    final dialogCloseStart = DateTime.now();

    await AppPopup.showRandomLoading(
      context: context,
      category: LoadingCategory.joinRoom,
    );

    JoinGameResponse? response;
    try {
      response = await ref.read(joinGameProvider(inviteCode: code).future);
    } on DioException catch (e) {
      // 필수 약관 미동의 차단 → 스낵바 + /agreement 리디렉트
      if (mounted &&
          handleRequiredTermsErrorIfNeeded(
            context: context,
            ref: ref,
            error: e,
          )) {
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
    } finally {
      // 로딩 팝업 닫기 — 성공/실패 무관하게 보장
      if (mounted) Navigator.of(context).pop();
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
          );
      // 다이얼로그 닫힘 애니메이션 완료 + overlay cleanup frame 대기
      final elapsed = DateTime.now().difference(dialogCloseStart);
      final remaining =
          DialogAnimation.duration + const Duration(milliseconds: 32) - elapsed;
      if (remaining > Duration.zero) await Future.delayed(remaining);
      if (mounted) {
        context.go(
          '${RoutePaths.waitingRoomWithId('${response.gameId}')}?inviteCode=$code',
        );
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // 설정에서 튜토리얼 초기화 시 신호를 받아 재노출 (홈 인스턴스가 살아있어 initState 재실행 안 되는 문제 대응)
    ref.listen<int>(tutorialResetSignalProvider, (previous, next) {
      if (previous == null || previous == next) return;
      _showTutorialIfNeeded();
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,

      // floatingActionButton: kDebugMode
      // ? FloatingActionButton(
      //     mini: true,
      //     backgroundColor: AppColors.black.withValues(alpha: 0.7),
      //     foregroundColor: AppColors.white,
      //     onPressed: () => _showDevMenu(context),
      //     child: const Icon(Icons.bug_report),
      //   )
      // : null,

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

      body: SafeArea(
        child: Padding(
          padding: AppPadding.horizontal20,
          child: Column(
            children: [
              SizedBox(height: AppSpacing.vertical8),

              // ── Top Bar: LOGO + Settings (좌우 24px) ──
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 로케일별 워드마크 로고 — en은 세로 비중이 커 40, ko/ja는 20
                    SvgPicture.asset(
                      localizedAppLogo(Localizations.localeOf(context)),
                      height:
                          (Localizations.localeOf(context).languageCode == 'en'
                                  ? 40
                                  : 20)
                              .h,
                    ),
                    // 우측 아이콘 그룹 (공지 + 설정)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FlatIconButton(
                          assetPath: 'assets/icons/icon_alert.svg',
                          iconColor: AppColors.black800,
                          iconSize: 22,
                          onPressed: () {
                            context.push(RoutePaths.notices);
                          },
                          alignment: Alignment.centerRight,
                        ),
                        FlatIconButton(
                          assetPath: 'assets/icons/icon_setting_1.svg',
                          iconColor: AppColors.black800,
                          onPressed: () {
                            context.push(RoutePaths.settings);
                          },
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Middle Content (Expandable) ──
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 134.h),

                    // ── Speech Bubble ──
                    // 클래식 스킨(이스터에그)일 때는 옛 환영 메시지, 기본은 치즈 메시지
                    SpeechBubble(
                      text: ref.watch(characterSkinProvider) == 'classic'
                          ? l10n.homePageWelcomeMessageClassic
                          : l10n.homePageWelcomeMessage,
                    ),

                    SizedBox(height: AppSpacing.vertical40),

                    // ── 캐릭터 Stack (경찰 앞, 도둑 뒤) ──
                    const HomeCharacterStack(),
                  ],
                ),
              ),

              // ── Bottom Buttons ──
              // 코치마크가 두 버튼을 한 영역으로 하이라이트하도록 Column으로 묶어
              // 단일 GlobalKey를 부여한다. 하단 여백 SizedBox는 영역 밖으로 둔다.
              // (부모 Column이 비-flex 자식에 무한 높이 제약을 주므로 min 필수)
              Column(
                key: _tutorialKeyGameButtons,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    text: l10n.buttonCreateRoom,
                    onPressed: _onCreateSession,
                    showBorder: false,
                  ),
                  SizedBox(height: AppSpacing.vertical12),
                  AppButton(
                    text: l10n.buttonJoinRoom,
                    onPressed: _showJoinRoomDialog,
                    backgroundColor: AppColors.black100,
                    foregroundColor: AppColors.black600,
                    showBorder: false,
                  ),
                ],
              ),
              SizedBox(
                height: defaultTargetPlatform == TargetPlatform.android
                    ? AppSpacing.vertical40
                    : AppSpacing.vertical20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
