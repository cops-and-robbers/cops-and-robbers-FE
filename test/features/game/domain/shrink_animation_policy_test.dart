import 'package:cops_and_robbers/features/game/domain/shrink_animation_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ShrinkAnimation pick({
    int stage = 1,
    bool appVisible = true,
    bool qrOpen = false,
    bool chatOpen = false,
    bool participantsOpen = false,
  }) => shrinkAnimationFor(
    stage: stage,
    appVisible: appVisible,
    qrOpen: qrOpen,
    chatOpen: chatOpen,
    participantsOpen: participantsOpen,
  );

  test('every_shrink_tilts_the_same_way_when_nothing_is_open', () {
    // 4차(최종)도 1~3차와 같은 연출 — 구글 지도에서 한 바퀴가 끊겨 뺐다
    for (final stage in [1, 2, 3, 4]) {
      expect(pick(stage: stage), ShrinkAnimation.tilt);
    }
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
