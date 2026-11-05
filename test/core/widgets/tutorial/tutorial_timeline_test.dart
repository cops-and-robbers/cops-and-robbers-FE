import 'package:cops_and_robbers/core/widgets/tutorial/tutorial_timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('timeline_isPlaying_true_when_chase_scene_still_has_pending_steps', () {
    final timeline = TutorialTimeline();
    final actor = TutorialProps({'x': 0});

    timeline.to(actor, {'x': 100}, 100);
    timeline.after(300, () {});
    for (var i = 0; i < 10; i++) {
      timeline.tick(16);
    }

    expect(actor['x'], 100);
    expect(timeline.isPlaying, isTrue);

    for (var i = 0; i < 20; i++) {
      timeline.tick(16);
    }
    expect(timeline.isPlaying, isFalse);
  });

  test(
    'timeline_advances_at_most_one_short_step_when_app_returns_from_background',
    () {
      final timeline = TutorialTimeline();
      final actor = TutorialProps({'x': 0});

      timeline.to(actor, {'x': 100}, 1000);
      timeline.tick(60000);

      expect(timeline.isPlaying, isTrue);
      expect(actor['x'], lessThan(100));
    },
  );

  test('timeline_keeps_other_keys_moving_when_next_scene_tweens_one_key', () {
    // 시안에서 키 하나가 겹치면 이전 트윈 전체가 지워져 초대코드 창이 남던 버그
    final timeline = TutorialTimeline();
    final overlay = TutorialProps({'card': 1, 'timer': 0});

    timeline.to(overlay, {'card': 0, 'timer': 0}, 100);
    timeline.to(overlay, {'timer': 1}, 100);
    for (var i = 0; i < 10; i++) {
      timeline.tick(16);
    }

    expect(overlay['card'], 0);
    expect(overlay['timer'], 1);
  });

  test('timeline_runs_scheduled_step_when_its_time_arrives', () {
    final timeline = TutorialTimeline();
    var touched = false;

    timeline.after(100, () => touched = true);
    timeline.tick(50);
    expect(touched, isFalse);

    timeline.tick(50);
    expect(touched, isTrue);
  });
}
