import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/utils/firebase_auth_error_handler.dart';

part 'auth_provider.g.dart';

// ============================================================================
// Core Infrastructure Providers
// ============================================================================

/// FirebaseAuthDataSource Provider
///
/// 앱 생애주기 동안 유지 (keepAlive) — 인터셉터 콜백에서 안전하게 접근 가능
@Riverpod(keepAlive: true)
FirebaseAuthDataSource firebaseAuthDataSource(Ref ref) {
  return FirebaseAuthDataSource();
}

// ============================================================================
// Data Layer Providers
// ============================================================================

/// AuthRemoteDataSource Provider (Retrofit)
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSource(dio);
}

/// AuthRepository Provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    firebaseAuthDataSource: ref.watch(firebaseAuthDataSourceProvider),
    authRemoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
  );
}

// ============================================================================
// Domain Layer Providers (UseCases)
// ============================================================================

/// Google 로그인 UseCase Provider
@riverpod
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) {
  return SignInWithGoogleUseCase(repository: ref.watch(authRepositoryProvider));
}

/// Apple 로그인 UseCase Provider
@riverpod
SignInWithAppleUseCase signInWithAppleUseCase(Ref ref) {
  return SignInWithAppleUseCase(repository: ref.watch(authRepositoryProvider));
}

/// 로그아웃 UseCase Provider
@riverpod
SignOutUseCase signOutUseCase(Ref ref) {
  return SignOutUseCase(repository: ref.watch(authRepositoryProvider));
}

// ============================================================================
// Presentation Layer Providers
// ============================================================================

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
/// UseCase를 통해 로그인/로그아웃을 수행하며
/// 로딩/에러 상태를 관리합니다.
///
/// **State**: `AsyncValue<AuthResultEntity?>` - 로그인 결과 (null = 미로그인)
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthResultEntity?> build() async {
    // 강제 로그아웃 콜백 등록 (core → auth 역전 패턴)
    ref.read(forceLogoutCallbackNotifierProvider.notifier).register(() async {
      final firebaseDataSource = ref.read(firebaseAuthDataSourceProvider);
      await firebaseDataSource.signOut();
      await ref.read(secureTokenStorageProvider).clearTokens();
      forceLogout();
      debugPrint('🚨 강제 로그아웃 완료 (토큰 만료/재발급 실패)');
    });

    // 초기 상태: Firebase Auth + JWT 토큰 모두 존재해야 인증된 것으로 판단
    final dataSource = ref.watch(firebaseAuthDataSourceProvider);
    final tokenStorage = ref.watch(secureTokenStorageProvider);
    final currentUser = dataSource.currentUser;

    if (currentUser != null) {
      // Firebase에 로그인된 사용자가 있어도 JWT 토큰이 없으면 미인증
      final hasTokens = await tokenStorage.hasTokens();
      if (!hasTokens) {
        return null;
      }

      // Firebase + JWT 토큰 모두 존재 → 인증된 사용자
      // userId는 SecureTokenStorage에서 복원
      return AuthResultEntity(
        userId: await tokenStorage.getUserId() ?? 0,
        nickname: currentUser.displayName ?? '',
        isNewUser: false,
      );
    }

    return null;
  }

  /// Google 로그인 수행
  ///
  /// UseCase를 통해 Firebase 로그인 → 백엔드 로그인 → 토큰 저장을 수행합니다.
  /// 성공 시 [AuthResultEntity]를 state에 설정합니다.
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final useCase = ref.read(signInWithGoogleUseCaseProvider);
      final result = await useCase.execute();
      state = AsyncValue.data(result);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(
        FirebaseAuthErrorHandler.createAuthException(e, provider: 'Google'),
        StackTrace.current,
      );
      rethrow;
    } catch (e, stack) {
      if (e is AppException) {
        state = AsyncValue.error(e, stack);
      } else {
        state = AsyncValue.error(
          AuthException(message: '알 수 없는 오류가 발생했습니다.', originalException: e),
          stack,
        );
      }
      rethrow;
    }
  }

  /// Apple 로그인 수행
  ///
  /// UseCase를 통해 Firebase 로그인 → 백엔드 로그인 → 토큰 저장을 수행합니다.
  /// 성공 시 [AuthResultEntity]를 state에 설정합니다.
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();

    try {
      final useCase = ref.read(signInWithAppleUseCaseProvider);
      final result = await useCase.execute();
      state = AsyncValue.data(result);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(
        FirebaseAuthErrorHandler.createAuthException(e, provider: 'Apple'),
        StackTrace.current,
      );
      rethrow;
    } catch (e, stack) {
      if (e is AppException) {
        state = AsyncValue.error(e, stack);
      } else {
        state = AsyncValue.error(
          AuthException(message: '알 수 없는 오류가 발생했습니다.', originalException: e),
          stack,
        );
      }
      rethrow;
    }
  }

  /// 로그아웃
  ///
  /// 백엔드 + Firebase + 토큰 삭제를 모두 수행합니다.
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      final useCase = ref.read(signOutUseCaseProvider);
      await useCase.execute();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(
        AuthException(message: '로그아웃에 실패했습니다.', originalException: e),
        stack,
      );
    }
  }

  /// 닉네임 설정 완료 후 상태 갱신
  ///
  /// isNewUser를 false로 변경하여 GoRouter가 다시
  /// /nickname-setup으로 리다이렉트하지 않도록 합니다.
  void updateNicknameCompleted(String nickname) {
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(
        AuthResultEntity(
          userId: current.userId,
          nickname: nickname,
          isNewUser: false,
        ),
      );
    }
  }

  /// 강제 로그아웃 (AuthInterceptor에서 호출)
  ///
  /// 토큰 재발급 실패 시 state를 null로 초기화하여
  /// GoRouter가 로그인 화면으로 리다이렉트하도록 합니다.
  void forceLogout() {
    state = const AsyncValue.data(null);
  }
}
