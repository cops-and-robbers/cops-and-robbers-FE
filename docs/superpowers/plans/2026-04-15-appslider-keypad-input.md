# AppSlider 숫자 키패드 입력 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `AppSlider`의 값 영역을 탭하면 숫자 키패드로 직접 입력할 수 있게 하고(opt-in `editable` 플래그), 위치 공유 간격 슬라이더의 `min: 0` 변경을 모든 사용처에 동기화하면서 `divisions` 정합성을 바로잡는다.

**Architecture:** `AppSlider`는 `StatelessWidget`을 유지하고, 편집 상태가 필요한 부분만 동일 파일 내 private `_EditableValueText` `StatefulWidget`으로 추출한다. `_buildValueDisplay()`의 3가지 표시 모드(`displayValue` / `displayPrefix·displaySuffix` / 기본)별로 편집 분기를 끼우며, prefix/suffix 모드는 `RichText` → `Row`로 재구성한다. 입력 UX는 `InfoRadiusChip`의 편집 패턴(탭 → TextField → 100ms 디바운스 → 클램프 → 포커스 해제 시 종료)을 미러링하되, 데이터 타입(`double`)이 다르므로 코드는 별도로 두고 양쪽에 미래 추출용 TODO 주석을 단다.

**Tech Stack:** Flutter 3.9.2+, Dart 3.9.2+, `flutter_screenutil`, `flutter_test` (`testWidgets`), 기존 `AppColors`/`AppTextStyles`/`AppSpacing` 디자인 시스템.

**관련 문서:** `docs/superpowers/specs/2026-04-15-appslider-keypad-input-design.md`

---

## File Structure

**Modify**
- `lib/core/widgets/inputs/app_slider.dart` — `editable`/`onEditingChanged` 파라미터, `assert`, `_buildValueDisplay()` 분기, `_EditableValueText` private 위젯, 미래 추출 TODO
- `lib/core/widgets/chips/info_radius_chip.dart` — 미래 추출 TODO 주석 1개만 (로직 변경 없음)
- `lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart` — 3개 슬라이더에 `editable: true` 추가, 위치 공유 슬라이더 `divisions: 29 → 30` 수정, 클래스 docstring "위치 공유 간격 (1~30분)" → "(0~30분)" 정정
- `lib/features/session/presentation/widgets/session_creation_steps/step_1_participant_settings_content.dart` — 1개 슬라이더에 `editable: true` 추가
- `lib/features/session/presentation/pages/game_settings_edit_page.dart` — 3개 슬라이더에 `editable: true` 추가, 위치 공유 슬라이더 `min: 1 → 0`, `divisions: 29 → 30` 수정

**Create**
- `test/core/widgets/inputs/app_slider_test.dart` — 위젯 테스트 (편집 진입/입력/디바운스/클램프/빈값/외부 prop 보호/prefix·suffix 모드/assert)

**Unchanged**
- `lib/core/widgets/map/zone_setting_widget.dart` — 지도 오버레이용 (`valueFormatter` + 동적 unit 사용). 편집 모드와 키패드는 지도 인터랙션과 충돌 가능 → `editable` 적용 안 함
- `lib/test_widget_page.dart` — 위젯 카탈로그
- 도메인/네트워크/실시간 레이어 전부

---

## Task 0: 사전 점검 및 브랜치 확인

**Files:** 없음 (환경 확인만)

- [ ] **Step 1: 현재 브랜치 확인**

Run: `git branch --show-current`
Expected: `20260415_#253_슬라이더_값_영역_탭_시_숫자_키패드_입력_지원_및_위치_공유_간격_최소값_0_허용`

- [ ] **Step 2: 작업 트리 깨끗한지 확인**

Run: `git status`
Expected: `nothing to commit, working tree clean` (디자인 문서 커밋 후 상태)

- [ ] **Step 3: pub get 실행**

Run: `flutter pub get`
Expected: `Got dependencies!` 또는 변경 없음

- [ ] **Step 4: 베이스라인 analyze 통과 확인**

Run: `flutter analyze lib/core/widgets/inputs/app_slider.dart lib/features/session`
Expected: `No issues found!`

만약 이미 issue가 있으면 본 작업과 무관한 이슈인지 확인하고 노트만 남긴 뒤 진행.

---

## Task 1: 위치 공유 간격 슬라이더 동기화 (도메인 무관 설정 정정)

**목적:** 본 작업의 슬라이더 코드를 수정하기 전에, 두 호출처의 위치 공유 슬라이더 설정을 정합 상태로 만든다. 이 단계는 `AppSlider` 코드에 손대지 않으므로 회귀 위험이 가장 낮다.

**Files:**
- Modify: `lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart` (위치 공유 슬라이더 `divisions: 29 → 30`, docstring 정정)
- Modify: `lib/features/session/presentation/pages/game_settings_edit_page.dart` (위치 공유 슬라이더 `min: 1 → 0`, `divisions: 29 → 30`)

- [ ] **Step 1: `step_2_game_settings_content.dart` 위치 공유 슬라이더 divisions 수정**

대상 파일의 87~96 라인 부근(`AppSlider(... label: '위치 공유 간격' ...)`)에서 `divisions: 29` 를 `divisions: 30` 으로 변경하고, 인라인 주석을 `// 0~30, 1분 단위`로 갱신한다.

```dart
// 위치 공유 간격
AppSlider(
  key: locationShareKey,
  label: '위치 공유 간격',
  value: locationShareMinutes.toDouble(),
  min: 0,
  max: 30,
  unit: '분',
  divisions: 30, // 0~30, 1분 단위
  onChanged: (value) => onLocationShareChanged(value.toInt()),
  isDarkMode: isDarkMode,
),
```

- [ ] **Step 2: 같은 파일의 클래스 docstring 정정**

파일 상단 클래스 위 주석에서 `위치 공유 간격 (1~30분)` 을 `위치 공유 간격 (0~30분)` 으로 바꾼다.

```dart
/// - 라운드 제한 시간 (10~180분)
/// - 위치 공유 간격 (0~30분)
/// - 경찰 시작 시간 (도둑 시작 후 0~10분 뒤)
```

- [ ] **Step 3: `game_settings_edit_page.dart` 위치 공유 슬라이더 동기화**

대상 파일의 193~210 라인 부근에서 `min: 1` 을 `min: 0` 으로, `divisions: 29` 를 `divisions: 30` 으로 변경한다. 다른 파라미터는 손대지 않는다.

```dart
AppSlider(
  label: '위치 공유 간격',
  value: _locationShareMinutes.toDouble(),
  min: 0,
  max: 30,
  unit: '분',
  divisions: 30,
  onChanged: (v) =>
      setState(() => _locationShareMinutes = v.toInt()),
  isDarkMode: isDark,
  backgroundColor: isDark
      ? AppColors.black900
      : AppColors.white,
  // ...기존 나머지 파라미터 유지...
),
```

- [ ] **Step 4: analyze 통과 확인**

Run: `flutter analyze lib/features/session`
Expected: `No issues found!`

- [ ] **Step 5: 커밋**

```bash
git add lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart \
        lib/features/session/presentation/pages/game_settings_edit_page.dart
git commit -m "fix : 위치 공유 간격 슬라이더 min:0 동기화 및 divisions 정합성 보정 #253"
```

---

## Task 2: `AppSlider`에 `editable` / `onEditingChanged` 파라미터와 assert 추가

**목적:** 슬라이더 동작은 그대로 두고 공개 API만 먼저 확장한다. 이 단계 끝에서도 동작 변화는 0.

**Files:**
- Modify: `lib/core/widgets/inputs/app_slider.dart` (생성자, 필드 선언, dartdoc)

- [ ] **Step 1: 생성자에 파라미터 추가**

`AppSlider`의 `const AppSlider({...})` 생성자 끝부분(`this.valueTextStyle,` 다음)에 두 파라미터를 추가하고, 끝 `})` 뒤에 `assert`를 단다.

```dart
const AppSlider({
  super.key,
  required this.label,
  required this.value,
  required this.min,
  required this.max,
  required this.unit,
  required this.onChanged,
  this.displayValue,
  this.displayPrefix,
  this.displaySuffix,
  this.valueFormatter,
  this.activeTrackColor,
  this.thumbColor,
  this.inactiveTrackColor,
  this.backgroundColor,
  this.showMinMax = true,
  this.divisions,
  this.width,
  this.showContainer = true,
  this.labelColor,
  this.valueColor,
  this.minMaxColor,
  this.isDarkMode = false,
  this.valueTextStyle,
  this.editable = false,
  this.onEditingChanged,
}) : assert(
       !(editable && displayValue != null),
       'AppSlider: editable과 displayValue는 함께 사용할 수 없다 '
       '(displayValue는 임의 문자열이라 숫자 입력 위치를 알 수 없음)',
     );
```

- [ ] **Step 2: 필드 선언 추가**

기존 `valueTextStyle` 필드 선언 다음에 두 필드와 dartdoc을 추가한다.

```dart
/// 값 텍스트 스타일 (null이면 AppTextStyles.label_16 사용)
final TextStyle? valueTextStyle;

/// 값 표시 영역 탭 시 숫자 키패드 입력 모드 활성화 (기본: false)
///
/// `displayValue`와 함께 사용할 수 없다 (assert 실패).
/// `displayPrefix`/`displaySuffix`와는 호환된다.
final bool editable;

/// 편집 모드 진입/종료 콜백 (선택)
/// - true: 편집 시작 (탭 → TextField 표시)
/// - false: 편집 종료 (포커스 해제 또는 키보드 완료)
final ValueChanged<bool>? onEditingChanged;
```

- [ ] **Step 3: analyze 통과 확인**

Run: `flutter analyze lib/core/widgets/inputs/app_slider.dart`
Expected: `No issues found!`

- [ ] **Step 4: 코드 생성 미실행 확인 (이번 작업은 어노테이션 변경 없음)**

`@freezed`/`@riverpod`/`@RestApi` 같은 어노테이션을 추가하지 않았으므로 `build_runner` 실행 불필요.

- [ ] **Step 5: 커밋**

```bash
git add lib/core/widgets/inputs/app_slider.dart
git commit -m "feat : AppSlider editable opt-in API 추가 #253"
```

---

## Task 3: `_EditableValueText` 위젯 테스트 작성 (RED)

**목적:** `_EditableValueText`가 별도 위젯이지만 `app_slider.dart` 내 private 클래스이므로, 외부에서 직접 테스트할 수 없다. 따라서 **`AppSlider(editable: true)` 를 통해 행동을 검증**하는 위젯 테스트를 먼저 작성한다. 이 시점에는 아직 구현이 없으므로 모든 테스트가 실패해야 한다.

**Files:**
- Create: `test/core/widgets/inputs/app_slider_test.dart`

- [ ] **Step 1: 테스트 파일 생성 및 헬퍼 작성**

`AppSlider`는 내부에서 `flutter_screenutil`의 `.w/.h/.r/.sp`를 사용하므로 테스트는 `ScreenUtilInit`로 감싸야 한다. 헬퍼 함수를 파일 상단에 둔다.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/widgets/inputs/app_slider.dart';

/// AppSlider를 ScreenUtil 환경에서 띄우는 테스트 헬퍼
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
      double current = 30;
      await _pumpSlider(
        tester,
        child: AppSlider(
          label: '라운드',
          value: current,
          min: 10,
          max: 180,
          unit: '분',
          divisions: 170,
          onChanged: (v) => current = v,
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
            builder: (_, __) => StatefulBuilder(
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
```

- [ ] **Step 2: 테스트 실행해서 모두 실패하는지 확인 (RED)**

Run: `flutter test test/core/widgets/inputs/app_slider_test.dart`
Expected:
- `editable=false` 그룹의 첫 번째 테스트(탭해도 TextField 없음)는 PASS여야 함 (구현 없이도 통과)
- `editable=true` 그룹 테스트들은 모두 FAIL (TextField가 안 뜸)
- `assert` 테스트는 PASS (Task 2에서 이미 assert 추가됨)
- prefix/suffix 그룹 테스트는 FAIL

전체 결과는 "Some tests failed"로 끝나야 정상.

**중요:** 만약 `editable=true` 테스트가 PASS로 나오면 헬퍼나 단언이 잘못된 것이니 확인 필요.

- [ ] **Step 3: 커밋 (RED 상태로 커밋)**

```bash
git add test/core/widgets/inputs/app_slider_test.dart
git commit -m "test : AppSlider 편집 모드 위젯 테스트 추가 (RED) #253"
```

---

## Task 4: `_EditableValueText` 위젯 구현 (GREEN: 기본 모드)

**목적:** `app_slider.dart` 내부에 private `_EditableValueText` `StatefulWidget`을 추가하고, 기본 표시 모드(prefix/suffix 없음)에 통합한다. 이 단계 끝에서 기본 모드 관련 테스트가 통과한다.

**Files:**
- Modify: `lib/core/widgets/inputs/app_slider.dart`

- [ ] **Step 1: 파일 상단에 미래 추출 TODO 주석 추가**

`import` 다음, `class AppSlider` dartdoc 위에 다음 주석을 단다.

```dart
// TODO: 세 번째 편집 가능 텍스트 사용처가 생기면
// EditableNumberText로 추출하여 공용화한다.
// 참고 구현: lib/core/widgets/chips/info_radius_chip.dart
```

- [ ] **Step 2: import 추가 (services, async)**

파일 상단 import 영역에 아래 두 줄을 추가한다.

```dart
import 'dart:async';

import 'package:flutter/services.dart';
```

(`package:flutter/material.dart`, `package:flutter_screenutil/flutter_screenutil.dart` 등 기존 import는 그대로 둔다.)

- [ ] **Step 3: 파일 맨 아래(`_CustomSliderTrackShape` 다음)에 `_EditableValueText` 추가**

```dart
/// 슬라이더 값 영역의 편집 가능 텍스트
///
/// 비편집 모드에서는 일반 Text로 보이고, 탭하면 TextField로 전환된다.
/// 입력값은 100ms 디바운스 후 [min]~[max] 범위로 클램핑되어 [onChanged]로 전달된다.
///
/// 이 위젯은 `_EditableValueText` 라는 이름 그대로 `app_slider.dart` 내부 private이며,
/// `InfoRadiusChip`의 편집 로직과 의도적으로 동일한 메서드 구조를 가진다. 향후 세 번째
/// 사용처가 생기면 둘을 `EditableNumberText`로 통합할 수 있도록 미러링 구조를 유지한다.
class _EditableValueText extends StatefulWidget {
  const _EditableValueText({
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.textStyle,
    required this.onChanged,
    this.onEditingChanged,
  });

  /// 현재 값 (부모 슬라이더의 value)
  final double value;

  /// 클램핑 하한
  final double min;

  /// 클램핑 상한
  final double max;

  /// 단위 문자열 (예: '분', '명', 'm')
  final String unit;

  /// 표시·편집 모두에 적용되는 텍스트 스타일 (값 색상 포함)
  final TextStyle textStyle;

  /// 클램핑된 값을 부모에 전달하는 콜백
  final ValueChanged<double> onChanged;

  /// 편집 모드 진입/종료 콜백 (선택)
  final ValueChanged<bool>? onEditingChanged;

  @override
  State<_EditableValueText> createState() => _EditableValueTextState();
}

class _EditableValueTextState extends State<_EditableValueText> {
  bool _isEditing = false;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _EditableValueText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 편집 중에는 부모 prop으로 controller를 덮어쓰지 않는다 (사용자 입력 보호).
    // 편집 종료 후 다음 _startEditing()에서 최신 widget.value로 다시 채워진다.
  }

  /// 포커스 해제 시 자동으로 편집 종료
  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _isEditing) {
      _completeEditing();
    }
  }

  /// 편집 모드 진입: 값을 controller에 채우고 전체 선택 후 포커스 요청
  void _startEditing() {
    final text = widget.value.toInt().toString();
    setState(() {
      _isEditing = true;
      _textController.text = text;
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: text.length,
      );
    });
    widget.onEditingChanged?.call(true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  /// 입력 변경 시 100ms 디바운스로 부모 콜백 호출
  void _onTextChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), _applyCurrentInput);
  }

  /// 현재 입력값을 클램핑해 부모에 전달. 빈 입력은 무시.
  void _applyCurrentInput() {
    final input = _textController.text.trim();
    if (input.isEmpty) return;

    final parsed = int.tryParse(input);
    if (parsed == null) return;

    final clamped = parsed.toDouble().clamp(widget.min, widget.max);
    widget.onChanged(clamped);
  }

  /// 편집 종료: 디바운스 취소 후 즉시 적용, 포커스 해제, 편집 모드 끔
  void _completeEditing() {
    if (!_isEditing) return;

    _debounce?.cancel();
    _applyCurrentInput();

    setState(() => _isEditing = false);
    widget.onEditingChanged?.call(false);

    if (_focusNode.hasFocus) _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEditing) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _startEditing,
        child: Text(
          '${widget.value.toInt()}${widget.unit}',
          style: widget.textStyle,
        ),
      );
    }

    // 편집 중: 좁은 폭의 TextField + 단위 텍스트
    final maxDigits = widget.max.toInt().toString().length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IntrinsicWidth(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 24.w),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              textAlign: TextAlign.center,
              maxLength: maxDigits,
              style: widget.textStyle,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                counterText: '',
              ),
              onChanged: _onTextChanged,
              onSubmitted: (_) => _completeEditing(),
            ),
          ),
        ),
        Text(widget.unit, style: widget.textStyle),
      ],
    );
  }
}
```

- [ ] **Step 4: `_buildValueDisplay()` 의 기본 모드(모드 3) 분기에서 `_EditableValueText` 사용**

기존 `_buildValueDisplay()` 메서드의 마지막 `return Text(...)` 부분을 다음과 같이 교체한다. (모드 1, 모드 2 분기는 이 단계에서 손대지 않는다.)

```dart
// 기본 형식 (valueTextStyle ?? label_16 + thumbColor)
final valueStyle = (valueTextStyle ?? AppTextStyles.label_16).copyWith(
  color: _effectiveValueColor,
);

if (editable) {
  return _EditableValueText(
    value: value,
    min: min,
    max: max,
    unit: unit,
    textStyle: valueStyle,
    onChanged: onChanged,
    onEditingChanged: onEditingChanged,
  );
}

return Text(
  '${value.toInt()}$unit',
  style: valueStyle,
);
```

- [ ] **Step 5: analyze 통과 확인**

Run: `flutter analyze lib/core/widgets/inputs/app_slider.dart`
Expected: `No issues found!`

- [ ] **Step 6: 기본 모드 테스트 통과 확인**

Run: `flutter test test/core/widgets/inputs/app_slider_test.dart -p chrome` 가 아니라 일반 모드:
Run: `flutter test test/core/widgets/inputs/app_slider_test.dart`

Expected:
- `editable=false` 그룹: PASS
- `editable=true 기본 모드` 그룹: 모두 PASS
- `editable=true + displayPrefix/displaySuffix` 그룹: **여전히 FAIL** (모드 2 통합은 Task 5에서)
- `assert` 그룹: PASS

**프리픽스 모드 테스트가 FAIL인 것이 정상이다.** 그 외 테스트가 FAIL이면 구현을 확인할 것.

- [ ] **Step 7: 커밋**

```bash
git add lib/core/widgets/inputs/app_slider.dart
git commit -m "feat : _EditableValueText 위젯 추가 및 기본 모드 통합 #253"
```

---

## Task 5: prefix/suffix 모드(`_buildValueDisplay` 모드 2) 통합

**목적:** `displayPrefix`/`displaySuffix`가 있는 경우 `RichText` 구조를 `Row`로 재구성하여 편집 가능 모드를 지원한다. 비편집 시 동작은 시각적으로 동일해야 한다.

**Files:**
- Modify: `lib/core/widgets/inputs/app_slider.dart`

- [ ] **Step 1: `_buildValueDisplay()` 모드 2 분기 교체**

기존 `if (displayPrefix != null || displaySuffix != null)` 블록 전체를 다음으로 교체한다. 핵심: `RichText` → `Row`, 비편집/편집 양쪽 모두 동일한 prefix/suffix `Text` 위젯을 사용.

```dart
// prefix/suffix 사용 시 (복합 스타일)
if (displayPrefix != null || displaySuffix != null) {
  final prefixStyle = AppTextStyles.paragraph_14_100.copyWith(
    color: isDarkMode ? AppColors.black200 : AppColors.black800,
  );
  final valueStyle = (valueTextStyle ?? AppTextStyles.label_16).copyWith(
    color: valueColor ?? _effectiveThumbColor,
  );

  final Widget valueWidget = editable
      ? _EditableValueText(
          value: value,
          min: min,
          max: max,
          unit: unit,
          textStyle: valueStyle,
          onChanged: onChanged,
          onEditingChanged: onEditingChanged,
        )
      : Text(
          '${value.toInt()}$unit',
          style: valueStyle,
        );

  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      if (displayPrefix != null)
        Text('$displayPrefix ', style: prefixStyle),
      valueWidget,
      if (displaySuffix != null)
        Text(' $displaySuffix', style: valueStyle),
    ],
  );
}
```

**주의:**
- 기존 `RichText` 코드는 prefix 뒤에 공백을 `'$displayPrefix '` 형태로 자체 포함했고 suffix 앞에도 공백 ` $displaySuffix`이 있었다. 위 코드는 동일한 공백 패턴을 그대로 유지한다.
- 호출처에서 이미 `displayPrefix: '도둑 시작 후 '` 처럼 끝에 공백을 포함해 넘기는 케이스가 있으므로, `'$displayPrefix '`로 한 칸 더 붙여도 시각적 변화는 거의 없다 (기존과 동일 동작 유지).

- [ ] **Step 2: analyze 통과 확인**

Run: `flutter analyze lib/core/widgets/inputs/app_slider.dart`
Expected: `No issues found!`

- [ ] **Step 3: 전체 위젯 테스트 통과 확인 (GREEN 전체)**

Run: `flutter test test/core/widgets/inputs/app_slider_test.dart`
Expected: 모든 테스트 PASS

- [ ] **Step 4: 커밋**

```bash
git add lib/core/widgets/inputs/app_slider.dart
git commit -m "feat : AppSlider prefix/suffix 모드 편집 통합 #253"
```

---

## Task 6: `InfoRadiusChip`에 미래 추출 TODO 주석 추가

**목적:** 두 위젯의 편집 로직이 의도적으로 중복되어 있다는 사실을 코드에 명시한다. 세 번째 사용처가 생길 때 작업자가 양쪽을 모두 인지할 수 있게 한다.

**Files:**
- Modify: `lib/core/widgets/chips/info_radius_chip.dart`

- [ ] **Step 1: 파일 상단 import 다음에 TODO 주석 추가**

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

// TODO: 세 번째 편집 가능 텍스트 사용처가 생기면
// EditableNumberText로 추출하여 공용화한다.
// 참고 구현: lib/core/widgets/inputs/app_slider.dart (_EditableValueText)
```

- [ ] **Step 2: analyze 통과 확인**

Run: `flutter analyze lib/core/widgets/chips/info_radius_chip.dart`
Expected: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/core/widgets/chips/info_radius_chip.dart
git commit -m "docs : InfoRadiusChip 미래 공용화 TODO 주석 추가 #253"
```

---

## Task 7: 호출처에 `editable: true` 적용

**목적:** 본 이슈의 사용자 가치(키패드 입력)를 실제 화면에 노출한다. 슬라이더 작업이 끝났으므로 한 단계로 묶어 적용한다.

**Files:**
- Modify: `lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart`
- Modify: `lib/features/session/presentation/widgets/session_creation_steps/step_1_participant_settings_content.dart`
- Modify: `lib/features/session/presentation/pages/game_settings_edit_page.dart`

- [ ] **Step 1: `step_2_game_settings_content.dart` 3개 슬라이더에 `editable: true` 추가**

라운드 제한 시간, 위치 공유 간격, 경찰 시작 시간 — 세 `AppSlider` 모두에 `isDarkMode: isDarkMode,` 다음 줄에 `editable: true,` 를 추가한다.

```dart
// 라운드 제한 시간
AppSlider(
  key: roundDurationKey,
  label: '라운드 제한 시간',
  value: roundDurationMinutes.toDouble(),
  min: 10,
  max: 180,
  unit: '분',
  divisions: 170,
  onChanged: (value) => onRoundDurationChanged(value.toInt()),
  isDarkMode: isDarkMode,
  editable: true,
),

// 위치 공유 간격
AppSlider(
  key: locationShareKey,
  label: '위치 공유 간격',
  value: locationShareMinutes.toDouble(),
  min: 0,
  max: 30,
  unit: '분',
  divisions: 30, // 0~30, 1분 단위
  onChanged: (value) => onLocationShareChanged(value.toInt()),
  isDarkMode: isDarkMode,
  editable: true,
),

// 경찰 시작 시간 (도둑 시작 후)
AppSlider(
  key: policeWaitKey,
  label: '경찰 시작 시간',
  value: policeWaitMinutes.toDouble(),
  min: 1,
  max: 10,
  unit: '분',
  divisions: 9,
  displayPrefix: '도둑 시작 후 ',
  displaySuffix: ' 뒤',
  onChanged: (value) => onPoliceWaitChanged(value.toInt()),
  isDarkMode: isDarkMode,
  editable: true,
),
```

- [ ] **Step 2: `step_1_participant_settings_content.dart` 슬라이더에 `editable: true` 추가**

`AppSlider(... key: maxParticipantsKey ...)`에 `editable: true,`를 추가한다.

```dart
return AppSlider(
  key: maxParticipantsKey,
  label: '최대 참가자',
  value: maxParticipants.toDouble(),
  min: 2,
  max: 50,
  unit: '명',
  divisions: 48, // 2~50, 1명 단위
  onChanged: (value) => onChanged(value.toInt()),
  isDarkMode: isDarkMode,
  valueColor: isDarkMode ? AppColors.white : null,
  valueTextStyle: valueTextStyle,
  editable: true,
);
```

- [ ] **Step 3: `game_settings_edit_page.dart` 3개 슬라이더에 `editable: true` 추가**

라운드 제한 시간, 위치 공유 간격(이미 Task 1에서 `min: 0, divisions: 30`으로 수정됨), 경찰 시작 시간 — 세 `AppSlider` 모두에 `editable: true,` 추가. 다른 파라미터는 손대지 않는다.

각 슬라이더 블록의 마지막 파라미터(예: `backgroundColor: ...,` 또는 `displayPrefix/displaySuffix` 다음) 뒤에 줄을 추가하면 된다. 정확한 위치는 파일 내 컨텍스트에 따라 다르므로, 다음 형태가 되도록 한다:

```dart
AppSlider(
  label: '라운드 제한 시간',
  value: _roundDurationMinutes.toDouble(),
  min: 10,
  max: 180,
  unit: '분',
  divisions: 170,
  onChanged: (v) =>
      setState(() => _roundDurationMinutes = v.toInt()),
  isDarkMode: isDark,
  backgroundColor: isDark
      ? AppColors.black900
      : AppColors.white,
  // ...기존 추가 파라미터 유지...
  editable: true,
),
```

세 슬라이더 모두 동일하게 `editable: true,` 한 줄을 추가한다.

- [ ] **Step 4: analyze 통과 확인**

Run: `flutter analyze lib/features/session`
Expected: `No issues found!`

- [ ] **Step 5: 위젯 테스트 전체 재실행 (회귀 확인)**

Run: `flutter test test/core/widgets/inputs/app_slider_test.dart`
Expected: 모든 테스트 PASS

- [ ] **Step 6: 커밋**

```bash
git add lib/features/session/presentation/widgets/session_creation_steps/step_1_participant_settings_content.dart \
        lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart \
        lib/features/session/presentation/pages/game_settings_edit_page.dart
git commit -m "feat : 세션 설정 슬라이더에 키패드 입력 모드 활성화 #253"
```

---

## Task 8: 전체 검증 및 정리

**목적:** 본 작업이 다른 영역에 회귀를 일으키지 않았는지 확인하고, 수동 점검 항목을 정리한다.

**Files:** 없음 (검증만)

- [ ] **Step 1: 프로젝트 전체 analyze**

Run: `flutter analyze`
Expected: `No issues found!` (또는 본 작업 이전부터 존재하던 무관 이슈만)

- [ ] **Step 2: 프로젝트 전체 테스트**

Run: `flutter test`
Expected: 모든 테스트 PASS

- [ ] **Step 3: 본 작업 이전 베이스라인과 비교**

만약 Step 2에서 실패가 나오면, 본 작업 시작 전(`git log` 기준 디자인 문서 커밋 직후)에서도 동일하게 실패하던 테스트인지 확인한다. 무관 실패라면 노트로 남기고 진행, 본 작업으로 인한 회귀라면 원인 추적.

- [ ] **Step 4: 수동 점검 체크리스트** (코드 변경 없음, 작업자가 직접 확인)

다음 항목은 위젯 테스트로 보장하기 어려우므로 가능하면 시뮬레이터/실기기에서 한 번 확인한다.

- [ ] 방 만들기 → 2단계(게임 설정)에서 라운드 제한 시간 슬라이더의 값 텍스트(`30분` 등)를 탭하면 키보드가 올라오는가?
- [ ] 입력하면 슬라이더 트랙도 함께 움직이는가?
- [ ] `999`를 입력하면 `180`으로 클램핑되는가?
- [ ] 위치 공유 간격을 `0`으로 입력 가능한가?
- [ ] 경찰 시작 시간 슬라이더에서 "도둑 시작 후 [숫자]분 뒤" 형태가 편집 중에도 유지되는가?
- [ ] 1단계(참가자 설정)의 최대 참가자 슬라이더도 동일하게 키패드 입력이 되는가?
- [ ] 게임 설정 수정 페이지의 세 슬라이더도 동일하게 동작하는가?
- [ ] 지도 위 반경 슬라이더(`zone_setting_widget.dart`)는 편집 모드가 활성화되지 않았는가? (탭해도 아무 일이 일어나지 않아야 정상)

- [ ] **Step 5: TODO/Out-of-scope 항목 노트**

다음은 본 PR에 포함되지 않는 항목으로, 별도 이슈 또는 후속 작업이 필요하다. 작업자는 PR description에 명시한다.

- `locationShareMinutes == 0`을 "위치 공유 비활성화"로 해석할지 여부는 게임 도메인/STOMP 레이어 영향 범위. 본 이슈 범위 밖이며, 슬라이더 UI는 0 입력을 허용하지만 실제 의미는 후속 정의가 필요하다.
- `_EditableValueText`와 `InfoRadiusChip` 편집 로직 공용화는 세 번째 사용처가 등장하는 시점에 한꺼번에 처리한다.

- [ ] **Step 6: 최종 git 상태 확인**

Run: `git log --oneline -10`
Expected: 본 작업의 커밋들이 순서대로 보임 (Task 1~7).

Run: `git status`
Expected: `nothing to commit, working tree clean`

---

## 작업 완료 후

- PR을 만들 때 본 plan과 spec 문서를 함께 참고 자료로 링크한다.
- PR description에는 위 Task 8 Step 4 수동 점검 결과를 체크리스트로 옮긴다.
- `git push`는 사용자 명시 요청이 있을 때만 수행한다 (프로젝트 룰).
