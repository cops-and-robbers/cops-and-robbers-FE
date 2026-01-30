import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/storage/session_draft_storage_service.dart';
import '../../../../core/widgets/inputs/app_slider.dart';
import '../../../../router/route_paths.dart';
import '../widgets/session_step_layout.dart';

/// 인원 설정 화면 (2단계)
///
/// 게임 세션의 최대 참가자 수를 설정합니다.
/// AppSlider를 통해 5명부터 50명까지 설정 가능하며,
/// 설정 완료 시 데이터를 로컬 저장소에 저장한 후 다음 단계로 진행합니다.
class SessionSettingsPage extends StatefulWidget {
  const SessionSettingsPage({super.key});

  @override
  State<SessionSettingsPage> createState() => _SessionSettingsPageState();
}

class _SessionSettingsPageState extends State<SessionSettingsPage> {
  // ============================================
  // State Variables
  // ============================================

  /// 최대 참가자 수
  int _maxParticipants = 30; // 기본값: 30명

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
        _maxParticipants = draft?.maxParticipants ?? 30;
        _isLoading = false;
      });
    }
  }

  // ============================================
  // Event Handlers
  // ============================================

  /// 다음 버튼 클릭 시
  Future<void> _onNextPressed() async {
    // 로컬 저장소에 저장
    await _storageService.updateMaxParticipants(_maxParticipants);

    // 다음 페이지로 이동 (3단계: 기본정보 설정)
    if (mounted) {
      context.go(RoutePaths.gameSettingsPath);
    }
  }

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    return SessionStepLayout(
      currentStep: 1,
      title: '인원을 설정해요',
      description: '최소 5명부터 게임 진행이 가능해요',
      content: _buildMaxParticipantsSlider(),
      onNext: _onNextPressed,
      onPrevious: () => context.go(RoutePaths.selectArea),
      isLoading: _isLoading,
    );
  }

  /// 최대 참가자 수 슬라이더
  Widget _buildMaxParticipantsSlider() {
    return AppSlider(
      label: '최대 참가자',
      value: _maxParticipants.toDouble(),
      min: 5,
      max: 50,
      unit: '명',
      divisions: 45, // 5~50, 1명 단위
      onChanged: (value) {
        setState(() {
          _maxParticipants = value.toInt();
        });
      },
    );
  }
}
