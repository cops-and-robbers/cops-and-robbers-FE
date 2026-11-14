import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/session/domain/mode_change.dart';
import 'package:cops_and_robbers/features/session/domain/shrink_area_save_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const c = GeoPoint(latitude: 37.55, longitude: 127.07);
  const playground = AreaShape.circle(center: c, radiusInMeters: 1000);
  const jail250 = AreaShape.circle(center: c, radiusInMeters: 250);
  const copsRoom = GameAreaEntity(
    playground: playground,
    jail: AreaShape.circle(center: c, radiusInMeters: 100),
  );
  const tagRoom = GameAreaEntity(playground: playground);

  test(
    'switching_to_hide_and_seek_drops_jail_and_keeps_playground_when_host_changes_mode',
    () {
      expect(areaForMode(copsRoom, GameMode.hideAndSeek), tagRoom);
    },
  );

  test('switching_to_cops_and_robbers_uses_the_jail_the_host_just_drew', () {
    expect(
      areaForMode(tagRoom, GameMode.copsAndRobbers, newJail: jail250),
      const GameAreaEntity(playground: playground, jail: jail250),
    );
  });

  test('switching_to_cops_and_robbers_fails_when_no_jail_was_drawn', () {
    expect(
      () => areaForMode(tagRoom, GameMode.copsAndRobbers),
      throwsArgumentError,
    );
  });

  test(
    'switching_to_cops_and_robbers_saves_settings_first_when_new_jail_exceeds_final_radius',
    () {
      // 술래잡기 방(최종 반경 200m)에 감옥 250m를 그리면 200 < 250이라 구역 먼저는 거절된다
      final plan = planShrinkAreaSave(
        oldArea: tagRoom,
        newArea: areaForMode(
          tagRoom,
          GameMode.copsAndRobbers,
          newJail: jail250,
        ),
        currentFinalRadius: 200,
      );
      expect(
        [for (final s in plan.order) (s.step, s.finalRadius)],
        [(SaveStep.settings, 350), (SaveStep.area, null)],
      );
    },
  );

  test('mode_change_rolls_back_settings_when_put_mode_fails', () async {
    final plan = planShrinkAreaSave(
      oldArea: tagRoom,
      newArea: areaForMode(tagRoom, GameMode.copsAndRobbers, newJail: jail250),
      currentFinalRadius: 200,
    );
    final settingsSent = <int?>[];

    await expectLater(
      runShrinkAreaSave(
        plan,
        putSettings: (r) async => settingsSent.add(r),
        putArea: () async => throw StateError('JAIL_AREA_REQUIRED'),
        previousFinalRadius: 200,
        putPreviousArea: () async {},
      ),
      throwsStateError,
    );

    expect(settingsSent, [350, 200]);
  });
}
