import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cops_and_robbers/core/network/connectivity_service.dart';
import 'package:cops_and_robbers/features/auth/presentation/pages/agreement_page.dart';
import 'package:cops_and_robbers/features/user/domain/entities/agreement_status_entity.dart';
import 'package:cops_and_robbers/features/user/domain/repositories/user_repository.dart';
import 'package:cops_and_robbers/features/user/presentation/providers/user_provider.dart';
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

Widget _wrap(WidgetTester tester) {
  // 테스트 화면 크기를 iPhone X 크기로 설정 (overflow 방지)
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3.0;

  return ProviderScope(
    overrides: [
      connectivityServiceProvider.overrideWith(
        (ref) => ConnectivityService(_FakeConnectivity()),
      ),
      userRepositoryProvider.overrideWith((ref) => _FakeUserRepository()),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const MaterialApp(home: AgreementPage()),
    ),
  );
}

void main() {
  testWidgets('초기 진입 시 타이틀 + 4개 항목 + 버튼이 보인다', (tester) async {
    await tester.pumpWidget(_wrap(tester));
    await tester.pumpAndSettle();

    expect(find.textContaining('약관에 동의'), findsOneWidget);
    expect(find.text('전체 동의하기'), findsOneWidget);
    expect(find.text('이용약관'), findsOneWidget);
    expect(find.text('개인정보 처리방침'), findsOneWidget);
    expect(find.text('위치정보 이용약관'), findsOneWidget);
    expect(find.text('마케팅 정보 수신'), findsOneWidget);
    expect(find.text('동의하고 시작하기'), findsOneWidget);
  });

  testWidgets('전체 동의 탭 시 모든 항목 체크 상태가 된다', (tester) async {
    await tester.pumpWidget(_wrap(tester));
    await tester.pumpAndSettle();

    await tester.tap(find.text('전체 동의하기'));
    await tester.pumpAndSettle();

    // 체크 아이콘(Icons.check)이 5개 이상 보여야 함 (전체 동의 + 4개 개별)
    expect(find.byIcon(Icons.check), findsAtLeast(5));
  });
}
