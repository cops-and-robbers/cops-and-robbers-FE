import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// 로딩 메시지 카테고리
///
/// 카테고리별 ARB 키 풀에서 랜덤 메시지를 가져온다.
enum LoadingCategory {
  joinRoom,
  createRoom,
  changeTeam,
  startGame,
  updateArea,
  saveSettings,
  loadProfile,
  logout,
  deleteAccount,
  reconnect,
  bugReport,
}

/// 카테고리별 랜덤 로딩 메시지 제공 서비스
///
/// ARB(`lib/l10n/app_*.arb`)의 `asset_loading_*` 키를 카테고리별로 묶어 사용한다.
/// 과거 `assets/messages/loading_messages.json` 로드 방식을 i18n 통합으로 대체했다.
///
/// ```dart
/// final message = LoadingMessageService.getMessage(context, LoadingCategory.joinRoom);
/// // → "잠입 준비 중..." (랜덤)
/// ```
class LoadingMessageService {
  LoadingMessageService._();

  static final _random = Random();

  /// 카테고리에 해당하는 랜덤 메시지 반환
  ///
  /// 카테고리에 매핑된 ARB 키 풀에서 랜덤으로 하나를 선택해 현재 로케일의
  /// 번역 문자열을 반환한다.
  static String getMessage(
    BuildContext context,
    LoadingCategory category, {
    String? fallback,
  }) {
    final l10n = AppLocalizations.of(context);
    final pool = _poolFor(l10n, category);
    if (pool.isEmpty) {
      return fallback ?? l10n.asset_loading_joinRoom;
    }
    return pool[_random.nextInt(pool.length)];
  }

  /// 카테고리별 ARB 키 풀
  ///
  /// 동일 카테고리 내 메시지는 모두 동일 빈도로 선택된다.
  /// (이전 JSON 구조의 카테고리별 배열을 그대로 옮긴 것)
  static List<String> _poolFor(
    AppLocalizations l10n,
    LoadingCategory category,
  ) {
    switch (category) {
      case LoadingCategory.joinRoom:
        return [
          l10n.asset_loading_joinRoom,
          l10n.asset_loading_joinRoom477c,
          l10n.asset_loading_joinRoom24a9,
          l10n.asset_loading_joinRoomCb98,
          l10n.asset_loading_joinRoomF964,
          l10n.asset_loading_joinRoomB36a,
          l10n.asset_loading_joinRoomAaf8,
          l10n.asset_loading_joinRoom25aa,
        ];
      case LoadingCategory.createRoom:
        return [
          l10n.asset_loading_createRoom,
          l10n.asset_loading_createRoomF1fe,
          l10n.asset_loading_createRoom01f8,
          l10n.asset_loading_createRoom5076,
          l10n.asset_loading_createRoomDd9e,
          l10n.asset_loading_createRoomB36a,
          l10n.asset_loading_createRoomAaf8,
          l10n.asset_loading_createRoom25aa,
        ];
      case LoadingCategory.changeTeam:
        return [
          l10n.asset_loading_changeTeam,
          l10n.asset_loading_changeTeam681d,
          l10n.asset_loading_changeTeam1106,
          l10n.asset_loading_changeTeam4d7a,
          l10n.asset_loading_changeTeam4cdc,
          l10n.asset_loading_changeTeamB36a,
          l10n.asset_loading_changeTeamAaf8,
          l10n.asset_loading_changeTeam25aa,
        ];
      case LoadingCategory.startGame:
        return [
          l10n.asset_loading_startGame,
          l10n.asset_loading_startGameA35d,
          l10n.asset_loading_startGame64c3,
          l10n.asset_loading_startGame7a2f,
          l10n.asset_loading_startGame1b41,
          l10n.asset_loading_startGameB36a,
          l10n.asset_loading_startGameAaf8,
          l10n.asset_loading_startGame25aa,
        ];
      case LoadingCategory.updateArea:
        return [
          l10n.asset_loading_updateArea,
          l10n.asset_loading_updateArea8c32,
          l10n.asset_loading_updateArea0183,
          l10n.asset_loading_updateArea2433,
          l10n.asset_loading_updateAreaDc8b,
          l10n.asset_loading_updateAreaB36a,
          l10n.asset_loading_updateAreaAaf8,
          l10n.asset_loading_updateArea25aa,
        ];
      case LoadingCategory.saveSettings:
        return [
          l10n.asset_loading_saveSettings,
          l10n.asset_loading_saveSettingsFb58,
          l10n.asset_loading_saveSettings65dc,
          l10n.asset_loading_saveSettings5e80,
          l10n.asset_loading_saveSettings128d,
          l10n.asset_loading_saveSettingsB36a,
          l10n.asset_loading_saveSettingsAaf8,
          l10n.asset_loading_saveSettings25aa,
        ];
      case LoadingCategory.loadProfile:
        return [
          l10n.asset_loading_loadProfile,
          l10n.asset_loading_loadProfile27ee,
          l10n.asset_loading_loadProfile6dac,
          l10n.asset_loading_loadProfile23c6,
          l10n.asset_loading_loadProfile221d,
          l10n.asset_loading_loadProfileB36a,
          l10n.asset_loading_loadProfileAaf8,
          l10n.asset_loading_loadProfile25aa,
        ];
      case LoadingCategory.logout:
        return [
          l10n.asset_loading_logout,
          l10n.asset_loading_logout3031,
          l10n.asset_loading_logoutCe40,
          l10n.asset_loading_logout0ba9,
          l10n.asset_loading_logoutFc0d,
          l10n.asset_loading_logoutB36a,
          l10n.asset_loading_logoutAaf8,
          l10n.asset_loading_logout25aa,
        ];
      case LoadingCategory.deleteAccount:
        return [
          l10n.asset_loading_deleteAccount,
          l10n.asset_loading_deleteAccountC5fd,
          l10n.asset_loading_deleteAccount517f,
        ];
      case LoadingCategory.reconnect:
        return [
          l10n.asset_loading_reconnect,
          l10n.asset_loading_reconnectBa5f,
          l10n.asset_loading_reconnect098b,
          l10n.asset_loading_reconnect429b,
          l10n.asset_loading_reconnect6b88,
          l10n.asset_loading_reconnectB36a,
          l10n.asset_loading_reconnectAaf8,
          l10n.asset_loading_reconnect25aa,
        ];
      case LoadingCategory.bugReport:
        return [
          l10n.asset_loading_bugReport,
          l10n.asset_loading_bugReportDd4b,
          l10n.asset_loading_bugReport5d70,
          l10n.asset_loading_bugReport3c49,
          l10n.asset_loading_bugReport83ca,
        ];
    }
  }
}
