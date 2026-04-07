import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 스플래시 재시도 로직 단위 테스트
///
/// splash_page.dart의 _fetchActiveGameWithRetry와 동일한 패턴을
/// 독립 함수로 추출하여 테스트합니다.
/// (private 메서드를 직접 테스트할 수 없으므로 로직 패턴 검증)

/// 재시도 로직 순수 함수 (splash_page._fetchActiveGameWithRetry와 동일 패턴)
Future<T> fetchWithRetry<T>({
  required Future<T> Function() action,
  int maxRetries = 2,
  Duration delay = const Duration(seconds: 1),
}) async {
  var attempt = 0;
  while (true) {
    try {
      return await action();
    } on DioException {
      attempt++;
      if (attempt > maxRetries) rethrow;
      await Future.delayed(delay);
    }
  }
}

void main() {
  group('스플래시 재시도 로직', () {
    test('첫 번째 호출 성공 시 즉시 반환', () async {
      var callCount = 0;

      final result = await fetchWithRetry<String>(
        action: () async {
          callCount++;
          return 'success';
        },
      );

      expect(result, equals('success'));
      expect(callCount, equals(1));
    });

    test('DioException 발생 시 최대 maxRetries회 재시도', () async {
      var callCount = 0;

      final result = await fetchWithRetry<String>(
        action: () async {
          callCount++;
          if (callCount <= 2) {
            throw DioException(
              requestOptions: RequestOptions(path: '/test'),
              type: DioExceptionType.connectionTimeout,
            );
          }
          return 'success after retry';
        },
        maxRetries: 2,
        delay: Duration.zero, // 테스트에서는 딜레이 없이
      );

      expect(result, equals('success after retry'));
      expect(callCount, equals(3)); // 1차 실패 + 2차 실패 + 3차 성공
    });

    test('maxRetries 초과 시 DioException을 rethrow', () async {
      var callCount = 0;

      await expectLater(
        () => fetchWithRetry<String>(
          action: () async {
            callCount++;
            throw DioException(
              requestOptions: RequestOptions(path: '/test'),
              type: DioExceptionType.connectionTimeout,
            );
          },
          maxRetries: 2,
          delay: Duration.zero,
        ),
        throwsA(isA<DioException>()),
      );

      // 1차 + 재시도 2회 = 총 3회 호출
      expect(callCount, equals(3));
    });

    test('DioException이 아닌 에러는 재시도하지 않고 즉시 throw', () async {
      var callCount = 0;

      await expectLater(
        () => fetchWithRetry<String>(
          action: () async {
            callCount++;
            throw FormatException('파싱 에러');
          },
          maxRetries: 2,
          delay: Duration.zero,
        ),
        throwsA(isA<FormatException>()),
      );

      // FormatException은 재시도 안 함 → 1회만 호출
      expect(callCount, equals(1));
    });

    test('재시도 간 딜레이가 적용됨', () async {
      final stopwatch = Stopwatch()..start();
      var callCount = 0;

      await fetchWithRetry<String>(
        action: () async {
          callCount++;
          if (callCount <= 1) {
            throw DioException(
              requestOptions: RequestOptions(path: '/test'),
              type: DioExceptionType.connectionTimeout,
            );
          }
          return 'ok';
        },
        maxRetries: 2,
        delay: const Duration(milliseconds: 100),
      );

      stopwatch.stop();
      // 1회 재시도 × 100ms 딜레이 = 최소 100ms
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(90));
    });
  });
}
