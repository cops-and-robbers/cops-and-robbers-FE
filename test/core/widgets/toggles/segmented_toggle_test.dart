import 'package:cops_and_robbers/core/widgets/toggles/segmented_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('segmentAlignmentX', () {
    test('places_two_segments_at_both_ends', () {
      expect(segmentAlignmentX(0, 2), -1.0);
      expect(segmentAlignmentX(1, 2), 1.0);
    });

    test('spreads_three_segments_evenly_with_middle_at_center', () {
      expect(segmentAlignmentX(0, 3), -1.0);
      expect(segmentAlignmentX(1, 3), 0.0);
      expect(segmentAlignmentX(2, 3), 1.0);
    });

    test('returns_center_for_single_segment_without_dividing_by_zero', () {
      // count-1이 분모라 방어가 없으면 0으로 나눠 NaN이 된다.
      expect(segmentAlignmentX(0, 1), 0.0);
    });
  });

  group('SegmentedToggle', () {
    Widget wrap(Widget child) => ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, _) => MaterialApp(home: Scaffold(body: child)),
    );

    testWidgets('reports_tapped_index_when_unselected_segment_tapped', (
      tester,
    ) async {
      int? tapped;
      await tester.pumpWidget(
        wrap(
          SegmentedToggle(
            labels: const ['전체', '우리 동네', '내 모임'],
            selectedIndex: 0,
            onChanged: (i) => tapped = i,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('내 모임'));
      await tester.pumpAndSettle();

      expect(tapped, 2);
    });

    testWidgets('ignores_tap_when_already_selected_segment_tapped', (
      tester,
    ) async {
      int? tapped;
      await tester.pumpWidget(
        wrap(
          SegmentedToggle(
            labels: const ['전체', '우리 동네', '내 모임'],
            selectedIndex: 0,
            onChanged: (i) => tapped = i,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('전체'));
      await tester.pumpAndSettle();

      expect(tapped, isNull);
    });
  });
}
