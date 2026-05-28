import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../lobby/data/models/lobby_event_dto.dart';

part 'waiting_room_participants_provider.g.dart';

/// 대기실 참가자 목록 상태
class WaitingRoomParticipantsState {
  final List<LobbyParticipantInfo> participants;
  final int? hostParticipantId;

  const WaitingRoomParticipantsState({
    this.participants = const [],
    this.hostParticipantId,
  });

  /// 팀별 참가자 필터
  List<LobbyParticipantInfo> byTeam(String team) => participants
      .where((p) => p.team.toUpperCase() == team.toUpperCase())
      .toList();

  WaitingRoomParticipantsState copyWith({
    List<LobbyParticipantInfo>? participants,
    int? hostParticipantId,
  }) {
    return WaitingRoomParticipantsState(
      participants: participants ?? this.participants,
      hostParticipantId: hostParticipantId ?? this.hostParticipantId,
    );
  }
}

/// 대기실 참가자 목록 관리 Notifier
///
/// 흐름: WaitingRoomPage에서 fetchLobbyInfoProvider로 초기 목록 조회 →
/// [initFromApi]로 상태 초기화 → 이후 STOMP 로비 이벤트로 증분 업데이트.
@riverpod
class WaitingRoomParticipants extends _$WaitingRoomParticipants {
  @override
  WaitingRoomParticipantsState build() => const WaitingRoomParticipantsState();

  /// 방장 설정
  void setHost(int participantId) {
    state = state.copyWith(hostParticipantId: participantId);
  }

  /// 로비 조회 응답으로 초기 참가자 목록 및 방장 설정.
  ///
  /// WaitingRoomPage가 fetchLobbyInfoProvider(gameId) 결과를 받아 호출하며,
  /// 이후 STOMP 로비 이벤트는 _listenLobbyEvents()에서 증분 업데이트만 담당.
  void initFromApi({
    required List<LobbyParticipantInfo> participants,
    required int hostParticipantId,
  }) {
    state = WaitingRoomParticipantsState(
      participants: participants,
      hostParticipantId: hostParticipantId,
    );
  }

  /// [임시] 더미 데이터 로드 (서버 미연동 시 UI 확인용)
  ///
  /// participantId=3이 나(방장), 나머지는 전원 준비 완료 상태.
  /// → 방장 왕관 표시 및 게임 시작 버튼 활성화 확인 가능.
  void loadDummyData() {
    state = WaitingRoomParticipantsState(
      hostParticipantId: 3,
      participants: const [
        LobbyParticipantInfo(
          participantId: 3,
          nickname: '포근포근곰...',
          team: 'POLICE',
          isReady: false,
        ),
        LobbyParticipantInfo(
          participantId: 1,
          nickname: '오동통 너구리',
          team: 'POLICE',
          isReady: true,
        ),
        LobbyParticipantInfo(
          participantId: 2,
          nickname: '닉네임',
          team: 'POLICE',
          isReady: true,
        ),
        LobbyParticipantInfo(
          participantId: 4,
          nickname: '닉네임',
          team: 'ROBBER',
          isReady: true,
        ),
      ],
    );
  }

  /// 로비 이벤트 처리
  void handleLobbyEvent(LobbyEventDto event) {
    debugPrint('[WaitingRoomParticipants] 이벤트 처리: ${event.type}');

    switch (event.type) {
      case LobbyEventType.enter:
        _handleEnter(event.data);
      case LobbyEventType.exit:
        _handleExit(event.data);
      case LobbyEventType.teamUpdate:
        _handleUpdate(event.data);
      case LobbyEventType.readyUpdate:
        _handleUpdate(event.data);
      case LobbyEventType.hostChanged:
        _handleHostChanged(event.data);
      case LobbyEventType.kicked:
        _handleKicked(event.data);
      default:
        break;
    }
  }

  /// data에서 participant 정보를 추출
  ///
  /// 서버 이벤트 data 구조 (이벤트별 키가 다름):
  /// - ENTER: `{ "newParticipant": { ... } }` 또는 `{ "participant": { ... } }`
  /// - HOST_CHANGED: `{ "newHost": { ... } }` 또는 `{ "participant": { ... } }`
  /// - 기타: `{ "participant": { ... } }` 또는 직접 포함
  Map<String, dynamic> _extractParticipant(Map<String, dynamic> data) {
    // 서버 명세 우선 키
    for (final key in ['newParticipant', 'newHost', 'participant']) {
      if (data.containsKey(key) && data[key] is Map) {
        return data[key] as Map<String, dynamic>;
      }
    }
    return data;
  }

  void _handleEnter(Map<String, dynamic> data) {
    try {
      final participantData = _extractParticipant(data);
      final info = LobbyParticipantInfo.fromJson(participantData);
      if (!state.participants.any(
        (p) => p.participantId == info.participantId,
      )) {
        state = state.copyWith(participants: [...state.participants, info]);
      }
    } catch (e) {
      debugPrint('[WaitingRoomParticipants] ENTER 파싱 실패: $e');
    }
  }

  void _handleExit(Map<String, dynamic> data) {
    // 서버 EXIT data: { "exitedParticipantId": 37, "currentCount": 1, "maxCount": 27 }
    final pid =
        data['exitedParticipantId'] as int? ?? data['participantId'] as int?;
    if (pid == null) return;
    state = state.copyWith(
      participants: state.participants
          .where((p) => p.participantId != pid)
          .toList(),
    );
  }

  void _handleUpdate(Map<String, dynamic> data) {
    try {
      final participantData = _extractParticipant(data);
      final info = LobbyParticipantInfo.fromJson(participantData);
      final exists = state.participants.any(
        (p) => p.participantId == info.participantId,
      );

      if (!exists) {
        // 초기 fetch와 STOMP 이벤트 사이 race condition 방어 — 목록에 없는
        // 참가자의 UPDATE 이벤트가 먼저 도달하면 신규 ENTER로 간주해 추가한다.
        state = state.copyWith(participants: [...state.participants, info]);
        return;
      }

      final old = state.participants.firstWhere(
        (p) => p.participantId == info.participantId,
      );
      final teamChanged = old.team.toUpperCase() != info.team.toUpperCase();

      if (teamChanged) {
        // 팀 변경 시 기존 위치에서 제거 후 맨 뒤에 추가 → 새 팀 마지막 위치
        final updated =
            state.participants
                .where((p) => p.participantId != info.participantId)
                .toList()
              ..add(info);
        state = state.copyWith(participants: updated);
      } else {
        state = state.copyWith(
          participants: state.participants
              .map((p) => p.participantId == info.participantId ? info : p)
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('[WaitingRoomParticipants] UPDATE 파싱 실패: $e');
    }
  }

  void _handleHostChanged(Map<String, dynamic> data) {
    // 서버 HOST_CHANGED data: { "participant": { "participantId": ... } }
    // 또는 { "newHostParticipantId": ... } 등 다양한 형태 대응
    final participantData = _extractParticipant(data);
    final newHostId =
        participantData['participantId'] as int? ??
        data['newHostParticipantId'] as int?;
    if (newHostId != null) {
      state = state.copyWith(hostParticipantId: newHostId);
    }
  }

  void _handleKicked(Map<String, dynamic> data) {
    // 서버 KICKED data: { "kickedParticipantId": 3, "nickname": "도둑1" }
    final pid = data['kickedParticipantId'] as int?;
    if (pid == null) return;
    state = state.copyWith(
      participants: state.participants
          .where((p) => p.participantId != pid)
          .toList(),
    );
  }

  /// [임시] 더미 참가자 준비 상태 토글
  void toggleDummyReady(int participantId) {
    state = state.copyWith(
      participants: state.participants.map((p) {
        if (p.participantId == participantId) {
          return LobbyParticipantInfo(
            participantId: p.participantId,
            nickname: p.nickname,
            team: p.team,
            isReady: !p.isReady,
          );
        }
        return p;
      }).toList(),
    );
  }

  /// [임시] 더미 참가자 팀 변경
  void changeDummyTeam(int participantId, String newTeam) {
    final target = state.participants.firstWhere(
      (p) => p.participantId == participantId,
    );
    final moved = LobbyParticipantInfo(
      participantId: target.participantId,
      nickname: target.nickname,
      team: newTeam,
      isReady: target.isReady,
    );
    final updated =
        state.participants
            .where((p) => p.participantId != participantId)
            .toList()
          ..add(moved);
    state = state.copyWith(participants: updated);
  }

  /// 상태 초기화
  void clear() {
    state = const WaitingRoomParticipantsState();
  }
}
