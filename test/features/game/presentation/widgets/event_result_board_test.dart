import 'package:cops_and_robbers/features/game/domain/event_evidence.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/event_result_board.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(375, 812),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('portrait_evidence_fills_same_size_card_as_locked_evidence', (
    tester,
  ) async {
    await _pump(tester, EventResultBoard(arrestCount: 1, onGoHome: () {}));

    final revealed = tester.getSize(
      find.byKey(const ValueKey('event_result_slot_1')),
    );
    final locked = tester.getSize(
      find.byKey(const ValueKey('event_result_slot_2')),
    );
    final fitted = applyBoxFit(BoxFit.contain, const Size(941, 1672), revealed);
    expect(revealed, locked);
    expect(fitted.destination.width, greaterThan(revealed.width * 0.99));
    expect(fitted.destination.height, greaterThan(revealed.height * 0.99));
  });

  testWidgets('evidence_board_reveals_two_slots_as_arrests_accumulate', (
    tester,
  ) async {
    for (final count in [0, 1, 2, 3]) {
      await _pump(
        tester,
        EventResultBoard(arrestCount: count, onGoHome: () {}),
      );

      expect(find.byKey(const ValueKey('event_result_slot_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('event_result_slot_2')), findsOneWidget);
      expect(find.byKey(const ValueKey('event_result_slot_3')), findsNothing);
      final collected = count.clamp(0, 2);
      expect(find.byIcon(Icons.lock), findsNWidgets(2 - collected));
      expect(
        tester
            .widgetList<Image>(find.byType(Image))
            .map((image) => (image.image as AssetImage).assetName),
        [for (var i = 1; i <= collected; i++) 'assets/events/evidence$i.png'],
      );
    }
  });

  for (final size in [const Size(320, 568), const Size(768, 1024)]) {
    testWidgets('evidence_slots_fit_side_by_side_when_screen_is_$size', (
      tester,
    ) async {
      await _pump(
        tester,
        EventResultBoard(arrestCount: 2, onGoHome: () {}),
        size: size,
      );

      final images = find.byType(Image);
      final bounds = [
        for (var i = 0; i < 2; i++)
          MatrixUtils.transformRect(
            tester.renderObject<RenderBox>(images.at(i)).getTransformTo(null),
            Offset.zero & tester.getSize(images.at(i)),
          ),
      ];
      final button = tester.getRect(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(EventResultBoard)),
          ).buttonGoHome,
        ),
      );
      expect(bounds[0].right, lessThan(bounds[1].left));
      expect(bounds[0].left, greaterThan(0));
      expect(bounds[1].right, lessThan(size.width));
      expect(bounds[0].center.dy, closeTo(bounds[1].center.dy, 0.01));
      expect(bounds.every((rect) => rect.bottom < button.top), isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  const onePhoto = EventEvidence(
    photos: [EventEvidencePhoto(assetPath: 'assets/events/evidence1.png')],
    aspectRatio: 9 / 16,
  );
  const wideTwoPhotos = EventEvidence(
    photos: [
      EventEvidencePhoto(assetPath: 'assets/events/evidence1.png'),
      EventEvidencePhoto(assetPath: 'assets/events/evidence2.png'),
    ],
    aspectRatio: 16 / 9,
  );

  const threePhotos = EventEvidence(
    photos: [
      EventEvidencePhoto(assetPath: 'assets/events/evidence1.png'),
      EventEvidencePhoto(assetPath: 'assets/events/evidence2.png'),
      EventEvidencePhoto(assetPath: 'assets/events/evidence2.png'),
    ],
    aspectRatio: 9 / 16,
  );

  const wideThreePhotos = EventEvidence(
    photos: [
      EventEvidencePhoto(assetPath: 'assets/events/evidence1.png'),
      EventEvidencePhoto(assetPath: 'assets/events/evidence2.png'),
      EventEvidencePhoto(assetPath: 'assets/events/evidence2.png'),
    ],
    aspectRatio: 16 / 9,
  );

  testWidgets('landscape_three_photos_keep_same_size_two_over_one', (
    tester,
  ) async {
    await _pump(
      tester,
      EventResultBoard(
        arrestCount: 3,
        onGoHome: () {},
        evidence: wideThreePhotos,
      ),
    );

    final first = tester.getRect(
      find.byKey(const ValueKey('event_result_slot_1')),
    );
    final second = tester.getRect(
      find.byKey(const ValueKey('event_result_slot_2')),
    );
    final third = tester.getRect(
      find.byKey(const ValueKey('event_result_slot_3')),
    );
    expect(first.top, second.top);
    expect(first.right, lessThan(second.left));
    expect(first.bottom, lessThan(third.top));
    expect(third.center.dx, closeTo(375 / 2, 0.5));
    expect(first.size, third.size);
    expect(tester.takeException(), isNull);
  });

  testWidgets('three_slots_reveal_in_order_as_arrests_accumulate', (
    tester,
  ) async {
    await _pump(
      tester,
      EventResultBoard(arrestCount: 2, onGoHome: () {}, evidence: threePhotos),
    );

    expect(find.byKey(const ValueKey('event_result_slot_3')), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.byKey(const ValueKey('event_result_lock_3')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('board_shows_one_slot_when_event_has_one_photo', (tester) async {
    await _pump(
      tester,
      EventResultBoard(arrestCount: 2, onGoHome: () {}, evidence: onePhoto),
    );

    final slot = find.byKey(const ValueKey('event_result_slot_1'));
    expect(slot, findsOneWidget);
    expect(find.byKey(const ValueKey('event_result_slot_2')), findsNothing);
    expect(find.byIcon(Icons.lock), findsNothing);
    expect(tester.getCenter(slot).dx, closeTo(375 / 2, 0.5));
  });

  testWidgets('landscape_photos_stack_vertically_when_event_has_two', (
    tester,
  ) async {
    await _pump(
      tester,
      EventResultBoard(
        arrestCount: 1,
        onGoHome: () {},
        evidence: wideTwoPhotos,
      ),
    );

    final first = tester.getRect(
      find.byKey(const ValueKey('event_result_slot_1')),
    );
    final second = tester.getRect(
      find.byKey(const ValueKey('event_result_slot_2')),
    );
    expect(first.bottom, lessThan(second.top));
    expect(first.size, second.size);
    expect(first.width / first.height, closeTo(16 / 9, 0.01));
  });

  for (final size in [const Size(320, 568), const Size(768, 1024)]) {
    for (final evidence in [
      onePhoto,
      wideTwoPhotos,
      EventEvidence.bundled,
      threePhotos,
      wideThreePhotos,
    ]) {
      testWidgets(
        'board_fits_screen_when_screen_is_${size}_and_${evidence.count}_photos_ratio_${evidence.aspectRatio.toStringAsFixed(2)}',
        (tester) async {
          await _pump(
            tester,
            EventResultBoard(
              arrestCount: 2,
              onGoHome: () {},
              evidence: evidence,
            ),
            size: size,
          );

          expect(tester.takeException(), isNull);
          final button = tester.getBottomRight(
            find.text(
              AppLocalizations.of(
                tester.element(find.byType(EventResultBoard)),
              ).buttonGoHome,
            ),
          );
          expect(button.dy, lessThanOrEqualTo(size.height));
        },
      );
    }
  }

  testWidgets('shows_bundled_photo_when_remote_photo_fails_to_load', (
    tester,
  ) async {
    const remote = EventEvidence(
      photos: [
        EventEvidencePhoto(
          assetPath: 'assets/events/evidence1.png',
          url: 'https://example.com/a.png',
        ),
      ],
      aspectRatio: 9 / 16,
    );

    await _pump(
      tester,
      EventResultBoard(arrestCount: 1, onGoHome: () {}, evidence: remote),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    expect(
      tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => image.image)
          .whereType<AssetImage>()
          .map((image) => image.assetName),
      contains('assets/events/evidence1.png'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows_bundled_photo_when_remote_photo_takes_too_long', (
    tester,
  ) async {
    const remote = EventEvidence(
      photos: [
        EventEvidencePhoto(
          assetPath: 'assets/events/evidence1.png',
          url: 'https://example.com/slow.png',
        ),
      ],
      aspectRatio: 9 / 16,
    );

    await _pump(
      tester,
      EventResultBoard(arrestCount: 1, onGoHome: () {}, evidence: remote),
    );
    await tester.pump(const Duration(seconds: 6));

    expect(
      tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => image.image)
          .whereType<AssetImage>()
          .map((image) => image.assetName),
      contains('assets/events/evidence1.png'),
    );
  });

  testWidgets('shows_arrest_count_text_and_only_home_button', (tester) async {
    await _pump(tester, EventResultBoard(arrestCount: 2, onGoHome: () {}));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(EventResultBoard)),
    );

    expect(find.text(l10n.gameEventResultArrestCount(2)), findsOneWidget);
    expect(find.text(l10n.buttonGoHome), findsOneWidget);
    expect(find.text(l10n.buttonPlayAgain), findsNothing); // 한 번 더 숨김
  });

  testWidgets('renders_overridden_title_and_button_when_provided', (
    tester,
  ) async {
    await _pump(
      tester,
      EventResultBoard(
        arrestCount: 1,
        onGoHome: () {},
        title: 'PROGRESS_TITLE',
        buttonText: 'CLOSE_BTN',
      ),
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byType(EventResultBoard)),
    );

    // 오버라이드 문구 렌더
    expect(find.text('PROGRESS_TITLE'), findsOneWidget);
    expect(find.text('CLOSE_BTN'), findsOneWidget);
    // 기본 게임종료 문구는 노출 안 됨
    expect(find.text(l10n.gameEventResultTitle), findsNothing); // "수사 종료"
    expect(find.text(l10n.buttonGoHome), findsNothing); // "홈으로"
  });
}
