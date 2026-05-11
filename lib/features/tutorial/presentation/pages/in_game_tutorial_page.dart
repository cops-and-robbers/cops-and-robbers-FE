import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/buttons/my_location_button.dart';
import '../../../../core/widgets/buttons/svg_icon_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../chat/presentation/widgets/chat_overlay.dart'
    show kChatOverlayCollapsedFixedHeight;
import '../../../lobby/data/models/lobby_event_dto.dart';
import '../../../session/presentation/widgets/team_section.dart';

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
class InGameTutorialPage extends StatefulWidget {
  const InGameTutorialPage({super.key});

  @override
  State<InGameTutorialPage> createState() => _InGameTutorialPageState();
}

class _InGameTutorialPageState extends State<InGameTutorialPage>
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

  /// 데모 경찰팀 (1명)
  static const List<LobbyParticipantInfo> _demoPolice = [
    LobbyParticipantInfo(
      participantId: 1,
      nickname: '경찰1',
      team: 'POLICE',
      isReady: true,
    ),
  ];

  /// 데모 도둑팀 (3명: 도주 2 + 수감 1)
  static const List<LobbyParticipantInfo> _demoRobbers = [
    LobbyParticipantInfo(
      participantId: 10,
      nickname: '도둑킹',
      team: 'ROBBER',
      isReady: false, // ALIVE → 도주 중
    ),
    LobbyParticipantInfo(
      participantId: 11,
      nickname: '도둑이게아니게',
      team: 'ROBBER',
      isReady: false, // ALIVE → 도주 중 (본인)
    ),
    LobbyParticipantInfo(
      participantId: 12,
      nickname: '잡힌도둑',
      team: 'ROBBER',
      isReady: true, // JAILED
    ),
  ];

  /// 게임 컨텍스트 상태 맵 (ParticipantCard 의 SVG 분기에 사용)
  Map<int, String> get _demoGameStatus => const {
    1: 'POLICE_WAITING',
    10: 'ALIVE',
    11: 'ALIVE',
    12: 'JAILED',
  };

  /// 미션 진행도 (0=참가자, 1=QR, 2=지도복귀, 3=완료)
  int _missionStep = 0;

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
    VibrationService.instance().buttonTap();
    setState(() => _missionStep++);
    if (_missionStep >= 3) {
      // 화면 전환(_showParticipants=false) 후 살짝 텀 두고 다이얼로그
      Future.delayed(const Duration(milliseconds: 500), _showCompletionDialog);
    }
  }

  /// 완료 다이얼로그
  void _showCompletionDialog() {
    if (!mounted) return;
    AppDialog.show<void>(
      context: context,
      title: '튜토리얼 완료!',
      message: '핵심 흐름을 익혔어요\n실제 게임에서 활용해보세요',
      confirmText: '튜토리얼 끝내기',
      onConfirm: () => context.pop(),
      isDarkMode: _isDarkMode,
    );
  }

  /// 활성 미션 타깃 버튼에 레이더 핑 펄스 애니메이션을 입힌다.
  ///
  /// 두 레이어:
  /// 1. **외곽 ring** — 팀 컬러 보더만 있는 둥근 사각형이 1.0 → 1.8로 확장하며
  ///    opacity 1.0 → 0.0 페이드아웃. 시각적으로 "핑" 신호처럼 퍼져나간다.
  /// 2. **버튼 본체** — sin 곡선 기반 1.0 → 1.18 → 1.0 부드러운 왕복.
  ///
  /// `clipBehavior: Clip.none`으로 ring이 SizedBox 경계 밖으로 자연스럽게 확장.
  Widget _pulseIfActive({required int step, required Widget child}) {
    if (_missionStep != step) return child;

    final accentColor = _isDarkMode ? AppColors.green : AppColors.blue;

    return SizedBox(
      width: 48.w,
      height: 48.w,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (_, _) {
          final t = _pulseController.value; // 0.0 → 1.0
          final ringScale = 1.0 + t * 0.8; // 1.0 → 1.8
          final ringOpacity = 1.0 - t; // 1.0 → 0.0
          final buttonScale = 1.0 + math.sin(t * math.pi) * 0.18;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Opacity(
                opacity: ringOpacity,
                child: Transform.scale(
                  scale: ringScale,
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: accentColor, width: 2.5),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
              Transform.scale(scale: buttonScale, child: child),
            ],
          );
        },
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

        // 2. 우측 액션 버튼 — 실제 GamePage와 동일하게 [참가자, 내 위치] 2개
        Positioned(
          right: 20.w,
          bottom: actionButtonBottom,
          child: Column(
            children: [
              _pulseIfActive(
                step: 0,
                child: SvgIconButton(
                  assetPath: 'assets/icons/icon_person.svg',
                  onPressed: () {
                    _tryAdvanceMission(0);
                    setState(() => _showParticipants = true);
                  },
                  containerSize: 48,
                  iconSize: 24,
                  iconColor: _isDarkMode ? AppColors.green : AppColors.blue,
                  backgroundColor: _isDarkMode ? AppColors.black : null,
                ),
              ),
              SizedBox(height: AppSpacing.vertical8),
              MyLocationButton(
                onPressed: () {
                  AppSnackbar.show(
                    context,
                    message: '내 위치로 카메라가 이동했어요',
                    isDarkMode: _isDarkMode,
                  );
                },
                isFocused: true,
                containerSize: 48,
                iconSize: 24,
                focusedColor: _isDarkMode ? AppColors.green : null,
                unfocusedColor: _isDarkMode ? AppColors.green500 : null,
                backgroundColor: _isDarkMode ? AppColors.black : null,
              ),
            ],
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
          child: SafeArea(bottom: false, child: _buildBackButton()),
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

        // 우측 액션 [지도 복귀, QR]
        Positioned(
          right: 20.w,
          bottom: actionButtonBottom,
          child: Column(
            children: [
              _pulseIfActive(
                step: 2,
                child: SvgIconButton(
                  assetPath: 'assets/icons/icon_map.svg',
                  onPressed: () {
                    _tryAdvanceMission(2);
                    setState(() => _showParticipants = false);
                  },
                  containerSize: 48,
                  iconSize: 24,
                  iconColor: _isDarkMode ? AppColors.green : AppColors.blue,
                  backgroundColor: _isDarkMode ? AppColors.black : null,
                ),
              ),
              SizedBox(height: AppSpacing.vertical8),
              _buildQrButton(),
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
          child: SafeArea(bottom: false, child: _buildBackButton()),
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
    return Container(
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
                '지도 미리보기',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: _isDarkMode ? AppColors.black400 : AppColors.black500,
                ),
              ),
              SizedBox(height: AppSpacing.vertical16),
              _buildTeamToggle(),
            ],
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
                '다음 도둑 위치 공개까지 04:30',
                style: AppTextStyles.tag_12.copyWith(
                  color: _isDarkMode ? AppColors.black400 : AppColors.red,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                AppSnackbar.show(
                  context,
                  message: '게임 룰 안내가 열려요',
                  isDarkMode: _isDarkMode,
                );
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 48.w,
                height: 48.w,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/icon_info.svg',
                    width: 24.w,
                    height: 24.w,
                    colorFilter: ColorFilter.mode(
                      _isDarkMode ? AppColors.black200 : AppColors.black800,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
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
  Widget _buildQrButton() {
    return _pulseIfActive(
      step: 1,
      child: SvgIconButton(
        assetPath: _isDarkMode
            ? 'assets/icons/icon_qr_code.svg'
            : 'assets/icons/icon_qr_scan.svg',
        onPressed: () {
          _tryAdvanceMission(1);
          AppSnackbar.show(
            context,
            message: _isDarkMode
                ? '내 수배 QR이 화면에 표시돼요. 경찰에게 보여주면 체포'
                : '카메라가 켜지고 도둑의 QR을 스캔해 체포할 수 있어요',
            isDarkMode: _isDarkMode,
          );
        },
        containerSize: 48,
        iconSize: 24,
        iconColor: _isDarkMode ? AppColors.green : AppColors.blue,
        backgroundColor: _isDarkMode ? AppColors.black : null,
      ),
    );
  }

  /// 미션 배너 — 상단 타이머 바 바로 아래에 표시.
  /// 3개 미션 모두 완료되면 숨김.
  Widget _buildMissionBanner() {
    if (_missionStep >= 3) return const SizedBox.shrink();

    const descriptions = ['참가자 보기 버튼을 눌러보세요', 'QR 버튼을 눌러보세요', '지도로 돌아가 보세요'];

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
            '미션 ${_missionStep + 1}/3',
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
            children: List.generate(3, (i) {
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

  /// 좌측 상단 뒤로가기 버튼
  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.only(left: AppSpacing.horizontal4),
      child: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/icon_previous.svg',
          width: 24.w,
          height: 24.w,
          colorFilter: ColorFilter.mode(
            _isDarkMode ? AppColors.white : AppColors.black,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () => context.pop(),
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
              _isDarkMode ? '도둑 시점 보는 중' : '경찰 시점 보는 중',
              style: AppTextStyles.tag12Semibold.copyWith(
                color: _isDarkMode ? AppColors.white : AppColors.black,
              ),
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeamSection(
            team: 'POLICE',
            members: _demoPolice,
            isExpanded: _isPoliceExpanded,
            onToggle: () =>
                setState(() => _isPoliceExpanded = !_isPoliceExpanded),
            hostParticipantId: _demoHostParticipantId,
            myParticipantId: _demoMyParticipantId,
            badge: const SizedBox.shrink(),
            isDarkMode: _isDarkMode,
            gameStatusByParticipantId: _demoGameStatus,
          ),
          Divider(
            height: 1,
            color: _isDarkMode ? AppColors.black800 : AppColors.black200,
          ),
          TeamSection(
            team: 'ROBBER',
            members: _demoRobbers,
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
                  message: '본인이 수감됐다면 카드 탭으로 탈옥을 시도할 수 있어요',
                  isDarkMode: true,
                );
              } else {
                AppSnackbar.show(
                  context,
                  message: '실제 게임에서는 QR 스캔으로 도둑을 체포해요',
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
    return RichText(
      text: TextSpan(
        style: AppTextStyles.tag_12.copyWith(color: badgeColor),
        children: [
          const TextSpan(text: '현재 '),
          TextSpan(
            text: '$count명',
            style: AppTextStyles.tag_12.copyWith(
              color: badgeBoldColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const TextSpan(text: ' 도주 중!'),
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
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 10,
            color: _isDarkMode ? AppColors.black : AppColors.black200,
          ),
        ],
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
          message: '핸들을 위로 드래그하면 채팅이 펼쳐져요',
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
            message: '여기에 메시지를 입력하면 팀/전체 채팅으로 보낼 수 있어요',
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
                  '채팅을 입력하세요',
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
