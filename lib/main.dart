import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cops_and_robbers/core/config/env_config.dart';
import 'package:cops_and_robbers/core/constants/text_styles.dart';
import 'package:cops_and_robbers/core/constants/spacing_and_radius.dart';
import 'package:cops_and_robbers/core/services/fcm/firebase_messaging_service.dart';
import 'package:cops_and_robbers/core/services/fcm/local_notifications_service.dart';

void main() async {
  // Flutter 엔진 초기화 보장
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 초기화 (API URL, WebSocket URL 등)
  // Initialize environment variables (API URL, WebSocket URL, etc.)
  await EnvConfig.initialize();

  // 화면 방향을 세로 모드(정방향)로 고정
  // Lock screen orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
  // 3. 로컬 알림 서비스 초기화 (Firebase와 독립적)
  // 3. Initialize local notifications (independent from Firebase)
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
  // 4. FCM 서비스 초기화 (Firebase + 로컬 알림 필요)
  // 4. Initialize FCM (requires Firebase + Local notifications)
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

  runApp(MyApp(isFirebaseInitialized: isFirebaseInitialized));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.isFirebaseInitialized = true});

  final bool isFirebaseInitialized;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // 디자인 기준 화면 크기 (iPhone 12/13/14 기준)
      // Base design screen size (iPhone 12/13/14)
      designSize: const Size(390, 844),

      // 텍스트 크기 자동 조정 (접근성 설정 반영)
      // Automatic text size adaptation (respects accessibility settings)
      minTextAdapt: true,

      // 멀티윈도우/폴더블 디바이스 대응
      // Support for multi-window and foldable devices
      splitScreenMode: true,

      builder: (context, child) {
        return MaterialApp(
          title: '경찰과도둑',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const FontTestPage(),
        );
      },
    );
  }
}

class FontTestPage extends StatelessWidget {
  const FontTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'AppTextStyles 테스트123',
          style: AppTextStyles.heading4.semiBold(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spacing & Radius 테스트
            Container(
              padding: AppPadding.cardPadding,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: AppRadius.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spacing & Radius 테스트',
                    style: AppTextStyles.heading4.bold(),
                  ),
                  SizedBox(height: AppSpacing.s8),
                  Text(
                    'AppPadding.cardPadding + AppRadius.card 적용됨',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.s24),

            // Heading Styles 테스트
            Text('Heading Styles', style: AppTextStyles.heading3.bold()),
            SizedBox(height: AppSpacing.s16),
            Text('Heading 1 (32sp)', style: AppTextStyles.heading1),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.heading1,
            ),
            Divider(height: AppSpacing.s32),
            Text('Heading 2 (28sp)', style: AppTextStyles.heading2),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.heading2,
            ),
            Divider(height: AppSpacing.s32),
            Text('Heading 3 (24sp)', style: AppTextStyles.heading3),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.heading3,
            ),
            Divider(height: AppSpacing.s32),
            Text('Heading 4 (20sp)', style: AppTextStyles.heading4),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.heading4,
            ),
            SizedBox(height: AppSpacing.s32),

            // Body Styles 테스트
            Text('Body Styles', style: AppTextStyles.heading3.bold()),
            SizedBox(height: AppSpacing.s16),
            Text('Body 1 (16sp)', style: AppTextStyles.body1),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.body1,
            ),
            Divider(height: AppSpacing.s32),
            Text('Body 2 (14sp)', style: AppTextStyles.body2),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.body2,
            ),
            SizedBox(height: AppSpacing.s32),

            // Small Styles 테스트
            Text('Small Styles', style: AppTextStyles.heading3.bold()),
            SizedBox(height: AppSpacing.s16),
            Text('Caption (12sp)', style: AppTextStyles.caption),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.caption,
            ),
            Divider(height: AppSpacing.s32),
            Text('Overline (10sp)', style: AppTextStyles.overline),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.overline,
            ),
            SizedBox(height: AppSpacing.s32),

            // Weight 테스트
            Text('Weight Variations', style: AppTextStyles.heading3.bold()),
            SizedBox(height: AppSpacing.s16),
            Text('Thin (100)', style: AppTextStyles.body1.thin()),
            Text('경찰과 도둑 Cops and Robbers', style: AppTextStyles.body1.thin()),
            Divider(height: AppSpacing.s24),
            Text('ExtraLight (200)', style: AppTextStyles.body1.extraLight()),
            Text(
              '경찰과 도둑 Cops and Robbers',
              style: AppTextStyles.body1.extraLight(),
            ),
            Divider(height: AppSpacing.s24),
            Text('Light (300)', style: AppTextStyles.body1.light()),
            Text('경찰과 도둑 Cops and Robbers', style: AppTextStyles.body1.light()),
            Divider(height: AppSpacing.s24),
            Text('Regular (400)', style: AppTextStyles.body1.regular()),
            Text(
              '경찰과 도둑 Cops and Robbers',
              style: AppTextStyles.body1.regular(),
            ),
            Divider(height: AppSpacing.s24),
            Text('Medium (500)', style: AppTextStyles.body1.medium()),
            Text(
              '경찰과 도둑 Cops and Robbers',
              style: AppTextStyles.body1.medium(),
            ),
            Divider(height: AppSpacing.s24),
            Text('SemiBold (600)', style: AppTextStyles.body1.semiBold()),
            Text(
              '경찰과 도둑 Cops and Robbers',
              style: AppTextStyles.body1.semiBold(),
            ),
            Divider(height: AppSpacing.s24),
            Text('Bold (700)', style: AppTextStyles.body1.bold()),
            Text('경찰과 도둑 Cops and Robbers', style: AppTextStyles.body1.bold()),
            Divider(height: AppSpacing.s24),
            Text('ExtraBold (800)', style: AppTextStyles.body1.extraBold()),
            Text(
              '경찰과 도둑 Cops and Robbers',
              style: AppTextStyles.body1.extraBold(),
            ),
            Divider(height: AppSpacing.s24),
            Text('Black (900)', style: AppTextStyles.body1.black()),
            Text('경찰과 도둑 Cops and Robbers', style: AppTextStyles.body1.black()),

            SizedBox(height: AppSpacing.s32),
          ],
        ),
      ),
    );
  }
}
