import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../domain/utils/firebase_auth_error_handler.dart';

part 'auth_provider.g.dart';

/// FirebaseAuthDataSource Provider
@riverpod
FirebaseAuthDataSource firebaseAuthDataSource(Ref ref) {
  return FirebaseAuthDataSource();
}

/// Firebase Auth State를 실시간으로 제공하는 StreamProvider
///
/// GoRouter의 refreshListenable로 사용되어
/// 인증 상태 변경 시 자동으로 라우팅을 재평가합니다.
@riverpod
Stream<User?> authState(Ref ref) {
  final dataSource = ref.watch(firebaseAuthDataSourceProvider);
  return dataSource.authStateChanges();
}

/// 인증 상태를 관리하는 Notifier
///
/// Google 로그인, 로그아웃 등의 인증 작업을 수행하며
/// 로딩/에러 상태를 관리합니다.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() {
    // Firebase Auth의 현재 사용자를 반환
    final dataSource = ref.watch(firebaseAuthDataSourceProvider);
    return dataSource.currentUser;
  }

  /// Google 로그인 수행
  ///
  /// 사용자가 취소하거나 네트워크 오류 발생 시
  /// [AuthException]으로 변환하여 에러 상태를 설정합니다.
  ///
  /// 로그인 실패 시 Firebase/Google 세션을 모두 정리합니다.
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final dataSource = ref.read(firebaseAuthDataSourceProvider);
      final userCredential = await dataSource.signInWithGoogle();

      // Firebase ID Token 검증 (실패 시 세션 정리 및 에러 전파)
      await _validateIdToken('google');

      state = AsyncValue.data(userCredential.user);
    } on FirebaseAuthException catch (e) {
      // 로그인 실패 시 세션 정리
      await _cleanupSessionOnFailure('google');

      // Firebase 에러를 사용자 친화적 메시지로 변환
      state = AsyncValue.error(
        FirebaseAuthErrorHandler.createAuthException(e, provider: 'Google'),
        StackTrace.current,
      );
    } catch (e, stack) {
      // 로그인 실패 시 세션 정리
      await _cleanupSessionOnFailure('google');

      // 기타 예외 처리
      state = AsyncValue.error(
        AuthException(message: '알 수 없는 오류가 발생했습니다.', originalException: e),
        stack,
      );
    }
  }

  /// Apple 로그인 수행
  ///
  /// 사용자가 취소하거나 네트워크 오류 발생 시
  /// [AuthException]으로 변환하여 에러 상태를 설정합니다.
  ///
  /// 로그인 실패 시 Firebase/Google 세션을 모두 정리합니다.
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();

    try {
      final dataSource = ref.read(firebaseAuthDataSourceProvider);
      final userCredential = await dataSource.signInWithApple();

      // Firebase ID Token 검증 (실패 시 세션 정리 및 에러 전파)
      await _validateIdToken('apple');

      state = AsyncValue.data(userCredential.user);
    } on FirebaseAuthException catch (e) {
      // 로그인 실패 시 세션 정리
      await _cleanupSessionOnFailure('apple');

      // Firebase 에러를 사용자 친화적 메시지로 변환
      state = AsyncValue.error(
        FirebaseAuthErrorHandler.createAuthException(e, provider: 'Apple'),
        StackTrace.current,
      );
    } catch (e, stack) {
      // 로그인 실패 시 세션 정리
      await _cleanupSessionOnFailure('apple');

      // 기타 예외 처리
      state = AsyncValue.error(
        AuthException(message: '알 수 없는 오류가 발생했습니다.', originalException: e),
        stack,
      );
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      final dataSource = ref.read(firebaseAuthDataSourceProvider);
      await dataSource.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(
        AuthException(message: '로그아웃에 실패했습니다.', originalException: e),
        stack,
      );
    }
  }

  /// 로그인 실패 시 세션 정리
  ///
  /// Firebase 및 Google 세션을 모두 정리합니다.
  /// 에러가 발생해도 무시하고 계속 진행합니다.
  ///
  /// [provider]: 로그인 제공자 이름 (로그 출력용)
  Future<void> _cleanupSessionOnFailure(String provider) async {
    try {
      final dataSource = ref.read(firebaseAuthDataSourceProvider);
      await dataSource.signOut();
      debugPrint('🔄 로그인 실패 - Firebase/Google 세션 정리 완료 ($provider)');
    } catch (signOutError) {
      debugPrint('⚠️ 로그아웃 중 에러 (무시): $signOutError');
    }
  }

  /// 로그인 후 Firebase ID Token 검증
  ///
  /// 토큰 발급 실패 시 세션을 정리하고 에러를 재전파합니다.
  ///
  /// [provider]: 로그인 제공자 이름 (로그 출력용)
  ///
  /// Throws: [FirebaseAuthException] 토큰 발급 실패 시
  Future<void> _validateIdToken(String provider) async {
    try {
      final dataSource = ref.read(firebaseAuthDataSourceProvider);
      await dataSource.getIdToken();
    } catch (tokenError) {
      debugPrint('❌ Firebase ID Token 발급 실패 - 로그인 취소 및 로그아웃 처리 ($provider)');
      await _cleanupSessionOnFailure(provider);
      rethrow;
    }
  }
}
