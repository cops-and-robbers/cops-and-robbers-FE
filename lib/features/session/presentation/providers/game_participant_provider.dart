import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/game_team.dart';

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

  /// 경찰 대기 시간 (분) — 게임 시작 후 경찰이 이동할 수 없는 시간
  final int? policeWaitMinutes;

  /// 라운드 제한 시간 (분) — 앱바 카운트다운 타이머용
  final int? roundTimeMinutes;

  /// 게임 시작 시각 (GAME_START 이벤트의 startTime, ISO 8601)
  final String? gameStartTime;

  /// 방장 여부
  final bool isHost;

  /// 방장 participantId (참가자 오버레이 정렬용)
  final int? hostParticipantId;

  const GameParticipantInfo({
    required this.gameId,
    required this.team,
    required this.nickname,
    this.participantId,
    this.maxParticipants,
    this.locationRevealIntervalMinutes,
    this.policeWaitMinutes,
    this.roundTimeMinutes,
    this.gameStartTime,
    this.isHost = false,
    this.hostParticipantId,
  });

  GameParticipantInfo copyWith({
    int? gameId,
    String? team,
    String? nickname,
    int? participantId,
    int? maxParticipants,
    int? locationRevealIntervalMinutes,
    int? policeWaitMinutes,
    int? roundTimeMinutes,
    String? gameStartTime,
    bool? isHost,
    int? hostParticipantId,
  }) {
    return GameParticipantInfo(
      gameId: gameId ?? this.gameId,
      team: team ?? this.team,
      nickname: nickname ?? this.nickname,
      participantId: participantId ?? this.participantId,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      locationRevealIntervalMinutes:
          locationRevealIntervalMinutes ?? this.locationRevealIntervalMinutes,
      policeWaitMinutes: policeWaitMinutes ?? this.policeWaitMinutes,
      roundTimeMinutes: roundTimeMinutes ?? this.roundTimeMinutes,
      gameStartTime: gameStartTime ?? this.gameStartTime,
      isHost: isHost ?? this.isHost,
      hostParticipantId: hostParticipantId ?? this.hostParticipantId,
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
    String team = GameTeam.police,
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

  /// 게임 시작 시각 저장 (GAME_START 이벤트 수신 시)
  void setGameStartTime(String startTime) {
    if (state != null) {
      state = state!.copyWith(gameStartTime: startTime);
    }
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
    int? policeWaitMinutes,
    int? roundTimeMinutes,
    int? hostParticipantId,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      participantId: participantId,
      team: team,
      maxParticipants: maxParticipants,
      locationRevealIntervalMinutes: locationRevealIntervalMinutes,
      policeWaitMinutes: policeWaitMinutes,
      roundTimeMinutes: roundTimeMinutes,
      hostParticipantId: hostParticipantId,
    );
  }

  /// 방장 participantId 설정 (HOST_CHANGED 이벤트 시)
  void setHostParticipantId(int hostParticipantId) {
    if (state != null) {
      state = state!.copyWith(hostParticipantId: hostParticipantId);
    }
  }

  /// 게임 설정 업데이트 (SETTINGS_UPDATED 이벤트 시)
  void updateSettings({
    int? maxParticipants,
    int? locationRevealIntervalMinutes,
    int? policeWaitMinutes,
    int? roundTimeMinutes,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      maxParticipants: maxParticipants,
      locationRevealIntervalMinutes: locationRevealIntervalMinutes,
      policeWaitMinutes: policeWaitMinutes,
      roundTimeMinutes: roundTimeMinutes,
    );
  }

  /// 정보 초기화 (게임 종료/퇴장 시)
  void clear() {
    state = null;
  }
}
