import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../router/route_paths.dart';
import '../providers/game_participant_provider.dart';
import '../providers/session_provider.dart';

/// TODO: 임시 UI
///
/// 대기실 화면
///
/// 게임 시작 전 참가자들이 팀을 선택하고 준비 완료를 표시합니다.
///
/// ## TODO: 대기방 API 연동 (미구현)
///
/// ### 1. 방 참가 API 연동
/// - `POST /api/games/{gameId}/participants` (inviteCode 전달)
/// - 초대코드로 입장하는 사용자가 대기방 진입 시 호출
/// - 방 생성자는 createGame 응답의 gameId로 직접 진입 (별도 참가 API 불필요할 수 있음 - 백엔드 확인 필요)
///
/// ### 2. 대기방 정보 조회
/// - 참가자 목록, 초대코드 표시, 방 설정 정보 등
///
/// ### 3. 실시간 참가자 동기화
/// - WebSocket/STOMP 구독으로 참가자 입장/퇴장 실시간 반영
class WaitingRoomPage extends ConsumerStatefulWidget {
  const WaitingRoomPage({required this.sessionId, super.key});

  /// 게임 세션 ID
  final String sessionId;

  @override
  ConsumerState<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends ConsumerState<WaitingRoomPage> {
  /// 준비 상태
  bool _isReady = false;

  /// 준비 상태 변경 중
  bool _isUpdatingReady = false;

  /// 팀 변경 중
  bool _isChangingTeam = false;

  /// 팀 변경
  Future<void> _changeTeam(String targetTeam) async {
    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;

    // 현재 팀과 같으면 무시
    final currentTeam = ref.read(gameParticipantNotifierProvider)?.team;
    if (currentTeam == targetTeam) return;

    setState(() => _isChangingTeam = true);

    final success = await ref.read(
      changeTeamProvider(gameId, targetTeam: targetTeam).future,
    );

    if (success) {
      // 로컬 상태 업데이트
      ref.read(gameParticipantNotifierProvider.notifier).setTeam(targetTeam);
      // 팀 변경 시 준비 상태 해제 (서버에서 자동으로 해제됨)
      setState(() => _isReady = false);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('팀 변경에 실패했습니다.')),
        );
      }
    }

    setState(() => _isChangingTeam = false);
  }

  /// 준비 상태 토글
  Future<void> _toggleReady() async {
    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) return;

    setState(() => _isUpdatingReady = true);

    final newReadyState = !_isReady;
    final success = await ref.read(
      updateReadyProvider(gameId, isReady: newReadyState).future,
    );

    if (success) {
      setState(() => _isReady = newReadyState);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('준비 상태 변경에 실패했습니다.')),
        );
      }
    }

    setState(() => _isUpdatingReady = false);
  }

  /// 지도 선택 및 게임 시작
  Future<void> _startGame(String mapType) async {
    final gameId = int.tryParse(widget.sessionId);
    if (gameId == null) {
      debugPrint('❌ 잘못된 sessionId: ${widget.sessionId}');
      return;
    }

    debugPrint('========================================');
    debugPrint('🎮 게임 시작 요청: gameId=$gameId');
    debugPrint('========================================');

    // 게임 시작 API 호출
    final success = await ref.read(startGameProvider(gameId).future);

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게임 시작에 실패했습니다. 모든 참가자가 준비되었는지 확인해주세요.')),
        );
      }
      return;
    }

    // 게임 시작 성공 → GamePage로 이동
    final participantInfo = ref.read(gameParticipantNotifierProvider);
    final team = participantInfo?.team ?? 'POLICE';
    final participantId = participantInfo?.participantId ?? 0;

    final route =
        '${RoutePaths.gameWithId(widget.sessionId)}?mapType=$mapType&team=$team&pid=$participantId';
    debugPrint('✅ 게임 시작 성공! 이동 경로: $route');

    if (mounted) {
      context.go(route);
    }
  }

  /// 방 나가기
  Future<void> _leaveRoom() async {
    final gameId = int.tryParse(widget.sessionId);
    if (gameId != null) {
      // 서버에 퇴장 알림
      await ref.read(leaveGameProvider(gameId).future);
    }
    // 로컬 상태 초기화
    ref.read(gameParticipantNotifierProvider.notifier).clear();
    if (mounted) {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final participantInfo = ref.watch(gameParticipantNotifierProvider);
    final currentTeam = participantInfo?.team ?? 'POLICE';

    return Scaffold(
      appBar: AppBar(title: const Text('대기실')),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('대기실', style: AppTextStyles.heading_24),
              SizedBox(height: AppSpacing.vertical20),
              Text('Game ID: ${widget.sessionId}', style: AppTextStyles.label_16),
              SizedBox(height: AppSpacing.vertical32),

              // 팀 선택
              Text('팀을 선택하세요', style: AppTextStyles.paragraph_14),
              SizedBox(height: AppSpacing.vertical16),
              if (_isChangingTeam)
                const SizedBox(
                  width: 216,
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TeamButton(
                      team: 'POLICE',
                      label: '경찰',
                      color: Colors.blue,
                      isSelected: currentTeam == 'POLICE',
                      onTap: () => _changeTeam('POLICE'),
                    ),
                    const SizedBox(width: 16),
                    _TeamButton(
                      team: 'ROBBER',
                      label: '도둑',
                      color: Colors.red,
                      isSelected: currentTeam == 'ROBBER',
                      onTap: () => _changeTeam('ROBBER'),
                    ),
                  ],
                ),

              SizedBox(height: AppSpacing.vertical32),

              // 준비 버튼
              SizedBox(
                width: 200,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUpdatingReady ? null : _toggleReady,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isReady ? Colors.orange : Colors.grey[300],
                    foregroundColor: _isReady ? Colors.white : Colors.black87,
                  ),
                  child: _isUpdatingReady
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isReady ? '준비 완료 ✓' : '준비하기',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              SizedBox(height: AppSpacing.vertical48),

              // 지도 선택 안내
              Text('지도를 선택하고 게임 시작 (방장만)', style: AppTextStyles.paragraph_14),
              SizedBox(height: AppSpacing.vertical16),

              // Google Map 버튼
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _startGame('google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Google Map'),
                ),
              ),
              SizedBox(height: AppSpacing.vertical16),

              // Naver Map 버튼
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _startGame('naver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Naver Map'),
                ),
              ),

              SizedBox(height: AppSpacing.vertical48),
              ElevatedButton(
                onPressed: _leaveRoom,
                child: const Text('나가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 팀 선택 버튼
class _TeamButton extends StatelessWidget {
  const _TeamButton({
    required this.team,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String team;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              team == 'POLICE' ? Icons.local_police : Icons.directions_run,
              size: 36,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
