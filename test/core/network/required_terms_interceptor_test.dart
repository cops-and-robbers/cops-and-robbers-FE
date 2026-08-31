import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/constants/api_endpoints.dart';
import 'package:cops_and_robbers/core/network/auth_interceptor.dart';
import 'package:cops_and_robbers/core/network/dio_client.dart';
import 'package:cops_and_robbers/core/network/required_terms_interceptor.dart';
import 'package:cops_and_robbers/core/storage/secure_token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  }) async => _store[key];

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

ResponseBody _rfc7807(String errorCode, {int statusCode = 400}) {
  return ResponseBody.fromString(
    '{"title":"필수 약관 미동의","status":$statusCode,'
    '"detail":"필수 약관은 모두 동의해야 합니다.","errorCode":"$errorCode"}',
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// RequiredTermsInterceptor
///
/// 서버가 `/api/**` 전역에서 내리는 `REQUIRED_TERMS_NOT_AGREED` 400을
/// 화면별 호출이 아니라 Dio 인터셉터 한 곳에서 받는지 검증한다.
void main() {
  late int callbackCount;
  late Dio dio;

  Dio buildDio(Future<ResponseBody> Function(RequestOptions) fetch) {
    final d = Dio(BaseOptions(baseUrl: 'https://test.api'));
    d.interceptors.add(
      RequiredTermsInterceptor(onRequiredTermsNotAgreed: () => callbackCount++),
    );
    d.httpClientAdapter = _StubHttpClientAdapter(fetch);
    return d;
  }

  setUp(() {
    callbackCount = 0;
  });

  group('필수 약관 미동의 감지', () {
    test('notifies_once_when_error_code_matches', () async {
      dio = buildDio((_) async => _rfc7807('REQUIRED_TERMS_NOT_AGREED'));

      await expectLater(
        dio.get<void>('/api/community-posts'),
        throwsA(isA<DioException>()),
      );

      expect(callbackCount, 1);
    });

    test('propagates_the_error_when_it_was_handled', () async {
      dio = buildDio((_) async => _rfc7807('REQUIRED_TERMS_NOT_AGREED'));

      final error = await dio
          .get<void>('/api/notices')
          .then<Object?>((_) => null)
          .catchError((Object e) => e);

      expect(error, isA<DioException>());
      expect((error as DioException).response?.statusCode, 400);
    });

    test('stays_silent_when_error_code_differs', () async {
      dio = buildDio((_) async => _rfc7807('POST_NOT_FOUND', statusCode: 404));

      await expectLater(
        dio.get<void>('/api/community-posts/1'),
        throwsA(isA<DioException>()),
      );

      expect(callbackCount, 0);
    });

    test('stays_silent_when_body_is_not_rfc7807', () async {
      dio = buildDio((_) async => ResponseBody.fromString('', 500));

      await expectLater(
        dio.get<void>('/api/user/me'),
        throwsA(isA<DioException>()),
      );

      expect(callbackCount, 0);
    });

    test('stays_silent_when_response_succeeds', () async {
      dio = buildDio(
        (_) async => ResponseBody.fromString(
          '{}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );

      await dio.get<void>('/api/notices');

      expect(callbackCount, 0);
    });
  });

  group('약관 제출 경로 제외', () {
    test('stays_silent_when_path_is_the_agreement_submit', () async {
      dio = buildDio((_) async => _rfc7807('REQUIRED_TERMS_NOT_AGREED'));

      await expectLater(
        dio.put<void>('/api/user/agreements'),
        throwsA(isA<DioException>()),
      );

      expect(callbackCount, 0);
    });

    test('stays_silent_when_agreement_submit_carries_a_query', () async {
      dio = buildDio((_) async => _rfc7807('REQUIRED_TERMS_NOT_AGREED'));

      await expectLater(
        dio.put<void>('/api/user/agreements?retry=true'),
        throwsA(isA<DioException>()),
      );

      expect(callbackCount, 0);
    });

    test('notifies_when_path_is_below_the_agreement_submit', () async {
      dio = buildDio((_) async => _rfc7807('REQUIRED_TERMS_NOT_AGREED'));

      await expectLater(
        dio.put<void>('/api/user/agreements/game-push'),
        throwsA(isA<DioException>()),
      );

      expect(callbackCount, 1);
    });
  });

  // 이 그룹이 지키는 것: dio_client 의 인터셉터 순서(Auth → RequiredTerms).
  // AuthInterceptor 는 재발급 후 재시도를 인터셉터 없는 _plainDio 로 보내지만
  // 실패는 handler.next 로 이 체인에 되돌린다. 순서가 뒤집히거나 그 전달이
  // handler.reject 로 바뀌면 재발급 경로의 약관 400 이 조용히 사라진다.
  group('AuthInterceptor 와의 순서', () {
    test(
      'notifies_when_terms_error_arrives_on_the_retry_after_reissue',
      () async {
        final storage = SecureTokenStorage(storage: _FakeSecureStorage());
        await storage.saveTokens(
          accessToken: 'expired-access-token',
          refreshToken: 'valid-refresh-token',
        );

        var protectedCalls = 0;
        Future<ResponseBody> fetch(RequestOptions options) async {
          if (options.path.contains(ApiEndpoints.reissue)) {
            return ResponseBody.fromString(
              '{"tokens":{"accessToken":"new-access","refreshToken":"new-refresh"}}',
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }
          protectedCalls++;
          // 첫 호출은 401 로 재발급을 유도하고, 재시도에서 약관 400 을 준다
          return protectedCalls == 1
              ? ResponseBody.fromString('', 401)
              : _rfc7807('REQUIRED_TERMS_NOT_AGREED');
        }

        final plainDio = Dio(BaseOptions(baseUrl: 'https://test.api'))
          ..httpClientAdapter = _StubHttpClientAdapter(fetch);

        final protectedDio = Dio(BaseOptions(baseUrl: 'https://test.api'))
          ..httpClientAdapter = _StubHttpClientAdapter(fetch)
          ..interceptors.addAll([
            AuthInterceptor(
              tokenStorage: storage,
              plainDio: plainDio,
              onForceLogout: ({String? messageKey}) async {},
            ),
            RequiredTermsInterceptor(
              onRequiredTermsNotAgreed: () => callbackCount++,
            ),
          ]);

        await expectLater(
          protectedDio.get<void>('/api/community-posts'),
          throwsA(isA<DioException>()),
        );

        expect(protectedCalls, 2, reason: '재발급 후 재시도가 실제로 일어나야 한다');
        expect(callbackCount, 1);
      },
    );

    test('registers_the_terms_interceptor_after_auth_when_dio_is_built', () {
      // DioClient.create 가 EnvConfig.apiBaseUrl(.env)을 읽으므로 dotenv 초기화
      dotenv.loadFromString(envString: '', isOptional: true);

      final built = DioClient.create(
        tokenStorage: SecureTokenStorage(storage: _FakeSecureStorage()),
        currentLanguageCode: () => 'ko',
        onForceLogout: ({String? messageKey}) async {},
        onRequiredTermsNotAgreed: () {},
      );

      final authAt = built.interceptors.indexWhere((i) => i is AuthInterceptor);
      final termsAt = built.interceptors.indexWhere(
        (i) => i is RequiredTermsInterceptor,
      );

      expect(authAt, isNonNegative);
      expect(termsAt, isNonNegative);
      expect(
        termsAt,
        greaterThan(authAt),
        reason: '앞에 두면 재발급 재시도 경로의 약관 400 을 놓친다',
      );
    });
  });

  // 리디렉트를 못 하는데 플래그만 켜두면 그 true 가 소비되지 않고 남아,
  // 같은 앱 세션에서 신규 가입자가 약관 화면에 들어왔을 때 엉뚱한 안내가 뜬다.
  group('콜백 미등록 상태', () {
    /// [notifyRequiredTermsNotAgreed] 는 Ref 를 받으므로 provider 를 거친다.
    /// 단 build 중에 부르면 안 된다 — Riverpod 이 build 중 타 provider 수정을
    /// 막는다. 실제 호출도 Dio 에러 콜백(항상 await 뒤)이라 build 밖이므로,
    /// 클로저로 감싸 같은 시점을 재현한다.
    final probe = Provider<void Function()>(
      (ref) =>
          () => notifyRequiredTermsNotAgreed(ref),
    );

    test('keeps_the_blocked_flag_off_when_no_callback_is_registered', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(probe)();

      expect(container.read(requiredTermsBlockedProvider), isFalse);
    });

    test('raises_the_blocked_flag_when_a_callback_is_registered', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(requiredTermsCallbackNotifierProvider.notifier)
          .register(() => callbackCount++);

      container.read(probe)();

      expect(container.read(requiredTermsBlockedProvider), isTrue);
      expect(callbackCount, 1);
    });
  });
}
