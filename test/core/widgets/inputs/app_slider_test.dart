import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/widgets/inputs/app_slider.dart';

/// AppSlider를 ScreenUtil 환경에서 띄우는 테스트 헬퍼
///
/// 기본 flutter_test view(800x600)에서 AppSlider가 그려질 때 일부
/// RenderFlex overflow 경고가 출력될 수 있으나, 테스트 통과/실패에는
/// 영향이 없으며 실제 기기(375 logical)에서는 overflow가 발생하지 않는다.
/// Task 4/5 편집 모드 통합 시 hit-test 문제가 실제로 발생하면 그 시점에
/// 명시적 폭 제약을 재검토한다.
Future<void> _pumpSlider(
  WidgetTester tester, {
  required Widget child,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AppSlider editable=false (기존 동작 회귀 방지)', () {
    testWidgets('값 텍스트를 탭해도 TextField가 나타나지 않는다', (tester) async {
      await _pumpSlider(
        tester,
        child: AppSlider(
          label: '라운드',
          value: 30,
          min: 10,
          max: 180,
          unit: '분',
          divisions: 170,
          onChanged: (_) {},
        ),
      );

      // 값 텍스트가 보이는지 확인
      expect(find.text('30분'), findsOneWidget);

      // 탭해도 TextField가 안 뜸
      await tester.tap(find.text('30분'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('AppSlider editable=true 기본 모드', () {
    testWidgets('값 텍스트 탭 → TextField 출현', (tester) async {
      await _pumpSlider(
        tester,
        child: AppSlider(
          label: '라운드',
          value: 30,
          min: 10,
          max: 180,
          unit: '분',
          divisions: 170,
          editable: true,
          onChanged: (_) {},
        ),
      );

      expect(find.text('30분'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.text('30분'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('숫자 입력 → 100ms 디바운스 후 onChanged 호출', (tester) async {
      double? captured;
      await _pumpSlider(
        tester,
        child: AppSlider(
          label: '라운드',
          value: 30,
          min: 10,
          max: 180,
          unit: '분',
          divisions: 170,
          editable: true,
          onChanged: (v) => captured = v,
        ),
      );

      await tester.tap(find.text('30분'));
      await tester.pumpAndSettle();

      // 전체 선택 상태에서 새 값 입력
      await tester.enterText(find.byType(TextField), '90');
      // 디바운스 100ms 대기
      await tester.pump(const Duration(milliseconds: 150));

      expect(captured, 90.0);
    });

    testWidgets('min보다 작은 값 입력 → min으로 클램프', (tester) async {
      double? captured;
      await _pumpSlider(
        tester,
        child: AppSlider(
          label: '라운드',
          value: 30,
          min: 10,
          max: 180,
          unit: '분',
          divisions: 170,
          editable: true,
          onChanged: (v) => captured = v,
        ),
      );

      await tester.tap(find.text('30분'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '5');
      await tester.pump(const Duration(milliseconds: 150));

      expect(captured, 10.0);
    });

    testWidgets('max보다 큰 값 입력 → max로 클램프', (tester) async {
      double? captured;
      await _pumpSlider(
        tester,
        child: AppSlider(
          label: '시간',
          value: 5,
          min: 0,
          max: 30,
          unit: '분',
          divisions: 30,
          editable: true,
          onChanged: (v) => captured = v,
        ),
      );

      await tester.tap(find.text('5분'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '99');
      await tester.pump(const Duration(milliseconds: 150));

      expect(captured, 30.0);
    });

    testWidgets('빈 문자열 후 편집 종료 → onChanged 미호출', (tester) async {
      int callCount = 0;
      await _pumpSlider(
        tester,
        child: AppSlider(
          label: '라운드',
          value: 30,
          min: 10,
          max: 180,
          unit: '분',
          divisions: 170,
          editable: true,
          onChanged: (_) => callCount++,
        ),
      );

      await tester.tap(find.text('30분'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '');
      // 키보드 'Done' 액션으로 편집 종료 → _completeEditing 호출
      // (라벨 Text를 탭하는 방식은 hit test가 보장되지 않아 flaky하므로 사용하지 않음)
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('편집 중 외부 value prop 변경 → controller 미동기화', (tester) async {
      double parentValue = 30;
      late StateSetter setOuter;

      await tester.pumpWidget(
        MaterialApp(
          home: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (_, child) => StatefulBuilder(
              builder: (context, setState) {
                setOuter = setState;
                return Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppSlider(
                      label: '라운드',
                      value: parentValue,
                      min: 10,
                      max: 180,
                      unit: '분',
                      divisions: 170,
                      editable: true,
                      onChanged: (_) {},
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 편집 진입
      await tester.tap(find.text('30분'));
      await tester.pumpAndSettle();

      // 사용자가 직접 입력
      await tester.enterText(find.byType(TextField), '77');
      // 외부에서 prop을 강제로 다른 값으로 변경
      setOuter(() => parentValue = 50);
      await tester.pump();

      // controller.text는 사용자가 친 '77'을 유지해야 함
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.controller!.text, '77');
    });
  });

  group('AppSlider editable=true + displayPrefix/displaySuffix', () {
    testWidgets('편집 진입 시 prefix/suffix는 그대로 있고 값 부분만 TextField로 변환', (tester) async {
      await _pumpSlider(
        tester,
        child: AppSlider(
          label: '경찰 시작 시간',
          value: 5,
          min: 1,
          max: 10,
          unit: '분',
          divisions: 9,
          displayPrefix: '도둑 시작 후 ',
          displaySuffix: ' 뒤',
          editable: true,
          onChanged: (_) {},
        ),
      );

      // 편집 전: prefix/value/suffix 모두 보임
      expect(find.textContaining('도둑 시작 후'), findsOneWidget);
      expect(find.textContaining('뒤'), findsOneWidget);

      // 값 텍스트(5분)를 찾아 탭
      await tester.tap(find.text('5분'));
      await tester.pumpAndSettle();

      // TextField 출현
      expect(find.byType(TextField), findsOneWidget);
      // prefix/suffix는 여전히 보임
      expect(find.textContaining('도둑 시작 후'), findsOneWidget);
      expect(find.textContaining('뒤'), findsOneWidget);
    });
  });

  group('AppSlider assert', () {
    test('editable=true와 displayValue 동시 사용 시 assert 실패', () {
      expect(
        () => AppSlider(
          label: 'x',
          value: 1,
          min: 0,
          max: 10,
          unit: '분',
          editable: true,
          displayValue: '커스텀',
          onChanged: (_) {},
        ),
        throwsAssertionError,
      );
    });
  });
}
