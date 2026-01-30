import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/inputs/app_slider.dart';
import '../../../../router/route_paths.dart';
import '../../data/models/create_session_request.dart';
import '../widgets/session_step_layout.dart';

/// 기본 정보 설정 화면 (3단계)
///
/// 게임 규칙을 설정합니다:
/// - 라운드 제한 시간 (10~60분)
/// - 위치 공유 간격 (1~10분)
/// - 경찰 시작 시간 (도둑 시작 후 1~10분 뒤)
///
/// 설정 완료 시 데이터를 로컬 저장소에 저장한 후 초대 코드 페이지로 진행합니다.
class GameSettingsPage extends StatefulWidget {
  const GameSettingsPage({super.key});

  @override
  State<GameSettingsPage> createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends State<GameSettingsPage> {
  // ============================================
  // State Variables
  // ============================================

  /// 라운드 제한 시간 (분)
  int _roundDurationMinutes = 30; // 기본값: 30분

  /// 위치 공유 간격 (분)
  int _locationRevealIntervalMinutes = 5; // 기본값: 5분

  /// 경찰 시작 시간 (분, 도둑 시작 후)
  int _policeWaitMinutes = 5; // 기본값: 5분

  /// 로딩 상태 (데이터 로드 중 여부)
  bool _isLoading = true;

  /// 로컬 저장소 서비스
  final _storageService = SessionDraftStorageService();

  // ============================================
  // Lifecycle Methods
  // ============================================

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  /// 기존에 저장된 데이터 불러오기 (재설정 시)
  Future<void> _loadExistingData() async {
    final draft = await _storageService.loadDraft();
    if (mounted) {
      setState(() {
        _roundDurationMinutes = draft?.roundDurationMinutes ?? 30;
        _locationRevealIntervalMinutes =
            draft?.locationRevealIntervalMinutes ?? 5;
        _policeWaitMinutes = draft?.policeWaitMinutes ?? 5;
        _isLoading = false;
      });
    }
  }

  // ============================================
  // Event Handlers
  // ============================================

  /// 다음 버튼 클릭 시
  Future<void> _onNextPressed() async {
    // 1. 로컬 저장소에 게임 설정 저장
    await _storageService.updateGameSettings(
      roundDurationMinutes: _roundDurationMinutes,
      locationRevealIntervalMinutes: _locationRevealIntervalMinutes,
      policeWaitMinutes: _policeWaitMinutes,
    );

    // 2. 로컬 저장소에서 전체 데이터 로드
    final draft = await _storageService.loadDraft();

    // 3. 필수 데이터 검증
    if (draft == null ||
        draft.playgroundCenter == null ||
        draft.jailCenter == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('구역 정보가 없습니다. 처음부터 다시 설정해주세요.')),
        );
      }
      return;
    }

    // 4. CreateSessionRequest 생성
    final request = CreateSessionRequest(
      playgroundLatitude: draft.playgroundCenter!.latitude,
      playgroundLongitude: draft.playgroundCenter!.longitude,
      playgroundRadiusInMeters: draft.playgroundRadiusInMeters ?? 500,
      jailLatitude: draft.jailCenter!.latitude,
      jailLongitude: draft.jailCenter!.longitude,
      jailRadiusInMeters: draft.jailRadiusInMeters ?? 100,
      roundDurationMinutes: _roundDurationMinutes,
      locationRevealIntervalMinutes: _locationRevealIntervalMinutes,
      policeWaitMinutes: _policeWaitMinutes,
      maxParticipants: draft.maxParticipants ?? 30,
    );

    // TODO: 5. API 호출 (현재는 하드코딩된 응답 사용)
    // final response = await sessionRepository.createSession(request);
    // API 연동 시 실제 엔드포인트로 POST 요청
    // 예: POST /api/sessions
    //
    // 임시 하드코딩 응답 (디버깅용)
    const inviteCode = 'ABC123';

    debugPrint('📤 세션 생성 요청 데이터:');
    debugPrint(
      '  - 플레이그라운드: (${draft.playgroundCenter!.latitude}, ${draft.playgroundCenter!.longitude}), 반경: ${draft.playgroundRadiusInMeters}m',
    );
    debugPrint(
      '  - 감옥: (${draft.jailCenter!.latitude}, ${draft.jailCenter!.longitude}), 반경: ${draft.jailRadiusInMeters}m',
    );
    debugPrint(
      '  - 게임 설정: 라운드 $_roundDurationMinutes분, 위치 공유 $_locationRevealIntervalMinutes분, 경찰 대기 $_policeWaitMinutes분',
    );
    debugPrint('  - 최대 참가자: ${draft.maxParticipants}명');
    debugPrint('  - 요청 객체: $request');
    debugPrint('📥 세션 생성 응답 (TODO): inviteCode=$inviteCode');

    // 6. 초대 코드 페이지로 이동 (초대 코드만 전달)
    if (mounted) {
      context.go('${RoutePaths.inviteCodePath}/$inviteCode');
    }
  }

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    return SessionStepLayout(
      currentStep: 2,
      title: '기본 정보를 설정해요',
      description: '게임을 진행할 때, 꼭 필요한 정보들이에요',
      content: Column(
        children: [
          _buildRoundDurationSlider(),
          SizedBox(height: AppSpacing.vertical20),
          _buildLocationIntervalSlider(),
          SizedBox(height: AppSpacing.vertical20),
          _buildPoliceWaitSlider(),
        ],
      ),
      onNext: _onNextPressed,
      onPrevious: () => context.go(RoutePaths.sessionSettingsPath),
      isLoading: _isLoading,
    );
  }

  /// 라운드 제한 시간 슬라이더
  Widget _buildRoundDurationSlider() {
    return AppSlider(
      label: '라운드 제한 시간',
      value: _roundDurationMinutes.toDouble(),
      min: 10,
      max: 60,
      unit: '분',
      divisions: 50, // 10~60, 1분 단위
      onChanged: (value) {
        setState(() {
          _roundDurationMinutes = value.toInt();
        });
      },
    );
  }

  /// 위치 공유 간격 슬라이더
  Widget _buildLocationIntervalSlider() {
    return AppSlider(
      label: '위치 공유 간격',
      value: _locationRevealIntervalMinutes.toDouble(),
      min: 1,
      max: 10,
      unit: '분',
      divisions: 9, // 1~10, 1분 단위
      onChanged: (value) {
        setState(() {
          _locationRevealIntervalMinutes = value.toInt();
        });
      },
    );
  }

  /// 경찰 시작 시간 슬라이더
  Widget _buildPoliceWaitSlider() {
    return AppSlider(
      label: '경찰 시작 시간',
      value: _policeWaitMinutes.toDouble(),
      min: 1,
      max: 10,
      unit: '분',
      displayPrefix: '도둑 시작 후',
      displaySuffix: '뒤',
      divisions: 9, // 1~10, 1분 단위
      onChanged: (value) {
        setState(() {
          _policeWaitMinutes = value.toInt();
        });
      },
    );
  }
}
