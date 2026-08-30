import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env_config.dart';
import '../i18n/locale_provider.dart';
import '../storage/secure_token_storage.dart';
import 'auth_interceptor.dart';
import 'required_terms_interceptor.dart';

part 'dio_client.g.dart';

/// 강제 로그아웃 콜백 함수 타입
///
/// 강제 로그아웃 사유를 식별자(messageKey)로 전달. UI에서 i18n 변환.
typedef ForceLogoutFn = Future<void> Function({String? messageKey});

/// 강제 로그아웃 사유 messageKey (login_page에서 errorByKey로 변환)
///
/// reissue 실패 시 원인을 식별하는 키를 저장합니다.
/// 로그인 화면에서 1회 소비(consume) 후 null로 초기화됩니다.
final forceLogoutMessageKeyProvider = StateProvider<String?>((ref) => null);

/// 서버가 필수 약관 미동의로 차단했는지 여부 (agreement_page에서 1회 소비)
///
/// 인터셉터에는 BuildContext가 없어 스낵바를 직접 띄울 수 없다.
/// [forceLogoutMessageKeyProvider]와 같은 방식으로, 안내는 목적지 화면이
/// 소비해서 표시한다. 신규 가입 동의 플로우에서는 켜지지 않는다.
final requiredTermsBlockedProvider = StateProvider<bool>((ref) => false);

/// 강제 로그아웃 콜백 Provider
///
/// auth 모듈에서 구체적인 로그아웃 동작을 등록합니다.
/// core 모듈이 feature 모듈에 의존하지 않기 위한 역전 패턴입니다.
@Riverpod(keepAlive: true)
class ForceLogoutCallbackNotifier extends _$ForceLogoutCallbackNotifier {
  @override
  ForceLogoutFn? build() => null;

  /// 강제 로그아웃 콜백 등록
  void register(ForceLogoutFn callback) {
    state = callback;
  }

  /// 강제 로그아웃 콜백 해제
  void unregister() {
    state = null;
  }
}

/// 필수 약관 미동의 감지 콜백 Provider
///
/// [ForceLogoutCallbackNotifier]와 같은 역전 패턴. auth 모듈이
/// `markNeedsAgreement` 호출을 등록한다.
@Riverpod(keepAlive: true)
class RequiredTermsCallbackNotifier extends _$RequiredTermsCallbackNotifier {
  @override
  VoidCallback? build() => null;

  /// 필수 약관 미동의 콜백 등록
  void register(VoidCallback callback) {
    state = callback;
  }

  /// 필수 약관 미동의 콜백 해제
  void unregister() {
    state = null;
  }
}

/// Dio Provider (AuthInterceptor 포함)
///
/// 앱 생애주기 동안 유지 (keepAlive) — HTTP 클라이언트는 dispose되면 안 됨.
/// [forceLogoutCallbackNotifier]를 통해 강제 로그아웃 동작을 외부에서 주입받습니다.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final tokenStorage = ref.watch(secureTokenStorageProvider);

  return DioClient.create(
    tokenStorage: tokenStorage,
    // 언어는 설정에서 언제든 바뀔 수 있으므로 요청 시점마다 현재 로캘을 읽는다
    currentLanguageCode: () => ref.read(appLocaleProvider).locale.languageCode,
    onForceLogout: ({String? messageKey}) async {
      final callback = ref.read(forceLogoutCallbackNotifierProvider);
      if (callback != null) {
        await callback(messageKey: messageKey);
      } else {
        debugPrint('🚨 forceLogoutCallback 미등록 — 토큰만 삭제');
        await tokenStorage.clearTokens();
      }
    },
    onRequiredTermsNotAgreed: () => notifyRequiredTermsNotAgreed(ref),
  );
}

/// 필수 약관 미동의(400)를 받았을 때의 공용 처리
///
/// 전역 [dioProvider] 말고 별도 Dio를 쓰는 곳도 같은 처리를 붙일 수 있도록
/// 공개한다 (예: 게임 결과 조회 전용 Dio).
///
/// **콜백이 없으면 플래그도 켜지 않는다.** 리디렉트를 못 하는데 플래그만 켜두면
/// 그 true가 소비되지 않고 남아, 나중에 같은 앱 세션에서 신규 가입자가 약관
/// 화면에 들어왔을 때 엉뚱한 에러 안내를 띄운다.
void notifyRequiredTermsNotAgreed(Ref ref) {
  final callback = ref.read(requiredTermsCallbackNotifierProvider);
  if (callback == null) {
    debugPrint('🚨 requiredTermsCallback 미등록 — /agreement 리디렉트 불가');
    return;
  }

  // 안내는 목적지(약관 화면)가 표시한다 — 인터셉터에는 BuildContext가 없다
  ref.read(requiredTermsBlockedProvider.notifier).state = true;
  callback();
}

/// Dio HTTP 클라이언트 설정
///
/// 앱 전체에서 사용되는 Dio 인스턴스를 생성합니다.
/// AuthInterceptor를 통해 JWT 토큰 자동 주입 및 재발급을 처리합니다.
class DioClient {
  // Private 생성자 - 인스턴스화 방지
  DioClient._();

  /// Dio 인스턴스 생성
  ///
  /// [tokenStorage]: JWT 토큰 저장소
  /// [currentLanguageCode]: 매 요청에 실을 현재 앱 언어 코드 (Accept-Language)
  /// [onForceLogout]: 토큰 재발급 실패 시 호출되는 강제 로그아웃 콜백 (messageKey로 사유 전달)
  /// [onRequiredTermsNotAgreed]: 필수 약관 미동의 400 감지 시 호출되는 콜백
  static Dio create({
    required SecureTokenStorage tokenStorage,
    required String Function() currentLanguageCode,
    required Future<void> Function({String? messageKey}) onForceLogout,
    required VoidCallback onRequiredTermsNotAgreed,
  }) {
    final baseOptions = BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final dio = Dio(baseOptions);

    // reissue 전용 plain Dio (인터셉터 없음)
    // AuthInterceptor 재진입으로 인한 이중 강제 로그아웃 방지
    final plainDio = Dio(baseOptions);

    // 인터셉터 추가
    dio.interceptors.addAll([
      // 1. 언어 인터셉터 (Accept-Language 주입)
      //
      // 서버가 언어에 따라 달라지는 응답(닉네임 생성 등)을 현재 앱 언어로
      // 내려줄 수 있도록 모든 요청에 싣는다.
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Accept-Language'] = currentLanguageCode();
          handler.next(options);
        },
      ),

      // 2. 인증 인터셉터 (토큰 주입 + 자동 재발급)
      AuthInterceptor(
        tokenStorage: tokenStorage,
        plainDio: plainDio,
        onForceLogout: onForceLogout,
      ),

      // 3. 필수 약관 미동의 인터셉터
      //
      // Auth 뒤에 둔다. 재발급 후 재시도(_plainDio)가 400을 받는 경우
      // AuthInterceptor가 handler.next로 에러를 이 체인에 되돌리므로
      // 그때도 잡힌다. BE의 Auth → Terms 순서와 같다.
      RequiredTermsInterceptor(
        onRequiredTermsNotAgreed: onRequiredTermsNotAgreed,
      ),

      // 4. 로깅 인터셉터 (디버그 모드에서만)
      if (kDebugMode)
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (log) => debugPrint('📡 $log'),
        ),
    ]);

    return dio;
  }
}
