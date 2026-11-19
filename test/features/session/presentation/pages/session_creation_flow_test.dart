import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/core/network/dio_client.dart';
import 'package:cops_and_robbers/core/widgets/buttons/previous_button.dart';
import 'package:cops_and_robbers/core/widgets/map/zone_draw_layer.dart';
import 'package:cops_and_robbers/core/widgets/indicators/step_indicator.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/session_creation_flow_page.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/setup_playground_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/setup_prison_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'creation_flow_fakes.dart';

/// 생성 흐름을 열어 모드 화면에서 [mode]를 고르고 다음을 누른다.
Future<void> _openFlowAndPickMode(
  WidgetTester tester, {
  String mode = '경찰과 도둑',
  FakeCreateGameServer? server,
}) async {
  await pumpCreationFlow(
    tester,
    overrides: [if (server != null) dioProvider.overrideWithValue(server.dio)],
  );
  await tester.tap(find.text('start'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(mode));
  await tester.tap(find.text('다음'));
  await tester.pumpAndSettle();
}

/// 폴리곤으로 플레이그라운드를 올가미로 그리고 완료한다.
Future<void> _drawPolygonPlayground(WidgetTester tester) async {
  await tester.tap(find.text('핀으로 설정'));
  await tester.pumpAndSettle();
  // 손가락으로 삼각형을 그린 것과 같은 화면 좌표 궤적
  await tester.runAsync(
    () async => tester
        .widget<ZoneDrawLayer>(find.byType(ZoneDrawLayer))
        .onDrawEnd(const [
          Offset(100, 300),
          Offset(200, 200),
          Offset(300, 100),
          Offset(300, 200),
          Offset(300, 300),
          Offset(200, 300),
          Offset(100, 300),
        ]),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('완료'));
  await tester.pumpAndSettle();
}

/// 생성 흐름을 열고 플레이그라운드·감옥 지도의 완료를 차례로 누른다.
Future<void> _finishBothMaps(WidgetTester tester) async {
  await _openFlowAndPickMode(tester);
  await tester.tap(find.text('완료')); // 플레이그라운드
  await tester.pumpAndSettle();
  await tester.tap(find.text('완료')); // 감옥
  await tester.pumpAndSettle();
}

/// 지금 보이는 화면 상단 바의 뒤로 버튼
Future<void> _tapBack(WidgetTester tester) async {
  await tester.tap(find.byType(PreviousButton).hitTestable());
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  setUp(() {
    // 생성 진입(startGameCreation)이 초안을 지우므로 늘 빈 상태에서 시작한다
    SharedPreferences.setMockInitialValues({});
    final oldLocation = GeolocatorPlatform.instance;
    final oldMap = GoogleMapsFlutterPlatform.instance;
    GeolocatorPlatform.instance = FakeLocation();
    GoogleMapsFlutterPlatform.instance = FakeMap();
    addTearDown(() {
      GeolocatorPlatform.instance = oldLocation;
      GoogleMapsFlutterPlatform.instance = oldMap;
    });
  });

  // 방장이 지도 두 장만 마치면 추천값이 채워진 확인 화면에 도착한다
  testWidgets(
    'creation_flow_lands_on_confirm_with_recommended_values_when_both_maps_are_done',
    (tester) async {
      await _finishBothMaps(tester);

      expect(find.text('최종 설정을 확인해요'), findsOneWidget);
      expect(find.text('기본 정보를 설정해요'), findsNothing);
      expect(find.text('10명'), findsOneWidget);
      expect(find.text('30분'), findsOneWidget);
      expect(find.text('도둑 시작 후 5분 뒤'), findsOneWidget);
    },
  );

  // 플레이그라운드에서 감옥으로 넘어가는 동안 뒤로 버튼과 단계 표시는 제자리에
  // 하나만 있고 본문만 바뀐다 (#658 전환 B안)
  testWidgets('top_bar_stays_single_while_moving_from_playground_to_prison', (
    tester,
  ) async {
    await _openFlowAndPickMode(tester);
    final barTop = tester.getTopLeft(find.byType(StepIndicator));

    await tester.tap(find.text('완료'));
    await tester.pump(const Duration(milliseconds: 120)); // 전환 도중

    expect(find.byType(StepIndicator), findsOneWidget);
    expect(find.byType(PreviousButton), findsOneWidget);
    expect(tester.getTopLeft(find.byType(StepIndicator)), barTop);
    await tester.pumpAndSettle();
  });

  // 처음 만들 때 감옥에서 완료를 누르면 감옥은 왼쪽으로 밀려나고 확인이 오른쪽에서
  // 들어와야 한다. 감옥이 오른쪽으로 빠지면 뒤로 가는 것처럼 보인다
  testWidgets('prison_slides_left_when_done_on_first_pass_to_confirm', (
    tester,
  ) async {
    await _openFlowAndPickMode(tester);
    await tester.tap(find.text('완료')); // 플레이그라운드
    await tester.pumpAndSettle();

    await tester.tap(find.text('완료')); // 감옥
    await tester.pump(); // 전환 시작
    await tester.pump(const Duration(milliseconds: 150)); // 전환 도중

    expect(tester.getTopLeft(find.byType(SetupPrisonPage)).dx, lessThan(0));
    expect(
      tester.getTopLeft(find.text('최종 설정을 확인해요')).dx,
      greaterThan(tester.getTopLeft(find.byType(SetupPrisonPage)).dx),
    );
    await tester.pumpAndSettle();
  });

  // 방장은 단계 표시로 지금이 몇 번째 화면인지 본다.
  // 모드, 구역(플레이그라운드·감옥), 확인 세 칸이고 칸 수는 끝까지 같다
  testWidgets('step_indicator_advances_one_step_per_screen_out_of_three', (
    tester,
  ) async {
    (int, int) step() {
      final indicator = tester.widget<StepIndicator>(
        find.byType(StepIndicator).hitTestable(),
      );
      return (indicator.currentStep, indicator.totalSteps);
    }

    await pumpCreationFlow(tester);
    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();
    expect(step(), (0, 3)); // 모드

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(step(), (1, 3)); // 플레이그라운드

    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();
    expect(step(), (1, 3)); // 감옥도 같은 구역 단계

    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();
    expect(step(), (2, 3)); // 확인
  });

  // 확인 화면에서 감옥 위치가 마음에 안 들어 뒤로 갔다가 다시 완료한다
  testWidgets(
    'back_on_confirm_reopens_prison_map_and_done_returns_to_confirm',
    (tester) async {
      await _finishBothMaps(tester);

      await _tapBack(tester);
      expect(find.byType(SetupPrisonPage), findsOneWidget);

      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();
      expect(find.text('최종 설정을 확인해요'), findsOneWidget);
    },
  );

  // 게임 시간을 고치러 들어갔다가 숫자만 바꾸고 확인 없이 뒤로 나온다
  testWidgets('row_edit_keeps_old_value_when_left_with_back', (tester) async {
    await _finishBothMaps(tester);

    await tester.tap(find.text('게임 시간'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4'));
    await tester.tap(find.text('5'));
    await tester.pump();
    expect(find.text('45분'), findsOneWidget);

    await _tapBack(tester);
    expect(find.text('최종 설정을 확인해요'), findsOneWidget);
    expect(find.text('30분'), findsOneWidget);
  });

  // 확인 화면까지 왔다가 방을 만들지 않기로 하고 뒤로만 계속 눌러 나간다
  testWidgets('back_from_confirm_through_maps_and_mode_leaves_the_flow', (
    tester,
  ) async {
    await _finishBothMaps(tester);

    await _tapBack(tester); // 확인 → 감옥
    await _tapBack(tester); // 감옥 → 플레이그라운드
    expect(find.byType(SetupPlaygroundPage), findsOneWidget);
    await _tapBack(tester); // 플레이그라운드 → 모드
    expect(find.text('어떤 모드로 할까요?'), findsOneWidget);
    await _tapBack(tester); // 모드 → 흐름 종료

    expect(find.byType(SessionCreationFlowPage), findsNothing);
    expect(find.text('start'), findsOneWidget);
  });

  // 구역 축소 카드는 확인 화면 맨 위, 처음엔 꺼져 있다 (#668 시안)
  testWidgets('confirm_shows_shrink_card_above_zone_card_turned_off', (
    tester,
  ) async {
    await _finishBothMaps(tester);

    final shrink = find.text('구역 축소');
    expect(shrink, findsOneWidget);
    expect(find.text('구역이 점점 줄어들어요'), findsOneWidget);
    expect(
      tester.getTopLeft(shrink).dy,
      lessThan(tester.getTopLeft(find.text('플레이그라운드')).dy),
    );
  });

  testWidgets('turning_shrink_on_shows_how_far_it_shrinks', (tester) async {
    await _finishBothMaps(tester);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.textContaining('→'), findsOneWidget);
    expect(find.text('구역이 점점 줄어들어요'), findsNothing);
  });

  // 핀으로 그린 뒤에야 잠긴 걸 알면 다시 그려야 하니 고르는 순간 알려 준다 (#668)
  testWidgets('choosing_pins_warns_that_shrinking_is_unavailable', (
    tester,
  ) async {
    await _openFlowAndPickMode(tester);
    expect(find.text('핀으로 그리면 구역 축소를 쓸 수 없어요'), findsNothing);

    await tester.tap(find.text('핀으로 설정'));
    await tester.pumpAndSettle();

    expect(find.text('핀으로 그리면 구역 축소를 쓸 수 없어요'), findsOneWidget);
  });

  // 술래잡기는 감옥이 없으니 플레이그라운드를 마치면 감옥 지도를 건너뛴다
  testWidgets('hide_and_seek_room_skips_jail_map_when_playground_is_done', (
    tester,
  ) async {
    await _openFlowAndPickMode(tester, mode: '술래잡기');

    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    expect(find.byType(SetupPrisonPage), findsNothing);
    expect(find.text('최종 설정을 확인해요'), findsOneWidget);
    expect(find.text('감옥'), findsNothing);
    expect(find.text('모드'), findsOneWidget);
    expect(find.text('술래잡기'), findsOneWidget);
  });

  // 방장이 술래잡기로 방을 만들면 서버에는 TAG와 함께 감옥 키 없는 구역이 간다
  testWidgets('hide_and_seek_room_sends_null_jail_when_host_taps_create', (
    tester,
  ) async {
    final server = FakeCreateGameServer();
    await _openFlowAndPickMode(tester, mode: '술래잡기', server: server);
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('방 생성하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('만들기')); // 확인 모달
    await tester.pumpAndSettle();

    final body = server.requestBodies.single;
    expect(body['gameMode'], 'TAG');
    final circle = (body['area'] as Map)['circle'] as Map;
    expect(circle.containsKey('jailCenter'), isFalse);
    expect(circle.containsKey('jailRadiusInMeters'), isFalse);
  });

  // 방장이 방 생성하기를 누르면 방이 바로 만들어지지 않고 확인 모달이 먼저 뜬다
  testWidgets('create_button_asks_confirm_before_sending_request', (
    tester,
  ) async {
    final server = FakeCreateGameServer();
    await _openFlowAndPickMode(tester, mode: '술래잡기', server: server);
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('방 생성하기'));
    await tester.pumpAndSettle();

    expect(find.text('이대로 방을 만들까요?'), findsOneWidget);
    expect(server.requestBodies, isEmpty);
  });

  // 모달에서 닫기를 누르면 방을 만들지 않고 확인 화면에 남아 설정을 고칠 수 있다
  testWidgets('close_in_confirm_modal_stays_on_review_without_creating', (
    tester,
  ) async {
    final server = FakeCreateGameServer();
    await _openFlowAndPickMode(tester, mode: '술래잡기', server: server);
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('방 생성하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();

    expect(find.text('이대로 방을 만들까요?'), findsNothing);
    expect(find.text('최종 설정을 확인해요'), findsOneWidget);
    expect(server.requestBodies, isEmpty);
  });

  // 확인 화면에서 모드 행을 눌러 술래잡기 → 경찰과 도둑으로 바꾸면 그려 둔 감옥이
  // 없으니 감옥 지도로 간다
  testWidgets(
    'switching_to_cops_and_robbers_on_confirm_opens_jail_map_when_no_jail_was_drawn',
    (tester) async {
      await _openFlowAndPickMode(tester, mode: '술래잡기');
      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('술래잡기')); // 모드 행
      await tester.pumpAndSettle();
      await tester.tap(find.text('경찰과 도둑'));
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.byType(SetupPrisonPage), findsOneWidget);
      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();
      expect(find.text('최종 설정을 확인해요'), findsOneWidget);
      expect(find.text('경찰과 도둑'), findsOneWidget);
    },
  );

  // 감옥을 그려 둔 경찰과 도둑 방에서 모드 행만 열었다 닫으면 그대로 확인으로 돌아온다
  testWidgets(
    'mode_row_keeps_jail_and_returns_to_confirm_when_mode_unchanged',
    (tester) async {
      await _finishBothMaps(tester);

      await tester.tap(find.text('경찰과 도둑')); // 모드 행
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('최종 설정을 확인해요'), findsOneWidget);
      expect(find.text('감옥'), findsOneWidget);
    },
  );

  // 폴리곤으로 그린 술래잡기 방은 감옥 없이 만들어지고, 축소는 원형이 아니라 잠긴다
  testWidgets(
    'hide_and_seek_polygon_room_creates_without_jail_and_locks_shrink',
    (tester) async {
      final server = FakeCreateGameServer();
      final container = await pumpCreationFlow(
        tester,
        overrides: [dioProvider.overrideWithValue(server.dio)],
      );
      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('술래잡기'));
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await _drawPolygonPlayground(tester);

      expect(find.text('최종 설정을 확인해요'), findsOneWidget);
      expect(find.text('원형 구역에서만 쓸 수 있어요'), findsOneWidget);

      await tester.tap(find.text('방 생성하기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('만들기')); // 확인 모달
      await tester.pumpAndSettle();

      final body = server.requestBodies.single;
      expect(body['gameMode'], 'TAG');
      final polygon = (body['area'] as Map)['polygon'] as Map;
      expect(polygon.keys, isNot(contains('jailPolygon')));
      expect(
        container.read(gameParticipantNotifierProvider)?.gameMode,
        GameMode.hideAndSeek,
      );
    },
  );

  // 모드 카드는 두 모드의 규칙 요약을 한 줄씩 보여 준다
  testWidgets('mode_screen_shows_both_modes_with_one_line_rules', (
    tester,
  ) async {
    await pumpCreationFlow(tester);
    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();

    expect(find.text('어떤 모드로 할까요?'), findsOneWidget);
    expect(find.text('잡히면 감옥에 갇혀요'), findsOneWidget);
    expect(find.text('감옥 없이 잡히면 바로 끝나요'), findsOneWidget);
  });

  // 술래잡기 → 경찰과 도둑으로 바꿨다가 감옥 지도를 그리지 않고 닫으면 구역이 비어
  // 있다. 그래도 방장은 모드 행으로 술래잡기로 되돌릴 수 있어야 한다
  testWidgets(
    'host_can_switch_back_to_hide_and_seek_when_jail_map_was_abandoned_on_confirm',
    (tester) async {
      await _openFlowAndPickMode(tester, mode: '술래잡기');
      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('술래잡기')); // 모드 행
      await tester.pumpAndSettle();
      await tester.tap(find.text('경찰과 도둑'));
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await _tapBack(tester); // 감옥을 그리지 않고 닫는다

      expect(find.text('구역 정보를 먼저 설정해주세요'), findsOneWidget);
      await tester.tap(find.text('경찰과 도둑')); // 모드 행
      await tester.pumpAndSettle();
      await tester.tap(find.text('술래잡기'));
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('구역 정보를 먼저 설정해주세요'), findsNothing);
      expect(find.text('감옥'), findsNothing);
      expect(find.text('술래잡기'), findsOneWidget);
    },
  );
}
