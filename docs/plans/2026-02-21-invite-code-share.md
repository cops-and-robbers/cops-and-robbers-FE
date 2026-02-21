# 초대코드 공유하기 구현 계획

**Goal:** `share_plus` 패키지를 사용하여 초대코드 다이얼로그의 "공유하기" 버튼에 네이티브 공유 시트(OS Share Sheet)를 연결한다. 기존 `Clipboard.setData` 임시 코드를 교체한다.

**Architecture:** `share_plus` 패키지를 추가하고, 공유 유틸리티 함수를 `core/utils/`에 생성한다. 초대코드 다이얼로그(`test_widget_page.dart`)와 세션 코드 카드(`session_code_card.dart`)에서 공유 기능을 사용할 수 있도록 한다.

**Tech Stack:** Flutter, share_plus ^12.0.1

---

## Task 1: share_plus 패키지 추가

**Files:**

- Modify: `pubspec.yaml:47-48` (외부 링크 그룹)

**Step 1: pubspec.yaml에 share_plus 추가**

`dependencies` 섹션의 `# 외부 링크` 그룹에 추가:

```yaml
  # 외부 링크
  url_launcher: ^6.3.2 # 외부 URL 브라우저 열기
  share_plus: ^12.0.1  # 네이티브 공유 시트
```

**Step 2: 의존성 설치**

Run: `flutter pub get`
Expected: 성공적으로 의존성 설치 완료

**Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: share_plus 패키지 추가"
```

---

## Task 2: 공유 유틸리티 함수 생성

**Files:**

- Create: `lib/core/utils/share_util.dart`

**Step 1: 유틸리티 함수 작성**

```dart
import 'package:share_plus/share_plus.dart';

/// 텍스트를 네이티브 공유 시트로 공유하는 유틸리티
///
/// OS 기본 공유 시트를 열어 [text]를 다른 앱으로 공유합니다.
/// [subject]는 이메일 등에서 제목으로 사용됩니다.
Future<void> shareText(String text, {String? subject}) async {
  await SharePlus.instance.share(
    ShareParams(text: text, subject: subject),
  );
}
```

**Step 2: Commit**

```bash
git add lib/core/utils/share_util.dart
git commit -m "feat: shareText 유틸리티 함수 추가"
```

---

## Task 3: 초대코드 다이얼로그에 공유 기능 연결

**Files:**

- Modify: `lib/test_widget_page.dart:2,1016-1021`

**Step 1: import 추가**

`test_widget_page.dart` 상단에 share_util import 추가:

```dart
import 'core/utils/share_util.dart';
```

**Step 2: onConfirm 콜백 교체**

기존 (test_widget_page.dart:1016-1021):

```dart
                      onConfirm: () {
                        // TODO: 나중에 공유 기능으로 교체
                        Clipboard.setData(
                          const ClipboardData(text: sessionCode),
                        );
                      },
```

수정:

```dart
                      onConfirm: () {
                        shareText(
                          '경찰과 도둑 게임에 참여하세요!\n참여코드: $sessionCode',
                          subject: '경찰과 도둑 초대코드',
                        );
                      },
```

**Step 3: 미사용 import 정리**

`flutter/services.dart`가 다른 곳에서 사용되지 않는지 확인 후, 사용처가 없으면 제거. (`Clipboard.setData` 제거로 인해 미사용 가능)

주의: `customContent` 내부의 `GestureDetector > onTap`에서 `Clipboard.setData`를 여전히 사용 중이므로 `flutter/services.dart` import는 유지.

**Step 4: Commit**

```bash
git add lib/test_widget_page.dart
git commit -m "feat: 초대코드 다이얼로그 공유하기 버튼에 share_plus 연결"
```

---

## 최종 파일 변경 요약

| 파일                              | 변경 유형 | 설명                           |
| --------------------------------- | --------- | ------------------------------ |
| `pubspec.yaml`                    | Modify    | share_plus 의존성 추가         |
| `lib/core/utils/share_util.dart`  | Create    | 공유 유틸리티 함수             |
| `lib/test_widget_page.dart`       | Modify    | 공유하기 버튼에 share_plus 연결 |

## 향후 확장 참고

- `SessionCodeCard`에도 공유 버튼 추가 시, `shareText` 유틸리티를 동일하게 사용
- 딥링크 기능 추가 시, 공유 텍스트에 앱 링크 URL 포함 가능
- `shareText`의 `ShareParams`에 `uri` 파라미터 추가로 앱 스토어 링크 첨부 가능
