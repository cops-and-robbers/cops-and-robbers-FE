import 'package:cops_and_robbers/features/game/domain/qr_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QrPayload.freshFor', () {
    test('참가자 ID를 보존하고 만료시각을 now + ttl로 설정한다', () {
      final now = DateTime(2026, 4, 22, 12, 0, 0);

      final payload = QrPayload.freshFor(
        participantId: 102,
        now: now,
        ttl: const Duration(seconds: 30),
      );

      expect(payload.participantId, 102);
      expect(payload.expiresAt, DateTime(2026, 4, 22, 12, 0, 30));
    });
  });

  group('QrPayload 라운드트립 (toRaw ↔ tryParse)', () {
    test('toRaw 결과를 tryParse로 파싱하면 원본과 동등하다', () {
      final original = QrPayload(
        participantId: 102,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(1729508430000),
      );

      final parsed = QrPayload.tryParse(original.toRaw());

      expect(parsed, isNotNull);
      expect(parsed!.participantId, original.participantId);
      expect(parsed.expiresAt, original.expiresAt);
    });
  });

  group('QrPayload.tryParse 파싱 실패', () {
    test('잘못된 JSON 문자열은 null을 반환한다', () {
      expect(QrPayload.tryParse('not a json'), isNull);
    });

    test('최상위가 Map이 아니면 null을 반환한다', () {
      expect(QrPayload.tryParse('[1, 2, 3]'), isNull);
      expect(QrPayload.tryParse('42'), isNull);
      expect(QrPayload.tryParse('"string"'), isNull);
    });

    test('pid 필드가 없으면 null을 반환한다', () {
      expect(QrPayload.tryParse('{"exp": 1729508430000}'), isNull);
    });

    test('pid가 문자열이면 null을 반환한다', () {
      expect(
        QrPayload.tryParse('{"pid": "102", "exp": 1729508430000}'),
        isNull,
      );
    });

    test('exp 필드가 없으면 null을 반환한다', () {
      expect(QrPayload.tryParse('{"pid": 102}'), isNull);
    });

    test('exp가 문자열이면 null을 반환한다', () {
      expect(
        QrPayload.tryParse('{"pid": 102, "exp": "1729508430000"}'),
        isNull,
      );
    });

    test('pid가 num(double) 타입이어도 int로 정규화하여 허용한다', () {
      // 실제 JSON 파싱에서 정수가 num으로 들어올 수 있음
      final parsed = QrPayload.tryParse('{"pid": 102, "exp": 1729508430000}');
      expect(parsed, isNotNull);
      expect(parsed!.participantId, 102);
    });
  });

  group('QrPayload.isExpiredAt 만료 판정', () {
    final payload = QrPayload(
      participantId: 102,
      expiresAt: DateTime(2026, 4, 22, 12, 0, 30),
    );

    test('expiresAt 1ms 이전은 유효하다', () {
      expect(
        payload.isExpiredAt(DateTime(2026, 4, 22, 12, 0, 29, 999)),
        isFalse,
      );
    });

    test('expiresAt과 정확히 같은 시각은 만료로 판정한다', () {
      expect(payload.isExpiredAt(DateTime(2026, 4, 22, 12, 0, 30)), isTrue);
    });

    test('expiresAt 1ms 이후는 만료로 판정한다', () {
      expect(payload.isExpiredAt(DateTime(2026, 4, 22, 12, 0, 30, 1)), isTrue);
    });
  });
}
