# AppSlider 숫자 키패드 입력 지원 설계 문서

- 작성일: 2026-04-15
- 관련 이슈: #253
- 브랜치: `20260415_#253_슬라이더_값_영역_탭_시_숫자_키패드_입력_지원_및_위치_공유_간격_최소값_0_허용`
- 작업 범위: `lib/core/widgets/inputs/app_slider.dart` 편집 모드 추가, 호출처 3곳 opt-in

---

## 1. 배경

`AppSlider`는 현재 드래그 방식만 지원해서, 범위가 넓거나 정확한 값이 필요한 사용처(반경 100~1000m, 최대 인원 5~50명, 라운드 10~180분)에서 원하는 값을 정확히 맞추기 번거롭다. 이슈 #253은 두 가지를 요구한다:

1. `AppSlider`의 값 영역을 탭하면 숫자 키패드로 직접 입력 가능.
2. 위치 공유 간격 슬라이더의 최소값을 0분으로 변경 (사용자가 별도 작업으로 이미 적용 — 본 설계는 검증 항목으로만 다룸).

`InfoRadiusChip`이 이미 동일한 편집 UX 패턴(탭 → TextField → 디바운스 → 클램프)을 갖고 있어, 그 패턴을 미러링한다.

---

## 2. 결정 사항 요약

| 결정 | 값 | 근거 |
|---|---|---|
| 활성화 방식 | `editable: bool = false` opt-in | 기존 호출처 동작 보존, 지도 오버레이 같은 부적절한 케이스 배제 |
| `displayPrefix`/`displaySuffix` 시 편집 UI | 숫자 부분만 `TextField`로 교체 | `_buildValueDisplay`의 기존 `RichText` 구조를 `Row`로 재구성하면 변경 폭 최소 + 편집 중 맥락 유지 |
| 입력 반영 타이밍 | 100ms 디바운스 + 편집 종료 시 확정 | `InfoRadiusChip` 일관성, 슬라이더 트랙 실시간 시각 피드백 |
| 입력 타입 | 정수만 (`digitsOnly`) | 모든 사용처가 `value.toInt()` 패턴 |
| 범위 밖 입력 처리 | Silent clamp on commit | 슬라이더 트랙 움직임 자체가 피드백, `InfoRadiusChip`과 일관 |
| 컴포넌트 추출 위치 | `app_slider.dart` 내부 private `_EditableValueText` | 변경 폭 최소화, `AppSlider`는 `StatelessWidget` 유지 |
| `InfoRadiusChip`과 공용화 | **하지 않음** (rule of three) | 두 사용처의 데이터 타입(String vs double)과 레이아웃(Stack vs inline)이 달라 지금 추상화하면 옵션이 누설된 위젯이 됨. 양쪽에 TODO 주석으로 미래 작업자에게 알림 |

---

## 3. 컴포넌트 구조

```
AppSlider (StatelessWidget, 변경 최소)
├─ _buildHeader()
│   └─ _buildValueDisplay()              ← 여기서 editable 분기
│       ├─ editable=false → 기존 Text/RichText 그대로
│       └─ editable=true  → _EditableValueText 삽입
│
└─ _buildSlider() … 변경 없음

_EditableValueText (StatefulWidget, private, 신규)
├─ State
│   ├─ TextEditingController
│   ├─ FocusNode + listener
│   ├─ Timer? _debounce (100ms)
│   └─ bool _isEditing
├─ build()
│   ├─ !_isEditing → GestureDetector + Text
│   └─ _isEditing  → SizedBox(IntrinsicWidth) + TextField
└─ Lifecycle: dispose()에서 timer/focus/controller 정리
```

**책임 분리:**
- `AppSlider`: 값을 받아 그린다. 편집 모드와 무관.
- `_EditableValueText`: 텍스트를 보여주다가 탭하면 TextField로 바뀌고, 입력값을 클램핑해서 부모에 알린다. 슬라이더를 모름.

---

## 4. `_EditableValueText` 상세 스펙

### 생성자

```dart
class _EditableValueText extends StatefulWidget {
  const _EditableValueText({
    required this.value,           // double, 현재 슬라이더 값
    required this.min,             // double, 클램핑 하한
    required this.max,             // double, 클램핑 상한
    required this.unit,            // String, 단위 표시 ('분'/'명'/'m')
    required this.textStyle,       // TextStyle, 표시·편집 모두에 적용
    required this.onChanged,       // ValueChanged<double>, 부모 콜백
    this.onEditingChanged,         // ValueChanged<bool>?
  });
}
```

### 상태 머신

| 메서드 | 책임 |
|---|---|
| `_startEditing()` | `_isEditing=true` → `controller.text = value.toInt().toString()` → 전체 선택(`baseOffset:0, extentOffset:length`) → 다음 프레임에 `requestFocus` |
| `_onTextChanged(text)` | 100ms 디바운스로 `_applyCurrentInput()` 호출 |
| `_applyCurrentInput()` | `trim()` → `int.tryParse` → 실패 시 `min` → `clamp(min, max)` → `onChanged(clamped)`. 빈 문자열이면 early return |
| `_completeEditing()` | `_debounce?.cancel()` → `_applyCurrentInput()` 즉시 → `_isEditing=false` → `unfocus()` |
| `_onFocusChanged()` | 포커스 잃고 `_isEditing`이면 `_completeEditing()` 자동 호출 |

### `build()` 분기

- **`!_isEditing`**: `GestureDetector(onTap: _startEditing, child: Text('${value.toInt()}$unit', style: textStyle))`
- **`_isEditing`**: `Row(mainAxisSize: MainAxisSize.min, [TextField, Text(unit)])`
  - TextField:
    - `keyboardType: TextInputType.numberWithOptions(decimal: false)`
    - `inputFormatters: [FilteringTextInputFormatter.digitsOnly]`
    - `maxLength: max.toInt().toString().length`
    - `textAlign: TextAlign.center`
    - `decoration: InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none, counterText: '')`
    - `style: textStyle`
  - 단위 텍스트는 TextField 옆에 별도 `Text` 위젯으로 붙여 편집 중에도 단위가 보이도록.

### dispose 처리

```dart
@override
void dispose() {
  _debounce?.cancel();
  _focusNode.removeListener(_onFocusChanged);
  _focusNode.dispose();
  _textController.dispose();
  super.dispose();
}
```

### 편집 중 외부 prop 변경 보호

`didUpdateWidget`에서 `_isEditing == true`인 동안에는 부모의 `widget.value`로 `_textController.text`를 덮어쓰지 않는다. 사용자 입력 보호.

---

## 5. `AppSlider` 통합 — 3가지 표시 모드

### 모드 1: `displayValue != null` (레거시 커스텀 문자열)

- 현재: `Text(displayValue!)`
- **편집 처리**: 편집 불가. `displayValue`는 호출자가 임의 문자열을 박는 모드라 어디가 숫자인지 알 수 없음.
- 동작: `editable: true && displayValue != null` 조합은 `assert` 실패. release 빌드에서는 `editable` 무시 + `debugPrint` 경고.
- 비고: 현재 호출처 중 `displayValue`를 쓰는 곳은 없음. 호환성만 유지.

### 모드 2: `displayPrefix != null || displaySuffix != null`

- 현재: `RichText` + 3개 `TextSpan`.
- **편집 처리**: `RichText` → `Row`로 재구성:
  ```dart
  Row(mainAxisSize: MainAxisSize.min, children: [
    if (displayPrefix != null) Text(displayPrefix!, style: prefixStyle),
    editable
        ? _EditableValueText(value, min, max, unit, valueStyle, onChanged)
        : Text('${value.toInt()}$unit', style: valueStyle),
    if (displaySuffix != null) Text(' $displaySuffix', style: valueStyle),
  ])
  ```
- 이유: `RichText`/`WidgetSpan`은 baseline/높이 정렬이 까다로움. `Row`가 의미적으로 명확하고 prefix/suffix는 `Text` 그대로라 기존 스타일(`paragraph_14_100`) 유지.
- jitter 방지: `_EditableValueText` 내부에서 `IntrinsicWidth` + 최소 폭으로 헤더 폭 변동 최소화.

### 모드 3: 기본 (`displayValue == null && prefix == null && suffix == null`)

- 현재: `Text('${value.toInt()}${unit}', style: valueStyle)`
- **편집 처리**: 그대로 `_EditableValueText(...)`로 교체.

### 비편집 경로 (`editable: false`)

세 모드 모두 **현재 코드 한 줄도 바뀌지 않음**. 기존 사용처 무영향.

---

## 6. 공개 API 변경

```dart
const AppSlider({
  // ... 기존 파라미터 모두 동일 ...

  /// 값 표시 영역을 탭하면 숫자 키패드로 직접 입력할 수 있게 한다.
  /// `displayValue`를 함께 사용하는 경우 무시된다.
  this.editable = false,

  /// 편집 모드 진입/종료 콜백 (선택)
  /// true: 편집 시작, false: 편집 종료
  this.onEditingChanged,
}) : assert(
        !(editable && displayValue != null),
        'editable과 displayValue는 함께 사용할 수 없다',
      );

final bool editable;
final ValueChanged<bool>? onEditingChanged;
```

기본값 `false`. opt-in.

---

## 7. 호출처 변경

### 변경 대상 (`editable: true` 추가)

| 파일 | 사용처 |
|---|---|
| `lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart` | 라운드 제한 시간, 위치 공유 간격, 경찰 시작 시간 (3개) |
| `lib/features/session/presentation/widgets/session_creation_steps/step_1_participant_settings_content.dart` | 사용처 확인 후 적용 (실제 사용 형태 점검 필요) |
| `lib/features/session/presentation/pages/game_settings_edit_page.dart` | 동일 슬라이더들 |

### 변경하지 않을 호출처

- **`lib/core/widgets/map/zone_setting_widget.dart`** — 지도 오버레이용 슬라이더 (`showContainer: false` 가능성). 지도 위 키패드는 인터랙션과 충돌 → 기본값 `false` 유지. 구현 직전 실제 사용 형태를 확인하고 필요 시 재검토.
- **`lib/test_widget_page.dart`** — 위젯 카탈로그용 페이지. 변경 없음.

---

## 8. 위치 공유 간격 최소값 0 (이미 적용)

이슈 두 번째 항목은 사용자가 `step_2_game_settings_content.dart`에서 이미 `min: 0`으로 변경했다. 본 설계는 다음 검증만 수행한다:

1. **`divisions` 정합성** — `min: 0, max: 30, divisions: 30`이 1분 단위와 맞는지 확인 (현재 코드는 `divisions: 29`로 보이는 부분이 있어 점검 필요).
2. **`game_settings_edit_page.dart` 동기화** — 동일한 위치 공유 간격 슬라이더가 이 파일에도 있다면 `min: 0`이 적용되어 있는지 확인.
3. **0분 의미 정의** — `locationShareMinutes == 0`을 "위치 공유 비활성화"로 해석할지 여부는 게임 도메인/실시간 통신 레이어 영향 범위. **본 이슈의 슬라이더 작업 범위 밖**. 별도 이슈/확인 항목으로 기록.

---

## 9. 엣지 케이스

| 케이스 | 처리 |
|---|---|
| 빈 입력 후 편집 종료 | early return → 콜백 미호출 → 슬라이더 값 유지 |
| `min`보다 작은 값 입력 | `clamp` → `min`. 슬라이더가 `min` 위치로 스냅 |
| `max`보다 큰 값 입력 | `maxLength` 1차 방어 + `clamp` 2차 방어 |
| 잘못된 문자 입력 시도 | `digitsOnly` 키보드 레벨 차단 |
| 편집 중 부모 rebuild로 `value` 변경 | `_isEditing` 중에는 controller 미동기화 |
| 편집 중 위젯 dispose | timer/focus/controller 모두 정리 |
| `onSubmitted` (키보드 완료) | `_completeEditing()` 호출 |
| 다른 슬라이더 탭 (포커스 이동) | 포커스 리스너가 자동 종료 |
| `displayValue` + `editable: true` | `assert` 실패 + release 시 `editable` 무시 |
| `divisions` 정합성 | 정수 입력 + 1단위 `divisions` 사용처라 자동 정합 |
| `value`가 범위 밖에서 시작 (외부 버그) | 표시는 그대로, 사용자 편집 시 클램핑 |

---

## 10. 에러 처리 및 로깅

- `Exception` 발생 경로 없음 (`int.tryParse` null 반환, 외부 호출 없음). try-catch 불필요.
- `assert` 1개: `displayValue`와 `editable` 동시 사용 금지.
- 디버그 로깅: 잘못된 조합 시 `debugPrint('⚠️ AppSlider: editable과 displayValue는 함께 사용할 수 없음')`.

---

## 11. 테스트 전략

`test/core/widgets/inputs/app_slider_test.dart` 신규 작성.

| 테스트 | 검증 |
|---|---|
| `editable: false`일 때 값 영역 탭 → 변화 없음 | 회귀 방지 |
| `editable: true`일 때 값 영역 탭 → TextField 출현 | 편집 진입 |
| `7` 입력 → 100ms 디바운스 후 `onChanged(7.0)` | 정상 입력 |
| `min=10`에 `5` 입력 → `onChanged(10.0)` | 하한 클램프 |
| `max=30`에 `99` 입력 → `onChanged(30.0)` | 상한 클램프 |
| 빈 문자열 후 포커스 해제 → `onChanged` 미호출 | 빈 입력 안전 |
| 편집 중 외부 `value` 변경 → controller 미반영 | 입력 보호 |
| `displayPrefix`/`displaySuffix` 모드 편집 진입/종료 | 모드 2 검증 |
| `displayValue` + `editable: true` 조합 → `assert` 실패 | API 가드 |

기존 호출처 위젯 테스트가 있다면 `editable: true` 추가 후 회귀 확인. 없다면 작성하지 않음.

---

## 12. 미래 작업 (Out of Scope)

이번 PR에 포함하지 않지만 다음 작업자가 알아야 할 항목.

### TODO: 편집 패턴 공용화

`_EditableValueText`(`AppSlider`)와 `InfoRadiusChip`의 편집 로직은 80%가 중복되지만, 두 사용처의 데이터 타입과 레이아웃이 달라 지금 합치면 추상화가 누설된다. **세 번째 사용처가 등장하면** 두 위젯의 편집 코드와 새 요구사항을 한꺼번에 보고 `lib/core/widgets/inputs/editable_number_text.dart`로 추출한다.

다음 두 파일 상단에 미러링 TODO 주석 추가:

```dart
// TODO: 세 번째 편집 가능 텍스트 사용처가 생기면 EditableNumberText로 추출
// 참고 구현: lib/core/widgets/chips/info_radius_chip.dart  (또는 app_slider.dart)
```

### TODO: 위치 공유 간격 0분 처리 정책

`locationShareMinutes == 0`을 "위치 공유 비활성화"로 해석할지, 게임 시작 차단으로 처리할지, 도메인/STOMP 레이어에서 정의 필요. 본 이슈 범위 밖.

---

## 13. 변경 파일 요약

**수정**
- `lib/core/widgets/inputs/app_slider.dart` — `editable`/`onEditingChanged` 파라미터 추가, `_buildValueDisplay()` 분기, `_EditableValueText` private 위젯 신규, TODO 주석
- `lib/core/widgets/chips/info_radius_chip.dart` — TODO 주석만 추가
- `lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart` — `editable: true` 적용
- `lib/features/session/presentation/widgets/session_creation_steps/step_1_participant_settings_content.dart` — `editable: true` 적용 (사용처 확인 후)
- `lib/features/session/presentation/pages/game_settings_edit_page.dart` — `editable: true` 적용

**신규**
- `test/core/widgets/inputs/app_slider_test.dart`
- `docs/superpowers/specs/2026-04-15-appslider-keypad-input-design.md` (본 문서)

**변경 없음**
- `lib/core/widgets/map/zone_setting_widget.dart`
- `lib/test_widget_page.dart`
- 도메인/네트워크/실시간 레이어 전부
