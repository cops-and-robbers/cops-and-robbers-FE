import 'package:cops_and_robbers/core/widgets/tutorial/tutorial_camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('camera_keeps_zone_center_at_screen_middle_when_viewed_from_top', () {
    final p = projectPoint(TutorialCamera.flat(), 0, 0);

    expect(p.x, closeTo(196.5, 0.01));
    expect(p.y, closeTo(243, 0.01));
  });

  test('camera_places_taller_roof_above_its_base_when_tilted', () {
    final camera = TutorialCamera.wide3d();
    final base = projectPoint(camera, 100, 50);
    final roof = projectPoint(camera, 100, 50, 30);

    expect(roof.y, lessThan(base.y));
  });

  test('camera_matches_approved_mockup_position_when_wide_and_chase_views', () {
    // 값은 승인된 시안(interaction.mjs의 project)으로 계산했다
    final wide = projectPoint(TutorialCamera.wide3d(), 100, 50, 20);
    expect(wide.x, closeTo(276.61, 0.01));
    expect(wide.y, closeTo(228.93, 0.01));

    final chase = projectPoint(
      TutorialCamera({
        ...TutorialCamera.wide3dValues,
        'tilt': 80,
        'persp': 200,
        'scale': 2,
        'cx': 12,
        'cy': -27,
        'oy': .62,
      }),
      -24,
      55,
    );
    expect(chase.x, closeTo(197.15, 0.01));
    expect(chase.y, closeTo(279.74, 0.01));
  });
}
