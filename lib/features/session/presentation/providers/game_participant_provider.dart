import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_participant_provider.g.dart';

/// 현재 게임 참가 정보
///
/// 대기실에서 설정된 gameId, team 정보를 게임 화면까지 전달합니다.
/// participantId는 방 참여 API 연동 후 설정됩니다.
class GameParticipantInfo {
  final int gameId;

  /// 팀 ("POLICE" 또는 "ROBBER")
  final String team;

  /// 방 참여 API 응답에서 설정 (방 참여 전 null)
  final int? participantId;

  /// 본인 닉네임 (STOMP 이벤트 매칭용)
  final String nickname;

  /// 최대 참가 인원
  final int? maxParticipants;

  /// 위치 공개 주기 (분)
  final int? locationRevealIntervalMinutes;

  /// 방장 여부
  final bool isHost;

  const GameParticipantInfo({
    required this.gameId,
    required this.team,
    required this.nickname,
    this.participantId,
    this.maxParticipants,
    this.locationRevealIntervalMinutes,
    this.isHost = false,
  });

  GameParticipantInfo copyWith({
    int? gameId,
    String? team,
    String? nickname,
    int? participantId,
    int? maxParticipants,
    int? locationRevealIntervalMinutes,
    bool? isHost,
  }) {
    return GameParticipantInfo(
      gameId: gameId ?? this.gameId,
      team: team ?? this.team,
      nickname: nickname ?? this.nickname,
      participantId: participantId ?? this.participantId,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      locationRevealIntervalMinutes:
          locationRevealIntervalMinutes ?? this.locationRevealIntervalMinutes,
      isHost: isHost ?? this.isHost,
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
    required String nickname,
    String team = 'POLICE',
    int? participantId,
    int? maxParticipants,
    int? locationRevealIntervalMinutes,
    bool isHost = false,
  }) {
    state = GameParticipantInfo(
      gameId: gameId,
      nickname: nickname,
      team: team,
      participantId: participantId,
      maxParticipants: maxParticipants,
      locationRevealIntervalMinutes: locationRevealIntervalMinutes,
      isHost: isHost,
    );
  }

  /// 팀 변경 (대기실에서)
  void setTeam(String team) {
    if (state != null) {
      state = state!.copyWith(team: team);
    }
  }

  /// 방장 여부 설정 (HOST_CHANGED 이벤트 시)
  void setIsHost(bool isHost) {
    if (state != null) {
      state = state!.copyWith(isHost: isHost);
    }
  }

  /// participantId 설정 (방 참여 API 응답 후)
  void setParticipantId(int participantId) {
    if (state != null) {
      state = state!.copyWith(participantId: participantId);
    }
  }

  /// 로비 조회 API 응답으로 정보 초기화
  ///
  /// [participantId], [team]은 서버가 반환한 값으로 덮어씁니다.
  /// [team]이 null이면 기존 팀을 유지합니다.
  void initFromLobby({
    required int participantId,
    String? team,
    int? maxParticipants,
    int? locationRevealIntervalMinutes,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      participantId: participantId,
      team: team,
      maxParticipants: maxParticipants,
      locationRevealIntervalMinutes: locationRevealIntervalMinutes,
    );
  }

  /// 정보 초기화 (게임 종료/퇴장 시)
  void clear() {
    state = null;
  }
}
