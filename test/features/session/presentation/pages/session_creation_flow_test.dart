import 'package:cops_and_robbers/core/widgets/buttons/previous_button.dart';
import 'package:cops_and_robbers/core/widgets/indicators/step_indicator.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/session_creation_flow_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/setup_playground_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/setup_prison_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'creation_flow_fakes.dart';

/// 생성 흐름을 열고 플레이그라운드·감옥 지도의 완료를 차례로 누른다.
Future<void> _finishBothMaps(WidgetTester tester) async {
  await pumpCreationFlow(tester);
  await tester.tap(find.text('start'));
  await tester.pumpAndSettle();
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
    await pumpCreationFlow(tester);
    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();
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
    await pumpCreationFlow(tester);
    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();
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
  // 플레이그라운드, 감옥, 확인이 한 칸씩 차지하고 칸 수는 끝까지 같다
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
    expect(step(), (0, 3)); // 플레이그라운드

    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();
    expect(step(), (1, 3)); // 감옥

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
  testWidgets('back_from_confirm_through_both_maps_leaves_the_flow', (
    tester,
  ) async {
    await _finishBothMaps(tester);

    await _tapBack(tester); // 확인 → 감옥
    await _tapBack(tester); // 감옥 → 플레이그라운드
    expect(find.byType(SetupPlaygroundPage), findsOneWidget);
    await _tapBack(tester); // 플레이그라운드 → 흐름 종료

    expect(find.byType(SessionCreationFlowPage), findsNothing);
    expect(find.text('start'), findsOneWidget);
  });
}
