import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cops_and_robbers/core/services/permission/game_entry_gate.dart';
import 'package:cops_and_robbers/core/services/permission/location_permission_messages.dart';
import 'package:cops_and_robbers/features/session/presentation/game_creation_entry.dart';
import 'package:cops_and_robbers/router/route_paths.dart';

/// 게이트 결과를 주입하는 페이크 — `deeplink_join_page_test` 와 같은 방식.
class _FakeGate implements GameEntryGate {
  _FakeGate(this.result);
  final bool result;
  bool called = false;

  @override
  Future<bool> ensure({
    required BuildContext context,
    required LocationPermissionContext locationContext,
  }) async {
    called = true;
    return result;
  }
}

void main() {
  /// 초안 저장 키 — `SessionDraftStorageService._key` 와 같은 값.
  const draftKey = 'session_creation_draft';

  /// 어린이대공원역 근처에서 한 번 잡힌 뒤 남아 있는 초안 (#525 재현용).
  final staleDraft = jsonEncode({
    'playgroundCenter': {'latitude': 37.5480, 'longitude': 127.0810},
    'playgroundRadiusInMeters': 500.0,
  });

  /// 진입점 하나를 흉내내는 최소 화면. 실제 홈·채팅방 화면을 띄우지 않고
  /// "이 함수를 부르면 무슨 일이 일어나는가"만 관찰한다.
  Future<void> pumpEntry(
    WidgetTester tester, {
    required GameEntryGate gate,
    int? communityPostId,
    bool replace = false,
  }) async {
    final router = GoRouter(
      initialLocation: '/entry',
      routes: [
        GoRoute(
          path: '/entry',
          builder: (context, state) => Consumer(
            builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () => startGameCreation(
                  context: context,
                  ref: ref,
                  communityPostId: communityPostId,
                  replace: replace,
                ),
                child: const Text('start'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.sessionCreationFlow,
          builder: (context, state) => const Scaffold(body: Text('flow')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [gameEntryGateProvider.overrideWithValue(gate)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({draftKey: staleDraft});
  });

  testWidgets(
    'clears_the_saved_draft_when_entering_from_a_community_post',
    (tester) async {
      await pumpEntry(tester, gate: _FakeGate(true), communityPostId: 7);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(draftKey),
        isNull,
        reason:
            '이전 초안이 남으면 플로우가 그 중심점을 복원하고, 구역 설정 지도가 '
            '현재 위치 조회를 건너뛴다 (#525)',
      );
    },
  );

  testWidgets('clears_the_saved_draft_when_entering_from_home', (tester) async {
    await pumpEntry(tester, gate: _FakeGate(true), replace: true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(draftKey), isNull);
  });

  testWidgets('opens_the_creation_flow_when_the_gate_passes', (tester) async {
    await pumpEntry(tester, gate: _FakeGate(true), communityPostId: 7);

    expect(find.text('flow'), findsOneWidget);
  });

  testWidgets('stays_on_the_caller_screen_when_the_gate_blocks', (
    tester,
  ) async {
    await pumpEntry(tester, gate: _FakeGate(false), communityPostId: 7);

    expect(find.text('flow'), findsNothing);
    expect(find.text('start'), findsOneWidget);
  });

  testWidgets('keeps_the_draft_when_the_gate_blocks', (tester) async {
    await pumpEntry(tester, gate: _FakeGate(false), communityPostId: 7);

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(draftKey),
      isNotNull,
      reason: '진입하지 못했으면 사용자의 작업 중 초안을 지울 이유가 없다',
    );
  });

  testWidgets('evaluates_the_gate_before_entering', (tester) async {
    final gate = _FakeGate(true);
    await pumpEntry(tester, gate: gate, communityPostId: 7);

    expect(gate.called, isTrue);
  });
}
