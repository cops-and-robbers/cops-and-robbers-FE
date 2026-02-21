# 닉네임 입력 필드 랜덤값 및 힌트 텍스트 문구 통일 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 닉네임 설정 페이지의 placeholder 텍스트를 백엔드 랜덤 닉네임 생성 패턴(형용사+괴도+숫자)과 동일한 톤앤매너로 통일하고, 닉네임 관련 상수를 공통 관리 구조로 개선한다.

**Architecture:** 닉네임 관련 문자열 상수를 별도 파일(`nickname_constants.dart`)로 분리하여 placeholder와 랜덤 닉네임 예시를 동일 소스에서 관리한다. `nickname_setup_page.dart`는 이 상수를 참조하도록 수정한다. 추후 톤 변경 시 한 곳만 수정하면 된다.

**Tech Stack:** Flutter/Dart, 기존 프로젝트 구조 활용

**Issue:** [#89](https://github.com/cops-and-robbers/cops-and-robbers-FE/issues/89)

**Branch:** `20260214_#89_닉네임_입력_필드_랜덤값_및_힌트_텍스트_문구_통일`

**Commit Message Convention:** `닉네임 입력 필드 랜덤값 및 힌트 텍스트 문구 통일 : feat : {변경 사항} https://github.com/cops-and-robbers/cops-and-robbers-FE/issues/89`

---

## 현재 상태 분석

### 문제점
- 백엔드 랜덤 닉네임: `"민첩한괴도5308"`, `"집요한괴도4053"` (형용사 + 괴도 + 숫자4자리)
- placeholder 텍스트: `"포근포근백설기"` (전혀 다른 톤 - 귀여운/따뜻한 느낌)
- 톤앤매너 불일치로 UX 혼란 발생

### 해결 방향
1. placeholder를 백엔드 닉네임 패턴과 동일한 톤으로 변경 (예: `"용감한괴도1234"`)
2. 닉네임 관련 상수를 별도 파일로 분리하여 공통 관리

### 영향 범위
- `lib/core/constants/nickname_constants.dart` (신규 생성)
- `lib/features/auth/presentation/pages/nickname_setup_page.dart` (placeholder 수정)

---

## Task 1: 닉네임 상수 파일 생성

**Files:**
- Create: `lib/core/constants/nickname_constants.dart`

**Step 1: 상수 파일 작성**

```dart
/// 닉네임 관련 상수
///
/// 백엔드 랜덤 닉네임 생성 패턴과 동일한 톤앤매너를 유지하기 위해
/// placeholder, 예시 문구 등을 한 곳에서 관리합니다.
///
/// 백엔드 닉네임 생성 패턴: 형용사 + 괴도 + 숫자4자리
/// 예: "민첩한괴도5308", "집요한괴도4053"
class NicknameConstants {
  NicknameConstants._();

  /// 닉네임 입력 필드 placeholder 텍스트
  ///
  /// 백엔드 랜덤 닉네임 패턴(형용사+괴도+숫자)과 동일한 톤앤매너로 작성
  static const String hintText = '용감한괴도1234';

  /// 닉네임 최대 길이
  static const int maxLength = 10;

  /// 닉네임 최소 길이
  static const int minLength = 1;
}
```

**Step 2: Commit**

```bash
git add lib/core/constants/nickname_constants.dart
git commit -m "$(cat <<'EOF'
닉네임 입력 필드 랜덤값 및 힌트 텍스트 문구 통일 : feat : 닉네임 상수 파일 생성 https://github.com/cops-and-robbers/cops-and-robbers-FE/issues/89
EOF
)"
```

---

## Task 2: nickname_setup_page.dart placeholder 수정

**Files:**
- Modify: `lib/features/auth/presentation/pages/nickname_setup_page.dart:270` (hintText)
- Modify: `lib/features/auth/presentation/pages/nickname_setup_page.dart:271` (maxLength)

**Step 1: import 추가 및 placeholder/maxLength 변경**

`nickname_setup_page.dart` 상단에 import 추가:
```dart
import '../../../../core/constants/nickname_constants.dart';
```

270번 라인의 `_buildNicknameInputRow()` 메서드 내 `AppTextField` 수정:

변경 전:
```dart
AppTextField(
  hintText: '포근포근백설기',
  controller: _nicknameController,
  maxLength: 10,
```

변경 후:
```dart
AppTextField(
  hintText: NicknameConstants.hintText,
  controller: _nicknameController,
  maxLength: NicknameConstants.maxLength,
```

**Step 2: 앱 빌드 확인**

Run: `flutter analyze`
Expected: No errors

**Step 3: Commit**

```bash
git add lib/features/auth/presentation/pages/nickname_setup_page.dart
git commit -m "$(cat <<'EOF'
닉네임 입력 필드 랜덤값 및 힌트 텍스트 문구 통일 : feat : placeholder를 백엔드 닉네임 패턴과 통일 https://github.com/cops-and-robbers/cops-and-robbers-FE/issues/89
EOF
)"
```

---

## Task 3: 최종 검증

**Step 1: flutter analyze 실행**

Run: `flutter analyze`
Expected: No issues found

**Step 2: 전체 빌드 확인**

Run: `flutter build apk --debug` (또는 해당 환경 빌드)
Expected: BUILD SUCCESSFUL

**Step 3: 변경사항 최종 확인**

Run: `git diff main`

확인 사항:
- [ ] `NicknameConstants.hintText`가 `'용감한괴도1234'`로 설정
- [ ] `nickname_setup_page.dart`에서 `NicknameConstants.hintText` 참조
- [ ] `nickname_setup_page.dart`에서 `NicknameConstants.maxLength` 참조
- [ ] 하드코딩된 `'포근포근백설기'` 문자열 제거 확인
- [ ] 하드코딩된 `10` (maxLength) 제거 확인

---

## 변경 파일 요약

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `lib/core/constants/nickname_constants.dart` | 신규 생성 | 닉네임 관련 상수 (hintText, maxLength, minLength) |
| `lib/features/auth/presentation/pages/nickname_setup_page.dart` | 수정 | placeholder를 NicknameConstants 참조로 변경 |
