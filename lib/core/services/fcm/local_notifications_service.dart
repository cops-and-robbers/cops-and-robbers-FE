import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 로컬 알림 서비스
/// 앱 내에서 로컬 푸시 알림을 관리하고 표시합니다
class LocalNotificationsService {
  // Private constructor for singleton pattern
  // 싱글톤 패턴을 위한 private 생성자
  LocalNotificationsService._internal();

  // Singleton instance
  // 싱글톤 인스턴스
  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();

  // Factory constructor to return singleton instance
  // 싱글톤 인스턴스를 반환하는 팩토리 생성자
  factory LocalNotificationsService.instance() => _instance;

  // Main plugin instance for handling notifications
  // 알림 처리를 위한 메인 플러그인 인스턴스
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  // Android-specific initialization settings using app launcher icon
  // 앱 런처 아이콘을 사용하는 Android 전용 초기화 설정
  final _androidInitializationSettings = const AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  // iOS-specific initialization settings with permission requests
  // 권한 요청을 포함한 iOS 전용 초기화 설정
  final _iosInitializationSettings = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // Android notification channel configuration
  // Android 알림 채널 설정
  final _androidChannel = const AndroidNotificationChannel(
    'channel_id',
    'Channel name',
    description: 'Android push notification channel',
    importance: Importance.max,
  );

  // Flag to track initialization status
  // 초기화 상태를 추적하는 플래그
  bool _isFlutterLocalNotificationInitialized = false;

  // Counter for generating unique notification IDs
  // 고유한 알림 ID를 생성하기 위한 카운터
  int _notificationIdCounter = 0;

  /// Initializes the local notifications plugin for Android and iOS.
  /// Android와 iOS를 위한 로컬 알림 플러그인을 초기화합니다
  Future<void> init() async {
    // Check if already initialized to prevent redundant setup
    // 중복 설정을 방지하기 위해 이미 초기화되었는지 확인
    if (_isFlutterLocalNotificationInitialized) {
      return;
    }

    // Create plugin instance
    // 플러그인 인스턴스 생성
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Combine platform-specific settings
    // 플랫폼별 설정 결합
    final initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iosInitializationSettings,
    );

    // Initialize plugin with settings and callback for notification taps
    // 설정과 알림 탭 콜백으로 플러그인 초기화
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap in foreground
        // 포그라운드에서 알림 탭 처리
        debugPrint(
          'Foreground notification has been tapped: ${response.payload}',
        );
      },
    );

    // Create Android notification channel
    // Android 알림 채널 생성
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    // Mark initialization as complete
    // 초기화 완료 표시
    _isFlutterLocalNotificationInitialized = true;
  }

  /// Show a local notification with the given title, body, and payload.
  /// 주어진 제목, 본문, 페이로드로 로컬 알림을 표시합니다
  Future<void> showNotification(
    String? title,
    String? body,
    String? payload,
  ) async {
    // Android-specific notification details
    // Android 전용 알림 세부 설정
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high,
    );

    // iOS-specific notification details
    // iOS 전용 알림 세부 설정
    const iosDetails = DarwinNotificationDetails();

    // Combine platform-specific details
    // 플랫폼별 세부 설정 결합
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Display the notification
    // 알림 표시
    await _flutterLocalNotificationsPlugin.show(
      _notificationIdCounter++,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
