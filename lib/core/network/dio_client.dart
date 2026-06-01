import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env_config.dart';
import '../storage/secure_token_storage.dart';
import 'auth_interceptor.dart';

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

/// Dio Provider (AuthInterceptor 포함)
///
/// 앱 생애주기 동안 유지 (keepAlive) — HTTP 클라이언트는 dispose되면 안 됨.
/// [forceLogoutCallbackNotifier]를 통해 강제 로그아웃 동작을 외부에서 주입받습니다.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final tokenStorage = ref.watch(secureTokenStorageProvider);

  return DioClient.create(
    tokenStorage: tokenStorage,
    onForceLogout: ({String? messageKey}) async {
      final callback = ref.read(forceLogoutCallbackNotifierProvider);
      if (callback != null) {
        await callback(messageKey: messageKey);
      } else {
        debugPrint('🚨 forceLogoutCallback 미등록 — 토큰만 삭제');
        await tokenStorage.clearTokens();
      }
    },
  );
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
  /// [onForceLogout]: 토큰 재발급 실패 시 호출되는 강제 로그아웃 콜백 (messageKey로 사유 전달)
  static Dio create({
    required SecureTokenStorage tokenStorage,
    required Future<void> Function({String? messageKey}) onForceLogout,
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
      // 1. 인증 인터셉터 (토큰 주입 + 자동 재발급)
      AuthInterceptor(
        tokenStorage: tokenStorage,
        plainDio: plainDio,
        onForceLogout: onForceLogout,
      ),

      // 2. 로깅 인터셉터 (디버그 모드에서만)
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
