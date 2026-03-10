# Review-Design-System: Constants & Design System Compliance

앱 상수(AppColors, AppSpacing, AppPadding, AppRadius, AppTextStyles) 미사용, 하드코딩 위반, 공통 위젯 미사용을 찾아냅니다.

## 리뷰 범위 결정

**시작 전 반드시 실행:**
```bash
git diff --name-only main...HEAD -- '*.dart'
```
변경된 `.dart` 파일 목록을 기준으로 리뷰합니다. 변경 파일이 없으면 전체 `lib/features/` 대상.

---

## 상수 파일 참조

리뷰 시작 전 반드시 다음 파일들을 읽어서 사용 가능한 상수 목록을 파악:

1. **`lib/core/constants/app_colors.dart`** — AppColors 클래스
2. **`lib/core/constants/spacing_and_radius.dart`** — AppSpacing, AppPadding, AppRadius 클래스
3. **`lib/core/constants/text_styles.dart`** — AppTextStyles 클래스
4. **`lib/core/constants/app_gradients.dart`** — AppGradients 클래스

---

## 검사 항목

### 1. 하드코딩된 색상 탐지

**검색 패턴:**
- `Color(0x` — 직접 색상 코드 사용
- `Colors.` — Material Colors 직접 사용 (`Colors.white`, `Colors.transparent` 제외 가능)
- `Color.fromRGBO`, `Color.fromARGB` — 직접 색상 생성
- `.withOpacity(` — AppColors에 이미 정의된 투명도 조합 확인

**예외 (허용):**
- `Colors.white` (AppColors.textPrimary와 동일하나 관용적 사용)
- `Colors.transparent`
- 그라데이션 내부 색상 (AppGradients에 없는 경우)
- 테스트 파일

**출력 형식:**
```markdown
### 하드코딩 색상

| # | 파일:라인 | 현재 코드 | 대체 상수 | 확신도 |
|---|----------|----------|----------|--------|
| 1 | home.dart:45 | `Color(0xFF2196F3)` | `AppColors.primary` | 확실 |
| 2 | card.dart:23 | `Colors.blue` | `AppColors.primary` | 높음 |
| 3 | badge.dart:67 | `Color(0xFF1A1F3A)` | `AppColors.spaceSurface` | 확실 |
```

---

### 2. 하드코딩된 간격/패딩/라운드 탐지

**검색 패턴 — 간격(Spacing):**
- `SizedBox(height:` 또는 `SizedBox(width:` 에서 `AppSpacing.` 대신 숫자 직접 사용
- 매칭 가능한 값: 4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64
- 매칭 불가한 값(2, 6, 10, 14 등)은 허용

**검색 패턴 — 패딩(Padding):**
- `EdgeInsets.all(` — AppPadding.all4~all24 대체 가능한지 확인
- `EdgeInsets.symmetric(horizontal:` — AppPadding.horizontal8~24 대체 가능한지 확인
- `EdgeInsets.symmetric(vertical:` — AppPadding.vertical8~24 대체 가능한지 확인
- `EdgeInsets.symmetric(horizontal: 16, vertical: 12)` → `AppPadding.listItemPadding`
- `EdgeInsets.symmetric(horizontal: 20, vertical: 16)` → `AppPadding.screenPadding`
- `EdgeInsets.symmetric(horizontal: 24, vertical: 12)` → `AppPadding.buttonPadding`

**검색 패턴 — 라운드(Radius):**
- `BorderRadius.circular(` — AppRadius 상수 대체 가능한지 확인
  - 4 → `AppRadius.small`, 8 → `AppRadius.medium`, 12 → `AppRadius.large`
  - 16 → `AppRadius.xlarge`, 24 → `AppRadius.xxlarge`, 100 → `AppRadius.chip`
- `BorderRadius.vertical(top: Radius.circular(16` → `AppRadius.modal`

**예외 (허용):**
- 매칭 상수가 없는 값 (예: `SizedBox(height: 2.h)`)
- 아이콘 크기, 폰트 크기(`.sp`), 위젯 고정 치수, blur, border width
- `.g.dart`, `.freezed.dart` 생성 파일
- `EdgeInsets.fromLTRB`, `EdgeInsets.only` (조합형)

**출력 형식:**
```markdown
### 하드코딩 간격/패딩/라운드

| # | 파일:라인 | 유형 | 현재 코드 | 대체 상수 |
|---|----------|------|----------|----------|
| 1 | screen.dart:34 | spacing | `SizedBox(height: 16.h)` | `AppSpacing.s16` |
| 2 | card.dart:56 | padding | `EdgeInsets.all(16.w)` | `AppPadding.all16` |
| 3 | dialog.dart:78 | radius | `BorderRadius.circular(12.r)` | `AppRadius.large` |
```

---

### 3. 하드코딩된 TextStyle 탐지

**사전 준비:** `lib/core/constants/text_styles.dart`를 읽고, 정의된 모든 스타일의 `fontSize`와 `fontWeight` 조합 목록을 파악한다.

**검색 패턴:**
- `TextStyle(` — `AppTextStyles.`를 사용하지 않고 직접 TextStyle을 생성하는 경우
- `.copyWith(fontSize:)` — AppTextStyles에 해당 크기+weight 조합이 이미 존재하면 위반
- `fontFamily:` — 폰트를 직접 지정하는 경우 (AppTextStyles를 사용해야 함)
- `.copyWith(fontWeight:)` — AppTextStyles에 해당 weight+size 조합이 이미 존재하면 위반

**판단 기준:** `text_styles.dart`에서 파악한 fontSize+fontWeight 조합과 동일한 조합이 직접 생성되어 있으면 위반.

**예외 (허용):**
- `.copyWith(color:)` — 색상 변경은 정상 사용
- `.copyWith(decoration:)` — 밑줄 등 장식 변경은 정상 사용
- `.copyWith(overflow:)`, `.copyWith(height:)` — 레이아웃 조정은 허용
- 생성된 파일 (`.g.dart`, `.freezed.dart`)
- 테스트 파일
- `TextStyle(fontSize: XX.sp)` — 매칭되는 AppTextStyles가 없는 크기/weight 조합

**출력 형식:**
```markdown
### 하드코딩 텍스트 스타일

| # | 파일:라인 | 현재 코드 | 대체 상수 | 확신도 |
|---|----------|----------|----------|--------|
| 1 | dialog.dart:45 | `TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600)` | `AppTextStyles.heading_20` | 확실 |
| 2 | card.dart:67 | `TextStyle(fontSize: 14.sp, fontFamily: 'Pretendard-Medium')` | `AppTextStyles.paragraph_14` | 확실 |
```

---

### 4. 공통 위젯 미사용 탐지

**검사 대상 — 공통 위젯이 존재하는데 직접 구현한 경우:**

| 공통 위젯 | 대신 사용될 수 있는 직접 구현 패턴 |
|----------|-------------------------------|
| `AppButton` | `ElevatedButton`, `TextButton`, `InkWell`+스타일링 조합으로 커스텀 버튼 |
| `AppTextField` | `TextField`, `TextFormField` 직접 스타일링 |
| `AppCard` | `Container`+`BoxDecoration`으로 카드 모양 직접 구현 |
| `AppDialog` | `showDialog`+`AlertDialog` 직접 구현 |
| `AppLoading` | `CircularProgressIndicator` 직접 사용 |
| `AppSnackBar` | `ScaffoldMessenger.of(context).showSnackBar` 직접 사용 |
| `AppEmptyState` / `SpaceEmptyState` | 빈 상태 UI 직접 구현 |
| `SpaceBackground` | Scaffold 배경에 SpaceBackground 미적용 |

**출력 형식:**
```markdown
### 공통 위젯 미사용 (4)

| # | 파일:라인 | 현재 코드 | 대체 공통 위젯 | 심각도 |
|---|----------|----------|--------------|--------|
| 1 | form.dart:23 | `TextField(decoration: ...)` | `AppTextField` | Minor |
| 2 | list.dart:89 | `Center(child: Text('없음'))` | `SpaceEmptyState` | Minor |
| 3 | page.dart:12 | Scaffold 배경 없음 | `SpaceBackground` 추가 | Major |
```

---

### 5. 미사용 상수 역방향 탐지

AppColors, AppSpacing, AppPadding, AppRadius, AppTextStyles에 정의된 상수 중 프로젝트 어디에서도 사용되지 않는 것:

```bash
# 예시: AppColors의 각 상수가 lib/ 내에서 참조되는지 검사
grep -r "AppColors.accentPink" lib/ --include="*.dart" | grep -v ".g.dart" | grep -v ".freezed.dart"
```

**출력 형식:**
```markdown
### 미사용 앱 상수

| # | 상수 클래스 | 상수명 | 참조 횟수 | 비고 |
|---|-----------|--------|----------|------|
| 1 | AppColors | accentPinkDark | 0 | 제거 고려 |
| 2 | AppRadius | snackbar | 0 | 제거 고려 |
```

---

## 실행 절차

1. 상수 파일 4개 읽기 (app_colors, spacing_and_radius, text_styles, app_gradients)
2. 변경 파일 목록 추출
3. 각 변경 파일에서 하드코딩 패턴 Grep 검색
4. 공통 위젯 미사용 패턴 검사
5. 역방향 미사용 상수 검사
6. 결과 종합 출력

## 최종 출력

```markdown
# Review-2 결과: Constants & Design System Compliance

**대상 파일**: N개
**검사 일시**: YYYY-MM-DD

## 요약
- 하드코딩 색상: X건
- 하드코딩 간격/패딩/라운드: Y건
- 하드코딩 텍스트 스타일: T건
- 공통 위젯 미사용: Z건
- 미사용 앱 상수: W건
- **총 이슈**: N건

## 상세 결과
[위 카테고리별 테이블]

## 자동 수정 가능 항목
[확신도 높은 하드코딩 → 상수 교체 목록 — 사용자 승인 후 일괄 교체 가능]
```
