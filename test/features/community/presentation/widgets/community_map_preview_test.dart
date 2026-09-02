import 'dart:async';

import 'package:cops_and_robbers/features/community/presentation/widgets/community_map_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 지도 위젯 파인더.
///
/// `skipOffstage`를 끄는 게 핵심이다 — 기본값이면 "덮여서 offstage가 된" 것과
/// "트리에서 빠진" 것이 똑같이 안 잡혀, 아무것도 고치지 않아도 통과한다.
/// 크래시를 막는 건 offstage가 아니라 **언마운트**뿐이다.
final _map = find.byType(GoogleMap, skipOffstage: false);

/// 미리보기를 얹은 화면 하나. 여기 위로 다른 화면·시트를 올려 본다.
Widget _wrap(GlobalKey<NavigatorState> navigatorKey) => ScreenUtilInit(
  designSize: const Size(393, 852),
  builder: (_, _) => MaterialApp(
    navigatorKey: navigatorKey,
    home: const Scaffold(
      body: CommunityMapPreview(latitude: 37.5502, longitude: 127.0736),
    ),
  ),
);

void main() {
  group('CommunityMapPreview', () {
    testWidgets('removes_the_map_while_another_page_covers_it', (tester) async {
      // 덮인 화면은 Overlay가 레이아웃에서 빼는데, 플랫폼 뷰는 전역 포인터
      // 라우트로 터치마다 자기 크기를 묻는다 — 그 조합이 iOS·Android 모두에서
      // `hasSize` assert로 앱을 죽인다. 덮이는 동안에는 지도를 들어내야 한다.
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(_wrap(navigatorKey));
      await tester.pumpAndSettle();
      expect(_map, findsOneWidget);

      unawaited(
        navigatorKey.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('덮는 화면')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_map, findsNothing);

      // 다시 드러나면 지도가 돌아온다 — 덮인 동안만 들어내는 것이지
      // 영영 없애는 게 아니다.
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(_map, findsOneWidget);
    });

    testWidgets('keeps_the_map_when_a_bottom_sheet_opens_over_it', (
      tester,
    ) async {
      // 시트·다이얼로그가 뜨면 `isCurrent`는 false가 되지만 아래 화면은 그대로
      // 레이아웃된다 — 크래시 조건이 아니다. 여기서까지 지도를 들어내면 시트를
      // 여닫을 때마다 지도가 새로 뜬다(작성 화면의 날짜·인원 시트).
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(_wrap(navigatorKey));
      await tester.pumpAndSettle();

      unawaited(
        showModalBottomSheet<void>(
          context: navigatorKey.currentContext!,
          builder: (_) => const SizedBox(height: 200, child: Text('시트')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('시트'), findsOneWidget);
      expect(_map, findsOneWidget);

      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
    });
  });
}
