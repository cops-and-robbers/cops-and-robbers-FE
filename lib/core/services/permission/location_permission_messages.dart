import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';

/// 위치 권한 다이얼로그 사용 컨텍스트
///
/// 상황별로 다이얼로그 본문이 다르게 매핑된다.
enum LocationPermissionContext { home, game, waitingRoom }

/// 위치 권한 다이얼로그 메시지 (title + message)
class LocationPermissionDialogText {
  const LocationPermissionDialogText({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;
}

/// 위치 권한 다이얼로그 메시지 서비스
///
/// ARB(`asset_locationpermission_*` 키)에서 컨텍스트별 문구를 가져온다.
/// 과거 `assets/messages/location_permission_messages.json` 로드 방식을
/// i18n 통합으로 대체했다.
class LocationPermissionMessages {
  LocationPermissionMessages._();

  /// 위치 서비스 꺼짐 / 권한 미허용에 따른 다이얼로그 텍스트 반환
  ///
  /// [isServiceDisabled] true → 위치 서비스 자체가 꺼진 경우 문구
  /// false → 앱 권한 거부 상태 문구
  static LocationPermissionDialogText getText({
    required BuildContext context,
    required bool isServiceDisabled,
    required LocationPermissionContext locationContext,
  }) {
    final l10n = AppLocalizations.of(context);

    if (isServiceDisabled) {
      final title = l10n.asset_locationpermission_serviceDisabledTitle;
      final message = switch (locationContext) {
        LocationPermissionContext.home =>
          l10n.asset_locationpermission_serviceDisabledHome,
        LocationPermissionContext.game =>
          l10n.asset_locationpermission_serviceDisabledGame,
        LocationPermissionContext.waitingRoom =>
          l10n.asset_locationpermission_serviceDisabledWaitingRoom,
      };
      return LocationPermissionDialogText(title: title, message: message);
    }

    final title = l10n.asset_locationpermission_permissionDeniedTitle;
    final message = switch (locationContext) {
      LocationPermissionContext.home =>
        l10n.asset_locationpermission_permissionDeniedHome,
      LocationPermissionContext.game =>
        l10n.asset_locationpermission_permissionDeniedGame,
      LocationPermissionContext.waitingRoom =>
        l10n.asset_locationpermission_permissionDeniedWaitingRoom,
    };
    return LocationPermissionDialogText(title: title, message: message);
  }
}
