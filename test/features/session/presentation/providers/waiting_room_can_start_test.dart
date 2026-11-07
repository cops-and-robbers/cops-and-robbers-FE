import 'package:cops_and_robbers/core/constants/game_team.dart';
import 'package:cops_and_robbers/features/lobby/data/models/lobby_event_dto.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/waiting_room_participants_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// 팀별 인원으로 대기실 상태를 만든다. 1번이 방장이다.
WaitingRoomParticipantsState _room({required int police, required int robber}) {
  var id = 1;
  return WaitingRoomParticipantsState(
    hostParticipantId: 1,
    participants: [
      for (var i = 0; i < police; i++)
        LobbyParticipantInfo(
          participantId: id++,
          nickname: 'cop$i',
          team: GameTeam.police,
        ),
      for (var i = 0; i < robber; i++)
        LobbyParticipantInfo(
          participantId: id++,
          nickname: 'robber$i',
          team: GameTeam.robber,
        ),
    ],
  );
}

void main() {
  // 서버(BE #230)는 경찰·도둑 각 1명 이상이면 시작을 받아 준다. 방장 버튼도 같은 조건이어야
  // 눌렀는데 오류가 나거나, 시작할 수 있는데 버튼이 꺼져 있는 일이 없다(#661).
  group('WaitingRoomParticipantsState.canStart', () {
    test('cannotStart_whenHostIsAlone', () {
      expect(_room(police: 1, robber: 0).canStart(isEventGame: false), isFalse);
    });

    test('cannotStart_whenEveryoneIsPolice', () {
      expect(_room(police: 4, robber: 0).canStart(isEventGame: false), isFalse);
    });

    test('cannotStart_whenEveryoneIsRobber', () {
      expect(_room(police: 0, robber: 3).canStart(isEventGame: false), isFalse);
    });

    test('canStart_whenBothTeamsHaveAtLeastOne', () {
      expect(_room(police: 1, robber: 1).canStart(isEventGame: false), isTrue);
    });

    test('cannotStart_beforeParticipantsAreLoaded', () {
      // 로비 조회 전에는 목록이 비어 있어 버튼이 꺼져 있어야 한다
      expect(
        const WaitingRoomParticipantsState().canStart(isEventGame: false),
        isFalse,
      );
    });

    test('canStart_whenTeamStringsAreLowercase', () {
      // 이벤트 data 의 팀 문자열 대소문자가 달라도 같은 팀으로 센다
      const state = WaitingRoomParticipantsState(
        participants: [
          LobbyParticipantInfo(participantId: 1, nickname: 'a', team: 'police'),
          LobbyParticipantInfo(participantId: 2, nickname: 'b', team: 'robber'),
        ],
      );
      expect(state.canStart(isEventGame: false), isTrue);
    });

    test('canStart_whenEventGame_evenIfHostIsAlone', () {
      // 이벤트 게임은 운영진만 먼저 들어오고 경찰은 시작 뒤 합류한다
      expect(_room(police: 0, robber: 1).canStart(isEventGame: true), isTrue);
    });
  });
}
