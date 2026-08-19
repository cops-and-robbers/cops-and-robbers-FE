import 'dart:async';
import 'dart:math' as math;

import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/buttons/flat_icon_button.dart';
import '../../../../core/widgets/buttons/my_location_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/buttons/svg_icon_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/dividers/solid_divider.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../chat/presentation/widgets/chat_overlay.dart'
    show kChatOverlayCollapsedFixedHeight;
import '../../../lobby/data/models/lobby_event_dto.dart';
import '../../../session/presentation/widgets/team_section.dart';
import '../../../game/domain/entities/ping.dart';
import '../../../game/presentation/widgets/ping_selection_card.dart';

/// 인게임 화면 튜토리얼
///
/// 실제 게임 화면(`GamePage`) 레이아웃을 그대로 본떠서 만든 튜토리얼 뷰.
/// 외부 데이터 의존성(STOMP, Riverpod provider, GPS)은 차단하고
/// 버튼 액션은 [AppSnackbar]로 안내한다.
///
/// 정책
/// - 별도 [AppBar] 없음. 좌측 상단 뒤로가기 버튼 오버레이만.
/// - 지도는 실 [GoogleMapView] 대신 격자 placeholder(권한 요청 회피).
/// - 채팅 시트는 collapsed 시각을 정밀 복제 (드래그/입력 동작 없음).
/// - 팀 시점 토글은 지도 placeholder 중앙에 배치 (가독성).
/// - 참가자 목록은 실 [TeamSection] + [ParticipantCard] 재사용.
class InGameTutorialPage extends ConsumerStatefulWidget {
  const InGameTutorialPage({super.key});

  @override
  ConsumerState<InGameTutorialPage> createState() => _InGameTutorialPageState();
}

class _InGameTutorialPageState extends ConsumerState<InGameTutorialPage>
    with SingleTickerProviderStateMixin {
  /// 도둑 모드 토글 (false = 경찰/라이트, true = 도둑/다크)
  bool _isDarkMode = false;

  /// 참가자 목록 모드 (실제 게임에서 person 버튼 누르면 전환되는 화면)
  bool _showParticipants = false;

  /// 참가자 화면 — 경찰팀 접힘/펼침
  bool _isPoliceExpanded = false;

  /// 참가자 화면 — 도둑팀 접힘/펼침 (실제 ParticipantOverlay 기본값과 동일)
  bool _isRobberExpanded = true;

  // 데모 참가자 데이터 — 호스트는 경찰1, 본인은 도둑이게아니게
  static const int _demoHostParticipantId = 1;
  static const int _demoMyParticipantId = 11;

  /// 데모 경찰팀 (1명) — 닉네임이 l10n 의존이라 런타임에 빌드
  List<LobbyParticipantInfo> _buildDemoPolice(AppLocalizations l10n) {
    return [
      LobbyParticipantInfo(
        participantId: 1,
        nickname: l10n.tutorialDummyNicknameCop1,
        team: 'POLICE',
        isReady: true,
      ),
    ];
  }

  /// 데모 도둑팀 (3명: 도주 2 + 수감 1) — 닉네임이 l10n 의존이라 런타임에 빌드
  List<LobbyParticipantInfo> _buildDemoRobbers(AppLocalizations l10n) {
    return [
      LobbyParticipantInfo(
        participantId: 10,
        nickname: l10n.tutorialDummyNicknameRobberKing,
        team: 'ROBBER',
        isReady: false, // ALIVE → 도주 중
      ),
      LobbyParticipantInfo(
        participantId: 11,
        nickname: l10n.tutorialDummyNicknameRobberOrNot,
        team: 'ROBBER',
        isReady: false, // ALIVE → 도주 중 (본인)
      ),
      LobbyParticipantInfo(
        participantId: 12,
        nickname: l10n.tutorialDummyNicknameCapturedRobber,
        team: 'ROBBER',
        isReady: true, // JAILED
      ),
    ];
  }

  /// 게임 컨텍스트 상태 맵 (ParticipantCard 의 SVG 분기에 사용)
  Map<int, String> get _demoGameStatus => const {
    1: 'POLICE_WAITING',
    10: 'ALIVE',
    11: 'ALIVE',
    12: 'JAILED',
  };

  /// 미션 진행도 (0=QR, 1=참가자, 2=지도복귀, 3=핀찍기, 4=완료)
  int _missionStep = 0;

  /// step 3 핀 선택 카드 표시 위치 (clamp 적용, null = 미표시)
  Offset? _pingCardOffset;

  /// step 3 롱프레스 원본 좌표 (배치 마커 기준점)
  Offset? _pingTouchOffset;

  /// 배치된 핀 (null = 아직 안 찍음)
  Offset? _placedPingOffset;
  PingType? _placedPingType;

  /// 펄스 애니메이션 컨트롤러 (활성 미션 타깃 버튼 강조용).
  ///
  /// 레이더 핑 효과 — `repeat()` (reverse 없음)으로 매 사이클마다
  /// 외곽 ring이 1.0 → 1.8 확장하며 페이드아웃, 다음 사이클 시작 시 1.0으로 스냅.
  /// 버튼 자체 scale은 sin 곡선으로 1.0 → 1.18 → 1.0 부드럽게 왕복.
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// 정답 버튼 탭 시 미션 진행
  void _tryAdvanceMission(int expectedStep) {
    if (_missionStep != expectedStep) return;
    setState(() => _missionStep++);
    if (_missionStep >= 4) {
      // 튜토리얼 완주 퍼널 이벤트
      unawaited(ref.read(analyticsServiceProvider).logTutorialComplete());
      // 화면 전환(_showParticipants=false) 후 살짝 텀 두고 다이얼로그
      Future.delayed(const Duration(milliseconds: 500), _showCompletionDialog);
    }
  }

  /// 지도 롱프레스 (step 3에서만 활성) — 햅틱 + 선택 카드 표시
  ///
  /// `localPosition`은 [_buildMapPlaceholder]가 `_buildMapMode` 최상위 Stack을
  /// 가득 채우므로(Positioned.fill) 오버레이 Positioned와 동일 좌표계를 공유한다.
  void _onTutorialMapLongPress(LongPressStartDetails details) {
    if (_missionStep != 3) return; // step 3 전용(가이드 흐름 보호)
    if (_placedPingOffset != null) return; // 이미 찍었으면 무시
    VibrationService.instance().longPress();
    final size = MediaQuery.of(context).size;
    final raw = details.localPosition;
    // 실 게임과 동일한 clamp(좌우 60.w, 상하 80.h) — 카드가 화면 밖으로 안 나가게
    final clamped = Offset(
      raw.dx.clamp(60.w, size.width - 60.w),
      raw.dy.clamp(80.h, size.height - 80.h),
    );
    setState(() {
      _pingTouchOffset = raw;
      _pingCardOffset = clamped;
    });
  }

  /// 발견/의심 선택 → 그 자리에 마커 배치 + 미션 진행
  void _onTutorialSelectPing(PingType type) {
    // 핀 선택 탭 햅틱 — PingSelectionCard는 공통 버튼이 아니라 자체 햅틱이 없어
    // 여기서 직접 발동(SvgIconButton 미션 탭은 위젯 내장 햅틱이 담당)
    VibrationService.instance().buttonTap();
    setState(() {
      _placedPingOffset = _pingTouchOffset;
      _placedPingType = type;
      _pingCardOffset = null; // 카드 닫기
    });
    _tryAdvanceMission(3);
  }

  /// 완료 다이얼로그
  void _showCompletionDialog() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    AppDialog.show<void>(
      context: context,
      title: l10n.titleTutorialComplete,
      message: l10n.messageTutorialComplete,
      confirmText: l10n.buttonFinishTutorial,
      onConfirm: () => context.pop(),
      isDarkMode: _isDarkMode,
    );
  }

  /// 활성 미션 타깃 버튼에 sin 곡선 scale 애니메이션만 적용.
  ///
  /// ring(확장하는 외곽선)은 [_pulseRing]으로 분리되어 부모 Stack의 마지막
  /// 자식으로 별도 페인트된다. 같은 Column의 형제 버튼이 ring을 덮어버리는
  /// z-order 문제를 피하기 위함 — Column children은 리스트 순서대로 페인트되어
  /// 위에 있는 형제의 ring overflow가 아래 형제에게 가려진다.
  Widget _pulseButtonScale({required int step, required Widget child}) {
    if (_missionStep != step) return child;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, _) {
        final t = _pulseController.value; // 0.0 → 1.0
        final buttonScale = 1.0 + math.sin(t * math.pi) * 0.18;
        return Transform.scale(scale: buttonScale, child: child);
      },
    );
  }

  /// 펄스 외곽 ring (1.0 → 1.8 확장 + opacity 페이드아웃).
  ///
  /// 부모 Stack의 마지막 자식으로 배치하여 다른 형제 위젯에 가려지지 않게 한다.
  /// `IgnorePointer`로 감싸 ring이 하단 버튼의 터치를 막지 않도록 보호.
  ///
  /// 외곽 박스 크기는 [SvgIconButton.containerSize] 기본값(56)에 맞춘다.
  /// 그래야 `Positioned(top:0)` / `Positioned(bottom:0)`로 배치했을 때
  /// 56×56 버튼과 정확히 같은 영역을 차지하고, 그 안에서 ring(48×48)이
  /// `Center`로 정중앙 정렬되어 버튼 중심과 일치한다.
  Widget _pulseRing() {
    final accentColor = _isDarkMode ? AppColors.green : AppColors.blue;

    return IgnorePointer(
      child: SizedBox(
        width: 56.w,
        height: 56.w,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (_, _) {
            final t = _pulseController.value;
            return Center(
              child: Opacity(
                opacity: 1.0 - t,
                child: Transform.scale(
                  scale: 1.0 + t * 0.8,
                  child: SizedBox(
                    width: 48.w,
                    height: 48.w,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: accentColor, width: 2.5),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _isDarkMode ? AppColors.black800 : AppColors.white,
      body: _showParticipants ? _buildParticipantsMode() : _buildMapMode(),
    );
  }

  // ============================================================================
  // 모드별 레이아웃
  // ============================================================================

  /// 지도 모드 (기본 화면)
  Widget _buildMapMode() {
    final viewPaddingBottom = MediaQuery.of(context).viewPadding.bottom;
    // 실제 GamePage._kActionButtonChatGap(45) + kChatOverlayCollapsedFixedHeight(112)
    // + 시스템 네비 inset(viewPadding.bottom).
    final actionButtonBottom =
        kChatOverlayCollapsedFixedHeight.h + 45.h + viewPaddingBottom;

    return Stack(
      children: [
        // 0. 지도 (status bar까지 깔림)
        Positioned.fill(child: _buildMapPlaceholder()),

        // 1. 상단 타이머 바 + 미션 배너
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: _isDarkMode ? AppColors.black900 : AppColors.white,
            child: SafeArea(
              bottom: false,
              child: Column(children: [_buildTopBar(), _buildMissionBanner()]),
            ),
          ),
        ),

        // 2. 우측 액션 버튼 — 실제 GamePage와 동일하게 [참가자, QR] 2개
        //
        // Column children은 페인트 순서가 리스트 순서와 동일하므로, 위 참가자 ring이
        // 아래 QR 버튼에 가려지는 z-order 문제가 발생한다. ring을 Stack의 마지막
        // 자식으로 분리해 활성 버튼 위치에 오버레이로 띄움.
        Positioned(
          right: 20.w,
          bottom: actionButtonBottom,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  _pulseButtonScale(
                    step: 1,
                    child: SvgIconButton(
                      assetPath: 'assets/icons/icon_person.svg',
                      onPressed: () {
                        _tryAdvanceMission(1);
                        setState(() => _showParticipants = true);
                      },
                      iconColor: _isDarkMode ? AppColors.green : AppColors.blue,
                      backgroundColor: _isDarkMode ? AppColors.black : null,
                      isDarkMode: _isDarkMode,
                    ),
                  ),
                  SizedBox(height: AppSpacing.vertical8),
                  _buildQrButton(),
                ],
              ),
              // 펄스 ring 오버레이 — Stack 마지막 자식이라 항상 최상위 페인트.
              // step 1: 참가자(위), step 0: QR(아래) 위치에 맞춰 표시.
              if (_missionStep == 1)
                Positioned(top: 0, child: _pulseRing())
              else if (_missionStep == 0)
                Positioned(bottom: 0, child: _pulseRing()),
            ],
          ),
        ),

        // 좌측 하단 내 위치 (실 게임 화면 미러링).
        // 펄스 강조 없음 — 학습 대상이 아닌 정보용 버튼.
        Positioned(
          left: 20.w,
          bottom: actionButtonBottom,
          child: MyLocationButton(
            onPressed: () {
              AppSnackbar.show(
                context,
                message: AppLocalizations.of(context).tutorialInGameMyLocation,
                isDarkMode: _isDarkMode,
              );
            },
            isFocused: true,
            focusedColor: _isDarkMode ? AppColors.green : null,
            unfocusedColor: _isDarkMode ? AppColors.green500 : null,
            backgroundColor: _isDarkMode ? AppColors.black : null,
            isDarkMode: _isDarkMode,
          ),
        ),

        // 3. 하단 채팅 collapsed placeholder
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildChatCollapsedReplica(),
        ),

        // 4. 좌측 상단 뒤로가기
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            bottom: false,
            // 상단 바(_buildTopBar)와 동일한 64.h 높이로 세로 중앙 정렬 —
            // 우측 정보 버튼·타이머와 아이콘 중심을 맞춘다.
            child: SizedBox(
              height: 64.h,
              child: Padding(
                padding: EdgeInsets.only(left: AppSpacing.horizontal4),
                child: PreviousButton(
                  onPressed: () => context.pop(),
                  size: 24.w,
                  color: _isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
            ),
          ),
        ),

        // 5. 배치된 핀 마커 (step 3 선택 후) — center anchor 24×24 (실 게임 마커 동일)
        if (_placedPingOffset != null && _placedPingType != null)
          Positioned(
            left: _placedPingOffset!.dx,
            top: _placedPingOffset!.dy,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: SvgPicture.asset(
                'assets/icons/icon_ping_'
                '${_placedPingType == PingType.found ? 'found' : 'suspect'}'
                '_marker_${_isDarkMode ? 'darkmode' : 'lightmode'}.svg',
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),

        // 6. 핀 선택 카드 (롱프레스 시) — 바깥 탭으로 닫힘 (실 게임 구조 미러링)
        if (_pingCardOffset != null)
          Positioned.fill(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _pingCardOffset = null),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.expand(),
                ),
                Positioned(
                  left: _pingCardOffset!.dx,
                  top: _pingCardOffset!.dy,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -1.0),
                    child: PingSelectionCard(
                      isDarkMode: _isDarkMode,
                      onFound: () => _onTutorialSelectPing(PingType.found),
                      onSuspect: () => _onTutorialSelectPing(PingType.suspect),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 참가자 모드 — 실제 [ParticipantOverlay]와 동일 구조
  ///
  /// 실제 [GamePage] Stack에서 [ChatOverlay]는 `_showParticipants` 분기 바깥
  /// (index 7)에 고정되어 참가자 모드에서도 항상 노출된다. 본 튜토리얼도
  /// 동일하게 채팅 collapsed placeholder를 항상 렌더링.
  Widget _buildParticipantsMode() {
    final viewPaddingBottom = MediaQuery.of(context).viewPadding.bottom;
    final actionButtonBottom =
        kChatOverlayCollapsedFixedHeight.h + 45.h + viewPaddingBottom;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: _isDarkMode ? AppColors.black900 : AppColors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildTopBar(),
                  _buildMissionBanner(),
                  Expanded(child: _buildParticipantsList()),
                ],
              ),
            ),
          ),
        ),

        // 우측 액션 [지도 복귀, QR] — _buildMapMode와 동일하게 ring을 Stack
        // 오버레이로 분리해 형제 버튼이 ring을 덮는 z-order 문제 회피.
        Positioned(
          right: 20.w,
          bottom: actionButtonBottom,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  _pulseButtonScale(
                    step: 2,
                    child: SvgIconButton(
                      assetPath: 'assets/icons/icon_map.svg',
                      onPressed: () {
                        _tryAdvanceMission(2);
                        setState(() => _showParticipants = false);
                      },
                      iconColor: _isDarkMode ? AppColors.green : AppColors.blue,
                      backgroundColor: _isDarkMode ? AppColors.black : null,
                      isDarkMode: _isDarkMode,
                    ),
                  ),
                  SizedBox(height: AppSpacing.vertical8),
                  _buildQrButton(),
                ],
              ),
              // 참가자 모드에선 step 2(지도복귀)가 위, QR은 아래. step 0은 이미
              // 진행이 지난 후라 보통 발생하지 않지만 안전하게 함께 처리.
              if (_missionStep == 2)
                Positioned(top: 0, child: _pulseRing())
              else if (_missionStep == 0)
                Positioned(bottom: 0, child: _pulseRing()),
            ],
          ),
        ),

        // 하단 채팅 collapsed placeholder (참가자 모드에서도 항상 노출)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildChatCollapsedReplica(),
        ),

        // 좌측 상단 뒤로가기
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            bottom: false,
            // 상단 바(_buildTopBar)와 동일한 64.h 높이로 세로 중앙 정렬 —
            // 우측 정보 버튼·타이머와 아이콘 중심을 맞춘다.
            child: SizedBox(
              height: 64.h,
              child: Padding(
                padding: EdgeInsets.only(left: AppSpacing.horizontal4),
                child: PreviousButton(
                  onPressed: () => context.pop(),
                  size: 24.w,
                  color: _isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // 지도 placeholder
  // ============================================================================

  /// 지도 영역 placeholder — 격자 + 안내 텍스트 + 팀 시점 토글
  ///
  /// 실제 [GoogleMapView]는 위치 권한을 요청하므로 튜토리얼에선 격자로 대체.
  /// 토글은 가독성을 위해 placeholder 중앙에 배치한다.
  Widget _buildMapPlaceholder() {
    return GestureDetector(
      // step 3 전에는 핸들러가 즉시 return → 무반응
      onLongPressStart: _onTutorialMapLongPress,
      child: Container(
        color: _isDarkMode ? AppColors.black800 : AppColors.black100,
        child: CustomPaint(
          painter: _MapGridPainter(isDarkMode: _isDarkMode),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 56.w,
                  color: _isDarkMode ? AppColors.black600 : AppColors.black300,
                ),
                SizedBox(height: AppSpacing.vertical8),
                Text(
                  AppLocalizations.of(context).tutorialMapPreviewLabel,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: _isDarkMode
                        ? AppColors.black400
                        : AppColors.black500,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical16),
                _buildTeamToggle(),
                if (_missionStep == 3 &&
                    _pingCardOffset == null &&
                    _placedPingOffset == null) ...[
                  SizedBox(height: AppSpacing.vertical16),
                  _buildLongPressHint(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // 상단 바
  // ============================================================================

  /// 상단 바 — 실제 [GamePage._buildAppBar]와 동일한 구조
  Widget _buildTopBar() {
    return Container(
      height: 64.h,
      color: _isDarkMode ? AppColors.black900 : AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 튜토리얼은 정적 미리보기 — 실 GameTimerText/LocationRevealCountdown은
              // 매초 setState로 재빌드되어 학습용 화면에서는 불필요한 부담.
              // 외형(스타일/텍스트 위치)은 그대로 복제하고 값만 고정.
              Text(
                '29:30',
                style: _isDarkMode
                    ? AppTextStyles.robberHeading.copyWith(
                        color: AppColors.white,
                      )
                    : AppTextStyles.heading_20.copyWith(color: AppColors.black),
              ),
              SizedBox(height: 6.h),
              Text(
                AppLocalizations.of(context).tutorialLocationRevealCountdown,
                style: AppTextStyles.tag_12.copyWith(
                  color: _isDarkMode ? AppColors.black400 : AppColors.red,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FlatIconButton(
              assetPath: 'assets/icons/icon_info.svg',
              iconColor: _isDarkMode ? AppColors.black200 : AppColors.black800,
              onPressed: () {
                AppSnackbar.show(
                  context,
                  message: AppLocalizations.of(
                    context,
                  ).tutorialInGameRulesGuide,
                  isDarkMode: _isDarkMode,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 액션 버튼들
  // ============================================================================

  /// QR 버튼 (경찰: 스캔 / 도둑: 표시)
  ///
  /// scale 애니메이션만 적용. ring은 부모 Stack의 [_pulseRing] 오버레이로 분리.
  Widget _buildQrButton() {
    return _pulseButtonScale(
      step: 0,
      child: SvgIconButton(
        assetPath: _isDarkMode
            ? 'assets/icons/icon_qr_code.svg'
            : 'assets/icons/icon_qr_scan.svg',
        onPressed: () {
          _tryAdvanceMission(0);
          final l10n = AppLocalizations.of(context);
          AppSnackbar.show(
            context,
            message: _isDarkMode
                ? l10n.tutorialQrRobberHint
                : l10n.tutorialQrCopHint,
            isDarkMode: _isDarkMode,
          );
        },
        backgroundColor: _isDarkMode ? AppColors.black : null,
        isDarkMode: _isDarkMode,
      ),
    );
  }

  /// 미션 배너 — 상단 타이머 바 바로 아래에 표시.
  /// 4개 미션 모두 완료되면 숨김.
  Widget _buildMissionBanner() {
    if (_missionStep >= 4) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final descriptions = [
      l10n.tutorialMissionQrButton, // step 0 (QR 먼저)
      l10n.tutorialMissionParticipantsButton, // step 1
      l10n.tutorialMissionMapButton, // step 2
      l10n.tutorialMissionDropPing, // step 3 (핀 찍기)
    ];

    final accentColor = _isDarkMode ? AppColors.green : AppColors.blue;
    final bgColor = _isDarkMode ? AppColors.black800 : AppColors.blue100;
    final descColor = _isDarkMode ? AppColors.white : AppColors.black800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal16,
        vertical: AppSpacing.vertical8,
      ),
      color: bgColor,
      child: Row(
        children: [
          Text(
            l10n.tutorialMissionProgress('${_missionStep + 1}'),
            style: AppTextStyles.tag12Semibold.copyWith(color: accentColor),
          ),
          SizedBox(width: AppSpacing.horizontal8),
          Expanded(
            child: Text(
              descriptions[_missionStep],
              style: AppTextStyles.paragraph_14.copyWith(color: descColor),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (i) {
              return Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: i < _missionStep ? accentColor : AppColors.black300,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 팀 시점 토글 (튜토리얼 전용 — 경찰/도둑 시점 미리보기)
  ///
  /// 가독성을 위해 지도 placeholder 중앙에 배치.
  Widget _buildTeamToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isDarkMode = !_isDarkMode),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal16,
          vertical: AppSpacing.vertical8,
        ),
        decoration: BoxDecoration(
          color: _isDarkMode ? AppColors.black900 : AppColors.white,
          borderRadius: AppRadius.xlarge,
          border: Border.all(
            color: _isDarkMode ? AppColors.black700 : AppColors.black200,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/icon_change.svg',
              width: 16.w,
              height: 16.w,
              colorFilter: ColorFilter.mode(
                _isDarkMode ? AppColors.green : AppColors.blue,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: AppSpacing.horizontal6),
            Text(
              _isDarkMode
                  ? AppLocalizations.of(context).tutorialPerspectiveRobber
                  : AppLocalizations.of(context).tutorialPerspectiveCop,
              style: AppTextStyles.tag12Semibold.copyWith(
                color: _isDarkMode ? AppColors.white : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// step 3 롱프레스 안내 힌트 — 펄스 scale로 주목도 부여(지도 중앙, 토글 아래)
  Widget _buildLongPressHint() {
    final accentColor = _isDarkMode ? AppColors.green : AppColors.blue;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) {
        final t = _pulseController.value; // 0.0 → 1.0
        final scale = 1.0 + math.sin(t * math.pi) * 0.08;
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal16,
          vertical: AppSpacing.vertical8,
        ),
        decoration: BoxDecoration(
          color: _isDarkMode ? AppColors.black900 : AppColors.white,
          borderRadius: AppRadius.xlarge,
          border: Border.all(color: accentColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 16.w, color: accentColor),
            SizedBox(width: AppSpacing.horizontal6),
            Text(
              AppLocalizations.of(context).tutorialPingLongPressHint,
              style: AppTextStyles.tag12Semibold.copyWith(color: accentColor),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // 참가자 목록 — 실제 ParticipantOverlay 구조 그대로 재현
  // ============================================================================

  /// 참가자 목록 — 실제 [TeamSection] + [ParticipantCard] 재사용
  ///
  /// 데이터는 정적 fixture, 의존성 0 (TeamSection은 stateless 순수 위젯).
  Widget _buildParticipantsList() {
    final l10n = AppLocalizations.of(context);
    final demoPolice = _buildDemoPolice(l10n);
    final demoRobbers = _buildDemoRobbers(l10n);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeamSection(
            team: 'POLICE',
            members: demoPolice,
            isExpanded: _isPoliceExpanded,
            onToggle: () =>
                setState(() => _isPoliceExpanded = !_isPoliceExpanded),
            hostParticipantId: _demoHostParticipantId,
            myParticipantId: _demoMyParticipantId,
            badge: const SizedBox.shrink(),
            isDarkMode: _isDarkMode,
            gameStatusByParticipantId: _demoGameStatus,
          ),
          SolidDivider(
            color: _isDarkMode ? AppColors.black800 : AppColors.black200,
          ),
          TeamSection(
            team: 'ROBBER',
            members: demoRobbers,
            isExpanded: _isRobberExpanded,
            onToggle: () =>
                setState(() => _isRobberExpanded = !_isRobberExpanded),
            hostParticipantId: _demoHostParticipantId,
            myParticipantId: _demoMyParticipantId,
            badge: _buildRobberBadge(2),
            onMemberTap: (member) {
              // 튜토리얼: 카드 탭 시 안내 스낵바 (실제는 체포/탈옥 모달)
              if (_isDarkMode) {
                AppSnackbar.show(
                  context,
                  message: l10n.tutorialInGameSelfEscape,
                  isDarkMode: true,
                );
              } else {
                AppSnackbar.show(
                  context,
                  message: l10n.tutorialInGameQrArrest,
                  isDarkMode: false,
                );
              }
            },
            isDarkMode: _isDarkMode,
            gameStatusByParticipantId: _demoGameStatus,
          ),
        ],
      ),
    );
  }

  /// 도둑팀 헤더 배지 (실제 [ParticipantOverlay._buildRobberBadge]와 동일)
  Widget _buildRobberBadge(int count) {
    final badgeColor = _isDarkMode ? AppColors.green800 : AppColors.blue800;
    final badgeBoldColor = _isDarkMode ? AppColors.green : AppColors.blue;
    final l10n = AppLocalizations.of(context);
    return RichText(
      text: TextSpan(
        style: AppTextStyles.tag_12.copyWith(color: badgeColor),
        children: [
          TextSpan(text: '${l10n.tutorialCurrentLabel} '),
          TextSpan(
            text: l10n.tutorialPlayerCount(count),
            style: AppTextStyles.tag_12.copyWith(
              color: badgeBoldColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: ' ${l10n.tutorialOnTheRun}'),
        ],
      ),
    );
  }

  // ============================================================================
  // 채팅 collapsed 시트 정밀 복제
  // ============================================================================

  /// 실제 [ChatOverlay] collapsed 외형을 픽셀 단위로 복제.
  ///
  /// 구조 (실제 sheet 내부 Column 그대로):
  /// - 외곽: black100/black900, 상단 xl20 라운드, shadow offset(0,-2) blur 10
  /// - 28h 드래그 핸들 (48×4 indicator)
  /// - **8h gap** (실제는 `Expanded(SizedBox.shrink)` — collapsed에서 8h 차지)
  /// - [ChatInputBar] 외형 복제 (8 + 48 + 8 = 64h)
  /// - 12h spacer
  /// - 시스템 네비 inset (viewPadding.bottom or 37h fallback)
  /// 합 = 28 + 8 + 64 + 12 + bottom = 112 + bottom (= kChatOverlayCollapsedFixedHeight + bottom)
  Widget _buildChatCollapsedReplica() {
    final viewPaddingBottom = MediaQuery.of(context).viewPadding.bottom;
    // chat_overlay.dart _fallbackBottomPadding = 37 (SafeArea 없는 기기 대비)
    final safeBottom = viewPaddingBottom > 0 ? viewPaddingBottom : 37.h;

    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode ? AppColors.black900 : AppColors.black100,
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.xl20.topLeft,
          topRight: AppRadius.xl20.topRight,
        ),
        boxShadow: AppShadows.topLiftThemed(_isDarkMode),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          SizedBox(height: 8.h), // Expanded(SizedBox.shrink) 자리
          _buildChatInputBarReplica(),
          SizedBox(height: AppSpacing.vertical12),
          SizedBox(height: safeBottom),
        ],
      ),
    );
  }

  /// 드래그 핸들 (실제 [ChatOverlay._buildDragHandle]와 동일)
  Widget _buildDragHandle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppSnackbar.show(
          context,
          message: AppLocalizations.of(context).tutorialInGameChatExpand,
          isDarkMode: _isDarkMode,
        );
      },
      child: SizedBox(
        height: 28.h,
        child: Center(
          child: Container(
            width: 48.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: _isDarkMode ? AppColors.black600 : AppColors.black200,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
      ),
    );
  }

  /// [ChatInputBar] 외형 정밀 복제
  Widget _buildChatInputBarReplica() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal20,
        vertical: AppSpacing.vertical8,
      ),
      color: _isDarkMode ? AppColors.black900 : AppColors.black100,
      child: GestureDetector(
        onTap: () {
          AppSnackbar.show(
            context,
            message: AppLocalizations.of(context).tutorialInGameChatInput,
            isDarkMode: _isDarkMode,
          );
        },
        child: Container(
          height: 48.h,
          padding: EdgeInsets.only(
            left: AppSpacing.horizontal20,
            right: AppSpacing.horizontal12,
          ),
          decoration: BoxDecoration(
            color: _isDarkMode ? AppColors.black : AppColors.white,
            borderRadius: AppRadius.large,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).tutorialChatHint,
                  style: AppTextStyles.label16Medium.copyWith(
                    color: _isDarkMode
                        ? AppColors.black200
                        : AppColors.black400,
                  ),
                ),
              ),
              _buildSendButtonReplica(),
            ],
          ),
        ),
      ),
    );
  }

  /// 전송 버튼 (32×32 원형, 텍스트 없으니 비활성 색상 사용)
  Widget _buildSendButtonReplica() {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: _isDarkMode ? AppColors.black900 : AppColors.black200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Transform.rotate(
          angle: -math.pi / 2,
          child: SvgPicture.asset(
            'assets/icons/icon_arrow.svg',
            width: 20.w,
            height: 20.w,
            colorFilter: ColorFilter.mode(
              _isDarkMode ? AppColors.black400 : AppColors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

/// 지도 placeholder 격자 패턴 페인터
class _MapGridPainter extends CustomPainter {
  _MapGridPainter({required this.isDarkMode});

  final bool isDarkMode;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = isDarkMode ? AppColors.black700 : AppColors.black200
      ..strokeWidth = 1;

    const double step = 40;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.isDarkMode != isDarkMode;
}
