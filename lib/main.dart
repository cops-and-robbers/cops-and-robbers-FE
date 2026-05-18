import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cops_and_robbers/core/config/env_config.dart';
import 'package:cops_and_robbers/core/i18n/locale_provider.dart';
import 'package:cops_and_robbers/core/services/fcm/firebase_messaging_service.dart';
import 'package:cops_and_robbers/core/services/fcm/local_notifications_service.dart';
import 'package:cops_and_robbers/core/services/permission/location_permission_service.dart';
import 'package:cops_and_robbers/core/services/vibration_service.dart';
import 'package:cops_and_robbers/core/storage/secure_token_storage.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/router/app_router.dart';

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
  try {
    await LocalNotificationsService.instance().init();
    debugPrint('✅ Local notifications initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Local notifications initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    // 실패해도 계속 진행 (푸시 알림 없이 앱 사용 가능)
    // Continue execution (app works without push notifications)
  }

  // ============================================================
  // 5. FCM 서비스 초기화 (Firebase 의존)
  // 5. Initialize FCM (requires Firebase)
  // ============================================================
  if (isFirebaseInitialized) {
    try {
      await FirebaseMessagingService.instance().init();
      debugPrint('✅ FCM initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ FCM initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      // FCM 실패해도 앱은 계속 실행 (원격 푸시 없이 사용 가능)
      // Continue execution (app works without remote push)
    }
  } else {
    debugPrint('⚠️ FCM skipped (Firebase not initialized)');
  }

  runApp(
    ProviderScope(child: MyApp(isFirebaseInitialized: isFirebaseInitialized)),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key, this.isFirebaseInitialized = true});

  final bool isFirebaseInitialized;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

      // locale watch는 _LocalizedApp 안으로 내려서 ScreenUtilInit child 캐싱을 회피.
      // ScreenUtilInit는 한 번만 만들어지고, locale 변경 시 _LocalizedApp만 rebuild된다.
      builder: (context, child) => const _LocalizedApp(),
    );
  }
}

/// Locale에 의존하는 MaterialApp wrapper
///
/// ScreenUtilInit 바깥에서 locale을 watch하면 builder 콜백이 재호출되지 않는 케이스가 있어
/// (라이브러리가 child를 캐싱), ScreenUtilInit 안쪽 ConsumerWidget으로 분리한다.
/// MaterialApp.router에 `ValueKey(locale.languageCode)`를 부여해 locale 변경 시
/// Localizations widget을 포함한 전체 트리를 강제로 새로 만들어 즉시 반영되도록 한다.
class _LocalizedApp extends ConsumerWidget {
  const _LocalizedApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(appLocaleProvider).locale;

    return MaterialApp.router(
      key: ValueKey(locale.languageCode),
      // i18n — title은 locale 변경 시 자동 재계산되도록 onGenerateTitle 사용
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
