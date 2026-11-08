import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/session/domain/shrink_area_save_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const c = GeoPoint(latitude: 37.55, longitude: 127.07);
  GameAreaEntity zone(double playground, double jail) => GameAreaEntity(
    playground: AreaShape.circle(center: c, radiusInMeters: playground),
    jail: AreaShape.circle(center: c, radiusInMeters: jail),
  );
  const pin = AreaShape.polygon(
    points: [
      GeoPoint(latitude: 37.55, longitude: 127.07),
      GeoPoint(latitude: 37.56, longitude: 127.07),
      GeoPoint(latitude: 37.56, longitude: 127.08),
    ],
  );

  List<(SaveStep, int?)> steps(ShrinkAreaSavePlan p) => [
    for (final s in p.order) (s.step, s.finalRadius),
  ];

  group('저장 순서', () {
    test('shrinking_500m_room_to_180m_turns_shrink_off_before_saving_area', () {
      // 감옥 100m — 180m는 감옥 + 100 이하라 잠긴다
      final p = planShrinkAreaSave(
        oldArea: zone(500, 100),
        newArea: zone(180, 100),
        currentFinalRadius: 200,
      );
      expect(p.turnedOff, isTrue);
      expect(steps(p), [(SaveStep.settings, null), (SaveStep.area, null)]);
    });

    test(
      'widening_500m_room_to_1km_sends_settings_first_when_new_radius_fits_old_area',
      () {
        // 새 최종 200이 옛 구역(감옥 100 < 200 < 500)에서도 통과
        final p = planShrinkAreaSave(
          oldArea: zone(500, 100),
          newArea: zone(1000, 100),
          currentFinalRadius: 200,
        );
        expect(steps(p), [(SaveStep.settings, 200), (SaveStep.area, null)]);
      },
    );

    test('widening_150m_room_to_1km_saves_area_first', () {
      // 옛 최종 110, 새 최종 200 — 200은 옛 구역 150에서 통과 못 함, 옛 110은 새 구역에서 통과
      final p = planShrinkAreaSave(
        oldArea: zone(150, 10),
        newArea: zone(1000, 10),
        currentFinalRadius: 110,
      );
      expect(steps(p), [(SaveStep.area, null), (SaveStep.settings, 200)]);
    });

    test('growing_jail_from_100m_to_150m_sends_whichever_passes_first', () {
      // 새 최종 250이 옛 구역(100 < 250 < 500)에서 통과
      final p = planShrinkAreaSave(
        oldArea: zone(500, 100),
        newArea: zone(500, 150),
        currentFinalRadius: 200,
      );
      expect(steps(p), [(SaveStep.settings, 250), (SaveStep.area, null)]);
    });

    test(
      'moving_150m_room_to_1km_with_120m_jail_turns_off_then_area_then_on',
      () {
        // 새 220은 옛 구역 150에서, 옛 110은 새 감옥 120에서 둘 다 거절된다
        final p = planShrinkAreaSave(
          oldArea: zone(150, 10),
          newArea: zone(1000, 120),
          currentFinalRadius: 110,
        );
        expect(steps(p), [
          (SaveStep.settings, null),
          (SaveStep.area, null),
          (SaveStep.settings, 220),
        ]);
        expect(p.turnedOff, isFalse);
      },
    );

    test('room_without_shrink_saves_area_only', () {
      final p = planShrinkAreaSave(
        oldArea: zone(500, 100),
        newArea: zone(300, 100),
        currentFinalRadius: null,
      );
      expect(steps(p), [(SaveStep.area, null)]);
    });

    test('switching_to_pin_area_turns_shrink_off_first', () {
      final p = planShrinkAreaSave(
        oldArea: zone(500, 100),
        newArea: GameAreaEntity(playground: pin, jail: pin),
        currentFinalRadius: 200,
      );
      expect(p.turnedOff, isTrue);
      expect(steps(p), [(SaveStep.settings, null), (SaveStep.area, null)]);
    });
  });

  group('되돌리기', () {
    Future<List<String>> run(
      ShrinkAreaSavePlan plan, {
      required int failAt,
      required int? previous,
    }) async {
      final calls = <String>[];
      var n = 0;
      Future<void> maybeFail() async {
        if (n++ == failAt) throw Exception('400');
      }

      await expectLater(
        runShrinkAreaSave(
          plan,
          putSettings: (r) async {
            calls.add('settings($r)');
            await maybeFail();
          },
          putArea: () async {
            calls.add('area');
            await maybeFail();
          },
          previousFinalRadius: previous,
          putPreviousArea: () async => calls.add('previousArea'),
        ),
        throwsException,
      );
      return calls;
    }

    test('area_save_failure_turns_the_disabled_shrink_back_on', () async {
      final plan = planShrinkAreaSave(
        oldArea: zone(500, 100),
        newArea: zone(180, 100),
        currentFinalRadius: 200,
      );
      expect(await run(plan, failAt: 1, previous: 200), [
        'settings(null)',
        'area',
        'settings(200)',
      ]);
    });

    test('last_step_failure_rolls_back_in_reverse_order', () async {
      final plan = planShrinkAreaSave(
        oldArea: zone(150, 10),
        newArea: zone(1000, 120),
        currentFinalRadius: 110,
      );
      expect(await run(plan, failAt: 2, previous: 110), [
        'settings(null)',
        'area',
        'settings(220)',
        'previousArea',
        'settings(110)',
      ]);
    });
  });
}
