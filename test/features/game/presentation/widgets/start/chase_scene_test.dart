// test/features/game/presentation/widgets/start/chase_scene_test.dart
import 'package:clock/clock.dart';
import 'package:cops_and_robbers/core/services/vibration_service.dart';
import 'package:cops_and_robbers/features/game/domain/recede.dart';
import 'package:cops_and_robbers/features/game/domain/start_flow.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/chase_scene.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/chase_scene_rules.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/run_cycle.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
// 시스템 경계(진동 플러그인)만 갈아 끼우려고 전이 의존성을 직접 쓴다
// ignore: depend_on_referenced_packages
import 'package:vibration_platform_interface/vibration_platform_interface.dart';

/// [elapsed]만큼 지난 5분 대기 게임의 장면을 띄운다(시계는 테스트의 fakeAsync 시계).
Future<void> pumpScene(
  WidgetTester tester, {
  required ChaseSceneMode mode,
  required bool isPolice,
  required Duration elapsed,
  VoidCallback? onClose,
  int revealMinutes = 3, // 기본값 5와 달라야 방 설정을 읽는지 드러난다
  int roundTimeMinutes = 30,
  Size size = const Size(393, 852),
  Locale locale = const Locale('ko'),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, _) => MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ChaseScene(
            mode: mode,
            isPolice: isPolice,
            scene: StartScene.town,
            gameStartTime: clock.now().subtract(elapsed),
            policeWaitMinutes: 5,
            revealMinutes: revealMinutes,
            roundTimeMinutes: roundTimeMinutes,
            onClose: onClose,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// 진동 플러그인 자리. 실제 기기처럼 진동기가 있다고 답하고 vibrate 호출만 센다.
class FakeVibrationPlugin extends VibrationPlatform {
  int vibrateCalls = 0;

  @override
  Future<bool> hasVibrator() async => true;
  @override
  Future<bool> hasAmplitudeControl() async => true;
  @override
  Future<bool> hasCustomVibrationsSupport() async => true;
  @override
  Future<void> vibrate({
    int duration = 500,
    List<int> pattern = const [],
    int repeat = -1,
    List<int> intensities = const [],
    int amplitude = -1,
    double sharpness = 0.5,
  }) async => vibrateCalls++;
}

Future<FakeVibrationPlugin> installVibration() async {
  final fake = FakeVibrationPlugin();
  VibrationPlatform.instance = fake;
  await VibrationService.instance().init();
  return fake;
}

/// 250ms 갱신 주기로 [total]만큼 흘려보낸다.
Future<void> advance(WidgetTester tester, Duration total) async {
  for (
    var t = Duration.zero;
    t < total;
    t += const Duration(milliseconds: 250)
  ) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

/// 먼 쪽 캐릭터(트리에서 먼저 그려지는 SVG)의 배치
Positioned farCharacter(WidgetTester tester) => tester.widget<Positioned>(
  find
      .ancestor(
        of: find.byType(SvgPicture).first,
        matching: find.byType(Positioned),
      )
      .first,
);

void expectPose(Positioned actual, RecedePose pose, double scale) {
  expect(actual.left, closeTo(pose.left * scale, 1e-6));
  expect(actual.top, closeTo(pose.top * scale, 1e-6));
  expect(actual.width, closeTo(pose.width * scale, 1e-6));
}

String backgroundAsset(WidgetTester tester) {
  final image = tester.widget<Image>(find.byType(Image).first).image;
  // 화면 폭에 맞춰 줄여 디코딩하면 ResizeImage로 한 번 감싸진다
  final asset = image is ResizeImage ? image.imageProvider : image;
  return (asset as AssetImage).assetName;
}

/// 타이머가 남지 않게 장면을 내린다.
Future<void> unmount(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox());

void main() {
  testWidgets(
    'police_wait_shows_three_minutes_left_when_two_of_five_minutes_passed',
    (tester) async {
      await pumpScene(
        tester,
        mode: ChaseSceneMode.policeWait,
        isPolice: true,
        elapsed: const Duration(minutes: 2),
      );
      expect(find.text('03:00'), findsOneWidget);
      expect(find.text('경찰 출동까지'), findsOneWidget);
      expect(find.text('도둑이 도망치는 중이에요'), findsOneWidget);
      await unmount(tester);
    },
  );

  testWidgets('police_wait_number_grows_when_ten_seconds_remain', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 4, seconds: 48), // 12초 남음
    );
    double scale() =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
    expect(scale(), 1);
    await tester.pump(const Duration(seconds: 3)); // 9초 남음
    await tester.pump(const Duration(milliseconds: 300));
    expect(scale(), closeTo(72 / 56, 1e-9));
    await unmount(tester);
  });

  testWidgets(
    'police_wait_third_rule_uses_room_reveal_interval_when_it_comes_up',
    (tester) async {
      await pumpScene(
        tester,
        mode: ChaseSceneMode.policeWait,
        isPolice: true,
        elapsed: const Duration(minutes: 1),
      );
      expect(find.text('게임 규칙 1/4'), findsOneWidget);
      // 한 줄을 5초씩 보여 준다 — 3초는 읽기도 전에 넘어가 산만했다
      await tester.pump(const Duration(seconds: 4, milliseconds: 800));
      expect(find.text('게임 규칙 1/4'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5, milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('게임 규칙 3/4'), findsOneWidget);
      expect(find.text('도둑 위치는 3분마다 경찰에게 공개돼요'), findsOneWidget);
      await unmount(tester);
    },
  );

  testWidgets('police_wait_stays_open_when_police_taps_screen', (tester) async {
    var closed = 0;
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 1),
      onClose: () => closed++,
    );
    await tester.tapAt(const Offset(196, 426));
    expect(closed, 0);
    await unmount(tester);
  });

  testWidgets('robber_explainer_closes_when_robber_taps_screen', (
    tester,
  ) async {
    var closed = 0;
    await pumpScene(
      tester,
      mode: ChaseSceneMode.robberExplainer,
      isPolice: false,
      elapsed: const Duration(seconds: 4),
      onClose: () => closed++,
    );
    expect(find.text('경찰에게서 멀어지는 중이에요'), findsOneWidget);
    await tester.tapAt(const Offset(196, 426));
    expect(closed, 1);
    await unmount(tester);
  });

  // 규칙 4줄 × 5초
  testWidgets('robber_explainer_closes_by_itself_when_twenty_seconds_pass', (
    tester,
  ) async {
    var closed = 0;
    await pumpScene(
      tester,
      mode: ChaseSceneMode.robberExplainer,
      isPolice: false,
      elapsed: const Duration(seconds: 4),
      onClose: () => closed++,
    );
    await tester.pump(const Duration(seconds: 19, milliseconds: 900));
    expect(closed, 0);
    await tester.pump(const Duration(milliseconds: 200));
    expect(closed, 1);
    await unmount(tester);
  });

  // 규칙마다 줄 수가 달라도 "게임 규칙 n/m" 라벨은 한자리에 있어야 읽기 편하다
  testWidgets(
    'rule_counter_stays_in_place_when_rules_of_different_length_rotate',
    (tester) async {
      await pumpScene(
        tester,
        mode: ChaseSceneMode.rulesReplay,
        isPolice: false,
        elapsed: const Duration(minutes: 12),
      );
      final tops = <double>[];
      final ruleHeights = <double>{};
      for (var i = 1; i <= 6; i++) {
        final counter = find.text('게임 규칙 $i/6');
        tops.add(tester.getTopLeft(counter).dy);
        final block = find.ancestor(of: counter, matching: find.byType(Column));
        ruleHeights.add(tester.getSize(block.first).height);
        await tester.pump(ChaseScene.ruleInterval);
        await tester.pump(const Duration(milliseconds: 700)); // 바뀌는 애니메이션 끝
      }
      expect(ruleHeights.length, greaterThan(1)); // 줄 수가 다른 규칙이 섞여 있다
      expect(tops.toSet(), hasLength(1));
      await unmount(tester);
    },
  );

  // ⓘ는 시작 때 본 화면과 똑같아야 헷갈리지 않는다 — 출동 전이면 같은 카운트다운
  testWidgets(
    'rules_replay_looks_like_robber_start_screen_when_opened_before_dispatch',
    (tester) async {
      await pumpScene(
        tester,
        mode: ChaseSceneMode.rulesReplay,
        isPolice: false,
        elapsed: const Duration(minutes: 2),
      );
      expect(find.text('03:00'), findsOneWidget);
      expect(find.text('경찰 출동까지'), findsOneWidget);
      expect(find.text('경찰에게서 멀어지는 중이에요'), findsOneWidget);
      expect(find.text('게임 규칙 1/6'), findsOneWidget);
      expect(find.text('탭하면 지도로 돌아가요'), findsOneWidget);
      await unmount(tester);
    },
  );

  // 출동 뒤엔 셀 대기 시간이 없어 같은 자리에 남은 게임 시간을 보여 준다
  testWidgets(
    'rules_replay_shows_game_time_left_in_countdown_spot_when_opened_after_dispatch',
    (tester) async {
      await pumpScene(
        tester,
        mode: ChaseSceneMode.rulesReplay,
        isPolice: true,
        elapsed: const Duration(minutes: 12),
        roundTimeMinutes: 30,
      );
      expect(find.text('18:00'), findsOneWidget);
      expect(find.text('남은 게임 시간'), findsOneWidget);
      expect(find.text('경찰 출동까지'), findsNothing);
      expect(find.text('도둑이 도망치는 중이에요'), findsOneWidget);
      expect(find.text('탭하면 지도로 돌아가요'), findsOneWidget);
      await unmount(tester);
    },
  );

  // ⓘ는 Scaffold 없는 다이얼로그 라우트에 장면만 띄운다 — Material 바탕이 없으면 글자에 노란 밑줄이 그어진다
  testWidgets('rules_replay_text_has_no_underline_when_opened_as_dialog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => MaterialApp(
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChaseScene(
            mode: ChaseSceneMode.rulesReplay,
            isPolice: false,
            scene: StartScene.town,
            gameStartTime: clock.now().subtract(const Duration(minutes: 2)),
            policeWaitMinutes: 5,
            revealMinutes: 5,
          ),
        ),
      ),
    );
    final label = tester.widget<RichText>(
      find.descendant(
        of: find.text('경찰 출동까지'),
        matching: find.byType(RichText),
      ),
    );
    expect(label.text.style?.decoration, isNot(TextDecoration.underline));
    await unmount(tester);
  });

  // 정보가 많아 난잡하다는 리뷰 — 미션은 방금 본 역할 배너와 규칙 1번(승리 조건)에 이미 있다
  testWidgets('police_wait_leaves_mission_to_role_banner_when_shown', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 2),
    );
    expect(
      find.textContaining('도둑을 찾아 QR로 모두 체포하세요', findRichText: true),
      findsNothing,
    );
    await unmount(tester);
  });

  // 도둑 설명 화면도 ⓘ와 같은 "게임 규칙 n/m" 라벨을 쓴다
  testWidgets('robber_explainer_numbers_rules_as_game_rules_when_shown', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.robberExplainer,
      isPolice: false,
      elapsed: const Duration(seconds: 3),
    );
    expect(find.text('게임 규칙 1/4'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('rules_replay_cycles_through_six_rules_when_opened_from_info', (
    tester,
  ) async {
    var closed = 0;
    await pumpScene(
      tester,
      mode: ChaseSceneMode.rulesReplay,
      isPolice: false,
      elapsed: const Duration(minutes: 12), // 출동 후
      onClose: () => closed++,
    );
    await tester.pump(
      const Duration(seconds: 25, milliseconds: 300),
    ); // 5초 × 5줄 뒤
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('게임 규칙 6/6'), findsOneWidget);
    expect(find.text('잡힌 도둑은 감옥에 들어갔다가 밖으로 나가 3초가 지나면 탈옥해요'), findsOneWidget);
    await tester.tapAt(const Offset(196, 426));
    expect(closed, 1);
    await unmount(tester);
  });

  testWidgets(
    'police_wait_vibrates_once_per_second_when_last_ten_seconds_tick_by',
    (tester) async {
      final vibration = await installVibration();
      await pumpScene(
        tester,
        mode: ChaseSceneMode.policeWait,
        isPolice: true,
        elapsed: const Duration(minutes: 4, seconds: 50), // 10초 남음
      );
      await advance(tester, const Duration(seconds: 3)); // 10→7초: 4개 숫자
      expect(vibration.vibrateCalls, 4);
      await unmount(tester);
    },
  );

  testWidgets(
    'police_wait_does_not_vibrate_when_more_than_ten_seconds_remain',
    (tester) async {
      final vibration = await installVibration();
      await pumpScene(
        tester,
        mode: ChaseSceneMode.policeWait,
        isPolice: true,
        elapsed: const Duration(minutes: 1),
      );
      await advance(tester, const Duration(seconds: 3));
      expect(vibration.vibrateCalls, 0);
      await unmount(tester);
    },
  );

  for (final (mode, isPolice) in [
    (ChaseSceneMode.robberExplainer, false),
    (ChaseSceneMode.rulesReplay, true),
  ]) {
    testWidgets(
      '${mode.name}_does_not_vibrate_when_dispatch_is_ten_seconds_away',
      (tester) async {
        final vibration = await installVibration();
        await pumpScene(
          tester,
          mode: mode,
          isPolice: isPolice,
          elapsed: const Duration(minutes: 4, seconds: 50),
        );
        await advance(tester, const Duration(seconds: 3));
        expect(vibration.vibrateCalls, 0);
        await unmount(tester);
      },
    );
  }

  testWidgets('police_wait_robber_recedes_along_progress_when_time_passes', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 1), // 5분 중 1분
    );
    const s = 393 / 300;
    expectPose(farCharacter(tester), recede(0.2, policeWaitRecede), s);
    await advance(tester, const Duration(minutes: 1));
    expectPose(farCharacter(tester), recede(0.4, policeWaitRecede), s);
    await unmount(tester);
  });

  testWidgets(
    'robber_explainer_cat_recedes_with_same_progress_as_police_wait',
    (tester) async {
      await pumpScene(
        tester,
        mode: ChaseSceneMode.robberExplainer,
        isPolice: false,
        elapsed: const Duration(minutes: 1),
      );
      expectPose(
        farCharacter(tester),
        recede(0.2, robberWaitRecede),
        393 / 300,
      );
      await unmount(tester);
    },
  );

  testWidgets('police_scene_uses_day_background_and_robber_scene_uses_night', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 1),
    );
    expect(
      backgroundAsset(tester),
      'assets/backgrounds/start_wait/start_wait_town_day.png',
    );
    await unmount(tester);
    await pumpScene(
      tester,
      mode: ChaseSceneMode.robberExplainer,
      isPolice: false,
      elapsed: const Duration(minutes: 1),
    );
    expect(
      backgroundAsset(tester),
      'assets/backgrounds/start_wait/start_wait_town_night.png',
    );
    await unmount(tester);
  });

  // 16:9 폰은 목업(300×652)보다 짧아 아래가 잘린다 — 돌아가는 규칙 네 줄 모두
  // 앞의 캐릭터를 가리지 않고 화면 안에 있어야 한다
  for (final size in const [Size(375, 667), Size(360, 640)]) {
    for (final (mode, isPolice) in [
      (ChaseSceneMode.policeWait, true),
      (ChaseSceneMode.robberExplainer, false),
    ]) {
      testWidgets(
        '${mode.name}_rules_stay_clear_of_near_character_when_phone_is_'
        '${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
          await pumpScene(
            tester,
            mode: mode,
            isPolice: isPolice,
            elapsed: const Duration(minutes: 1),
            size: size,
          );
          final near = tester.getRect(find.byType(RunCycle).last);
          for (var i = 1; i <= 4; i++) {
            final rule = tester.getRect(
              find
                  .ancestor(
                    of: find.textContaining('$i/4'),
                    matching: find.byType(Column),
                  )
                  .first,
            );
            expect(
              rule.overlaps(near),
              isFalse,
              reason: '규칙 $i: $rule / $near',
            );
            expect(rule.top, greaterThanOrEqualTo(0), reason: '규칙 $i');
            expect(
              rule.bottom,
              lessThanOrEqualTo(size.height),
              reason: '규칙 $i',
            );
            await tester.pump(ChaseScene.ruleInterval);
            await tester.pump(const Duration(milliseconds: 400));
          }
          await unmount(tester);
        },
      );
    }
  }

  testWidgets(
    'police_wait_does_not_vibrate_when_screen_is_off_in_last_ten_seconds',
    (tester) async {
      final vibration = await installVibration();
      await pumpScene(
        tester,
        mode: ChaseSceneMode.policeWait,
        isPolice: true,
        elapsed: const Duration(minutes: 4, seconds: 50), // 10초 남음
      );
      // 화면을 끈 채 주머니에 넣었다 — Android는 멈춘 앱의 타이머도 돈다
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      addTearDown(() {
        for (final state in [
          AppLifecycleState.hidden,
          AppLifecycleState.inactive,
          AppLifecycleState.resumed,
        ]) {
          tester.binding.handleAppLifecycleStateChanged(state);
        }
      });
      await advance(tester, const Duration(seconds: 3));
      expect(vibration.vibrateCalls, 0);
      await unmount(tester);
    },
  );

  // ⓘ 다시 보기 영어 규칙은 두 줄이 4줄까지 길어진다 — 짧은 폰에서도 제목·앞 캐릭터와 겹치지 않아야 한다
  for (final size in const [Size(375, 667), Size(360, 640), Size(360, 740)]) {
    for (final isPolice in [true, false]) {
      testWidgets(
        'rulesReplay_english_rules_stay_clear_of_title_and_character_when_'
        '${isPolice ? 'police' : 'robber'}_phone_is_'
        '${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
          await pumpScene(
            tester,
            mode: ChaseSceneMode.rulesReplay,
            isPolice: isPolice,
            elapsed: const Duration(minutes: 12),
            size: size,
            locale: const Locale('en'),
          );
          final l10n = lookupAppLocalizations(const Locale('en'));
          final title = tester.getRect(
            find.text(
              isPolice ? l10n.startWaitPoliceTitle : l10n.startWaitRobberTitle,
            ),
          );
          final near = tester.getRect(find.byType(RunCycle).last);
          for (var i = 1; i <= 6; i++) {
            final rule = tester.getRect(
              find
                  .ancestor(
                    of: find.textContaining('$i/6'),
                    matching: find.byType(Column),
                  )
                  .first,
            );
            expect(
              rule.overlaps(title),
              isFalse,
              reason: '규칙 $i: $rule / 제목 $title',
            );
            expect(
              rule.overlaps(near),
              isFalse,
              reason: '규칙 $i: $rule / 캐릭터 $near',
            );
            expect(
              rule.bottom,
              lessThanOrEqualTo(size.height),
              reason: '규칙 $i',
            );
            await tester.pump(ChaseScene.ruleInterval);
            await tester.pump(const Duration(milliseconds: 700));
          }
          await unmount(tester);
        },
      );
    }
  }
}
