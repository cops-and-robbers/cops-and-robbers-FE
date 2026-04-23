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

import '../../../../core/network/api_error_response.dart';
import '../../../../core/utils/agreement_error_handler.dart';
import '../../../../core/services/permission/location_permission_messages.dart';
import '../../../../core/services/permission/location_permission_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/services/tutorial/tutorial_keys.dart';
import '../../../../core/services/tutorial/tutorial_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/tutorial/app_tutorial_style.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/svg_icon_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/dialogs/app_popup.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/speech_bubble.dart';
import '../../../../router/route_paths.dart';
import '../../../../test_widget_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../game/presentation/widgets/qr_scanner_page.dart';
import '../providers/game_participant_provider.dart';
import '../../data/models/join_game_response.dart';
import '../providers/session_provider.dart';

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

  // 튜토리얼 대상 버튼을 특정하기 위한 GlobalKey
  final _tutorialKeyCreateRoom = GlobalKey();
  final _tutorialKeyJoinRoom = GlobalKey();

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

    AppTutorialStyle.show(
      context: context,
      targets: [
        AppTutorialStyle.target(
          keyTarget: _tutorialKeyCreateRoom,
          description: '새로운 게임을 만들 수 있어요',
          align: TutorialAlign.top,
        ),
        AppTutorialStyle.target(
          keyTarget: _tutorialKeyJoinRoom,
          description: '초대 코드를 입력하면 게임에 참가할 수 있어요',
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

    AppDialog.show(
      context: context,
      title: '주변을 확인하며 이용해 주세요',
      message: '게임 중 화면에만 집중하면 위험할 수 있어요\n도로 및 보행 환경을 확인하며 안전하게 이용해 주세요',
      confirmText: '확인했어요!',
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
                    '오늘은 다시 보지 않기',
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
        AppSnackbar.show(
          context,
          message: '이미 참가 중인 게임이 있습니다.',
          backgroundColor: AppColors.red,
        );
        return;
      }

      final info = status.participationInfo!;

      if (info.gameStatus == 'WAITING') {
        context.go(RoutePaths.waitingRoomWithId(info.gameId.toString()));
      } else if (info.gameStatus == 'IN_PROGRESS') {
        context.go(
          '${RoutePaths.gameWithId(info.gameId.toString())}'
          '?team=${info.team}&pid=${info.participantId}',
        );
      } else {
        debugPrint(
          '⚠️ 알 수 없는 게임 상태: ${info.gameStatus} (gameId=${info.gameId})',
        );
        AppSnackbar.show(
          context,
          message: '알 수 없는 게임 상태입니다.',
          backgroundColor: AppColors.red,
        );
      }
    } catch (_) {
      // 활성 게임 조회도 실패 → fallback 스낵바
      if (mounted) {
        AppSnackbar.show(
          context,
          message: '이미 참가 중인 게임이 있습니다.',
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

    final text = await LocationPermissionMessages.getText(
      isServiceDisabled: !serviceEnabled,
      context: LocationPermissionContext.home,
    );
    if (!mounted) return;

    AppDialog.show(
      context: context,
      title: text.title,
      message: text.message,
      confirmText: '설정으로 이동',
      cancelText: '취소',
      onConfirm: () async {
        if (!serviceEnabled) {
          await LocationPermissionService.openLocationSettings();
        } else {
          await LocationPermissionService.openAppSettings();
        }
      },
    );
  }

  /// 방 만들기 버튼 클릭 시
  ///
  /// 위치 권한 확인 후 세션 생성 플로우로 이동합니다.
  void _onCreateSession() {
    VibrationService.instance().buttonTap();
    _ensureLocationPermission(
      onGranted: () async {
        await SessionDraftStorageService().clearDraft();
        if (mounted) {
          context.go(RoutePaths.sessionCreationFlow);
        }
      },
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
    _ensureLocationPermission(onGranted: () => _showJoinRoomDialogInternal());
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
        final apiError = ApiErrorResponse.tryParse(e.response?.data);
        final message = apiError?.detail ?? '참여에 실패했습니다. 초대 코드를 확인해주세요.';
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
        AppSnackbar.show(
          context,
          message: '참여에 실패했습니다. 다시 시도해주세요.',
          backgroundColor: AppColors.red,
        );
      }
      return;
    } finally {
      // 로딩 팝업 닫기 — 성공/실패 무관하게 보장
      if (mounted) Navigator.of(context).pop();
    }

    if (response != null && mounted) {
      final myNickname = ref.read(authNotifierProvider).value?.nickname ?? '';
      // TODO(로비 조회 API): 현재 joinGame 응답에는 gameId, participantId만 포함됨.
      // 로비 조회 API 연동 후 아래 항목들도 설정 필요:
      //   - maxParticipants, locationRevealIntervalMinutes, nickname
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

    AppDialog.show(
      context: context,
      title: '방 참여하기',
      customContent: AppTextField(
        controller: codeController,
        hintText: '참여코드를 입력하세요',
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
                  title: '초대코드 QR을 스캔하세요',
                  onParse: (rawValue) {
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
      cancelText: '닫기',
      confirmText: '참여하기',
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
              SizedBox(height: AppSpacing.vertical16),

              // ── Top Bar: LOGO + Settings (좌우 24px) ──
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LOGO',
                      style: AppTextStyles.heading_20.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push(RoutePaths.settings);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 48.w,
                        height: 48.w,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SvgPicture.asset(
                            'assets/icons/icon_setting_1.svg',
                            width: 24.w,
                            height: 24.w,
                            colorFilter: const ColorFilter.mode(
                              AppColors.black800,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Middle Content (Expandable) ──
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.vertical32),

                    // ── Icon Buttons Row (aligned right) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgIconButton(
                          assetPath: 'assets/icons/icon_notice.svg',
                          onPressed: () {
                            context.push(RoutePaths.notices);
                          },
                        ),
                        SizedBox(width: AppSpacing.horizontal8),
                        SvgIconButton(
                          assetPath: 'assets/icons/Top_hat.svg',
                          onPressed: () {
                            AppSnackbar.show(context, message: '준비중입니다');
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: AppSpacing.vertical48),

                    // ── Speech Bubble ──
                    const SpeechBubble(text: '너무 기대 돼\n이번에는 어떤 역할을 할까?'),

                    // ── Avatar Placeholder ──
                    Image.asset(
                      'assets/app_icon.png',
                      width: 240.w,
                      height: 240.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              // ── Bottom Buttons ──
              AppButton(
                key: _tutorialKeyCreateRoom,
                text: '방 만들기',
                onPressed: _onCreateSession,
                showBorder: false,
              ),
              SizedBox(height: AppSpacing.vertical12),
              AppButton(
                key: _tutorialKeyJoinRoom,
                text: '방 참여하기',
                onPressed: _showJoinRoomDialog,
                backgroundColor: AppColors.black100,
                foregroundColor: AppColors.black600,
                showBorder: false,
              ),
              SizedBox(
                height: defaultTargetPlatform == TargetPlatform.android
                    ? AppSpacing.vertical32
                    : AppSpacing.vertical20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
