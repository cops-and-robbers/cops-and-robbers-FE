import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../router/route_paths.dart';

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
/// ### 3. 방 나가기 API 연동
/// - `DELETE /api/games/{gameId}/participants`
///
/// ### 4. 실시간 참가자 동기화
/// - WebSocket/STOMP 구독으로 참가자 입장/퇴장 실시간 반영
class WaitingRoomPage extends StatelessWidget {
  const WaitingRoomPage({required this.sessionId, super.key});

  /// 게임 세션 ID
  final String sessionId;

  /// 지도 선택 및 게임 시작
  void _startGame(BuildContext context, String mapType) {
    final route = '${RoutePaths.gameWithId(sessionId)}?mapType=$mapType';
    debugPrint('========================================');
    debugPrint('🎮 게임 시작 버튼 클릭');
    debugPrint('지도 타입: $mapType');
    debugPrint('이동 경로: $route');
    debugPrint('========================================');

    try {
      context.go(route);
    } catch (e, stack) {
      debugPrint('❌ 게임 시작 네비게이션 실패: $e');
      debugPrint('Stack: $stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('대기실'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('대기실', style: AppTextStyles.heading_24),
              SizedBox(height: AppSpacing.vertical20),
              Text('Session ID: $sessionId', style: AppTextStyles.label_16),
              SizedBox(height: AppSpacing.vertical64),

              // 지도 선택 안내
              Text('지도를 선택하세요', style: AppTextStyles.paragraph_14),
              SizedBox(height: AppSpacing.vertical20),

              // Google Map 버튼
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _startGame(context, 'google'),
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
                  onPressed: () => _startGame(context, 'naver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Naver Map'),
                ),
              ),

              SizedBox(height: AppSpacing.vertical64),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                child: const Text('나가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
