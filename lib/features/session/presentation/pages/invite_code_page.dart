import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/indicators/step_indicator.dart';
import '../../../../router/route_paths.dart';
import '../../domain/entities/session_settings.dart';
import '../../domain/entities/zone_info.dart';
import '../widgets/session_info_view.dart';

/// 초대 코드 생성 및 공유 화면 (4단계)
///
/// 생성된 게임 세션의 초대 코드를 표시하고,
/// SessionInfoView를 통해 설정한 모든 정보를 보여줍니다.
///
/// **사용 예시**:
/// ```dart
/// context.go('${RoutePaths.inviteCodePath}/$inviteCode');
/// ```
class InviteCodePage extends StatefulWidget {
  const InviteCodePage({super.key, required this.inviteCode});

  /// API로부터 받은 초대 코드
  final String inviteCode;

  @override
  State<InviteCodePage> createState() => _InviteCodePageState();
}

class _InviteCodePageState extends State<InviteCodePage> {
  // ============================================
  // State Variables
  // ============================================

  /// 로딩 상태
  bool _isLoading = true;

  /// 구역 정보 리스트
  List<ZoneInfo> _zones = [];

  /// 게임 설정 정보
  SessionSettings? _settings;

  /// 로컬 저장소 서비스
  final _storageService = SessionDraftStorageService();

  // ============================================
  // Lifecycle Methods
  // ============================================

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  /// 저장된 세션 데이터 불러오기
  Future<void> _loadSessionData() async {
    final draft = await _storageService.loadDraft();

    if (draft != null && mounted) {
      // 구역 정보 생성
      final zones = <ZoneInfo>[];

      if (draft.playgroundCenter != null &&
          draft.playgroundRadiusInMeters != null) {
        zones.add(
          ZoneInfo(
            id: '1',
            name: '플레이그라운드',
            radiusMeters: draft.playgroundRadiusInMeters!.toInt(),
          ),
        );
      }

      if (draft.jailCenter != null && draft.jailRadiusInMeters != null) {
        zones.add(
          ZoneInfo(
            id: '2',
            name: '감옥',
            radiusMeters: draft.jailRadiusInMeters!.toInt(),
          ),
        );
      }

      // 게임 설정 생성
      final settings = SessionSettings(
        maxPlayers: draft.maxParticipants ?? 30,
        roundTimeMinutes: draft.roundDurationMinutes ?? 30,
        locationShareSeconds: (draft.locationRevealIntervalMinutes ?? 5) * 60,
        policeStartDelayMinutes: draft.policeWaitMinutes ?? 5,
      );

      setState(() {
        _zones = zones;
        _settings = settings;
        _isLoading = false;
      });
    } else {
      // 데이터가 없으면 기본값 설정
      setState(() {
        _zones = [
          const ZoneInfo(id: '1', name: '플레이그라운드', radiusMeters: 500),
          const ZoneInfo(id: '2', name: '감옥', radiusMeters: 100),
        ];
        _settings = const SessionSettings(
          maxPlayers: 30,
          roundTimeMinutes: 30,
          locationShareSeconds: 300,
          policeStartDelayMinutes: 5,
        );
        _isLoading = false;
      });
    }
  }

  // ============================================
  // Event Handlers
  // ============================================

  /// 코드 복사 버튼 클릭 시
  void _onCodeCopy() {
    Clipboard.setData(ClipboardData(text: widget.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('초대 코드가 복사되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 대기실 입장 버튼 클릭 시
  void _onEnterWaitingRoom() {
    context.go(RoutePaths.waitingRoomWithId(widget.inviteCode));
  }

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    // 로딩 중일 때는 로딩 인디케이터 표시
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.black800),
          title: const StepIndicator(totalSteps: 4, currentStep: 3),
          centerTitle: false,
          actions: [SizedBox(width: AppSpacing.horizontal4)],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 로딩 완료 후 정상 UI 렌더링
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black800),
        title: const StepIndicator(totalSteps: 4, currentStep: 3),
        centerTitle: false,
        titleSpacing: 0,
        leading: PreviousButton(
          onPressed: () => context.go(RoutePaths.gameSettingsPath),
        ),
        actions: [SizedBox(width: AppSpacing.horizontal20)],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.vertical16),

              // 제목 및 설명
              _buildHeader(),

              SizedBox(height: AppSpacing.vertical28),

              // SessionInfoView (세션 코드, 구역 정보, 게임 설정)
              Expanded(
                child: SessionInfoView(
                  sessionCode: widget.inviteCode,
                  zones: _zones,
                  settings: _settings!,
                  onCodeCopy: _onCodeCopy,
                ),
              ),

              SizedBox(height: AppSpacing.vertical20),

              // 대기실 입장 버튼
              _buildEnterButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더 섹션 (제목 + 설명)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            '초대 코드를 생성했어요',
            style: AppTextStyles.heading_24.copyWith(color: AppColors.black),
          ),
          SizedBox(height: AppSpacing.vertical16),

          // 설명
          Text(
            '친구에게 아래 코드를 공유하고 함께 게임에 참여해요',
            style: AppTextStyles.paragraph_14_100.copyWith(
              color: AppColors.black600,
            ),
          ),
        ],
      ),
    );
  }

  /// 대기실 입장 버튼
  Widget _buildEnterButton() {
    return AppButton(
      text: '참여하기',
      onPressed: _onEnterWaitingRoom,
      showBorder: false,
    );
  }
}
