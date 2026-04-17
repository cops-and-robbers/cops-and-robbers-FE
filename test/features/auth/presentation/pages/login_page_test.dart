import 'package:cops_and_robbers/core/widgets/buttons/social_login_button.dart';
import 'package:cops_and_robbers/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// 테스트용 ProviderScope로 감싼 MaterialApp 생성
  ///
  /// 테스트 화면 크기를 실제 기기 크기로 설정하여 overflow 방지
  Widget createTestableWidget(WidgetTester tester) {
    // 테스트 화면 크기를 iPhone X 크기로 설정
    tester.view.physicalSize = const Size(1125, 2436); // iPhone X 해상도
    tester.view.devicePixelRatio = 3.0; // iPhone X DPR

    return ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => const MaterialApp(home: LoginPage()),
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('로고와 Google 로그인 버튼이 표시된다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));

      // Then - 로고 확인
      final logoFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/app_icon.png',
      );
      expect(logoFinder, findsOneWidget);

      // Then - Google 로그인 버튼 확인
      expect(find.byType(GoogleLoginButton), findsOneWidget);
    });

    testWidgets('AppBar가 표시되지 않는다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));

      // Then - AppBar 없음
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('Stack 레이아웃을 사용한다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));

      // Then - Stack 위젯 존재 (여러 개일 수 있음)
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('SafeArea가 적용되어 있다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));

      // Then - SafeArea 존재
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('초기 로드 시 기본 UI가 표시된다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));

      // Then - 로고와 버튼이 표시됨
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(GoogleLoginButton), findsOneWidget);
    });
  });

  group('LoginPage Lifecycle Tests', () {
    testWidgets('LoginPage가 정상적으로 초기화된다', (tester) async {
      // Given & When
      await tester.pumpWidget(createTestableWidget(tester));

      // Then - 위젯이 렌더링되었는지 확인
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('LoginPage가 정상적으로 dispose된다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));
      expect(find.byType(LoginPage), findsOneWidget);

      // When - 위젯 제거
      await tester.pumpWidget(Container());

      // Then - 메모리 누수 없이 정리됨 (테스트 통과하면 성공)
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('여러 번 빌드해도 안정적이다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));

      // When - 여러 번 rebuild
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Then - 여전히 정상적으로 렌더링
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(GoogleLoginButton), findsOneWidget);
    });
  });

  group('LoginPage Button Interaction Tests', () {
    testWidgets('Google 로그인 버튼을 탭할 수 있다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));

      // When - Google 버튼 찾기
      final googleButton = find.byType(GoogleLoginButton);
      expect(googleButton, findsOneWidget);

      // Then - 탭 가능한지 확인 (실제 탭은 Provider 모킹 필요)
      expect(
        tester.widget<GoogleLoginButton>(googleButton).onPressed,
        isNotNull,
      );
    });

    testWidgets('버튼에 onPressed 핸들러가 등록되어 있다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));

      // When - Google 버튼 찾기
      final googleButton = find.byType(GoogleLoginButton);

      // Then - onPressed가 null이 아님 (클릭 가능)
      final widget = tester.widget<GoogleLoginButton>(googleButton);
      expect(widget.onPressed, isNotNull);
      expect(widget.isLoading, false); // 초기 상태는 로딩 아님
    });
  });

  group('LoginPage Layout Tests', () {
    testWidgets('로고와 버튼이 Column으로 배치된다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));

      // Then - Column 위젯 존재
      final columnFinder = find.byWidgetPredicate(
        (widget) => widget is Column && widget.mainAxisSize == MainAxisSize.min,
      );
      expect(columnFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('로고와 버튼이 중앙에 정렬된다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));

      // Then - Center 위젯 존재
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('로고 이미지가 표시된다', (tester) async {
      // Given
      await tester.pumpWidget(createTestableWidget(tester));

      // Then - 로고 이미지 존재
      final logoFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/app_icon.png',
      );
      expect(logoFinder, findsOneWidget);
    });

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

      // 이용약관 텍스트 확인
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText && widget.text.toPlainText().contains('이용약관'),
        ),
        findsOneWidget,
      );
    });
  });
}
