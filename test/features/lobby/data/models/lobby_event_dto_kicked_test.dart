import 'package:cops_and_robbers/features/lobby/data/models/lobby_event_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LobbyEventType.kicked 상수', () {
    test("kicked 값이 'KICKED' 문자열이다", () {
      expect(LobbyEventType.kicked, equals('KICKED'));
    });
  });

  group('LobbyEventDto.fromJson KICKED 파싱', () {
    test('KICKED 타입 이벤트를 정상 파싱한다', () {
      final json = {
        'eventId': 'evt-kick-1',
        'gameId': 42,
        'type': 'KICKED',
        'timestamp': '2026-04-09T15:30:00',
        'data': {'kickedParticipantId': 7, 'nickname': '강퇴대상'},
      };

      final dto = LobbyEventDto.fromJson(json);

      expect(dto.type, equals(LobbyEventType.kicked));
      expect(dto.eventId, equals('evt-kick-1'));
      expect(dto.gameId, equals(42));
      expect(dto.data['kickedParticipantId'], equals(7));
      expect(dto.data['nickname'], equals('강퇴대상'));
    });
  });
}
