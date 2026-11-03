import 'package:cops_and_robbers/features/game/domain/event_evidence_layout.dart';
import 'package:flutter_test/flutter_test.dart';

EventEvidenceLayout _layout(double ratio, int count) =>
    EventEvidenceLayout.resolve(
      aspectRatio: ratio,
      count: count,
      maxWidth: 281,
      maxHeight: 383,
      horizontalGap: 16,
      verticalGap: 16,
    );

void main() {
  test('two_portrait_photos_sit_side_by_side_within_half_width', () {
    final layout = _layout(9 / 16, 2);

    expect(layout.arrangement, EventEvidenceArrangement.sideBySide);
    expect(layout.slotWidth, closeTo(132.5, 0.01));
    expect(layout.slotHeight, closeTo(235.6, 0.1));
    expect(layout.tiltRadians, EventEvidenceLayout.sideBySideTilt);
  });

  test('two_square_photos_stack_within_height_limit', () {
    final layout = _layout(1, 2);

    expect(layout.arrangement, EventEvidenceArrangement.stacked);
    expect(layout.slotWidth, closeTo(183.5, 0.01));
    expect(layout.slotHeight, closeTo(183.5, 0.01));
    expect(layout.tiltRadians, EventEvidenceLayout.fullWidthTilt);
  });

  test('two_landscape_photos_stack_at_full_width', () {
    final layout = _layout(16 / 9, 2);

    expect(layout.arrangement, EventEvidenceArrangement.stacked);
    expect(layout.slotWidth, closeTo(281, 0.01));
    expect(layout.slotHeight, closeTo(158.1, 0.1));
  });

  test('one_portrait_photo_stops_at_height_limit', () {
    final layout = _layout(9 / 16, 1);

    expect(layout.arrangement, EventEvidenceArrangement.single);
    expect(layout.slotHeight, closeTo(383, 0.01));
    expect(layout.slotWidth, closeTo(215.4, 0.1));
  });

  test('one_landscape_photo_stops_at_full_width', () {
    final layout = _layout(16 / 9, 1);

    expect(layout.slotWidth, closeTo(281, 0.01));
    expect(layout.slotHeight, closeTo(158.1, 0.1));
  });

  test('three_portrait_photos_share_width_side_by_side', () {
    final layout = _layout(9 / 16, 3);

    expect(layout.arrangement, EventEvidenceArrangement.sideBySide);
    expect(layout.slotWidth, closeTo(83, 0.01));
    expect(layout.slotHeight, closeTo(147.6, 0.1));
  });

  test('three_landscape_photos_sit_two_over_one', () {
    final layout = _layout(16 / 9, 3);

    expect(layout.arrangement, EventEvidenceArrangement.twoOverOne);
    expect(layout.slotWidth, closeTo(132.5, 0.01));
    expect(layout.slotHeight, closeTo(74.5, 0.1));
  });

  test('three_square_photos_sit_two_over_one', () {
    final layout = _layout(1, 3);

    expect(layout.arrangement, EventEvidenceArrangement.twoOverOne);
    expect(layout.slotWidth, closeTo(132.5, 0.01));
    expect(layout.slotHeight, closeTo(132.5, 0.01));
  });

  test('middle_photo_stays_straight_when_three_photos_tilt', () {
    final layout = _layout(9 / 16, 3);

    expect(layout.tiltFor(1, 3), -EventEvidenceLayout.sideBySideTilt);
    expect(layout.tiltFor(2, 3), 0);
    expect(layout.tiltFor(3, 3), EventEvidenceLayout.sideBySideTilt);
  });

  test('side_by_side_photos_shrink_when_height_limit_is_smaller', () {
    final layout = EventEvidenceLayout.resolve(
      aspectRatio: 9 / 16,
      count: 2,
      maxWidth: 281,
      maxHeight: 200,
      horizontalGap: 16,
      verticalGap: 16,
    );

    expect(layout.slotHeight, 200);
    expect(layout.slotWidth, closeTo(112.5, 0.01));
  });

  test('extreme_ratio_uses_allowed_range_when_photo_is_too_long', () {
    expect(_layout(0.1, 1).slotWidth, _layout(9 / 16, 1).slotWidth);
    expect(_layout(10, 1).slotHeight, _layout(16 / 9, 1).slotHeight);
  });
}
