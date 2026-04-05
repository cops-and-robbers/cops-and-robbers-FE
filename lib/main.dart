import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cops_and_robbers/core/config/env_config.dart';
import 'package:cops_and_robbers/core/services/fcm/firebase_messaging_service.dart';
import 'package:cops_and_robbers/core/services/fcm/local_notifications_service.dart';
import 'package:cops_and_robbers/core/services/permission/location_permission_service.dart';
import 'package:cops_and_robbers/core/services/vibration_service.dart';
import 'package:cops_and_robbers/core/storage/secure_token_storage.dart';
import 'package:cops_and_robbers/router/app_router.dart';
import 'package:cops_and_robbers/core/deep_link/deep_link_handler.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';
import 'package:cops_and_robbers/router/route_paths.dart';

void main() async {
  // Flutter 엔진 초기화 보장
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 재설치 시 이전 토큰 초기화 (iOS: Keychain 잔존 토큰 삭제, Android: 자동 삭제되므로 no-op)
  // Clear stale tokens on fresh install (iOS: Keychain persists after uninstall, Android: no-op)
  await SecureTokenStorage().clearTokensIfReinstalled();

  // 환경 변수 초기화 (API URL, WebSocket URL 등)
  // Initialize environment variables (API URL, WebSocket URL, etc.)
  await EnvConfig.initialize();

  // 화면 방향을 세로 모드(정방향)로 고정
  // Lock screen orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ============================================================
  // 위치 권한 확인
  // ============================================================
  final locationGranted = await LocationPermissionService.ensurePermission();

  if (!locationGranted) {
    debugPrint('[위치] ❌ 위치 권한 확보 실패');
    // 접근 제한 로직 추가 필요
  }

  // ============================================================
  // 1. Firebase 초기화 (필수, 하지만 실패해도 앱 실행 가능)
  // 1. Initialize Firebase (required, but app can run without it)
  // ============================================================
  bool isFirebaseInitialized = false;
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));
    isFirebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Firebase initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    // Firebase 없이도 앱 실행 가능하도록 계속 진행
    // Continue execution even without Firebase
  }

  // ============================================================
  // 2. Crashlytics 설정 (Firebase 성공 시에만 실행)
  // 2. Initialize Crashlytics (only if Firebase initialized)
  // ============================================================
  if (isFirebaseInitialized) {
    try {
      // 개발 모드에서는 Crashlytics 비활성화 (프로덕션에서만 수집)
      // Disable Crashlytics in debug mode (only collect in production)
      if (kDebugMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          false,
        );
      }

      // Flutter 프레임워크 에러 캡처 (위젯 빌드 에러 등)
      // Capture Flutter framework errors (widget build errors, etc.)
      FlutterError.onError = (errorDetails) {
        // 개발 모드: 콘솔에만 출력
        // Debug mode: Output to console only
        if (kDebugMode) {
          debugPrint('🔥 Flutter Error: ${errorDetails.exception}');
          debugPrint('Stack trace: ${errorDetails.stack}');
        } else {
          // 프로덕션 모드: Crashlytics에 전송
          // Production mode: Send to Crashlytics
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        }
      };

      // 비동기 에러 캡처 (Future, Stream 에러 등)
      // Capture asynchronous errors (Future, Stream errors, etc.)
      PlatformDispatcher.instance.onError = (error, stack) {
        // 개발 모드: 콘솔에만 출력
        // Debug mode: Output to console only
        if (kDebugMode) {
          debugPrint('🔥 Async Error: $error');
          debugPrint('Stack trace: $stack');
        } else {
          // 프로덕션 모드: Crashlytics에 전송
          // Production mode: Send to Crashlytics
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        return true;
      };

      debugPrint('✅ Crashlytics configured successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Crashlytics setup failed: $e');
      debugPrint('Stack trace: $stackTrace');
      // Crashlytics 실패해도 앱은 계속 실행
      // Continue execution even if Crashlytics fails
    }
  } else {
    debugPrint('⚠️ Crashlytics skipped (Firebase not initialized)');
  }

  // ============================================================
  // 3. 진동 서비스 초기화 (디바이스 지원 여부 캐싱)
  // ============================================================
  await VibrationService.instance().init();

  // ============================================================
  // 4. 로컬 알림 서비스 초기화 (Firebase와 독립적)
  // 4. Initialize local notifications (independent from Firebase)
  // ============================================================
  LocalNotificationsService? localNotificationsService;
  try {
    localNotificationsService = LocalNotificationsService.instance();
    await localNotificationsService.init();
    debugPrint('✅ Local notifications initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Local notifications initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    // 실패해도 계속 진행 (푸시 알림 없이 앱 사용 가능)
    // Continue execution (app works without push notifications)
  }

  // ============================================================
  // 5. FCM 서비스 초기화 (Firebase + 로컬 알림 필요)
  // 5. Initialize FCM (requires Firebase + Local notifications)
  // ============================================================
  if (isFirebaseInitialized && localNotificationsService != null) {
    try {
      await FirebaseMessagingService.instance().init(
        localNotificationsService: localNotificationsService,
      );
      debugPrint('✅ FCM initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ FCM initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      // FCM 실패해도 앱은 계속 실행 (원격 푸시 없이 사용 가능)
      // Continue execution (app works without remote push)
    }
  } else {
    if (!isFirebaseInitialized) {
      debugPrint('⚠️ FCM skipped (Firebase not initialized)');
    }
    if (localNotificationsService == null) {
      debugPrint('⚠️ FCM skipped (Local notifications not initialized)');
    }
  }

  runApp(
    ProviderScope(child: MyApp(isFirebaseInitialized: isFirebaseInitialized)),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, this.isFirebaseInitialized = true});

  final bool isFirebaseInitialized;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  DeepLinkHandler? _deepLinkHandler;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  /// 딥링크 핸들러 초기화
  ///
  /// 방 초대 딥링크 수신 시 기존 joinGameProvider로 방 참가 후 대기실로 이동.
  /// 인증되지 않은 상태에서는 무시 (go_router redirect가 로그인으로 보냄).
  void _initDeepLinks() {
    _deepLinkHandler = DeepLinkHandler(
      onDeepLink: (result) {
        switch (result) {
          case RoomInviteResult(:final inviteCode):
            debugPrint('[DeepLink] 🎯 방 초대코드 수신: $inviteCode');
            _handleRoomInvite(inviteCode);
        }
      },
    );
    _deepLinkHandler!.init();
  }

  /// 방 초대 딥링크 처리
  ///
  /// 인증 상태 확인 후 방 참가 API 호출 → 대기실로 이동.
  Future<void> _handleRoomInvite(String inviteCode) async {
    final authState = ref.read(authNotifierProvider);

    // 로그인 안 된 상태면 무시 (로그인 화면 유지)
    if (authState.isLoading || authState.value == null) {
      debugPrint('[DeepLink] ⚠️ 미인증 상태 — 딥링크 무시');
      return;
    }

    final router = ref.read(routerProvider);

    try {
      final response = await ref.read(
        joinGameProvider(inviteCode: inviteCode).future,
      );

      if (response != null) {
        debugPrint('[DeepLink] ✅ 방 참가 성공: gameId=${response.gameId}');
        router.go(
          '${RoutePaths.waitingRoomWithId('${response.gameId}')}'
          '?inviteCode=$inviteCode',
        );
      }
    } catch (e) {
      debugPrint('[DeepLink] ❌ 방 참가 실패: $e');
    }
  }

  @override
  void dispose() {
    _deepLinkHandler?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      // 디자인 기준 화면 크기 (iPhone 16 기준)
      // Base design screen size (iPhone 16)
      designSize: const Size(393, 852),

      // 텍스트 크기 자동 조정 (접근성 설정 반영)
      // Automatic text size adaptation (respects accessibility settings)
      minTextAdapt: true,

      // 멀티윈도우/폴더블 디바이스 대응
      // Support for multi-window and foldable devices
      splitScreenMode: true,

      builder: (context, child) {
        return MaterialApp.router(
          title: '경찰과도둑',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routerConfig: router,
        );
      },
    );
  }
}
