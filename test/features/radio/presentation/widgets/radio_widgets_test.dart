import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/radio/presentation/providers/radio_session_provider.dart';
import 'package:cops_and_robbers/features/radio/presentation/widgets/radio_ptt_button.dart';
import 'package:cops_and_robbers/features/radio/presentation/widgets/radio_speaker_pill.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../session/presentation/pages/creation_flow_fakes.dart'
    show loadAppFonts;

/// 실제 폰 크기(디자인 기준 393x852)에 앱 글꼴로 띄운다
Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, _) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ko'),
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

void main() {
  setUpAll(loadAppFonts);

  group('RadioPttButton', () {
    // 뛰다가 손가락이 버튼 밖으로 미끄러지면 포인터가 취소된다 — 마이크가 열린 채 남으면 안 된다
    testWidgets(
      'ptt_button_releases_when_finger_slides_off_and_pointer_cancels',
      (tester) async {
        var pressed = 0, released = 0;
        await _pump(
          tester,
          RadioPttButton(
            state: const RadioSessionState(status: RadioStatus.ready),
            onPress: () => pressed++,
            onRelease: () => released++,
            onBlockedTap: () {},
          ),
        );
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(RadioPttButton)),
        );
        await tester.pump();
        await gesture.cancel();
        await tester.pump();
        expect(pressed, 1);
        expect(released, 1);
      },
    );

    testWidgets(
      'ptt_button_calls_blocked_tap_instead_of_press_while_another_police_talks',
      (tester) async {
        var pressed = 0, blocked = 0;
        await _pump(
          tester,
          RadioPttButton(
            state: const RadioSessionState(
              status: RadioStatus.ready,
              speakerIdentity: '102',
            ),
            onPress: () => pressed++,
            onRelease: () {},
            onBlockedTap: () => blocked++,
          ),
        );
        await tester.tap(find.byType(RadioPttButton));
        expect(pressed, 0);
        expect(blocked, 1);
      },
    );

    testWidgets('ptt_button_calls_blocked_tap_during_police_wait', (
      tester,
    ) async {
      var pressed = 0, blocked = 0;
      await _pump(
        tester,
        RadioPttButton(
          state: const RadioSessionState(status: RadioStatus.waitingPolice),
          onPress: () => pressed++,
          onRelease: () {},
          onBlockedTap: () => blocked++,
        ),
      );
      await tester.tap(find.byType(RadioPttButton));
      expect(pressed, 0);
      expect(blocked, 1);
    });

    // 마이크를 거부한 경찰이 설정에서 허용하고 돌아와 다시 누른다 — 눌러야 다시 시도할 수 있다
    testWidgets('ptt_button_passes_press_through_when_mic_was_denied', (
      tester,
    ) async {
      var pressed = 0, blocked = 0;
      await _pump(
        tester,
        RadioPttButton(
          state: const RadioSessionState(status: RadioStatus.micDenied),
          onPress: () => pressed++,
          onRelease: () {},
          onBlockedTap: () => blocked++,
        ),
      );
      await tester.tap(find.byType(RadioPttButton));
      expect(pressed, 1);
      expect(blocked, 0);
    });

    // 혼잡으로 막힌 경찰이 회색 버튼을 누른다 — 말은 안 나가고 이유를 다시 알려 준다 (#722)
    testWidgets(
      'ptt_button_calls_blocked_tap_instead_of_press_while_radio_server_is_busy',
      (tester) async {
        var pressed = 0, blocked = 0;
        await _pump(
          tester,
          RadioPttButton(
            state: const RadioSessionState(status: RadioStatus.serverBusy),
            onPress: () => pressed++,
            onRelease: () {},
            onBlockedTap: () => blocked++,
          ),
        );
        await tester.tap(find.byType(RadioPttButton));
        expect(pressed, 0);
        expect(blocked, 1);
      },
    );
  });

  group('radioStatusNotice', () {
    final ko = lookupAppLocalizations(const Locale('ko'));
    final en = lookupAppLocalizations(const Locale('en'));
    final ja = lookupAppLocalizations(const Locale('ja'));

    // 출동 직후·끊겼다 붙는 중·출동 대기 재시도 중 어디서 막혀도 같은 안내가 뜬다
    test(
      'announces_congestion_in_each_language_when_radio_join_is_refused_as_busy',
      () {
        for (final before in [
          RadioStatus.connecting,
          RadioStatus.reconnecting,
          RadioStatus.waitingPolice,
        ]) {
          expect(
            radioStatusNotice(ko, before, RadioStatus.serverBusy),
            '지금 무전 사용자가 많아요\n혼잡이 풀리면 자동으로 연결돼요',
          );
        }
        expect(
          radioStatusNotice(en, RadioStatus.connecting, RadioStatus.serverBusy),
          "Radio is busy right now\nYou'll be connected automatically once it clears",
        );
        expect(
          radioStatusNotice(ja, RadioStatus.connecting, RadioStatus.serverBusy),
          'ただいま無線の利用者が多いです\n混雑が解消したら自動で接続します',
        );
      },
    );

    // 혼잡으로 못 들어가던 경찰이 다음 10초 시도에서 방에 들어갔다
    test('announces_connection_when_radio_joins_after_congestion', () {
      expect(
        radioStatusNotice(ko, RadioStatus.serverBusy, RadioStatus.ready),
        '무전이 연결됐어요',
      );
      expect(
        radioStatusNotice(en, RadioStatus.serverBusy, RadioStatus.ready),
        'Radio connected',
      );
      expect(
        radioStatusNotice(ja, RadioStatus.serverBusy, RadioStatus.ready),
        '無線に接続しました',
      );
    });

    // 혼잡 없이 평소처럼 붙었다 — 알릴 게 없다
    test('stays_silent_when_radio_joins_without_congestion', () {
      expect(
        radioStatusNotice(ko, RadioStatus.connecting, RadioStatus.ready),
        isNull,
      );
      expect(
        radioStatusNotice(ko, RadioStatus.reconnecting, RadioStatus.ready),
        isNull,
      );
      expect(radioStatusNotice(ko, null, RadioStatus.connecting), isNull);
    });

    // 혼잡한 채 게임이 끝났거나(off) 서버가 출동 대기로 돌려보냈다 — 연결된 게 아니다
    test('stays_silent_when_congestion_ends_without_joining', () {
      expect(
        radioStatusNotice(ko, RadioStatus.serverBusy, RadioStatus.off),
        isNull,
      );
      expect(
        radioStatusNotice(
          ko,
          RadioStatus.serverBusy,
          RadioStatus.waitingPolice,
        ),
        isNull,
      );
    });
  });

  group('radioSpeakerLabel', () {
    const nicknames = {'102': '상희', '103': '창희'};

    test('names_the_talking_police_in_each_language', () {
      expect(
        radioSpeakerLabel(
          lookupAppLocalizations(const Locale('ko')),
          '102',
          nicknames,
          mode: GameMode.copsAndRobbers,
        ),
        '상희 무전 중',
      );
      expect(
        radioSpeakerLabel(
          lookupAppLocalizations(const Locale('en')),
          '102',
          {'102': 'Sanghee'},
          mode: GameMode.copsAndRobbers,
        ),
        'Sanghee on radio',
      );
      expect(
        radioSpeakerLabel(
          lookupAppLocalizations(const Locale('ja')),
          '102',
          {'102': 'サンヒ'},
          mode: GameMode.copsAndRobbers,
        ),
        'サンヒ 無線中',
      );
    });

    // 참가자 목록을 아직 못 받았거나 늦게 들어온 경찰
    test('falls_back_to_cop_label_when_identity_not_in_participants', () {
      expect(
        radioSpeakerLabel(
          lookupAppLocalizations(const Locale('ko')),
          '999',
          nicknames,
          mode: GameMode.copsAndRobbers,
        ),
        '경찰 무전 중',
      );
    });

    // 술래잡기에서도 술래 팀은 무전을 쓴다 — 서버 푸시와 같은 "술래"로 부른다
    test(
      'falls_back_to_seeker_label_when_identity_not_in_participants_in_hide_and_seek',
      () {
        expect(
          radioSpeakerLabel(
            lookupAppLocalizations(const Locale('ko')),
            '999',
            nicknames,
            mode: GameMode.hideAndSeek,
          ),
          '술래 무전 중',
        );
      },
    );
  });

  testWidgets('speaker_pill_keeps_one_line_when_nickname_is_long', (
    tester,
  ) async {
    await _pump(
      tester,
      const RadioSpeakerPill(label: '달려라번개경찰관상희달려라번개경찰관상희 무전 중'),
    );
    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.textContaining('무전 중'));
    expect(text.maxLines, 1);
    expect(
      tester.getSize(find.byType(RadioSpeakerPill)).width,
      lessThanOrEqualTo(300),
    );
  });
}
