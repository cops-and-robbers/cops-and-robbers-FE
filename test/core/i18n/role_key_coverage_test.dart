import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 술래잡기에서 경찰·도둑·체포·수감 단어가 나오는 판 안 문구 키.
/// 서버 FCM(GameFcmWording TAG)이 "술래·도망자·잡힘"으로 보내므로 앱 문구도 같은 말이어야 한다.
/// 팀·역할 이름(gameTeam*/gameRole*Label)은 role_names.dart가 맡고,
/// 탈옥 전용 키(startRuleJailbreakReplay 등)는 술래잡기에서 안 나와 목록에서 뺀다.
const inGameRoleWordKeys = <String>[
  // 대기방·설정 (14)
  'dialogStartGamePoliceCount',
  'dialogStartGameRobberCount',
  'gameRulesCopGoalPrefix',
  'gameRulesRobberGoalPrefix',
  'gameRulesLocationShareLine1',
  'gameRulesLocationShareLine2',
  'gameRulesLocationShareLine3',
  'fieldLocationShareInterval',
  'fieldPoliceDispatchTime',
  'gameSettingPoliceStartDelay',
  'gameSettingPoliceStartPrefix',
  'gameSettingNoLocationShareWarning',
  'warnPoliceWaitMin',
  'shareInviteMessage',
  // 시작 연출 (14)
  'startTitlePolice',
  'startTitleRobber',
  'startWaitCountdownLabel',
  'startWaitPoliceTitle',
  'startWaitRobberTitle',
  'startMissionPoliceLabel',
  'startMissionRobberLabel',
  'startMissionPolice',
  'startRuleQrArrest',
  'startRuleRobberReveal',
  'startRuleQrCaught',
  'startRuleMyReveal',
  'startRuleWin',
  'startRuleTeamReveal',
  // 인게임 (14)
  'gameRobberOnTheRunBanner',
  'errorCannotArrestDuringWait',
  'qrScannerWantedRobberTitle',
  'errorAlreadyArrested',
  'gameLocationRevealCountdown',
  'gamePoliceStartCountdown',
  'gameQrDisplayMessage',
  'gameChatAllHint',
  'gameEventPoliceMove',
  'gameEventLocationReveal',
  'pingChatFoundRobber',
  'pingChatSuspectRobber',
  'pingChatFoundCops',
  'pingChatSuspectCops',
  // 잠금화면 (2)
  'lockScreenRemainingRobbers',
  'fieldRemainingRobbers',
  // 결과 (7)
  'gameOverReasonAllArrested',
  'gameOverReasonPoliceForfeited',
  'gameOverReasonRobberForfeited',
  'labelPoliceTeamMvp',
  'labelRobberTeamMvp',
  'mvpRevealPoliceSubtitle',
  'mvpRevealRobberSubtitle',
  // 서버 에러 (8)
  'errorCodeInvalidPoliceWaitTime',
  'errorCodeInvalidTeamComposition',
  'errorCodeNotRobberTeam',
  'errorCodeParticipantGameMismatch',
  'errorCodeOnlyPoliceCanArrest',
  'errorCodeOnlyRobberCanBeArrested',
  'errorCodeAlreadyArrested',
  'errorCodePoliceWaitingTime',
  // 무전 (3, main #697 병합분)
  'errorCodeOnlyPoliceCanUseRadio',
  'errorCodeRadioPoliceWaitingTime',
  'radioSpeakerFallback',
  // 체포·수감 문구 (12)
  'gameEventArrestNotice',
  'gameRulesCopGoalSuffix',
  'startTitlePoliceAccent',
  'labelArrestCount',
  'labelMyArrestCount',
  'labelTeamArrestShare',
  'statusJailed',
  'dialogArrestConfirmTitle',
  'errorEventArrestRequestFailed',
  'gameMenuArrest',
  'tutorialScanTitle',
  'tutorialCalloutArrest',
  // 이미 있는 키(Task 6): 잡힌 도망자 관전 오버레이 제목
  'gameArrestOverlayTitle',
];

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('every_in_game_role_key_has_tag_variant_in_all_locales', () {
    expect(inGameRoleWordKeys.length, 75);
    for (final locale in ['ko', 'en', 'ja']) {
      final arb = _arb(locale);
      final missing = [
        for (final key in inGameRoleWordKeys)
          if (!arb.containsKey('${key}Tag')) '${key}Tag',
      ];
      expect(missing, isEmpty, reason: '$locale ARB에 술래잡기 문구가 없다');
    }
  });

  test(
    'tag_wording_avoids_classic_role_words_when_server_pushes_tag_words',
    () {
      final ko = _arb('ko');
      final leaked = [
        for (final key in inGameRoleWordKeys)
          if (RegExp('경찰|도둑|체포|수감').hasMatch(ko['${key}Tag'] as String? ?? ''))
            key,
      ];
      expect(leaked, isEmpty);
    },
  );

  test(
    'tag_wording_avoids_classic_role_words_in_en_and_ja_when_seeker_hider_mode',
    () {
      final leaks = <String>[];
      for (final locale in ['en', 'ja']) {
        final arb = _arb(locale);
        final classicWords = locale == 'en'
            ? RegExp('cop|robber|police|arrest|jail', caseSensitive: false)
            : RegExp('警察|泥棒|逮捕|収監|逃げる人');
        for (final entry in arb.entries) {
          final value = entry.value;
          if (entry.key.endsWith('Tag') && value is String) {
            // 아이콘 표식(@icon_police)과 {policeNickname} 같은 자리표시자는 화면에 보이는 말이 아니라 뺀다
            final visible = value.replaceAll(RegExp(r'@icon_\w+|\{\w+\}'), '');
            if (classicWords.hasMatch(visible)) {
              leaks.add('$locale ${entry.key}');
            }
          }
        }
      }
      expect(leaks, isEmpty);
    },
  );
}
