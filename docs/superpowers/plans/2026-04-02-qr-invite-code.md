# QR 코드 방 입장 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 대기방에서 초대코드를 QR로 표시하고, 홈 화면에서 QR 스캔으로 방에 참가할 수 있게 한다.

**Architecture:** 기존 `QrScannerPage`를 제네릭 콜백 방식으로 확장하여 체포용/초대코드용 공용으로 사용. 초대코드 QR 데이터는 `{"inviteCode": "A1B2C3"}` 형식. `AppTextField`의 기존 `suffixIcon` 파라미터를 활용하여 카메라 아이콘을 입력 필드 내부에 배치.

**Tech Stack:** Flutter, qr_flutter (QR 생성), mobile_scanner (QR 스캔)

---

## 파일 구조

| 파일 | 변경 유형 | 역할 |
|------|-----------|------|
| `lib/features/game/presentation/widgets/qr_scanner_page.dart` | 수정 | 제네릭 콜백 방식으로 확장 (title, onParse) |
| `lib/features/game/presentation/pages/game_page.dart` | 수정 | 체포 스캐너 호출부를 새 API에 맞게 수정 |
| `lib/features/session/presentation/pages/waiting_room_page.dart` | 수정 | 초대코드 다이얼로그에 QR 이미지 추가 |
| `lib/features/session/presentation/pages/home_page.dart` | 수정 | 방 참여 다이얼로그에 카메라 아이콘 + QR 스캔 자동 참가 |

---

### Task 1: QrScannerPage 제네릭화

**Files:**
- Modify: `lib/features/game/presentation/widgets/qr_scanner_page.dart`

- [ ] **Step 1: QrScannerPage에 title, onParse 파라미터 추가**

```dart
class QrScannerPage<T> extends StatefulWidget {
  const QrScannerPage({
    required this.title,
    required this.onParse,
    super.key,
  });

  /// 상단 안내 텍스트
  final String title;

  /// QR 원본 문자열 → 파싱 결과 (null이면 무시)
  final T? Function(String rawValue) onParse;

  @override
  State<QrScannerPage<T>> createState() => _QrScannerPageState<T>();
}
```

기존 `_parseQrData` 메서드 제거. `_onDetect`에서 `widget.onParse(rawValue)` 호출로 변경.
`Navigator.of(context).pop(result)` 에서 result 타입이 T.
상단 안내 텍스트를 `widget.title`로 교체.

- [ ] **Step 2: flutter analyze 통과 확인**

Run: `flutter analyze lib/features/game/presentation/widgets/qr_scanner_page.dart`

- [ ] **Step 3: 커밋**

```
feat : QrScannerPage 제네릭 콜백 방식으로 확장 #207
```

---

### Task 2: game_page.dart 체포 스캐너 호출부 수정

**Files:**
- Modify: `lib/features/game/presentation/pages/game_page.dart:1117-1120`

- [ ] **Step 1: _openQrScanner의 QrScannerPage 호출을 새 API로 변경**

기존:
```dart
final participantId = await Navigator.push<int>(
  context,
  MaterialPageRoute(builder: (_) => const QrScannerPage()),
);
```

변경:
```dart
final participantId = await Navigator.push<int>(
  context,
  MaterialPageRoute(
    builder: (_) => QrScannerPage<int>(
      title: '도둑의 수배 QR을 스캔하세요',
      onParse: (rawValue) {
        try {
          final json = jsonDecode(rawValue) as Map<String, dynamic>;
          final pid = json['pid'];
          if (pid is int) return pid;
          if (pid is num) return pid.toInt();
          return null;
        } catch (_) {
          return null;
        }
      },
    ),
  ),
);
```

`dart:convert` import 추가 (이미 있으면 확인).

- [ ] **Step 2: flutter analyze 통과 확인**

Run: `flutter analyze lib/features/game/presentation/pages/game_page.dart`

- [ ] **Step 3: 커밋**

```
refactor : 체포 스캐너 호출을 QrScannerPage 새 API에 맞게 수정 #207
```

---

### Task 3: 초대코드 다이얼로그에 QR 이미지 추가

**Files:**
- Modify: `lib/features/session/presentation/pages/waiting_room_page.dart:719-785`

- [ ] **Step 1: _showInviteCodeDialog의 customContent에 QR 이미지 추가**

기존 `customContent`(GestureDetector + Row(코드 + 복사아이콘)) 위에 QR 이미지 삽입.
전체 `customContent`를 Column으로 감싸기:

```dart
customContent: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    // QR 코드 이미지
    Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.xlarge,
      ),
      child: QrImageView(
        data: jsonEncode({'inviteCode': code}),
        version: QrVersions.auto,
        size: 200.w,
        backgroundColor: AppColors.white,
      ),
    ),
    SizedBox(height: AppSpacing.vertical16),
    // 기존 코드 + 복사 아이콘 (GestureDetector 그대로)
    GestureDetector(
      onTap: () async { ... 기존 복사 로직 그대로 ... },
      child: Container( ... 기존 코드 표시 UI 그대로 ... ),
    ),
  ],
),
```

import 추가:
```dart
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
```

- [ ] **Step 2: flutter analyze 통과 확인**

Run: `flutter analyze lib/features/session/presentation/pages/waiting_room_page.dart`

- [ ] **Step 3: 커밋**

```
feat : 초대코드 공유 다이얼로그에 QR 코드 이미지 추가 #207
```

---

### Task 4: 홈 화면 방 참여 다이얼로그에 카메라 아이콘 + QR 스캔 자동 참가

**Files:**
- Modify: `lib/features/session/presentation/pages/home_page.dart:215-310`

- [ ] **Step 1: AppTextField에 suffixIcon으로 카메라 아이콘 추가**

`_showJoinRoomDialogInternal`의 `AppTextField` 수정:

```dart
AppTextField(
  controller: codeController,
  hintText: '참여코드를 입력하세요',
  maxLength: 6,
  inputFormatters: [_UpperCaseFormatter()],
  suffixIcon: GestureDetector(
    onTap: () async {
      // 현재 다이얼로그 닫기
      Navigator.of(context).pop();

      // QR 스캐너 열기
      final inviteCode = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => QrScannerPage<String>(
            title: '초대코드 QR을 스캔하세요',
            onParse: (rawValue) {
              try {
                final json = jsonDecode(rawValue) as Map<String, dynamic>;
                final code = json['inviteCode'];
                if (code is String && code.length == 6) return code;
                return null;
              } catch (_) {
                return null;
              }
            },
          ),
        ),
      );

      if (inviteCode == null || !context.mounted) return;

      // 스캔 성공 → 자동 방 참가 로직 실행
      // 기존 onConfirm 내부의 참가 로직을 별도 메서드로 추출하여 재사용
      _joinRoom(context, ref, inviteCode);
    },
    child: Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: SvgPicture.asset(
        'assets/icons/icon_camera.svg',
        width: 24.w,
        height: 24.w,
        colorFilter: const ColorFilter.mode(
          AppColors.black300,
          BlendMode.srcIn,
        ),
      ),
    ),
  ),
),
```

- [ ] **Step 2: 방 참가 로직을 별도 메서드로 추출**

기존 `onConfirm` 내부의 참가 로직(API 호출 → 네비게이션)을 `_joinRoom(BuildContext, WidgetRef, String code)` 메서드로 추출.
`_showJoinRoomDialogInternal`의 `onConfirm`에서도 이 메서드를 호출하도록 변경.

```dart
Future<void> _joinRoom(BuildContext context, WidgetRef ref, String code) async {
  // 기존 onConfirm 내부 로직 (로딩 → API 호출 → 에러 처리 → 네비게이션)
  final dialogCloseStart = DateTime.now();

  await AppPopup.showRandomLoading(
    context: context,
    category: LoadingCategory.joinRoom,
  );

  JoinGameResponse? response;
  try {
    response = await ref.read(joinGameProvider(inviteCode: code).future);
  } on DioException catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop();
      final apiError = ApiErrorResponse.tryParse(e.response?.data);
      final message = apiError?.detail ?? '참여에 실패했습니다. 초대 코드를 확인해주세요.';
      AppSnackbar.show(
        context,
        message: message,
        backgroundColor: AppColors.red,
      );
    }
    return;
  }

  if (context.mounted) {
    Navigator.of(context).pop();
  }

  if (response != null && context.mounted) {
    final myNickname = ref.read(authNotifierProvider).value?.nickname ?? '';
    ref
        .read(gameParticipantNotifierProvider.notifier)
        .setGameInfo(
          gameId: response.gameId,
          nickname: myNickname,
          participantId: response.participantId,
          isHost: false,
        );
    final elapsed = DateTime.now().difference(dialogCloseStart);
    final remaining =
        DialogAnimation.duration +
        const Duration(milliseconds: 32) -
        elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    if (context.mounted) {
      context.go(
        '${RoutePaths.waitingRoomWithId('${response.gameId}')}?inviteCode=$code',
      );
    }
  }
}
```

import 추가:
```dart
import 'dart:convert';
import '../../../game/presentation/widgets/qr_scanner_page.dart';
```

- [ ] **Step 3: flutter analyze 통과 확인**

Run: `flutter analyze lib/features/session/presentation/pages/home_page.dart`

- [ ] **Step 4: 커밋**

```
feat : 방 참여 다이얼로그에 QR 스캔 기능 추가 #207
```
