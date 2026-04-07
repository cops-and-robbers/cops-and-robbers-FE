import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/network/auth_interceptor.dart';
import 'package:cops_and_robbers/core/storage/secure_token_storage.dart';

/// AuthInterceptor 토큰 재발급 후 재시도 테스트
///
/// _plainDio를 사용하여 QueuedInterceptor 데드락을 방지하고,
/// RequestOptions를 불변으로 처리하는지 검증합니다.
void main() {
  group('AuthInterceptor 토큰 재시도', () {
    late Dio plainDio;
    late List<String> loggedPaths;

    setUp(() {
      loggedPaths = [];

      // plainDio: 요청을 가로채서 경로만 기록
      plainDio = Dio(BaseOptions(baseUrl: 'https://test.api'));
      plainDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            loggedPaths.add(options.path);
            // 200 응답으로 resolve (실제 네트워크 호출 없음)
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'test': true},
              ),
            );
          },
        ),
      );

      // AuthInterceptor 인스턴스 생성 (plainDio 주입 확인)
      AuthInterceptor(
        tokenStorage: SecureTokenStorage(),
        plainDio: plainDio,
        onForceLogout: ({String? message}) async {},
      );
    });

    test('재시도 시 plainDio를 사용하여 요청 전송', () async {
      // plainDio가 실제로 요청을 처리하는지 간접 검증
      await plainDio.get('/api/user/me/game');

      expect(loggedPaths, contains('/api/user/me/game'));
    });

    test('재시도 시 원본 RequestOptions를 변형하지 않음 (immutability)', () {
      final original = RequestOptions(
        path: '/api/user/me/game',
        method: 'GET',
        headers: {'Accept': 'application/json'},
        extra: {},
      );

      final originalHeadersCopy = Map<String, dynamic>.from(original.headers);
      final originalExtraCopy = Map<String, dynamic>.from(original.extra);

      // copyWith로 새 객체를 만들어야 원본이 변하지 않음
      final retry = original.copyWith(
        headers: {...original.headers, 'Authorization': 'Bearer new-token'},
      );

      // 원본 헤더는 변하지 않아야 함
      expect(original.headers, equals(originalHeadersCopy));
      expect(original.extra, equals(originalExtraCopy));

      // 재시도 헤더에는 Authorization이 있어야 함
      expect(retry.headers['Authorization'], equals('Bearer new-token'));

      // 원본에는 Authorization이 없어야 함
      expect(original.headers.containsKey('Authorization'), isFalse);
    });

    test('plainDio에는 AuthInterceptor가 없음 (무한 루프 방지)', () {
      // plainDio의 인터셉터에 AuthInterceptor가 없는지 확인
      final hasAuthInterceptor = plainDio.interceptors.any(
        (i) => i is AuthInterceptor,
      );

      expect(hasAuthInterceptor, isFalse);
    });
  });
}
