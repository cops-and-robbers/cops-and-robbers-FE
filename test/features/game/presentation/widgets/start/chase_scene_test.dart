// test/features/game/presentation/widgets/start/chase_scene_test.dart
import 'package:clock/clock.dart';
import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/services/vibration_service.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/marquee_alert_banner.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/chase_scene.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/chase_scene_rules.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/police_car_drive.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  String? notice,
  bool disableAnimations = false,
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
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: Scaffold(
              body: ChaseScene(
                mode: mode,
                isPolice: isPolice,
                gameStartTime: clock.now().subtract(elapsed),
                policeWaitMinutes: 5,
                revealMinutes: revealMinutes,
                roundTimeMinutes: roundTimeMinutes,
                onClose: onClose,
                notice: notice,
              ),
            ),
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

/// 바닥을 지나는 경찰차의 왼쪽 끝 x
double carLeft(WidgetTester tester) => tester
    .getTopLeft(
      find.descendant(
        of: find.byType(PoliceCarDrive),
        matching: find.byType(Positioned),
      ),
    )
    .dx;

/// "게임 안내 n/m" 라벨이 든 규칙 카드
Finder ruleCard(String counter) => find
    .ancestor(
      of: find.textContaining(counter),
      matching: find.byType(Container),
    )
    .first;

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
      expect(find.text('도둑이 도망치는 중이에요!'), findsOneWidget);
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
    expect(scale(), closeTo(1.2, 1e-9));
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
      expect(find.text('게임 안내 1/4'), findsOneWidget);
      // 한 줄을 5초씩 보여 준다 — 3초는 읽기도 전에 넘어가 산만했다
      await tester.pump(const Duration(seconds: 4, milliseconds: 800));
      expect(find.text('게임 안내 1/4'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5, milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('게임 안내 3/4'), findsOneWidget);
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
    await tester.tapAt(const Offset(196, 700)); // 카드 아래 빈 배경
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
    expect(find.text('경찰에게서 멀어지세요!'), findsOneWidget);
    await tester.tapAt(const Offset(196, 700)); // 카드 아래 빈 배경
    expect(closed, 1);
    await unmount(tester);
  });

  // 규칙 4줄 × 5초
  // 도둑 설명 화면은 저절로 닫히지 않는다 — 도둑이 누르거나 경찰이 출동할 때까지 남는다
  testWidgets('robber_explainer_stays_open_when_twenty_seconds_pass', (
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
    await advance(tester, const Duration(seconds: 40));
    expect(closed, 0);
    expect(find.text('도둑 팀 미션'), findsOneWidget);
    await unmount(tester);
  });

  // 규칙마다 줄 수가 달라도 "게임 안내 n/m" 라벨은 한자리에 있어야 읽기 편하다
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
      for (var i = 1; i <= 6; i++) {
        tops.add(tester.getTopLeft(find.text('게임 안내 $i/6')).dy);
        await tester.pump(ChaseScene.ruleInterval);
        await tester.pump(const Duration(milliseconds: 700)); // 바뀌는 애니메이션 끝
      }
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
      expect(find.text('경찰에게서 멀어지세요!'), findsOneWidget);
      expect(find.text('게임 안내 1/6'), findsOneWidget);
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
      expect(find.text('도둑이 도망치는 중이에요!'), findsOneWidget);
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

  // 새 시안(#674)은 미션을 카드로 다시 보여 준다 — 팀마다 자기 미션만 나온다
  for (final (isPolice, mode, label, mission) in [
    (true, ChaseSceneMode.policeWait, '경찰 팀 미션', '도둑을 찾아 QR로 모두 체포하세요'),
    (
      false,
      ChaseSceneMode.robberExplainer,
      '도둑 팀 미션',
      '게임이 끝날 때까지 잡히지 말고 도망치세요',
    ),
  ]) {
    testWidgets('${mode.name}_shows_own_team_mission_card_when_opened', (
      tester,
    ) async {
      await pumpScene(
        tester,
        mode: mode,
        isPolice: isPolice,
        elapsed: const Duration(minutes: 2),
      );
      expect(find.text(label), findsOneWidget);
      expect(find.text(mission), findsOneWidget);
      await unmount(tester);
    });
  }

  // 장면에는 위쪽 공지 줄이 없다 — 공지도 "게임 안내"의 한 장으로 규칙 앞에 넣어 함께 돈다
  testWidgets('notice_comes_first_in_game_guide_when_scene_opens_with_one', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 2),
      notice: '도둑 한 명이 체포됐어요',
    );
    expect(find.text('게임 안내'), findsOneWidget); // 공지는 숫자 없이 — 몇 개 올지 모른다
    expect(find.text('도둑 한 명이 체포됐어요'), findsOneWidget);
    expect(find.byType(MarqueeAlertBanner), findsNothing);
    await advance(tester, ChaseScene.ruleInterval);
    await tester.pump(const Duration(milliseconds: 700)); // 바뀌는 애니메이션
    expect(find.text('게임 안내 1/4'), findsOneWidget);
    expect(find.text('도둑의 QR을 스캔하면 체포돼요'), findsOneWidget);
    await unmount(tester);
  });

  // 보는 중에 새 공지가 오면 안내에 더해지고 바로 그 공지로 넘어간다
  testWidgets('new_notice_joins_game_guide_and_shows_at_once_when_it_arrives', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 1),
    );
    await advance(tester, const Duration(seconds: 6)); // 2/4를 1초 본 참
    expect(find.text('게임 안내 2/4'), findsOneWidget);
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 1, seconds: 6),
      notice: '잠시 후 게임이 시작돼요',
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('게임 안내'), findsOneWidget);
    expect(find.text('잠시 후 게임이 시작돼요'), findsOneWidget);
    await advance(tester, ChaseScene.ruleInterval);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('게임 안내 1/4'), findsOneWidget); // 규칙은 공지 수와 상관없이 /4
    await unmount(tester);
  });

  // 피그마 9164:20378: 도둑 카드는 black900
  testWidgets('robber_cards_use_black900_when_explainer_opens', (tester) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.robberExplainer,
      isPolice: false,
      elapsed: const Duration(seconds: 4),
    );
    final card = tester.widget<Container>(
      find
          .ancestor(of: find.text('도둑 팀 미션'), matching: find.byType(Container))
          .first,
    );
    expect((card.decoration! as BoxDecoration).color, AppColors.black900);
    await unmount(tester);
  });

  // 도둑은 화면을 누르면 지도로 간다는 걸 알아야 한다. 경찰 대기는 닫을 수 없어 안내가 없다
  testWidgets('robber_explainer_tells_tap_goes_to_map_when_opened', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.robberExplainer,
      isPolice: false,
      elapsed: const Duration(seconds: 4),
    );
    expect(find.text('화면을 누르면 지도로 가요'), findsOneWidget);
    await unmount(tester);
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(seconds: 4),
    );
    expect(find.text('화면을 누르면 지도로 가요'), findsNothing);
    await unmount(tester);
  });

  // ⓘ 규칙 다시 보기도 누르면 닫혀 지도로 간다 — 경찰·도둑 모두 알려 준다
  testWidgets('rules_replay_tells_tap_goes_to_map_when_opened', (tester) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.rulesReplay,
      isPolice: true,
      elapsed: const Duration(minutes: 12),
    );
    expect(find.text('화면을 누르면 지도로 가요'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('police_car_drives_left_to_right_when_scene_is_open', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 1),
    );
    final start = carLeft(tester);
    expect(start, lessThan(0)); // 왼쪽 화면 밖에서 들어온다
    await tester.pump(const Duration(seconds: 3));
    final later = carLeft(tester);
    expect(later, greaterThan(start));
    await tester.pump(const Duration(seconds: 3, milliseconds: 900));
    expect(carLeft(tester), greaterThan(later)); // 오른쪽 끝에 닿기 직전
    await unmount(tester);
  });

  testWidgets('police_car_stays_parked_when_reduce_motion_is_on', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 1),
      disableAnimations: true,
    );
    final parked = carLeft(tester);
    await tester.pump(const Duration(seconds: 3));
    expect(carLeft(tester), parked);
    expect(parked, closeTo(PoliceCarDrive.restLeft, 1e-6));
    await unmount(tester);
  });

  // 도둑 설명 화면도 ⓘ와 같은 "게임 안내 n/m" 라벨을 쓴다
  testWidgets('robber_explainer_numbers_rules_as_game_rules_when_shown', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.robberExplainer,
      isPolice: false,
      elapsed: const Duration(seconds: 3),
    );
    expect(find.text('게임 안내 1/4'), findsOneWidget);
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
    expect(find.text('게임 안내 6/6'), findsOneWidget);
    expect(find.text('잡힌 도둑은 감옥에 들어갔다가 밖으로 나가 3초가 지나면 탈옥해요'), findsOneWidget);
    await tester.tapAt(const Offset(196, 700)); // 카드 아래 빈 배경
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
      'assets/backgrounds/start_wait/start_wait_day.png',
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
      'assets/backgrounds/start_wait/start_wait_night.png',
    );
    await unmount(tester);
  });

  // 16:9 폰은 시안(393×852)보다 짧다 — 공지가 있어도 돌아가는 규칙 카드가 화면 안에 다 들어와야 한다
  for (final size in const [Size(375, 667), Size(360, 640)]) {
    for (final (mode, isPolice) in [
      (ChaseSceneMode.policeWait, true),
      (ChaseSceneMode.robberExplainer, false),
    ]) {
      testWidgets('${mode.name}_rule_card_stays_on_screen_when_phone_is_'
          '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        await pumpScene(
          tester,
          mode: mode,
          isPolice: isPolice,
          elapsed: const Duration(minutes: 1),
          size: size,
        );
        for (var i = 1; i <= 4; i++) {
          final rule = tester.getRect(ruleCard('$i/4'));
          expect(rule.bottom, lessThanOrEqualTo(size.height), reason: '규칙 $i');
          await tester.pump(ChaseScene.ruleInterval);
          await tester.pump(const Duration(milliseconds: 700));
        }
        await unmount(tester);
      });
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

  // ⓘ 다시 보기 영어 규칙은 여러 줄로 길어진다 — 짧은 폰에서도 제목과 겹치지 않고 화면 안에 있어야 한다
  for (final size in const [Size(375, 667), Size(360, 640), Size(360, 740)]) {
    for (final isPolice in [true, false]) {
      testWidgets('rulesReplay_english_rules_stay_clear_of_title_when_'
          '${isPolice ? 'police' : 'robber'}_phone_is_'
          '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
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
          expect(rule.bottom, lessThanOrEqualTo(size.height), reason: '규칙 $i');
          await tester.pump(ChaseScene.ruleInterval);
          await tester.pump(const Duration(milliseconds: 700));
        }
        await unmount(tester);
      });
    }
  }

  // 탈옥 규칙은 두 줄로 길다 — 카드는 한 줄(…)로 미션 카드와 같은 높이였다가, 누르면 펼쳐진다
  testWidgets(
    'robber_explainer_long_rule_shows_one_line_until_robber_taps_card',
    (tester) async {
      var closed = 0;
      await pumpScene(
        tester,
        mode: ChaseSceneMode.robberExplainer,
        isPolice: false,
        elapsed: const Duration(minutes: 1),
        onClose: () => closed++,
      );
      await advance(tester, ChaseScene.ruleInterval * 3); // 4/4 탈옥 규칙
      await tester.pump(const Duration(milliseconds: 700));
      const jailbreak = '잡히면 감옥에 들어갔다가 밖으로 나가 3초가 지나면 탈옥돼요';
      final mission = tester.getRect(
        find
            .ancestor(
              of: find.text('도둑 팀 미션'),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(tester.getRect(ruleCard('4/4')).height, mission.height);

      await tester.tap(find.text(jailbreak));
      await tester.pump();
      await tester.pump(ChaseScene.expandDuration);

      expect(
        tester.getRect(ruleCard('4/4')).height,
        greaterThan(mission.height),
      );
      expect(closed, 0); // 카드를 누른 건 장면을 닫는 탭이 아니다
      await unmount(tester);
    },
  );

  // 펼친 규칙을 읽는 동안 다음 규칙으로 넘어가지 않고, 다시 누르면 접히고 이어서 돈다
  testWidgets('rules_replay_waits_on_expanded_rule_until_player_folds_it', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.rulesReplay,
      isPolice: true,
      elapsed: const Duration(minutes: 12), // 1/6 승리 조건 — 두 줄로 길다
    );
    final win = find.textContaining('경찰은 모든 도둑을 체포하면');
    await tester.tap(win);
    await advance(tester, ChaseScene.ruleInterval * 2);
    expect(find.text('게임 안내 1/6'), findsOneWidget);

    await tester.tap(win);
    await advance(tester, ChaseScene.ruleInterval);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('게임 안내 2/6'), findsOneWidget);
    await unmount(tester);
  });

  // 펼친 규칙을 읽는 중에 공지가 와도 펼친 칸은 그대로, 접으면 그 공지가 보인다
  testWidgets('expanded_rule_stays_until_folded_when_new_notice_arrives', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.rulesReplay,
      isPolice: true,
      elapsed: const Duration(minutes: 12),
    );
    final win = find.textContaining('경찰은 모든 도둑을 체포하면');
    await tester.tap(win);
    await tester.pump(ChaseScene.expandDuration);
    await pumpScene(
      tester,
      mode: ChaseSceneMode.rulesReplay,
      isPolice: true,
      elapsed: const Duration(minutes: 12),
      notice: '도둑 한 명이 체포됐어요',
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('게임 안내 1/6'), findsOneWidget);
    expect(win, findsOneWidget);

    await tester.tap(win); // 접음
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('도둑 한 명이 체포됐어요'), findsOneWidget);
    await unmount(tester);
  });

  // 피그마 9164:20378: 팀 줄 top 118, 팀 → 라벨 48, 라벨 → 숫자 14, 숫자(80) → 안내 14,
  // 안내 → 첫 카드 50(y382), 카드끼리 18. 위쪽 공지 줄은 없다
  testWidgets('police_wait_keeps_design_vertical_gaps_without_notice_row', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 1),
    );
    final team = tester.getRect(find.text('경찰팀'));
    final label = tester.getRect(find.text('경찰 출동까지'));
    final digits = tester.getRect(find.text('04:00'));
    final title = tester.getRect(find.text('도둑이 도망치는 중이에요!'));
    Rect card(String label) => tester.getRect(
      find
          .ancestor(of: find.text(label), matching: find.byType(Container))
          .first,
    );
    final mission = card('경찰 팀 미션');
    final guide = card('게임 안내 1/4');
    // 팀 줄은 24(아이콘) 높이에 20 글자가 가운데라 아래로 2 더 있다
    expect(label.top - (team.bottom + 2), moreOrLessEquals(48));
    expect(digits.top - label.bottom, moreOrLessEquals(14));
    expect(title.top - digits.bottom, moreOrLessEquals(14));
    expect(mission.top - title.bottom, moreOrLessEquals(50));
    expect(mission.top, moreOrLessEquals(382));
    expect(guide.top - mission.bottom, moreOrLessEquals(18));
    await unmount(tester);
  });

  // 공지는 안내 카드 안에서 바뀔 뿐이라 미션 카드가 들썩이지 않는다
  testWidgets('mission_card_stays_in_place_when_notice_comes_and_goes', (
    tester,
  ) async {
    double missionTop() => tester
        .getTopLeft(
          find
              .ancestor(
                of: find.text('경찰 팀 미션'),
                matching: find.byType(Container),
              )
              .first,
        )
        .dy;
    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 1),
      notice: '도둑 한 명이 체포됐어요',
    );
    final withNotice = missionTop();
    await unmount(tester);

    await pumpScene(
      tester,
      mode: ChaseSceneMode.policeWait,
      isPolice: true,
      elapsed: const Duration(minutes: 1),
    );
    expect(missionTop(), withNotice);
    await unmount(tester);
  });

  // 규칙이 바뀐 직후 다음 틱 전에 눌러도, 화면에 보이던 규칙이 펼쳐진다
  testWidgets(
    'rules_replay_expands_shown_rule_when_tapped_right_after_rotation',
    (tester) async {
      await pumpScene(
        tester,
        mode: ChaseSceneMode.rulesReplay,
        isPolice: true,
        elapsed: const Duration(minutes: 12),
      );
      final win = find.textContaining('경찰은 모든 도둑을 체포하면');
      // 틱(250ms)과 어긋난 시각에 펼쳤다 접어 회전 시계가 틱과 엇갈리게 만든다
      await advance(tester, const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 100)); // 1.10초
      await tester.tap(win);
      await advance(tester, const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 30)); // 2.13초
      await tester.tap(win);
      // 6.00초 틱에 1/6이 보이고, 다음 틱 전인 6.10초에 누른다
      await advance(tester, const Duration(milliseconds: 3750));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('게임 안내 1/6'), findsOneWidget);
      await tester.tap(win);
      await advance(tester, const Duration(seconds: 2));
      expect(find.text('게임 안내 1/6'), findsOneWidget);
      await unmount(tester);
    },
  );

  // 키 큰 폰에서도 공지가 와도 미션 카드 자리가 그대로다
  testWidgets(
    'mission_card_stays_in_place_on_tall_phone_when_real_notice_comes',
    (tester) async {
      const size = Size(393, 960);
      double missionTop() => tester
          .getTopLeft(
            find
                .ancestor(
                  of: find.text('경찰 팀 미션'),
                  matching: find.byType(Container),
                )
                .first,
          )
          .dy;
      await pumpScene(
        tester,
        mode: ChaseSceneMode.policeWait,
        isPolice: true,
        elapsed: const Duration(minutes: 1),
        size: size,
        notice: '도둑 한 명이 체포됐어요',
      );
      await tester.pump(const Duration(milliseconds: 400));
      final withNotice = missionTop();
      await unmount(tester);
      await tester.pump(const Duration(seconds: 10));

      await pumpScene(
        tester,
        mode: ChaseSceneMode.policeWait,
        isPolice: true,
        elapsed: const Duration(minutes: 1),
        size: size,
      );
      expect(missionTop(), moreOrLessEquals(withNotice));
      await unmount(tester);
    },
  );

  // 규칙이 막 바뀐 직후 펼쳤다가 다음 틱 전에 접어도 이전 규칙으로 되돌아가지 않는다
  testWidgets('rules_replay_keeps_current_rule_when_folded_between_ticks', (
    tester,
  ) async {
    await pumpScene(
      tester,
      mode: ChaseSceneMode.rulesReplay,
      isPolice: true,
      elapsed: const Duration(minutes: 12),
      disableAnimations: true, // 규칙이 바뀔 때 이전 카드가 남지 않게
    );
    await advance(tester, ChaseScene.ruleInterval); // 5.00초 틱에 2/6
    expect(find.text('게임 안내 2/6'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 50)); // 5.05초
    final body = find
        .descendant(
          of: ruleCard('2/6'),
          matching: find.byWidgetPredicate((w) => w is Text && w.maxLines == 1),
        )
        .first;
    await tester.tap(body); // 펼침 — 화면 기준(5.00초) 2/6에 멈춘다
    await tester.pump(
      const Duration(milliseconds: 100),
    ); // 5.15초, 다음 틱(5.25초) 전
    await tester.tap(find.text('게임 안내 2/6')); // 접음
    await tester.pump();
    expect(find.text('게임 안내 2/6'), findsOneWidget);
    expect(find.text('게임 안내 1/6'), findsNothing);
    await unmount(tester);
  });
}
