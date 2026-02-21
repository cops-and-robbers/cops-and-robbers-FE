# CodeRabbit 리뷰 수정 계획

**Goal:** CodeRabbit이 지적한 6개 이슈를 수정한다. Major 2건 우선, Minor 4건 후속.

**Architecture:** 기존 유틸리티 함수에 에러 처리 추가, 호출부에서 async/await 보완, mounted 검사 추가.

**Tech Stack:** Flutter, share_plus, url_launcher

---

## 이슈 분류

| # | 심각도 | 파일 | 이슈 | 수정 방침 |
|---|--------|------|------|-----------|
| 1 | Minor | `docs/plans/*.md` | 헤딩 레벨 건너뜀 (h1→h3) | `### Task` → `## Task` |
| 2 | Major | `share_util.dart` | 에러 처리 미비, ShareResult 무시 | try-catch + debugPrint 추가 |
| 3 | Minor | `settings_page.dart:133,141` | launchExternalUrl Future 미처리 | `() async =>` + `await` 추가 |
| 4 | Major | `settings_page.dart:159-175` | signOut() 후 mounted 검사 누락 | `if (!mounted) return;` 추가 |
| 5 | Minor | `test_widget_page.dart:1019` | shareText Future 미처리 | `onConfirm`이 `VoidCallback`이라 async 불가 → share_util 내부에서 처리하므로 무시 가능 |
| 6 | Minor | `test_widget_page.dart:1027` | Clipboard.setData await 누락 | `async` + `await` 추가 |

---

## Task 1: share_util.dart 에러 처리 추가 (Major #2)

**Files:**

- Modify: `lib/core/utils/share_util.dart`

**변경 내용:**

```dart
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// 텍스트를 네이티브 공유 시트로 공유하는 유틸리티
///
/// OS 기본 공유 시트를 열어 [text]를 다른 앱으로 공유합니다.
/// [subject]는 이메일 등에서 제목으로 사용됩니다.
/// 플랫폼 예외 발생 시 디버그 로그를 남기고 무시합니다.
Future<void> shareText(String text, {String? subject}) async {
  try {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: subject),
    );
  } catch (e) {
    debugPrint('공유 실패: $e');
  }
}
```

**Commit:**

```bash
git add lib/core/utils/share_util.dart
git commit -m "fix: shareText에 플랫폼 예외 처리 추가 #99"
```

---

## Task 2: signOut() 후 mounted 검사 추가 (Major #4)

**Files:**

- Modify: `lib/features/settings/presentation/pages/settings_page.dart:159-175`

**변경 내용:**

```dart
                  if (result == true && mounted) {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (!mounted) return;
                    final authState = ref.read(authNotifierProvider);
                    messenger.clearSnackBars();
                    messenger.showSnackBar(
                      // ... (기존 코드 유지)
                    );
                  }
```

`await signOut()` 후 GoRouter 리다이렉트로 페이지가 언마운트될 수 있으므로 `if (!mounted) return;` 추가.

**Commit:**

```bash
git add lib/features/settings/presentation/pages/settings_page.dart
git commit -m "fix: signOut 후 mounted 검사 추가 #99"
```

---

## Task 3: launchExternalUrl Future 처리 (Minor #3)

**Files:**

- Modify: `lib/features/settings/presentation/pages/settings_page.dart:133,141`

**변경 내용:**

```dart
              // ── 개인정보 처리방침 ──
              _buildMenuItem(
                text: '개인정보 처리방침',
                onTap: () async => await launchExternalUrl(AppUrls.privacyPolicy),
              ),

              // ── 이용약관 ──
              _buildMenuItem(
                text: '이용약관',
                onTap: () async => await launchExternalUrl(AppUrls.termsOfService),
              ),
```

이 커밋은 Task 2와 같은 파일이므로 합산 커밋 가능.

---

## Task 4: Clipboard.setData await 추가 (Minor #6)

**Files:**

- Modify: `lib/test_widget_page.dart:1026`

**변경 내용:**

```dart
                      customContent: GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(
                            const ClipboardData(text: sessionCode),
                          );
                          messenger.clearSnackBars();
                          messenger.showSnackBar(...);
                        },
```

`onTap: ()` → `onTap: () async`, `Clipboard.setData` 앞에 `await` 추가.

**Commit:**

```bash
git add lib/test_widget_page.dart
git commit -m "fix: Clipboard.setData await 추가 #99"
```

---

## Task 5: 계획 문서 헤딩 레벨 수정 (Minor #1)

**Files:**

- Modify: `docs/plans/2026-02-21-invite-code-share.md`

**변경 내용:**

`### Task` → `## Task` (3곳)

---

## 미수정 항목 (Minor #5)

`test_widget_page.dart:1019`의 `shareText` Future 미처리 — `onConfirm`이 `VoidCallback?` 타입이라 async 콜백을 전달할 수 없음. `shareText` 내부에서 이미 try-catch로 에러를 처리하므로 (Task 1), fire-and-forget이 안전함. 수정 불필요.

---

## 최종 파일 변경 요약

| 파일 | 변경 유형 | 이슈 # |
|------|-----------|--------|
| `lib/core/utils/share_util.dart` | Modify | Major #2 |
| `lib/features/settings/presentation/pages/settings_page.dart` | Modify | Major #4, Minor #3 |
| `lib/test_widget_page.dart` | Modify | Minor #6 |
| `docs/plans/2026-02-21-invite-code-share.md` | Modify | Minor #1 |
