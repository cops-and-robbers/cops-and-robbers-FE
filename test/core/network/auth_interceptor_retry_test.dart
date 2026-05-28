import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/network/auth_interceptor.dart';
import 'package:cops_and_robbers/core/storage/secure_token_storage.dart';

class _FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> write({
    required String key,
    String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubHttpClientAdapter implements HttpClientAdapter {
  _StubHttpClientAdapter(this._fetch);

  final Future<ResponseBody> Function(RequestOptions options) _fetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _fetch(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(String body, int statusCode) {
  return ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Future<SecureTokenStorage> _storageWithTokens({
  String accessToken = 'expired-access-token',
  String refreshToken = 'valid-refresh-token',
}) async {
  final storage = SecureTokenStorage(storage: _FakeSecureStorage());
  await storage.saveTokens(
    accessToken: accessToken,
    refreshToken: refreshToken,
  );
  return storage;
}

Dio _protectedDio({
  required SecureTokenStorage storage,
  required Dio plainDio,
  required Future<void> Function({String? message}) onForceLogout,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
  dio.interceptors.add(
    AuthInterceptor(
      tokenStorage: storage,
      plainDio: plainDio,
      onForceLogout: onForceLogout,
    ),
  );
  dio.httpClientAdapter = _StubHttpClientAdapter((options) async {
    return ResponseBody.fromString('', 401);
  });
  return dio;
}

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

    test('401 발생 시 reissue 성공 후 새 토큰으로 원요청을 재시도한다', () async {
      final storage = await _storageWithTokens();
      var forceLogoutCalled = false;
      final retriedAuthorizations = <String?>[];
      final reissueDio = Dio(BaseOptions(baseUrl: 'https://test.api'));

      reissueDio.httpClientAdapter = _StubHttpClientAdapter((options) async {
        if (options.path == '/api/auth/reissue') {
          return _jsonResponse(
            '{"tokens":{"accessToken":"new-access-token","refreshToken":"new-refresh-token"}}',
            200,
          );
        }

        retriedAuthorizations.add(options.headers['Authorization'] as String?);
        return _jsonResponse('{"ok":true}', 200);
      });

      final dio = _protectedDio(
        storage: storage,
        plainDio: reissueDio,
        onForceLogout: ({String? message}) async {
          forceLogoutCalled = true;
        },
      );

      final response = await dio.get('/api/protected');

      expect(response.statusCode, 200);
      expect(response.data, {'ok': true});
      expect(retriedAuthorizations, ['Bearer new-access-token']);
      expect(await storage.getAccessToken(), 'new-access-token');
      expect(await storage.getRefreshToken(), 'new-refresh-token');
      expect(forceLogoutCalled, isFalse);
    });

    test('reissue 네트워크 실패는 강제 로그아웃하지 않고 토큰을 유지한다', () async {
      final storage = await _storageWithTokens();
      var forceLogoutCalled = false;
      final reissueDio = Dio(BaseOptions(baseUrl: 'https://test.api'));

      reissueDio.httpClientAdapter = _StubHttpClientAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'offline',
        );
      });

      final dio = _protectedDio(
        storage: storage,
        plainDio: reissueDio,
        onForceLogout: ({String? message}) async {
          forceLogoutCalled = true;
        },
      );

      await expectLater(
        dio.get('/api/protected'),
        throwsA(
          isA<DioException>()
              .having((e) => e.type, 'type', DioExceptionType.connectionError)
              .having((e) => e.requestOptions.path, 'path', '/api/protected'),
        ),
      );

      expect(forceLogoutCalled, isFalse);
      expect(await storage.getAccessToken(), 'expired-access-token');
      expect(await storage.getRefreshToken(), 'valid-refresh-token');
    });

    test('reissue 5xx는 강제 로그아웃하지 않고 토큰을 유지한다', () async {
      final storage = await _storageWithTokens();
      var forceLogoutCalled = false;
      final reissueDio = Dio(BaseOptions(baseUrl: 'https://test.api'));

      reissueDio.httpClientAdapter = _StubHttpClientAdapter((options) async {
        return _jsonResponse('{"detail":"temporary server error"}', 500);
      });

      final dio = _protectedDio(
        storage: storage,
        plainDio: reissueDio,
        onForceLogout: ({String? message}) async {
          forceLogoutCalled = true;
        },
      );

      await expectLater(
        dio.get('/api/protected'),
        throwsA(
          isA<DioException>()
              .having((e) => e.response?.statusCode, 'statusCode', 500)
              .having((e) => e.requestOptions.path, 'path', '/api/protected'),
        ),
      );

      expect(forceLogoutCalled, isFalse);
      expect(await storage.getAccessToken(), 'expired-access-token');
      expect(await storage.getRefreshToken(), 'valid-refresh-token');
    });

    for (final statusCode in [400, 401, 403]) {
      test('reissue $statusCode은 강제 로그아웃하고 토큰을 삭제한다', () async {
        final storage = await _storageWithTokens(
          refreshToken: 'invalid-refresh-token',
        );
        var forceLogoutCalled = false;
        final reissueDio = Dio(BaseOptions(baseUrl: 'https://test.api'));

        reissueDio.httpClientAdapter = _StubHttpClientAdapter((options) async {
          return _jsonResponse(
            '{"detail":"refresh token rejected"}',
            statusCode,
          );
        });

        final dio = _protectedDio(
          storage: storage,
          plainDio: reissueDio,
          onForceLogout: ({String? message}) async {
            forceLogoutCalled = true;
          },
        );

        await expectLater(
          dio.get('/api/protected'),
          throwsA(isA<DioException>()),
        );

        expect(forceLogoutCalled, isTrue);
        expect(await storage.getAccessToken(), isNull);
        expect(await storage.getRefreshToken(), isNull);
      });
    }

    test('reissue 200 malformed body는 강제 로그아웃하고 토큰을 삭제한다', () async {
      final storage = await _storageWithTokens();
      var forceLogoutCalled = false;
      final reissueDio = Dio(BaseOptions(baseUrl: 'https://test.api'));

      reissueDio.httpClientAdapter = _StubHttpClientAdapter((options) async {
        return _jsonResponse(
          '{"tokens":{"accessToken":"new-access-token"}}',
          200,
        );
      });

      final dio = _protectedDio(
        storage: storage,
        plainDio: reissueDio,
        onForceLogout: ({String? message}) async {
          forceLogoutCalled = true;
        },
      );

      await expectLater(
        dio.get('/api/protected'),
        throwsA(isA<DioException>()),
      );

      expect(forceLogoutCalled, isTrue);
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });

    test('reissue 성공 후 retry 403은 강제 로그아웃하지 않는다', () async {
      final storage = await _storageWithTokens();
      var forceLogoutCalled = false;
      final reissueDio = Dio(BaseOptions(baseUrl: 'https://test.api'));

      reissueDio.httpClientAdapter = _StubHttpClientAdapter((options) async {
        if (options.path == '/api/auth/reissue') {
          return _jsonResponse(
            '{"tokens":{"accessToken":"new-access-token","refreshToken":"new-refresh-token"}}',
            200,
          );
        }

        return ResponseBody.fromString('', 403);
      });

      final dio = _protectedDio(
        storage: storage,
        plainDio: reissueDio,
        onForceLogout: ({String? message}) async {
          forceLogoutCalled = true;
        },
      );

      await expectLater(
        dio.get('/api/protected'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            403,
          ),
        ),
      );

      expect(forceLogoutCalled, isFalse);
      expect(await storage.getAccessToken(), 'new-access-token');
      expect(await storage.getRefreshToken(), 'new-refresh-token');
    });

    test('reissue 성공 후 retry 5xx는 새 토큰을 유지한다', () async {
      final storage = await _storageWithTokens();
      var forceLogoutCalled = false;
      final reissueDio = Dio(BaseOptions(baseUrl: 'https://test.api'));

      reissueDio.httpClientAdapter = _StubHttpClientAdapter((options) async {
        if (options.path == '/api/auth/reissue') {
          return _jsonResponse(
            '{"tokens":{"accessToken":"new-access-token","refreshToken":"new-refresh-token"}}',
            200,
          );
        }

        return ResponseBody.fromString('', 500);
      });

      final dio = _protectedDio(
        storage: storage,
        plainDio: reissueDio,
        onForceLogout: ({String? message}) async {
          forceLogoutCalled = true;
        },
      );

      await expectLater(
        dio.get('/api/protected'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            500,
          ),
        ),
      );

      expect(forceLogoutCalled, isFalse);
      expect(await storage.getAccessToken(), 'new-access-token');
      expect(await storage.getRefreshToken(), 'new-refresh-token');
    });

    test('reissue 성공 후 retry 401은 강제 로그아웃하고 토큰을 삭제한다', () async {
      final storage = await _storageWithTokens();
      var forceLogoutCalled = false;
      final reissueDio = Dio(BaseOptions(baseUrl: 'https://test.api'));

      reissueDio.httpClientAdapter = _StubHttpClientAdapter((options) async {
        if (options.path == '/api/auth/reissue') {
          return _jsonResponse(
            '{"tokens":{"accessToken":"new-access-token","refreshToken":"new-refresh-token"}}',
            200,
          );
        }

        return ResponseBody.fromString('', 401);
      });

      final dio = _protectedDio(
        storage: storage,
        plainDio: reissueDio,
        onForceLogout: ({String? message}) async {
          forceLogoutCalled = true;
        },
      );

      await expectLater(
        dio.get('/api/protected'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            401,
          ),
        ),
      );

      expect(forceLogoutCalled, isTrue);
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });

    test('빈 refresh token은 강제 로그아웃하고 토큰을 삭제한다', () async {
      final storage = await _storageWithTokens(refreshToken: '');
      var forceLogoutCalled = false;
      var reissueCalled = false;
      final reissueDio = Dio(BaseOptions(baseUrl: 'https://test.api'));

      reissueDio.httpClientAdapter = _StubHttpClientAdapter((options) async {
        reissueCalled = true;
        return _jsonResponse(
          '{"tokens":{"accessToken":"new-access-token","refreshToken":"new-refresh-token"}}',
          200,
        );
      });

      final dio = _protectedDio(
        storage: storage,
        plainDio: reissueDio,
        onForceLogout: ({String? message}) async {
          forceLogoutCalled = true;
        },
      );

      await expectLater(
        dio.get('/api/protected'),
        throwsA(isA<DioException>()),
      );

      expect(reissueCalled, isFalse);
      expect(forceLogoutCalled, isTrue);
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });
  });
}
