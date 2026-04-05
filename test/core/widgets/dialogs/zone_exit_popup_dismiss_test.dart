import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 다이얼로그가 겹쳤을 때 특정 라우트만 안전하게 닫히는지 검증
///
/// 시나리오: 팝업 A(구역 이탈)가 떠 있는 상태에서 팝업 B(재연결 로딩)가 위에 쌓이면,
/// pop()은 최상단(B)을 닫지만, removeRoute()는 A만 정확히 제거한다.
void main() {
  group('팝업 dismiss 안전성', () {
    testWidgets('페이지 context로 pop하면 최상단 라우트가 닫힘 (버그 재현)', (tester) async {
      late BuildContext pageContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              pageContext = context;
              return const Scaffold(body: Text('Game Page'));
            },
          ),
        ),
      );

      // 팝업 A 표시 (구역 이탈 경고)
      showDialog(
        context: pageContext,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(title: Text('Zone Exit Warning')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Zone Exit Warning'), findsOneWidget);

      // 팝업 B 표시 (재연결 로딩 등)
      showDialog(
        context: pageContext,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(title: Text('Reconnecting...')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reconnecting...'), findsOneWidget);

      // 버그: 페이지 context로 pop → 팝업 B(최상단)가 닫힘
      Navigator.of(pageContext).pop();
      await tester.pumpAndSettle();

      // 팝업 A(구역 이탈)는 여전히 남아있음 — 의도와 반대
      expect(find.text('Zone Exit Warning'), findsOneWidget);
      // 팝업 B(재연결)가 닫힘 — 잘못된 라우트가 닫힌 것
      expect(find.text('Reconnecting...'), findsNothing);
    });

    testWidgets('removeRoute로 특정 팝업만 정확히 제거됨 (수정 방식)', (tester) async {
      late BuildContext pageContext;
      BuildContext? popupADialogContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              pageContext = context;
              return const Scaffold(body: Text('Game Page'));
            },
          ),
        ),
      );

      // 팝업 A 표시 — Builder로 다이얼로그 context 캡처
      showDialog(
        context: pageContext,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Builder(
            builder: (dialogContext) {
              popupADialogContext = dialogContext;
              return const Text('Zone Exit Warning');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Zone Exit Warning'), findsOneWidget);
      expect(popupADialogContext, isNotNull);

      // 팝업 B 표시 (위에 쌓임)
      showDialog(
        context: pageContext,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(title: Text('Reconnecting...')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reconnecting...'), findsOneWidget);

      // 수정: 팝업 A의 ModalRoute를 직접 제거
      final popupARoute = ModalRoute.of(popupADialogContext!);
      expect(popupARoute, isNotNull);
      Navigator.of(pageContext).removeRoute(popupARoute!);
      await tester.pumpAndSettle();

      // 팝업 A(구역 이탈)만 닫힘
      expect(find.text('Zone Exit Warning'), findsNothing);
      // 팝업 B(재연결)는 그대로 유지
      expect(find.text('Reconnecting...'), findsOneWidget);
    });
  });
}
