import 'package:cops_and_robbers/features/game/domain/shrink_animation_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ShrinkAnimation pick({
    int stage = 1,
    bool appVisible = true,
    bool qrOpen = false,
    bool chatOpen = false,
    bool participantsOpen = false,
    bool reduceMotion = false,
  }) => shrinkAnimationFor(
    stage: stage,
    appVisible: appVisible,
    qrOpen: qrOpen,
    chatOpen: chatOpen,
    participantsOpen: participantsOpen,
    reduceMotion: reduceMotion,
  );

  test('first_three_shrinks_tilt_only', () {
    expect(pick(stage: 1), ShrinkAnimation.tilt);
    expect(pick(stage: 3), ShrinkAnimation.tilt);
  });

  test('final_shrink_spins_once_around_the_zone', () {
    expect(pick(stage: 4), ShrinkAnimation.tiltSpin);
  });

  test('reduce_motion_keeps_final_shrink_from_spinning', () {
    expect(pick(stage: 4, reduceMotion: true), ShrinkAnimation.tilt);
  });

  test('cop_scanning_robber_qr_is_not_interrupted', () {
    // 체포 중에 화면을 덮으면 체포가 끊긴다
    expect(pick(stage: 4, qrOpen: true), ShrinkAnimation.none);
  });

  test('open_chat_or_participant_list_skips_animation', () {
    expect(pick(chatOpen: true), ShrinkAnimation.none);
    expect(pick(participantsOpen: true), ShrinkAnimation.none);
  });

  test('app_in_background_skips_animation', () {
    expect(pick(appVisible: false), ShrinkAnimation.none);
  });
}
