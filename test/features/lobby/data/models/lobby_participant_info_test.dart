import 'package:cops_and_robbers/features/lobby/data/models/lobby_event_dto.dart';
import 'package:cops_and_robbers/features/session/data/models/lobby_info_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 서버는 준비 상태를 없애며(BE #230) 1단계에서 isReady 를 항상 true 로 보내고,
  // 앱 강제 업데이트 뒤 2단계에서 필드를 지운다. 어느 단계 응답이 와도 대기실이 열려야 한다(#661).
  group('LobbyInfoResponse parsing', () {
    const expected = LobbyInfoResponse(
      myParticipantId: 2,
      hostParticipantId: 1,
      inviteCode: 'K7M2QX',
      participants: [
        LobbyParticipantInfo(participantId: 1, nickname: '방장', team: 'POLICE'),
        LobbyParticipantInfo(participantId: 2, nickname: '나', team: 'ROBBER'),
      ],
    );

    Map<String, dynamic> body({required bool withIsReady}) => {
      'myParticipantId': 2,
      'hostParticipantId': 1,
      'inviteCode': 'K7M2QX',
      'participants': [
        {
          'participantId': 1,
          'nickname': '방장',
          'team': 'POLICE',
          if (withIsReady) 'isReady': true,
        },
        {
          'participantId': 2,
          'nickname': '나',
          'team': 'ROBBER',
          if (withIsReady) 'isReady': false,
        },
      ],
    };

    test('parsesLobby_whenServerStillSendsIsReady', () {
      expect(LobbyInfoResponse.fromJson(body(withIsReady: true)), expected);
    });

    test('parsesLobby_whenServerDropsIsReady', () {
      expect(LobbyInfoResponse.fromJson(body(withIsReady: false)), expected);
    });
  });
}
