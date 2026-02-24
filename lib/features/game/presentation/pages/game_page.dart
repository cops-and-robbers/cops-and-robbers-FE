import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/svg_icon_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../router/route_paths.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/widgets/chat_overlay.dart';
import '../../../session/presentation/providers/game_participant_provider.dart';
import '../../../session/presentation/providers/session_provider.dart';
import '../../../session/presentation/widgets/game_rules_content.dart';
import '../widgets/google_map_view.dart';
import '../widgets/naver_map_view.dart';
import '../widgets/participant_overlay.dart';

/// 인게임 지도 화면
///
/// 게임 진행 중 사용되는 메인 화면
class GamePage extends ConsumerStatefulWidget {
  const GamePage({
    required this.sessionId,
    required this.mapType,
    required this.team,
    required this.participantId,
    this.isDummy = false,
    super.key,
  });

  /// 게임 세션 ID
  final String sessionId;

  /// 지도 타입 ('google' 또는 'naver')
  final String mapType;

  /// 플레이어 팀 ('POLICE' 또는 'ROBBER')
  final String team;

  /// 플레이어 참가자 ID
  final int participantId;

  /// 더미 모드 (서버 미연동 시 UI 테스트용)
  final bool isDummy;

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  final _googleMapKey = GlobalKey<GoogleMapViewState>();
  final _naverMapKey = GlobalKey<NaverMapViewState>();
  bool _showParticipants = false;

  @override
  void initState() {
    super.initState();
    _connectChat();
  }

  @override
  void dispose() {
    ref.read(chatNotifierProvider.notifier).disconnectChat();
    super.dispose();
  }

  /// 채팅 연결 및 구독
  void _connectChat() {
    final team = widget.team.toLowerCase();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isDummy) {
        ref
            .read(chatNotifierProvider.notifier)
            .enableDummyMode(participantId: widget.participantId, team: team);
      } else {
        final gameId = int.tryParse(widget.sessionId) ?? 1;
        ref
            .read(chatNotifierProvider.notifier)
            .connectAndSubscribe(gameId: gameId, team: team);
      }
    });
  }

  void _moveToCurrentLocation() {
    if (widget.mapType == 'naver') {
      _naverMapKey.currentState?.moveCameraToCurrentLocation();
    } else {
      _googleMapKey.currentState?.moveCameraToCurrentLocation();
    }
  }

  /// 게임 규칙 다이얼로그 (앱바 우측 info 버튼)
  ///
  /// 대기실과 동일한 GameRulesContent를 표시합니다.
  void _showGameRulesDialog() {
    final interval = ref
        .read(gameParticipantNotifierProvider)
        ?.locationRevealIntervalMinutes;
    AppDialog.show(
      context: context,
      title: '게임 규칙',
      customContent: GameRulesContent(locationRevealIntervalMinutes: interval),
      confirmText: '확인했어요!',
      confirmColor: AppColors.blue,
      confirmTextColor: AppColors.white,
    );
  }

  /// 게임 퇴장
  // TODO: 디자인에 나가기 버튼 없음 — 추후 삭제 예정
  Future<void> _leaveGame(BuildContext context) async {
    final gameId = int.tryParse(widget.sessionId);
    if (gameId != null) {
      await ref.read(leaveGameProvider(gameId).future);
    }
    ref.read(gameParticipantNotifierProvider.notifier).clear();
    if (context.mounted) {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 지도 (전체 화면)
          Positioned.fill(
            child: widget.mapType == 'naver'
                ? NaverMapView(key: _naverMapKey)
                : GoogleMapView(key: _googleMapKey),
          ),

          /// 참가자 목록 오버레이 (지도 위에 표시)
          if (_showParticipants)
            Positioned.fill(
              child: Container(
                color: AppColors.white,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: ParticipantOverlay(
                          onClose: () =>
                              setState(() => _showParticipants = false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          /// 참가자 모드: 지도 복귀 버튼 (위치 버튼과 동일한 위치)
          if (_showParticipants)
            Positioned(
              right: 20.w,
              bottom: 145.h,
              child: SvgIconButton(
                assetPath: 'assets/icons/icon_map.svg',
                onPressed: () => setState(() => _showParticipants = false),
                containerSize: 48,
                iconSize: 24,
                iconColor: AppColors.blue,
              ),
            ),

          /// 지도 모드일 때만 표시
          if (!_showParticipants) ...[
            /// 상단 앱바 (상태바 영역까지 흰색 배경)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.white,
                child: SafeArea(bottom: false, child: _buildAppBar()),
              ),
            ),

            /// 알림 배너 (지도 위에 플로팅)
            SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 64.h + 8.h),
                  _buildAlertBanner(),
                ],
              ),
            ),

            /// 우측 하단 버튼 (사람, 현위치)
            Positioned(
              right: 20.w,
              bottom: 145.h,
              child: Column(
                children: [
                  SvgIconButton(
                    assetPath: 'assets/icons/icon_person.svg',
                    onPressed: () => setState(() => _showParticipants = true),
                    containerSize: 48,
                    iconSize: 24,
                    iconColor: AppColors.blue,
                  ),
                  SizedBox(height: 8.h),
                  SvgIconButton(
                    assetPath: 'assets/icons/mage_location-fill.svg',
                    onPressed: _moveToCurrentLocation,
                    containerSize: 48,
                    iconSize: 24,
                  ),
                ],
              ),
            ),
          ],

          /// 하단 채팅 오버레이 (항상 표시)
          ChatOverlay(
            gameId: int.tryParse(widget.sessionId) ?? 1,
            myParticipantId: widget.participantId,
            myTeam: widget.team,
          ),
        ],
      ),
    );
  }

  /// 상단 앱바 (흰색 배경, 높이 64px)
  ///
  /// 대기실 등 다른 페이지 앱바 스타일과 동일.
  Widget _buildAppBar() {
    return Container(
      height: 64.h,
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 좌측: 나가기 버튼
          // TODO: 디자인에 나가기 버튼 없음 — 추후 삭제 예정
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => _leaveGame(context),
              child: SvgPicture.asset(
                'assets/icons/icon_previous.svg',
                width: 24.w,
                height: 24.w,
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          // 중앙: 타이머 + 서브 타이머
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO: 서버 타이머 연동
              Text(
                '25:00',
                style: AppTextStyles.heading_20.copyWith(
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 6.h),
              // TODO: 서버 타이머 연동
              Text(
                '다음 도둑 위치 공개까지 00:00',
                style: AppTextStyles.tag_12.copyWith(color: AppColors.red),
              ),
            ],
          ),
          // 우측: info 버튼 (24x24)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _showGameRulesDialog,
              child: SvgPicture.asset(
                'assets/icons/icon_info.svg',
                width: 24.w,
                height: 24.w,
                colorFilter: const ColorFilter.mode(
                  AppColors.black800,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 알림 배너 (353x44)
  // TODO: 서버 이벤트 연동 — 현재 하드코딩된 텍스트
  Widget _buildAlertBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.only(left: 16.w),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/Loudspeaker.svg',
              width: 20.w,
              height: 20.w,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '현재 도둑의 위치가 공개됩니다!',
              style: AppTextStyles.paragraph14Semibold.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
