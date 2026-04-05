import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import '../constants/deep_link_config.dart';

/// 딥링크 파싱 결과 sealed class
sealed class DeepLinkResult {}

/// 방 초대 딥링크 결과
class RoomInviteResult extends DeepLinkResult {
  RoomInviteResult({required this.inviteCode});

  final String inviteCode;
}

/// 딥링크 수신 및 파싱을 담당하는 핸들러
///
/// [init]을 호출하면 Cold Start 링크 확인 + 실행 중 링크 스트림을 구독한다.
/// 수신된 URI는 [parseDeepLink]로 파싱하여 [onDeepLink] 콜백으로 전달한다.
class DeepLinkHandler {
  DeepLinkHandler({required this.onDeepLink});

  final void Function(DeepLinkResult result) onDeepLink;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  /// 딥링크 수신 시작 (Cold Start + 실행 중)
  Future<void> init() async {
    // Cold Start: 앱이 종료 상태에서 딥링크로 열린 경우
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('[DeepLink] 🔗 Cold Start URI: $initialUri');
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('[DeepLink] ❌ Cold Start 링크 확인 실패: $e');
    }

    // 실행 중: 앱이 이미 떠있는 상태에서 딥링크 수신
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[DeepLink] 🔗 실행 중 URI 수신: $uri');
        _handleUri(uri);
      },
      onError: (error) {
        debugPrint('[DeepLink] ❌ URI 스트림 에러: $error');
      },
    );
  }

  /// URI를 파싱하고 유효하면 콜백 호출
  void _handleUri(Uri uri) {
    final result = parseDeepLink(uri);
    if (result != null) {
      onDeepLink(result);
    }
  }

  /// URI를 파싱하여 딥링크 결과 반환 (유효하지 않으면 null)
  ///
  /// 순수 함수로 테스트 용이성을 위해 static 메서드로 분리.
  static DeepLinkResult? parseDeepLink(Uri uri) {
    // 호스트 검증
    if (!DeepLinkConfig.isDeepLink(uri)) return null;

    // 방 초대 경로 확인
    if (!DeepLinkConfig.isRoomInvite(uri)) return null;

    // 초대코드 추출
    final code = DeepLinkConfig.extractRoomCode(uri);
    if (code == null || code.isEmpty) return null;

    return RoomInviteResult(inviteCode: code);
  }

  /// 리소스 해제
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
