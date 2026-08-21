import 'package:cops_and_robbers/features/community/domain/entities/community_address_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_create_page.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_location_picker_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_headcount_sheet.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_sheet_scaffold.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart' show CupertinoDatePicker;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_fakes.dart';

/// 주소 조회와 글 등록만 응답한다 — 작성 흐름이 쓰는 건 그 둘이다.
class _CreateRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs {
  CommunityPostEntity? lastCreated;
  String? lastPlaceName;
  double? lastLatitude;

  @override
  Future<CommunityAddressEntity> getAddress({
    required double latitude,
    required double longitude,
  }) async => const CommunityAddressEntity(
    region: '서울특별시 광진구 화양동',
    address: '서울특별시 광진구 화양동 1-20',
    countryCode: 'KR',
  );

  @override
  Future<CommunityPostEntity> createPost({
    required String title,
    required String content,
    required DateTime meetingAt,
    required double latitude,
    required double longitude,
    required String placeName,
    required int maxParticipants,
  }) async {
    lastPlaceName = placeName;
    lastLatitude = latitude;
    return lastCreated = CommunityPostEntity(
      id: 1,
      writerId: 0,
      title: title,
      content: content,
      meetingAt: meetingAt,
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
      maxParticipants: maxParticipants,
      status: CommunityPostStatus.recruiting,
      createdAt: DateTime(2026, 8, 20),
    );
  }
}

/// 기본 테스트 뷰포트(800×600)는 디자인 기준(393×852)보다 넓고 낮아, 글자가 2배로
/// 커진 채 아래 항목이 화면 밖으로 밀린다 — 탭이 빗나가는 원인이라 실기기 크기로 맞춘다.
Future<void> _pumpPage(WidgetTester tester, [_CreateRepository? repo]) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_wrap(repo ?? _CreateRepository()));
  await tester.pumpAndSettle();
}

Widget _wrap(_CreateRepository repo) => ProviderScope(
  overrides: [
    communityRepositoryProvider.overrideWithValue(repo),
    // 장소 선택 화면이 시작 좌표를 물을 때 GPS·권한을 친다. 덮지 않으면
    // 플랫폼 채널이 응답하지 않는다.
    currentPositionResolverProvider.overrideWithValue(
      () async => (latitude: 37.5502, longitude: 127.0736),
    ),
  ],
  child: ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (_, _) => MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CommunityCreatePage(),
    ),
  ),
);

/// 날짜 시트를 열어 기본값 그대로 확정한다.
///
/// 힌트 Text는 AbsorbPointer 안이라 스스로 탭을 못 받는다 — 탭은 바깥
/// GestureDetector가 처리하므로 빗나감 경고만 끈다.
Future<void> _pickDate(WidgetTester tester) async {
  await tester.tap(find.text('모임 날짜를 골라주세요'), warnIfMissed: false);
  await tester.pumpAndSettle();
  await _tapSheetDone(tester);
}

/// 지도 카드를 탭해 장소 선택 화면에서 좌표를 확정하고 돌아온다.
Future<void> _pickLocation(WidgetTester tester) async {
  await tester.tap(find.byKey(CommunityCreatePage.mapCardKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(CommunityLocationPickerPage.confirmKey));
  await tester.pumpAndSettle();
}

/// AppBar 완료 라벨의 색 — 활성/비활성 판정을 이 색 하나로 읽는다.
Color _doneColor(WidgetTester tester) {
  return tester.widget<Text>(find.text('완료')).style!.color!;
}

/// 시트가 열려 있으면 AppBar와 시트 양쪽에 "완료"가 있다. 시트 쪽만 누른다.
Future<void> _tapSheetDone(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(CommunitySheetScaffold),
      matching: find.text('완료'),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _fillTextFields(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), '퇴근하고 한 판');
  await tester.enterText(find.byType(TextField).at(1), '규칙은 현장에서 정해요');
  // 인덱스 2는 날짜, 3은 상세주소(둘 다 읽기 전용), 4가 상세주소 입력이다.
  await tester.enterText(find.byType(TextField).at(4), '어린이대공원 정문');
  await tester.pump();
}

void main() {
  group('CommunityCreatePage', () {
    testWidgets('renders_every_section_without_overflow_when_opened', (
      tester,
    ) async {
      await _pumpPage(tester);

      for (final label in ['제목', '설명', '날짜', '장소', '모집 인원']) {
        expect(find.text(label), findsOneWidget);
      }
      // 제목 / 설명 / 날짜 / 기본 주소 / 상세주소
      expect(find.byType(TextField), findsNWidgets(5));
      expect(find.text('10명'), findsOneWidget);
    });

    testWidgets('keeps_done_disabled_when_date_is_not_picked', (tester) async {
      await _pumpPage(tester);

      await _fillTextFields(tester);

      // 텍스트 세 칸이 다 차도 날짜가 비면 완료는 죽어 있다.
      expect(_doneColor(tester), const Color(0xFFCFD6DD));
    });

    testWidgets('keeps_done_disabled_when_location_is_not_picked', (
      tester,
    ) async {
      // 좌표는 백엔드 필수값이라, 텍스트와 날짜가 다 차도 지도에서 위치를
      // 안 고르면 완료가 살아나면 안 된다 — 눌러 봐야 400이다.
      await _pumpPage(tester);

      await _fillTextFields(tester);
      await _pickDate(tester);

      expect(_doneColor(tester), const Color(0xFFCFD6DD));
    });

    testWidgets('enables_done_when_location_is_picked_after_date', (
      tester,
    ) async {
      await _pumpPage(tester);

      await _fillTextFields(tester);
      await _pickDate(tester);
      await _pickLocation(tester);

      expect(_doneColor(tester), const Color(0xFF4D63FF));
    });

    testWidgets('shows_lot_address_not_region_when_location_picked', (
      tester,
    ) async {
      await _pumpPage(tester);
      await _pickLocation(tester);

      // 읽기 전용 칸에는 번지까지 붙은 address가 들어간다. region(동 단위)을
      // 잘못 꽂아도 컴파일은 되므로 값이 다른 픽스처로 못 박는다.
      expect(find.text('서울특별시 광진구 화양동 1-20'), findsOneWidget);
    });

    testWidgets('keeps_lot_address_out_of_the_typed_place_name', (
      tester,
    ) async {
      final repo = _CreateRepository();
      await _pumpPage(tester, repo);

      await _fillTextFields(tester);
      await _pickDate(tester);
      await _pickLocation(tester);
      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();

      // 서버는 placeName 하나만 받는다. 읽기 전용 주소가 거기 섞여 들어가면
      // 작성자가 입력한 만나는 곳이 사라진다.
      expect(repo.lastPlaceName, '어린이대공원 정문');
    });

    testWidgets('sends_typed_place_name_and_picked_coordinates_on_submit', (
      tester,
    ) async {
      final repo = _CreateRepository();
      await _pumpPage(tester, repo);

      await _fillTextFields(tester);
      await _pickDate(tester);
      await _pickLocation(tester);
      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();

      // 장소는 둘로 나뉜다 (DEC-0015): 좌표는 지도에서, 만나는 곳은 입력에서.
      expect(repo.lastLatitude, 37.5502);
      expect(repo.lastPlaceName, '어린이대공원 정문');
      expect(repo.lastCreated?.title, '퇴근하고 한 판');
    });

    testWidgets('shows_loading_while_the_post_is_being_created', (
      tester,
    ) async {
      // 등록에 1초 안팎 걸리는데 아무 변화가 없으면 "눌린 건가?" 싶어 두 번
      // 누르게 된다. 응답이 올 때까지 로딩으로 덮는다.
      final repo = _CreateRepository();
      await _pumpPage(tester, repo);

      await _fillTextFields(tester);
      await _pickDate(tester);
      await _pickLocation(tester);
      await tester.tap(find.text('완료'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('모집글 올리는 중...'), findsOneWidget);

      // 응답 뒤에는 걷힌다 — 남아 있으면 화면이 잠긴다.
      await tester.pumpAndSettle();
      expect(find.text('모집글 올리는 중...'), findsNothing);
    });

    testWidgets('shows_date_and_time_rows_when_date_sheet_opens', (
      tester,
    ) async {
      await _pumpPage(tester);

      await tester.tap(find.text('모임 날짜를 골라주세요'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('모임 날짜 및 시간'), findsOneWidget);
      expect(find.text('시간'), findsOneWidget);
      // 처음에는 두 행만 보이고 휠은 접혀 있다.
      expect(find.byType(CupertinoDatePicker), findsNothing);
    });

    testWidgets('expands_only_the_tapped_wheel_when_a_row_is_tapped', (
      tester,
    ) async {
      await _pumpPage(tester);

      await tester.tap(find.text('모임 날짜를 골라주세요'), warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.tap(find.text('시간'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoDatePicker), findsOneWidget);

      // 같은 행을 다시 누르면 접힌다.
      await tester.tap(find.text('시간'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoDatePicker), findsNothing);
    });

    testWidgets('moves_focus_to_content_when_title_is_submitted', (
      tester,
    ) async {
      await _pumpPage(tester);

      await tester.tap(find.byType(TextField).at(0));
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();

      final content = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(content.focusNode!.hasFocus, isTrue);
    });

    testWidgets('applies_picked_headcount_when_number_is_tapped', (
      tester,
    ) async {
      await _pumpPage(tester);

      await tester.tap(find.text('10명'));
      await tester.pumpAndSettle();

      // 시트의 "+ 5명" 칩으로 15명까지 올린 뒤 확정한다.
      await tester.tap(find.text('+ 5명'));
      await tester.pumpAndSettle();
      await _tapSheetDone(tester);

      expect(find.text('15명'), findsOneWidget);
    });

    testWidgets('stops_decreasing_headcount_at_backend_minimum', (
      tester,
    ) async {
      await _pumpPage(tester);

      // 기본 10에서 하한 2까지 여덟 번, 그 뒤로는 더 내려가지 않는다.
      for (int i = 0; i < 12; i++) {
        await tester.tap(find.text('-'));
        await tester.pump();
      }

      expect(find.text('${CommunityHeadcountSheet.min}명'), findsOneWidget);
    });
  });
}
