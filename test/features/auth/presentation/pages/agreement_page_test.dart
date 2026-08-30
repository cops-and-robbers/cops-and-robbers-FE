import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cops_and_robbers/core/network/connectivity_service.dart';
import 'package:cops_and_robbers/core/network/dio_client.dart';
import 'package:cops_and_robbers/features/auth/presentation/pages/agreement_page.dart';
import 'package:cops_and_robbers/features/user/domain/entities/agreement_status_entity.dart';
import 'package:cops_and_robbers/features/user/domain/repositories/user_repository.dart';
import 'package:cops_and_robbers/features/user/presentation/providers/user_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [
    ConnectivityResult.wifi,
  ];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<void> updateAgreements({required bool marketing}) async {}

  @override
  Future<AgreementStatusEntity> getAgreements() => throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap(WidgetTester tester, {bool blockedByServer = false}) {
  // 테스트 화면 크기를 iPhone X 크기로 설정 (overflow 방지)
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3.0;

  return ProviderScope(
    overrides: [
      connectivityServiceProvider.overrideWith(
        (ref) => ConnectivityService(_FakeConnectivity()),
      ),
      userRepositoryProvider.overrideWith((ref) => _FakeUserRepository()),
      requiredTermsBlockedProvider.overrideWith((ref) => blockedByServer),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AgreementPage(),
      ),
    ),
  );
}

/// 스낵바는 3초 뒤 스스로 사라지는 Future.delayed 를 들고 있어
/// pumpAndSettle 이 곧바로 끝나지 않는다. 진입 애니메이션까지만 돌려 검증한다.
Future<void> _settleSnackbar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// 검증 뒤 남은 dismiss 타이머와 퇴장 애니메이션을 흘려보낸다 (pending timer 방지).
Future<void> _drainSnackbar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('초기 진입 시 타이틀 + 4개 항목 + 버튼이 보인다', (tester) async {
    await tester.pumpWidget(_wrap(tester));
    await tester.pumpAndSettle();

    expect(find.textContaining('약관에 동의'), findsOneWidget);
    expect(find.text('전체 동의'), findsOneWidget);
    expect(find.text('이용약관'), findsOneWidget);
    expect(find.text('개인정보 처리방침'), findsOneWidget);
    expect(find.text('위치정보 이용약관'), findsOneWidget);
    expect(find.text('마케팅 정보 수신'), findsOneWidget);
    expect(find.text('동의하고 시작하기'), findsOneWidget);
  });

  testWidgets('전체 동의 탭 시 모든 항목 체크 상태가 된다', (tester) async {
    await tester.pumpWidget(_wrap(tester));
    await tester.pumpAndSettle();

    await tester.tap(find.text('전체 동의'));
    await tester.pumpAndSettle();

    // 체크 아이콘(Icons.check)이 5개 이상 보여야 함 (전체 동의 + 4개 개별)
    expect(find.byIcon(Icons.check), findsAtLeast(5));
  });

  testWidgets('shows_the_reason_when_server_blocked_the_user', (tester) async {
    await tester.pumpWidget(_wrap(tester, blockedByServer: true));
    await _settleSnackbar(tester);

    expect(find.text('필수 약관은 모두 동의해야 해요'), findsOneWidget);

    await _drainSnackbar(tester);
  });

  testWidgets('shows_no_reason_when_entering_the_signup_flow', (tester) async {
    await tester.pumpWidget(_wrap(tester));
    await tester.pumpAndSettle();

    expect(find.text('필수 약관은 모두 동의해야 해요'), findsNothing);
  });

  testWidgets('clears_the_flag_when_the_reason_was_shown', (tester) async {
    await tester.pumpWidget(_wrap(tester, blockedByServer: true));
    await _settleSnackbar(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AgreementPage)),
    );
    expect(container.read(requiredTermsBlockedProvider), isFalse);

    await _drainSnackbar(tester);
  });
}
