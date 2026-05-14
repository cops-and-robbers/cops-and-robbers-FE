import 'package:cops_and_robbers/features/chat/data/models/chat_message_dto.dart';
import 'package:flutter_test/flutter_test.dart';

ChatMessageDto _dto(String timestamp) => ChatMessageDto(
  id: 'msg-1',
  gameId: 1,
  sender: const ChatSenderDto(
    participantId: 1,
    nickname: 'tester',
    team: 'POLICE',
  ),
  message: 'hi',
  timestamp: timestamp,
  scope: 'ALL',
);

void main() {
  group('ChatMessageTimestamp.localDateTime', () {
    test('KST(+09:00) 입력은 단말 local DateTime으로 정규화된다', () {
      // KST 14:30:15 = UTC 05:30:15. 단말 timezone과 무관하게
      // 절대 시각이 동일해야 한다 (단말 local 표현은 단말마다 달라짐).
      final dt = _dto('2026-01-26T14:30:15+09:00').localDateTime;

      expect(dt, isNotNull);
      expect(dt!.isUtc, false);
      expect(dt.isAtSameMomentAs(DateTime.utc(2026, 1, 26, 5, 30, 15)), true);
    });

    test('nanosecond 단위는 microsecond로 절단된다', () {
      // KST 14:30:15.123456 (789ns 절단) = UTC 05:30:15.123456.
      // microsecond getter는 ms 외 잔여 μs(0~999)만 반환하므로
      // 절대 시각으로 절단 결과를 검증한다.
      final dt = _dto('2026-01-26T14:30:15.123456789+09:00').localDateTime;

      expect(dt, isNotNull);
      expect(
        dt!.isAtSameMomentAs(DateTime.utc(2026, 1, 26, 5, 30, 15, 123, 456)),
        true,
      );
    });

    test('잘못된 입력은 null을 반환한다', () {
      expect(_dto('not-a-date').localDateTime, isNull);
    });
  });

  group('ChatMessageTimestamp.formattedTimeLocal', () {
    test('HH:MM 형식으로 단말 local 시각을 출력한다', () {
      // 단말 timezone에 의존하므로 정확한 문자열은 비교하지 않고
      // 형식(HH:MM)과 길이만 검증.
      final formatted = _dto('2026-01-26T14:30:15+09:00').formattedTimeLocal;

      expect(formatted, matches(RegExp(r'^\d{2}:\d{2}$')));
    });

    test('파싱 실패 시 빈 문자열을 반환한다', () {
      expect(_dto('bad-timestamp').formattedTimeLocal, '');
    });
  });
}
