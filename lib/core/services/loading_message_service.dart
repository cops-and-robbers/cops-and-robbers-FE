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

  /// 카테고리별 안심 서브카피 (고정 1개)
  ///
  /// 제목(랜덤 세계관 문구)과 달리, 서브카피는 "앱을 끄면 취소돼요" 류의
  /// 안심 문구라 카테고리당 하나로 고정한다.
  /// [LoadingCategory.reconnect]는 별도 UI(reconnect_modal)를 쓰므로 null.
  static String? getSubtitle(BuildContext context, LoadingCategory category) =>
      subtitleFor(AppLocalizations.of(context), category);

  @visibleForTesting
  static String? subtitleFor(AppLocalizations l10n, LoadingCategory category) {
    switch (category) {
      case LoadingCategory.joinRoom:
        return l10n.asset_loading_sub_joinRoom;
      case LoadingCategory.createRoom:
        return l10n.asset_loading_sub_createRoom;
      case LoadingCategory.changeTeam:
        return l10n.asset_loading_sub_changeTeam;
      case LoadingCategory.startGame:
        return l10n.asset_loading_sub_startGame;
      case LoadingCategory.updateArea:
        return l10n.asset_loading_sub_updateArea;
      case LoadingCategory.saveSettings:
        return l10n.asset_loading_sub_saveSettings;
      case LoadingCategory.loadProfile:
        return l10n.asset_loading_sub_loadProfile;
      case LoadingCategory.logout:
        return l10n.asset_loading_sub_logout;
      case LoadingCategory.deleteAccount:
        return l10n.asset_loading_sub_deleteAccount;
      case LoadingCategory.bugReport:
        return l10n.asset_loading_sub_bugReport;
      case LoadingCategory.reconnect:
        return null;
    }
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
          l10n.asset_loading_joinRoomJoinOperation,
          l10n.asset_loading_joinRoomEnterSecretPassage,
          l10n.asset_loading_joinRoomCheckDisguise,
          l10n.asset_loading_joinRoomCheckDeployment,
          l10n.asset_loading_easterEggSettingsTap,
          l10n.asset_loading_easterEggVersionTap,
          l10n.asset_loading_easterEggVersionSecret,
          l10n.asset_loading_easterEggCharacterRumor,
          l10n.asset_loading_easterEggCharacterTap,
          l10n.asset_loading_easterEggCharacterSecret,
        ];
      case LoadingCategory.createRoom:
        return [
          l10n.asset_loading_createRoom,
          l10n.asset_loading_createRoomPrepareHideout,
          l10n.asset_loading_createRoomSecureArea,
          l10n.asset_loading_createRoomUnfoldMap,
          l10n.asset_loading_createRoomTuneRadio,
          l10n.asset_loading_easterEggSettingsTap,
          l10n.asset_loading_easterEggVersionTap,
          l10n.asset_loading_easterEggVersionSecret,
          l10n.asset_loading_easterEggCharacterRumor,
          l10n.asset_loading_easterEggCharacterTap,
          l10n.asset_loading_easterEggCharacterSecret,
        ];
      case LoadingCategory.changeTeam:
        return [
          l10n.asset_loading_changeTeam,
          l10n.asset_loading_changeTeamChangeCoverIdentity,
          l10n.asset_loading_changeTeamLaunderIdentity,
          l10n.asset_loading_changeTeamSwitchToDoubleSpy,
          l10n.asset_loading_changeTeamIssueNewId,
          l10n.asset_loading_easterEggSettingsTap,
          l10n.asset_loading_easterEggVersionTap,
          l10n.asset_loading_easterEggVersionSecret,
          l10n.asset_loading_easterEggCharacterRumor,
          l10n.asset_loading_easterEggCharacterTap,
          l10n.asset_loading_easterEggCharacterSecret,
        ];
      case LoadingCategory.startGame:
        return [
          l10n.asset_loading_startGame,
          l10n.asset_loading_startGamePrepareMoveOut,
          l10n.asset_loading_startGameCountdownStart,
          l10n.asset_loading_startGameTurnOnRadio,
          l10n.asset_loading_startGameDeployAgents,
          l10n.asset_loading_easterEggSettingsTap,
          l10n.asset_loading_easterEggVersionTap,
          l10n.asset_loading_easterEggVersionSecret,
          l10n.asset_loading_easterEggCharacterRumor,
          l10n.asset_loading_easterEggCharacterTap,
          l10n.asset_loading_easterEggCharacterSecret,
        ];
      case LoadingCategory.updateArea:
        return [
          l10n.asset_loading_updateArea,
          l10n.asset_loading_updateAreaDesignateZone,
          l10n.asset_loading_updateAreaPlotOnMap,
          l10n.asset_loading_updateAreaAnalyzeSatellite,
          l10n.asset_loading_updateAreaCalculateRange,
          l10n.asset_loading_easterEggSettingsTap,
          l10n.asset_loading_easterEggVersionTap,
          l10n.asset_loading_easterEggVersionSecret,
          l10n.asset_loading_easterEggCharacterRumor,
          l10n.asset_loading_easterEggCharacterTap,
          l10n.asset_loading_easterEggCharacterSecret,
        ];
      case LoadingCategory.saveSettings:
        return [
          l10n.asset_loading_saveSettings,
          l10n.asset_loading_saveSettingsUpdateRules,
          l10n.asset_loading_saveSettingsApplyNewRules,
          l10n.asset_loading_saveSettingsChangePasscode,
          l10n.asset_loading_saveSettingsApplyOperationCode,
          l10n.asset_loading_easterEggSettingsTap,
          l10n.asset_loading_easterEggVersionTap,
          l10n.asset_loading_easterEggVersionSecret,
          l10n.asset_loading_easterEggCharacterRumor,
          l10n.asset_loading_easterEggCharacterTap,
          l10n.asset_loading_easterEggCharacterSecret,
        ];
      case LoadingCategory.loadProfile:
        return [
          l10n.asset_loading_loadProfile,
          l10n.asset_loading_loadProfileCheckWantedPoster,
          l10n.asset_loading_loadProfileInspectId,
          l10n.asset_loading_loadProfileMatchFingerprints,
          l10n.asset_loading_loadProfileAnalyzeSuspect,
          l10n.asset_loading_easterEggSettingsTap,
          l10n.asset_loading_easterEggVersionTap,
          l10n.asset_loading_easterEggVersionSecret,
          l10n.asset_loading_easterEggCharacterRumor,
          l10n.asset_loading_easterEggCharacterTap,
          l10n.asset_loading_easterEggCharacterSecret,
        ];
      case LoadingCategory.logout:
        return [
          l10n.asset_loading_logout,
          l10n.asset_loading_logoutGoIntoHiding,
          l10n.asset_loading_logoutEraseTraces,
          l10n.asset_loading_logoutDestroyEvidence,
          l10n.asset_loading_logoutEscapeViaPassage,
          l10n.asset_loading_easterEggSettingsTap,
          l10n.asset_loading_easterEggVersionTap,
          l10n.asset_loading_easterEggVersionSecret,
          l10n.asset_loading_easterEggCharacterRumor,
          l10n.asset_loading_easterEggCharacterTap,
          l10n.asset_loading_easterEggCharacterSecret,
        ];
      case LoadingCategory.deleteAccount:
        return [
          l10n.asset_loading_deleteAccount,
          l10n.asset_loading_deleteAccountObliterateRecords,
          l10n.asset_loading_deleteAccountDeleteIdentity,
        ];
      case LoadingCategory.reconnect:
        return [
          l10n.asset_loading_reconnect,
          l10n.asset_loading_reconnectRejoinOperation,
          l10n.asset_loading_reconnectPrepareReturn,
          l10n.asset_loading_reconnectRestoreRadio,
          l10n.asset_loading_reconnectRescanFrequency,
          l10n.asset_loading_easterEggSettingsTap,
          l10n.asset_loading_easterEggVersionTap,
          l10n.asset_loading_easterEggVersionSecret,
          l10n.asset_loading_easterEggCharacterRumor,
          l10n.asset_loading_easterEggCharacterTap,
          l10n.asset_loading_easterEggCharacterSecret,
        ];
      case LoadingCategory.bugReport:
        return [
          l10n.asset_loading_bugReport,
          l10n.asset_loading_bugReportSubmitReport,
          l10n.asset_loading_bugReportAttachPhotos,
          l10n.asset_loading_bugReportAssignCaseNumber,
          l10n.asset_loading_bugReportHandToInvestigation,
        ];
    }
  }
}
