import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'local_notifications_service.dart';
import '../device/device_info_service.dart';
import '../device/device_id_manager.dart';

/// Firebase Cloud Messaging 서비스
/// FCM 푸시 알림을 관리하고 메시지를 처리합니다
class FirebaseMessagingService {
  // Private constructor for singleton pattern
  // 싱글톤 패턴을 위한 private 생성자
  FirebaseMessagingService._internal();

  // Singleton instance
  // 싱글톤 인스턴스
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  // Factory constructor to provide singleton instance
  // 싱글톤 인스턴스를 제공하는 팩토리 생성자
  factory FirebaseMessagingService.instance() => _instance;

  // Reference to local notifications service for displaying notifications
  // 알림 표시를 위한 로컬 알림 서비스 참조
  LocalNotificationsService? _localNotificationsService;

  // ═══════════════════════════════════════════════════════════════════════
  // 콘텐츠 완료 알림 Stream (NotificationScreen용)
  // ═══════════════════════════════════════════════════════════════════════

  /// 콘텐츠 분석 완료 알림을 위한 StreamController
  ///
  /// 백엔드에서 FCM 메시지로 다음과 같은 형식을 보냅니다:
  /// ```json
  /// {
  ///   "data": {
  ///     "type": "content_completed",
  ///     "id": "f95d2a71-e8ec-4ef1-b283-298deea9cf6b"
  ///   }
  /// }
  /// ```
  ///
  /// NotificationScreen에서 이 Stream을 구독하여 UI를 업데이트합니다.
  static final _contentCompletedController =
      StreamController<String>.broadcast();

  /// 콘텐츠 분석 완료 알림 Stream
  ///
  /// **사용 예시** (NotificationScreen):
  /// ```dart
  /// _fcmSubscription = FirebaseMessagingService.contentCompletedStream.listen(
  ///   (contentId) => _handleContentCompleted(contentId),
  /// );
  /// ```
  static Stream<String> get contentCompletedStream =>
      _contentCompletedController.stream;

  /// 백엔드 등록용 FCM 토큰을 가져옵니다
  ///
  /// 로그인 API 호출 시 이 메서드를 사용하여 FCM 토큰을 가져옵니다.
  ///
  /// **주의**:
  /// - iOS 시뮬레이터에서는 토큰을 사용할 수 없어 null을 반환합니다
  /// - 권한이 거부된 경우에도 null을 반환합니다
  ///
  /// Returns:
  /// - 성공: FCM 토큰 문자열
  /// - 실패/시뮬레이터: null
  Future<String?> getFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        debugPrint('[FCM] ✅ 토큰 가져오기 성공: ${token.toString()}');
      } else {
        debugPrint('[FCM] ⚠️ 토큰 없음 (시뮬레이터 또는 권한 거부)');
      }
      return token;
    } catch (e) {
      debugPrint('[FCM] ❌ 토큰 가져오기 실패: $e');
      return null;
    }
  }

  /// 백엔드 등록용 Device 정보를 가져옵니다
  ///
  /// 로그인 API 호출 시 FCM 토큰과 함께 이 정보를 서버에 전송합니다.
  ///
  /// **반환 데이터**:
  /// - deviceId: 플랫폼 기기 고유 ID (Android ID / iOS IDFV)
  /// - deviceName: 사용자가 지정한 기기 이름 (예: "루카의 iPhone")
  /// - deviceType: 플랫폼 타입 ("IOS" / "ANDROID")
  /// - osVersion: OS 버전 (예: "17.4" / "13")
  ///
  /// **사용 예시**:
  /// ```dart
  /// final deviceInfo = await FirebaseMessagingService.instance().getDeviceInfo();
  /// final fcmToken = await FirebaseMessagingService.instance().getFcmToken();
  ///
  /// await authApi.login(
  ///   idToken: googleIdToken,
  ///   fcmToken: fcmToken,
  ///   deviceId: deviceInfo['deviceId'],
  ///   deviceName: deviceInfo['deviceName'],
  ///   deviceType: deviceInfo['deviceType'],
  /// );
  /// ```
  ///
  /// Returns: Device 정보 Map
  Future<Map<String, String>> getDeviceInfo() async {
    try {
      final deviceId = await DeviceIdManager.getOrCreateDeviceId();
      final deviceName = await DeviceInfoService.getDeviceName();
      final deviceType = DeviceInfoService.getDeviceType();
      final osVersion = await DeviceInfoService.getOSVersion();

      return {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'deviceType': deviceType,
        'osVersion': osVersion,
      };
    } catch (e) {
      debugPrint('[FCM] ❌ Device 정보 가져오기 실패: $e');
      return {
        'deviceId': 'unknown',
        'deviceName': 'Unknown Device',
        'deviceType': 'UNKNOWN',
        'osVersion': 'Unknown',
      };
    }
  }

  /// Initialize Firebase Messaging and sets up all message listeners
  /// Firebase Messaging을 초기화하고 모든 메시지 리스너를 설정합니다
  Future<void> init({
    required LocalNotificationsService localNotificationsService,
  }) async {
    // Init local notifications service
    // 로컬 알림 서비스 초기화
    _localNotificationsService = localNotificationsService;

    // Handle FCM token
    // FCM 토큰 처리
    _handlePushNotificationsToken();

    // Request user permission for notifications
    // 알림 권한 요청
    _requestPermission();

    // Register handler for background messages (app terminated)
    // 백그라운드 메시지 핸들러 등록 (앱 종료 상태)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen for messages when the app is in foreground
    // 앱이 포그라운드 상태일 때 메시지 수신 대기
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen for notification taps when the app is in background but not terminated
    // 앱이 백그라운드 상태일 때 알림 탭 이벤트 수신 대기
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check for initial message that opened the app from terminated state
    // 앱이 종료 상태에서 알림으로 실행된 경우 초기 메시지 확인
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  /// Retrieves and manages the FCM token for push notifications
  /// 푸시 알림을 위한 FCM 토큰을 가져오고 관리합니다
  Future<void> _handlePushNotificationsToken() async {
    // 1. Get device information first (always runs, even on simulator)
    // 1. 먼저 기기 정보 수집 (시뮬레이터에서도 항상 실행됨)
    final deviceInfo = await getDeviceInfo();
    final isPhysical = await DeviceInfoService.isPhysicalDevice();

    // 2. Print device info (always visible, even on simulator)
    // 2. 기기 정보 출력 (시뮬레이터에서도 항상 표시됨)
    debugPrint('📱 Device ID: ${deviceInfo['deviceId']}');
    debugPrint('📱 Device Name: ${deviceInfo['deviceName']}');
    debugPrint('📱 Device Type: ${deviceInfo['deviceType']}');
    debugPrint('📱 OS Version: ${deviceInfo['osVersion']}');
    debugPrint('📱 Physical Device: $isPhysical');

    // Print full device info for debugging (개발 중에만 활성화)
    // 전체 기기 정보 출력 (디버깅용)
    if (kDebugMode) {
      final fullDeviceInfo = await DeviceInfoService.getFullDeviceInfo();
      debugPrint('📱 Full Device Info: $fullDeviceInfo');
    }

    // 3. Try to get FCM token (may fail on iOS simulator)
    // 3. FCM 토큰 가져오기 시도 (iOS 시뮬레이터에서는 실패할 수 있음)
    // getFcmToken()이 이미 try-catch 처리하므로 재사용
    final token = await getFcmToken();

    // 4. Setup token refresh listener if token exists
    // 4. 토큰이 있으면 갱신 리스너 등록
    if (token != null) {
      // Listen for token refresh events
      // 토큰 갱신 이벤트 수신 대기
      FirebaseMessaging.instance.onTokenRefresh
          .listen((fcmToken) {
            debugPrint('🔄 FCM token refreshed: $fcmToken');
            debugPrint('✅ Updated token will be sent on next login.');
          })
          .onError((error) {
            // Handle errors during token refresh
            // 토큰 갱신 중 발생한 에러 처리
            debugPrint('❌ Error refreshing FCM token: $error');
          });
    } else {
      // Show helpful message for simulator users when token is null
      // 시뮬레이터 사용자를 위한 안내 메시지
      if (!isPhysical) {
        debugPrint(
          '📱 Note: FCM tokens are only available on physical iOS devices, not simulators',
        );
        debugPrint(
          '💡 Device information is collected successfully, but push notifications require a real device',
        );
      }
    }
  }

  /// Requests notification permission from the user
  /// 사용자에게 알림 권한을 요청합니다
  Future<void> _requestPermission() async {
    // Request permission for alerts, badges, and sounds
    // 알림, 배지, 사운드에 대한 권한 요청
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Log the user's permission decision
    // 사용자의 권한 허용 여부 로그 기록
    debugPrint('User granted permission: ${result.authorizationStatus}');
  }

  /// Handles messages received while the app is in the foreground
  /// 앱이 포그라운드 상태일 때 수신한 메시지를 처리합니다
  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.data.toString()}');

    // 1. 백엔드 메시지 타입 확인 (data.type)
    final messageType = message.data['type'];

    // 2. 콘텐츠 분석 완료 알림 처리
    if (messageType == 'content_completed') {
      final contentId = message.data['id'];
      if (contentId != null) {
        debugPrint('[FCM] 콘텐츠 분석 완료 알림 수신: $contentId');
        _contentCompletedController.add(contentId); // ✅ Stream으로 브로드캐스트
      }
    }

    // 3. 로컬 알림 표시 (기존 기능 유지)
    final notificationData = message.notification;
    if (notificationData != null) {
      // Display a local notification using the service
      // 서비스를 사용하여 로컬 알림 표시
      _localNotificationsService?.showNotification(
        notificationData.title,
        notificationData.body,
        message.data.toString(),
      );
    }
  }

  /// Handles notification taps when app is opened from the background or terminated state
  /// 앱이 백그라운드 또는 종료 상태에서 알림 탭으로 열렸을 때 처리합니다
  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint(
      'Notification caused the app to open: ${message.data.toString()}',
    );

    // 백엔드 메시지 타입 확인 (data.type)
    final messageType = message.data['type'];

    // 콘텐츠 분석 완료 알림 처리
    if (messageType == 'content_completed') {
      final contentId = message.data['id'];
      if (contentId != null) {
        debugPrint('[FCM] 백그라운드에서 앱 열림 - contentId: $contentId');
        _contentCompletedController.add(contentId); // ✅ Stream으로 브로드캐스트
      }
    }

    // TODO: Add navigation or specific handling based on message data
    // TODO: 메시지 데이터를 기반으로 화면 이동 또는 특정 처리를 추가하세요
  }

  /// StreamController 정리
  ///
  /// 앱 종료 시 호출하여 메모리 누수를 방지합니다.
  static void dispose() {
    _contentCompletedController.close();
  }
}

/// Background message handler (must be top-level function or static)
/// Handles messages when the app is fully terminated
/// 백그라운드 메시지 핸들러 (최상위 함수 또는 static이어야 함)
/// 앱이 완전히 종료된 상태에서 메시지를 처리합니다
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.data.toString()}');

  // 백엔드 메시지 타입 확인 (data.type)
  final messageType = message.data['type'];

  // 콘텐츠 분석 완료 알림 처리
  if (messageType == 'content_completed') {
    final contentId = message.data['id'];
    if (contentId != null) {
      debugPrint('[FCM Background] 콘텐츠 분석 완료: $contentId');
      // ⚠️ 백그라운드 핸들러는 UI 업데이트 불가
      // 사용자가 앱을 열면 _onMessageOpenedApp에서 처리됨
    }
  }
}
