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
// NOTE: Cross-feature dependency — 로그인 후 활성 게임 복원을 위해 session provider 참조
// (splash_page.dart와 동일한 패턴)
import '../../../session/presentation/providers/session_provider.dart';
import '../../../../router/active_game_route.dart';
import '../pages/login_page.dart';
import '../../../session/presentation/pages/home_page.dart';
import '../../../../core/services/tutorial/tutorial_service.dart';
import '../../../user/presentation/providers/user_provider.dart';

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

/// 로그인 성공 후 이동할 목적지 (활성 게임 복원용, 1회성)
///
/// 로그인 성공 시 활성 게임이 있으면 해당 경로를 저장하고,
/// GoRouter redirect에서 소비한 뒤 null로 초기화합니다.
final postLoginDestinationProvider = StateProvider<String?>((ref) => null);

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
    // Future.microtask로 지연: build() 중 다른 provider 수정 금지 (Riverpod 제약)
    Future.microtask(() {
      ref.read(forceLogoutCallbackNotifierProvider.notifier).register(({
        String? message,
      }) async {
        final firebaseDataSource = ref.read(firebaseAuthDataSourceProvider);
        await firebaseDataSource.signOut();
        await ref.read(secureTokenStorageProvider).clearTokens();
        if (message != null) {
          ref.read(forceLogoutMessageProvider.notifier).state = message;
        }
        forceLogout();
        debugPrint(
          '🚨 강제 로그아웃 완료 (토큰 만료/재발급 실패)'
          '${message != null ? ' 사유: $message' : ''}',
        );
      });
    });

    // auto-dispose 시 keepAlive 콜백 해제 — 죽은 ref 접근 방지
    ref.onDispose(() {
      ref.read(forceLogoutCallbackNotifierProvider.notifier).unregister();
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
      final userId = await tokenStorage.getUserId();
      if (userId == null) {
        debugPrint('[AuthNotifier] userId 없음 → 세션 초기화');
        try {
          await dataSource.signOut();
        } catch (_) {}
        await tokenStorage.clearTokens();
        return null;
      }

      // Cold start 시점에는 로그인 응답이 없으므로 약관 상태와 프로필(닉네임)을
      // 백엔드에서 직접 조회한다. 각 조회는 독립적으로 실패를 허용하여
      // 한쪽이 실패해도 다른 값은 반영한다.
      // - 약관 실패 시: requiresAgreement=false (낙관적) — 이후 보호 API가 차단되면
      //   에러 플로우로 유저에게 피드백
      // - 프로필 실패 시: Firebase displayName으로 폴백 (백엔드 일시 장애 대비).
      //   프로필 조회 성공 시 백엔드 닉네임(서버 생성 랜덤 또는 유저 변경값) 사용
      final userRepo = ref.read(userRepositoryProvider);
      bool requiresAgreement = false;
      String nickname = currentUser.displayName ?? '';

      try {
        final status = await userRepo.getAgreements();
        requiresAgreement = !status.hasAllRequired;
      } catch (e) {
        debugPrint('⚠️ [AuthNotifier] cold start 약관 상태 조회 실패: $e');
      }

      try {
        final profile = await userRepo.getMyProfile();
        nickname = profile.nickname;
      } catch (e) {
        debugPrint('⚠️ [AuthNotifier] cold start 프로필 조회 실패: $e');
      }

      // isNewUser 복원 — 신규 유저가 온보딩(약관/닉네임) 도중 이탈 후 재진입 시
      // 닉네임 설정 화면으로 다시 유도하기 위함.
      // 저장된 값이 없으면 false (기존 유저로 취급).
      final isNewUser = await tokenStorage.getIsNewUser();

      return AuthResultEntity(
        userId: userId,
        nickname: nickname,
        isNewUser: isNewUser,
        requiresAgreement: requiresAgreement,
      );
    }

    return null;
  }

  /// 활성 게임 상태를 조회하여 로그인 후 목적지를 결정합니다.
  ///
  /// - WAITING → 대기실 경로
  /// - IN_PROGRESS → 게임 경로 (team, pid 포함)
  /// - 참여 중인 게임 없음 또는 API 실패 → null (홈 fallback)
  Future<void> _resolvePostLoginDestination() async {
    try {
      final status = await ref.read(getMyActiveGameUsecaseProvider).execute();
      if (!status.isParticipating || status.participationInfo == null) return;

      final info = status.participationInfo!;
      final destination = activeGameRoute(info);

      if (destination != null) {
        ref.read(postLoginDestinationProvider.notifier).state = destination;
        debugPrint('🎯 AuthNotifier: 로그인 후 목적지 설정 → $destination');
      }
    } catch (e) {
      debugPrint('⚠️ AuthNotifier: 활성 게임 조회 실패 (홈 fallback) - $e');
    }
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

      // 기존 회원: 활성 게임 체크 → 목적지 결정 (state 설정 전)
      if (!result.isNewUser) {
        await _resolvePostLoginDestination();
      }

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
          AuthException(
            // message는 로그/디버그용 — 사용자 노출은 messageKey 경유
            message: 'unknown auth error',
            messageKey: 'errorUnknown',
            originalException: e,
          ),
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

      // 기존 회원: 활성 게임 체크 → 목적지 결정 (state 설정 전)
      if (!result.isNewUser) {
        await _resolvePostLoginDestination();
      }

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
          AuthException(
            // message는 로그/디버그용 — 사용자 노출은 messageKey 경유
            message: 'unknown auth error',
            messageKey: 'errorUnknown',
            originalException: e,
          ),
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
      HomePage.resetSafetyNotice();
      LoginPage.resetAgeVerification();
      await TutorialService.resetAll();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(
        AuthException(
          // message는 로그/디버그용 — 사용자 노출은 messageKey 경유
          message: 'logout failed',
          messageKey: 'errorLogoutFailed',
          originalException: e,
        ),
        stack,
      );
    }
  }

  /// 닉네임 설정 완료 후 상태 갱신
  ///
  /// isNewUser를 false로 변경하여 GoRouter가 다시
  /// /nickname-setup으로 리다이렉트하지 않도록 합니다.
  /// storage의 영속 상태도 false로 갱신하여 앱 재시작 시에도 유지합니다.
  Future<void> updateNicknameCompleted(String nickname) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(
      AuthResultEntity(
        userId: current.userId,
        nickname: nickname,
        isNewUser: false,
        requiresAgreement: current.requiresAgreement,
      ),
    );

    // storage 영속 상태도 갱신 → 다음 cold-start에서 /nickname-setup 재진입 방지
    try {
      await ref.read(secureTokenStorageProvider).saveIsNewUser(false);
    } catch (e) {
      debugPrint('⚠️ [AuthNotifier] saveIsNewUser(false) 실패: $e');
    }
  }

  /// 약관 동의 완료를 표시합니다.
  ///
  /// [AgreementNotifier.submit] 성공 후 호출하여 `requiresAgreement`를 false로
  /// 갱신합니다. 상태 변화가 GoRouter refreshListenable을 통해 redirect를 재실행시켜
  /// 다음 화면(닉네임 설정 또는 홈)으로 자동 이동됩니다.
  void markAgreementCompleted() {
    final current = state.valueOrNull;
    if (current == null) {
      debugPrint('⚠️ [AuthNotifier] markAgreementCompleted: 상태 없음 (무시)');
      return;
    }
    if (!current.requiresAgreement) {
      debugPrint('ℹ️ [AuthNotifier] markAgreementCompleted: 이미 동의 완료 (무시)');
      return;
    }
    state = AsyncValue.data(current.copyWith(requiresAgreement: false));
    debugPrint('✅ [AuthNotifier] 약관 동의 완료 플래그 반영');
  }

  /// 백엔드가 "필수 약관 미동의" 차단 응답을 반환했을 때 호출합니다.
  ///
  /// `requiresAgreement`를 true로 세팅해 라우터가 `/agreement`로 자동 redirect
  /// 하도록 유도합니다. [markAgreementCompleted]의 반대 동작입니다.
  ///
  /// 구 버전에서 묵시적 동의만 한 기존 사용자가 방 생성/참여를 시도했을 때 등
  /// 백엔드가 400 에러로 차단한 케이스를 유저에게 안내하기 위한 경로로 사용됩니다.
  void markNeedsAgreement() {
    final current = state.valueOrNull;
    if (current == null) {
      debugPrint('⚠️ [AuthNotifier] markNeedsAgreement: 상태 없음 (무시)');
      return;
    }
    if (current.requiresAgreement) {
      debugPrint('ℹ️ [AuthNotifier] markNeedsAgreement: 이미 미동의 상태 (무시)');
      return;
    }
    state = AsyncValue.data(current.copyWith(requiresAgreement: true));
    debugPrint('🚨 [AuthNotifier] 필수 약관 미동의 플래그 반영 → /agreement로 리디렉트 예정');
  }

  /// 회원 탈퇴 후 로컬 정리
  ///
  /// 백엔드 계정 삭제(`DELETE /api/user/me`) 성공 후 호출됩니다.
  /// Firebase 세션 정리 + JWT 토큰 삭제를 수행합니다.
  ///
  /// **주의**: state는 여기서 초기화하지 않습니다.
  /// 호출부에서 `context.go(login?accountDeleted=true)` 후
  /// [forceLogout]으로 state를 초기화해야 GoRouter 리다이렉트보다
  /// 탈퇴 완료 메시지 전달이 먼저 실행됩니다.
  Future<void> cleanupAfterAccountDeletion() async {
    final firebaseDataSource = ref.read(firebaseAuthDataSourceProvider);
    try {
      await firebaseDataSource.signOut();
    } finally {
      await ref.read(secureTokenStorageProvider).clearTokens();
      await TutorialService.resetAll();
    }
  }

  /// 강제 로그아웃 (AuthInterceptor에서 호출)
  ///
  /// 토큰 재발급 실패 시 state를 null로 초기화하여
  /// GoRouter가 로그인 화면으로 리다이렉트하도록 합니다.
  void forceLogout() {
    HomePage.resetSafetyNotice();
    LoginPage.resetAgeVerification();
    TutorialService.resetAll();
    state = const AsyncValue.data(null);
  }
}
