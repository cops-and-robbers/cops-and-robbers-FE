# 개인정보 처리방침 & 이용약관 링크 구현 계획

**Goal:** 로그인 페이지 하단에 "로그인 시 개인정보 처리방침 및 이용약관에 동의합니다" 텍스트를 추가하고, 각 텍스트를 탭하면 외부 브라우저로 해당 링크를 여는 기능을 구현한다. 설정 페이지의 기존 TODO도 연결한다.

**Architecture:** `url_launcher` 패키지를 추가하고, URL 상수를 `core/constants/app_urls.dart`에 정의한다. 로그인 페이지에는 `RichText` + `TapGestureRecognizer`로 클릭 가능한 텍스트를 구현하고, 설정 페이지에서는 기존 메뉴 아이템의 TODO를 연결한다.

**Tech Stack:** Flutter, url_launcher, RichText/TextSpan, TapGestureRecognizer

---

### Task 1: url_launcher 패키지 추가

**Files:**

- Modify: `pubspec.yaml:17-60` (dependencies 섹션)

**Step 1: pubspec.yaml에 url_launcher 추가**

`dependencies` 섹션의 `# UI/UX 레이아웃` 그룹 아래에 추가:

```yaml
# 외부 링크
url_launcher: ^6.3.1 # 외부 URL 브라우저 열기
```

**Step 2: 의존성 설치**

Run: `flutter pub get`
Expected: 성공적으로 의존성 설치 완료

**Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: url_launcher 패키지 추가"
```

---

### Task 2: URL 상수 파일 생성

**Files:**

- Create: `lib/core/constants/app_urls.dart`

**Step 1: URL 상수 클래스 작성**

```dart
/// 앱 외부 링크 URL 상수
///
/// 개인정보 처리방침, 이용약관 등 외부 웹 링크를 관리합니다.
class AppUrls {
  AppUrls._();

  /// 개인정보 처리방침
  static const String privacyPolicy =
      'https://sites.google.com/view/copsandrobbers-pp/%ED%99%88';

  /// 이용약관
  static const String termsOfService =
      'https://sites.google.com/view/copsandrobbers-tos/%ED%99%88';
}
```

**Step 2: Commit**

```bash
git add lib/core/constants/app_urls.dart
git commit -m "feat: AppUrls 상수 클래스 추가 (개인정보 처리방침, 이용약관)"
```

---

### Task 3: URL 런처 유틸리티 함수 생성

**Files:**

- Create: `lib/core/utils/url_launcher_util.dart`

**Step 1: 유틸리티 함수 작성**

```dart
import 'package:url_launcher/url_launcher.dart';

/// 외부 URL을 브라우저에서 여는 유틸리티
///
/// [urlString]을 외부 브라우저에서 엽니다.
/// 열 수 없는 URL인 경우 무시합니다.
Future<void> launchExternalUrl(String urlString) async {
  final uri = Uri.parse(urlString);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

**Step 2: Commit**

```bash
git add lib/core/utils/url_launcher_util.dart
git commit -m "feat: launchExternalUrl 유틸리티 함수 추가"
```

---

### Task 4: 로그인 페이지에 약관 동의 텍스트 추가

**Files:**

- Modify: `lib/features/auth/presentation/pages/login_page.dart`

**Step 1: import 추가**

`login_page.dart` 상단에 3개 import 추가:

```dart
import 'package:flutter/gestures.dart';

import '../../../../core/constants/app_urls.dart';
import '../../../../core/utils/url_launcher_util.dart';
```

**Step 2: Column children에 약관 텍스트 위젯 추가**

`_LoginPageState`의 `build` 메서드 내 Column children에서, Apple 로그인 버튼 아래 (또는 Google 버튼 아래, 마지막 버튼 이후)에 다음을 추가:

```dart
                  // 약관 동의 안내 텍스트
                  SizedBox(height: AppSpacing.vertical16),
                  Padding(
                    padding: AppPadding.horizontal24,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.black400,
                        ),
                        children: [
                          const TextSpan(text: '로그인 시 '),
                          TextSpan(
                            text: '개인정보 처리방침',
                            style: AppTextStyles.tag_12.copyWith(
                              color: AppColors.black600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchExternalUrl(
                                    AppUrls.privacyPolicy,
                                  ),
                          ),
                          const TextSpan(text: ' 및 '),
                          TextSpan(
                            text: '이용약관',
                            style: AppTextStyles.tag_12.copyWith(
                              color: AppColors.black600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchExternalUrl(
                                    AppUrls.termsOfService,
                                  ),
                          ),
                          const TextSpan(text: '에 동의합니다.'),
                        ],
                      ),
                    ),
                  ),
```

이 코드는 `if (Platform.isIOS) ...[` 블록 닫힌 후, Column의 `]` 닫히기 전에 위치합니다.

**구체적 위치 (login_page.dart:213 근처):**

기존:

```dart
                  ],
                ],
              ),
            ),
```

수정 후:

```dart
                  ],

                  // 약관 동의 안내 텍스트
                  SizedBox(height: AppSpacing.vertical16),
                  Padding(
                    padding: AppPadding.horizontal24,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        // ... (위 코드)
                      ),
                    ),
                  ),
                ],
              ),
            ),
```

**Step 3: 앱 실행하여 시각적 확인**

Run: `flutter run`
Expected: 로그인 화면 하단 소셜 버튼 아래에 약관 텍스트 표시, 밑줄 친 텍스트 탭 시 외부 브라우저 열림

**Step 4: Commit**

```bash
git add lib/features/auth/presentation/pages/login_page.dart
git commit -m "feat: 로그인 페이지에 개인정보 처리방침/이용약관 동의 텍스트 추가"
```

---

### Task 5: 설정 페이지 개인정보 처리방침 & 이용약관 연결

**Files:**

- Modify: `lib/features/settings/presentation/pages/settings_page.dart`

**Step 1: import 추가**

```dart
import '../../../../core/constants/app_urls.dart';
import '../../../../core/utils/url_launcher_util.dart';
```

**Step 2: 개인정보 처리방침 메뉴 아이템 TODO 교체**

기존 (settings_page.dart:129-134):

```dart
              _buildMenuItem(
                text: '개인정보 처리방침',
                onTap: () {
                  // TODO: 개인정보 처리방침 페이지 이동
                },
              ),
```

수정:

```dart
              _buildMenuItem(
                text: '개인정보 처리방침',
                onTap: () => launchExternalUrl(AppUrls.privacyPolicy),
              ),
```

**Step 3: 이용약관 메뉴 아이템 추가**

개인정보 처리방침 Divider 아래에 이용약관 메뉴 추가:

```dart
              // ── 이용약관 ──
              _buildMenuItem(
                text: '이용약관',
                onTap: () => launchExternalUrl(AppUrls.termsOfService),
              ),

              const Divider(color: AppColors.black100, height: 1),
```

이 코드는 기존 `개인정보 처리방침` 아래 Divider와 `로그아웃` 사이에 위치합니다.

**Step 4: 앱 실행하여 시각적 확인**

Run: `flutter run`
Expected: 설정 > 개인정보 처리방침 탭 시 외부 브라우저 열림, 이용약관 메뉴도 동일 동작

**Step 5: Commit**

```bash
git add lib/features/settings/presentation/pages/settings_page.dart
git commit -m "feat: 설정 페이지 개인정보 처리방침/이용약관 외부 링크 연결"
```

---

### Task 6: 기존 테스트 업데이트

**Files:**

- Modify: `test/features/auth/presentation/pages/login_page_test.dart`

**Step 1: 약관 텍스트 표시 테스트 추가**

`LoginPage Layout Tests` 그룹 내에 추가:

```dart
    testWidgets('약관 동의 텍스트가 표시된다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));

      // Then - RichText로 약관 텍스트가 포함되어 있는지 확인
      expect(find.byType(RichText), findsWidgets);

      // 개인정보 처리방침 텍스트 확인
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('개인정보 처리방침'),
        ),
        findsOneWidget,
      );
    });
```

**Step 2: 테스트 실행**

Run: `flutter test test/features/auth/presentation/pages/login_page_test.dart`
Expected: 모든 테스트 PASS

**Step 3: Commit**

```bash
git add test/features/auth/presentation/pages/login_page_test.dart
git commit -m "test: 로그인 페이지 약관 동의 텍스트 테스트 추가"
```

---

## 최종 파일 변경 요약

| 파일                                                          | 변경 유형 | 설명                        |
| ------------------------------------------------------------- | --------- | --------------------------- |
| `pubspec.yaml`                                                | Modify    | url_launcher 의존성 추가    |
| `lib/core/constants/app_urls.dart`                            | Create    | 외부 링크 URL 상수          |
| `lib/core/utils/url_launcher_util.dart`                       | Create    | URL 런처 유틸리티 함수      |
| `lib/features/auth/presentation/pages/login_page.dart`        | Modify    | 약관 동의 RichText 추가     |
| `lib/features/settings/presentation/pages/settings_page.dart` | Modify    | 개인정보/이용약관 링크 연결 |
| `test/features/auth/presentation/pages/login_page_test.dart`  | Modify    | 약관 텍스트 테스트 추가     |

## 향후 확장 참고

- 설정 페이지에서 외부 브라우저 대신 앱 내 WebView로 전환 시, `launchExternalUrl` 대신 인앱 WebView 페이지로 라우팅하면 됨
- `AppUrls` 상수는 그대로 유지, 호출부만 변경하면 되는 구조
