import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cops_and_robbers/core/constants/text_styles.dart';
import 'package:cops_and_robbers/core/services/fcm/firebase_messaging_service.dart';
import 'package:cops_and_robbers/core/services/fcm/local_notifications_service.dart';

void main() async {
  // Flutter 엔진 초기화 보장
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase 초기화
  // 1. Initialize Firebase
  await Firebase.initializeApp();

  // 2. 로컬 알림 서비스 초기화
  // 2. Initialize local notifications service
  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  // 3. FCM 서비스 초기화
  // 3. Initialize FCM service
  await FirebaseMessagingService.instance().init(
    localNotificationsService: localNotificationsService,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X 기준
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Cops and Robbers',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading Styles 테스트
            Text('Heading Styles', style: AppTextStyles.heading3.bold()),
            const SizedBox(height: 16),
            Text('Heading 1 (32sp)', style: AppTextStyles.heading1),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.heading1,
            ),
            const Divider(),
            Text('Heading 2 (28sp)', style: AppTextStyles.heading2),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.heading2,
            ),
            const Divider(),
            Text('Heading 3 (24sp)', style: AppTextStyles.heading3),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.heading3,
            ),
            const Divider(),
            Text('Heading 4 (20sp)', style: AppTextStyles.heading4),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: 32),

            // Body Styles 테스트
            Text('Body Styles', style: AppTextStyles.heading3.bold()),
            const SizedBox(height: 16),
            Text('Body 1 (16sp)', style: AppTextStyles.body1),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.body1,
            ),
            const Divider(),
            Text('Body 2 (14sp)', style: AppTextStyles.body2),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: 32),

            // Small Styles 테스트
            Text('Small Styles', style: AppTextStyles.heading3.bold()),
            const SizedBox(height: 16),
            Text('Caption (12sp)', style: AppTextStyles.caption),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.caption,
            ),
            const Divider(),
            Text('Overline (10sp)', style: AppTextStyles.overline),
            Text(
              '경찰과 도둑 Cops and Robbers 1234567890',
              style: AppTextStyles.overline,
            ),
            const SizedBox(height: 32),

            // Weight 테스트
            Text('Weight Variations', style: AppTextStyles.heading3.bold()),
            const SizedBox(height: 16),
            Text('Thin (100)', style: AppTextStyles.body1.thin()),
            Text('경찰과 도둑 Cops and Robbers', style: AppTextStyles.body1.thin()),
            const Divider(),
            Text('ExtraLight (200)', style: AppTextStyles.body1.extraLight()),
            Text(
              '경찰과 도둑 Cops and Robbers',
              style: AppTextStyles.body1.extraLight(),
            ),
            const Divider(),
            Text('Light (300)', style: AppTextStyles.body1.light()),
            Text('경찰과 도둑 Cops and Robbers', style: AppTextStyles.body1.light()),
            const Divider(),
            Text('Regular (400)', style: AppTextStyles.body1.regular()),
            Text(
              '경찰과 도둑 Cops and Robbers',
              style: AppTextStyles.body1.regular(),
            ),
            const Divider(),
            Text('Medium (500)', style: AppTextStyles.body1.medium()),
            Text(
              '경찰과 도둑 Cops and Robbers',
              style: AppTextStyles.body1.medium(),
            ),
            const Divider(),
            Text('SemiBold (600)', style: AppTextStyles.body1.semiBold()),
            Text(
              '경찰과 도둑 Cops and Robbers',
              style: AppTextStyles.body1.semiBold(),
            ),
            const Divider(),
            Text('Bold (700)', style: AppTextStyles.body1.bold()),
            Text('경찰과 도둑 Cops and Robbers', style: AppTextStyles.body1.bold()),
            const Divider(),
            Text('ExtraBold (800)', style: AppTextStyles.body1.extraBold()),
            Text(
              '경찰과 도둑 Cops and Robbers',
              style: AppTextStyles.body1.extraBold(),
            ),
            const Divider(),
            Text('Black (900)', style: AppTextStyles.body1.black()),
            Text('경찰과 도둑 Cops and Robbers', style: AppTextStyles.body1.black()),
          ],
        ),
      ),
    );
  }
}
