import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/band_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 장면 자리(폰 393×852)에 띄운다. 보이는 영역 = 눌리는 영역이라 탭으로 확인한다.
Future<void> pumpScene(
  WidgetTester tester, {
  required VoidCallback onTap,
  bool revealFromBand = false,
  bool reduceMotion = false,
}) async {
  tester.view.physicalSize = const Size(393 * 3, 852 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: BandTransition(
        revealFromBand: revealFromBand,
        child: GestureDetector(
          onTap: onTap,
          child: const ColoredBox(color: AppColors.white),
        ),
      ),
    ),
  );
}

const topCorner = Offset(20, 120); // 띠 바깥 — 남은 시간 숫자가 있는 자리
const center = Offset(196, 426);

void main() {
  // 왼쪽 위 (20, 300)은 시안의 넓은 역할 띠 안쪽이고 예전 좁은 띠에선 바깥이다
  testWidgets('scene_shows_through_role_band_shape_when_role_banner_leaves', (
    tester,
  ) async {
    var taps = 0;
    await pumpScene(tester, onTap: () => taps++, revealFromBand: true);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tapAt(const Offset(20, 300));
    expect(taps, 1);
    await tester.pump(const Duration(milliseconds: 900));
  });

  // 역할 띠가 빠지는 동안엔 띠 자리로만 장면이 비치고, 다 빠진 뒤 화면 전체로 펼쳐진다
  testWidgets(
    'scene_shows_only_band_strip_then_fills_screen_when_role_banner_leaves',
    (tester) async {
      var taps = 0;
      await pumpScene(tester, onTap: () => taps++, revealFromBand: true);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tapAt(topCorner);
      expect(taps, 0);
      await tester.tapAt(center);
      expect(taps, 1);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tapAt(topCorner);
      expect(taps, 2);
    },
  );

  // 다시 켠 앱처럼 역할 배너 없이 뜨는 장면은 처음부터 화면 전체다
  testWidgets('scene_fills_screen_at_once_when_shown_without_role_banner', (
    tester,
  ) async {
    var taps = 0;
    await pumpScene(tester, onTap: () => taps++);
    await tester.tapAt(topCorner);
    expect(taps, 1);
  });

  testWidgets('scene_fills_screen_at_once_when_reduce_motion_is_on', (
    tester,
  ) async {
    var taps = 0;
    await pumpScene(
      tester,
      onTap: () => taps++,
      revealFromBand: true,
      reduceMotion: true,
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tapAt(topCorner);
    expect(taps, 1);
  });

  // 띠가 다 펼쳐진 순간에도 장면은 같은 장면이어야 한다 — 새로 만들어지면 공지·규칙·남은 시간 막대가 처음부터 다시 돈다
  testWidgets('scene_keeps_its_state_when_band_finishes_revealing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    var created = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: BandTransition(
          revealFromBand: true,
          child: _CountsCreation(onCreate: () => created++),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200)); // 펼치는 중
    await tester.pump(const Duration(seconds: 2)); // 다 펼쳐짐
    expect(created, 1);
  });
}

/// 만들어질 때마다 알린다 — 장면이 다시 만들어지는지 센다
class _CountsCreation extends StatefulWidget {
  const _CountsCreation({required this.onCreate});
  final VoidCallback onCreate;

  @override
  State<_CountsCreation> createState() => _CountsCreationState();
}

class _CountsCreationState extends State<_CountsCreation> {
  @override
  void initState() {
    super.initState();
    widget.onCreate();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
