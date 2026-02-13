import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_participant_provider.g.dart';

/// 현재 게임 참가 정보
///
/// 대기실에서 설정된 gameId, team 정보를 게임 화면까지 전달합니다.
/// participantId는 방 참여 API 연동 후 설정됩니다.
class GameParticipantInfo {
  final int gameId;
  final String team; // "POLICE" 또는 "ROBBER"
  final int? participantId; // 방 참여 API 응답에서 설정

  const GameParticipantInfo({
    required this.gameId,
    required this.team,
    this.participantId,
  });

  GameParticipantInfo copyWith({
    int? gameId,
    String? team,
    int? participantId,
  }) {
    return GameParticipantInfo(
      gameId: gameId ?? this.gameId,
      team: team ?? this.team,
      participantId: participantId ?? this.participantId,
    );
  }
}

/// 게임 참가 정보 관리 Notifier
///
/// 대기실에서 팀 선택 시 [setTeam] 호출,
/// 게임 시작 시 [setGameInfo] 호출하여 정보를 설정합니다.
@Riverpod(keepAlive: true)
class GameParticipantNotifier extends _$GameParticipantNotifier {
  @override
  GameParticipantInfo? build() => null;

  /// 게임 정보 설정 (방 생성/참여 시)
  void setGameInfo({
    required int gameId,
    String team = 'POLICE',
    int? participantId,
  }) {
    state = GameParticipantInfo(
      gameId: gameId,
      team: team,
      participantId: participantId,
    );
  }

  /// 팀 변경 (대기실에서)
  void setTeam(String team) {
    if (state != null) {
      state = state!.copyWith(team: team);
    }
  }

  /// participantId 설정 (방 참여 API 응답 후)
  void setParticipantId(int participantId) {
    if (state != null) {
      state = state!.copyWith(participantId: participantId);
    }
  }

  /// 정보 초기화 (게임 종료/퇴장 시)
  void clear() {
    state = null;
  }
}