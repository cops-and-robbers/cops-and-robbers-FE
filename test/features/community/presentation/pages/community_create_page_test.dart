import 'package:cops_and_robbers/core/errors/app_exception.dart';
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
  _CreateRepository({this.writeFailure});

  /// 넣어 두면 작성·수정이 이 예외로 실패한다 — 서버 거절 경로 재현용.
  final AppException? writeFailure;

  CommunityPostEntity? lastCreated;
  CommunityPostEntity? lastUpdated;
  int? lastUpdatedId;
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
    if (writeFailure != null) throw writeFailure!;
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

  @override
  Future<CommunityPostEntity> updatePost({
    required int postId,
    required String title,
    required String content,
    required DateTime meetingAt,
    required double latitude,
    required double longitude,
    required String placeName,
    required int maxParticipants,
  }) async {
    if (writeFailure != null) throw writeFailure!;
    lastUpdatedId = postId;
    lastPlaceName = placeName;
    lastLatitude = latitude;
    return lastUpdated = existingPost().copyWith(
      title: title,
      content: content,
      meetingAt: meetingAt,
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
      maxParticipants: maxParticipants,
    );
  }
}

/// 수정 모드 픽스처 — 다섯 칸이 전부 차 있는, 이미 서버에 있는 글.
CommunityPostEntity existingPost() => CommunityPostEntity(
  id: 42,
  writerId: 1,
  title: '기존 제목',
  content: '기존 설명',
  meetingAt: DateTime(2026, 9, 10, 18, 30),
  latitude: 37.5502,
  longitude: 127.0736,
  placeName: '어린이대공원 정문',
  region: '서울특별시 광진구 화양동',
  address: '서울특별시 광진구 화양동 1-20',
  maxParticipants: 8,
  status: CommunityPostStatus.recruiting,
  createdAt: DateTime(2026, 8, 20),
);

/// 기본 테스트 뷰포트(800×600)는 디자인 기준(393×852)보다 넓고 낮아, 글자가 2배로
/// 커진 채 아래 항목이 화면 밖으로 밀린다 — 탭이 빗나가는 원인이라 실기기 크기로 맞춘다.
Future<void> _pumpPage(WidgetTester tester, [_CreateRepository? repo]) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_wrap(repo ?? _CreateRepository()));
  await tester.pumpAndSettle();
}

/// 수정 화면을 push로 열고, 돌아온 pop 결과를 담을 그릇을 넘겨준다.
Future<_Popped> _pumpEditPage(
  WidgetTester tester,
  _CreateRepository repo,
  CommunityPostEntity post,
) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final popped = _Popped();
  await tester.pumpWidget(_wrapEditHost(repo, post, popped));
  await tester.pumpAndSettle();
  await tester.tap(find.text('수정 열기'));
  await tester.pumpAndSettle();
  return popped;
}

Widget _wrap(_CreateRepository repo) => _app(repo, const CommunityCreatePage());

/// 수정 화면은 상세 위로 열려 결과를 상세로 돌려준다. 그 왕복까지 재현해야
/// "무엇을 돌려주는지"가 검증된다.
Widget _wrapEditHost(
  _CreateRepository repo,
  CommunityPostEntity post,
  _Popped popped,
) => _app(
  repo,
  Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () async {
            popped.value = await Navigator.of(context)
                .push<CommunityPostEntity>(
                  MaterialPageRoute(
                    builder: (_) => CommunityCreatePage(post: post),
                  ),
                );
          },
          child: const Text('수정 열기'),
        ),
      ),
    ),
  ),
);

/// push 결과를 테스트로 실어 나르는 그릇.
class _Popped {
  CommunityPostEntity? value;
}

Widget _app(_CreateRepository repo, Widget home) => ProviderScope(
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
      home: home,
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

    group('수정 모드', () {
      testWidgets('prefills_every_field_from_the_post_when_opened_for_edit', (
        tester,
      ) async {
        await _pumpEditPage(tester, _CreateRepository(), existingPost());

        expect(find.text('모집글 수정'), findsOneWidget);
        expect(find.text('기존 제목'), findsOneWidget);
        expect(find.text('기존 설명'), findsOneWidget);
        expect(find.text('어린이대공원 정문'), findsOneWidget);
        expect(find.text('서울특별시 광진구 화양동 1-20'), findsOneWidget);
        expect(find.text('8명'), findsOneWidget);
        // 날짜·좌표가 이미 확정돼 있으니 아무것도 안 건드려도 완료는 살아 있다 —
        // 제목 한 글자만 고치러 들어온 사용자가 지도를 다시 찍게 하면 안 된다.
        expect(_doneColor(tester), const Color(0xFF4D63FF));
      });

      testWidgets(
        'sends_edited_values_to_updatePost_and_pops_with_the_result',
        (tester) async {
          final repo = _CreateRepository();
          final popped = await _pumpEditPage(tester, repo, existingPost());

          await tester.enterText(find.byType(TextField).at(0), '제목을 고쳤어요');
          await tester.pump();
          await tester.tap(find.text('완료'));
          await tester.pumpAndSettle();

          expect(repo.lastUpdatedId, 42);
          expect(repo.lastUpdated?.title, '제목을 고쳤어요');
          // PUT은 전체 교체다 — 손대지 않은 값도 그대로 다시 실려야 400을 안 맞는다.
          expect(repo.lastPlaceName, '어린이대공원 정문');
          expect(repo.lastLatitude, 37.5502);
          // 호출자가 재조회 없이 갱신할 수 있도록 수정된 글을 돌려준다.
          expect(popped.value?.title, '제목을 고쳤어요');
        },
      );

      testWidgets('shows_snackbar_and_keeps_input_when_update_fails', (
        tester,
      ) async {
        // 서버가 거절해도 화면을 닫으면 사용자가 방금 고친 내용이 통째로
        // 날아간다. 알리기만 하고 그대로 둔다.
        final repo = _CreateRepository(
          writeFailure: const ServerException(
            message: 'boom',
            messageKey: 'errorCommunityPostUpdateGeneric',
          ),
        );
        await _pumpEditPage(tester, repo, existingPost());

        await tester.enterText(find.byType(TextField).at(0), '제목을 고쳤어요');
        await tester.pump();
        await tester.tap(find.text('완료'));
        await tester.pumpAndSettle();

        expect(find.text('모집글을 수정하는 중 오류가 생겼어요'), findsOneWidget);
        expect(find.text('모집글 수정'), findsOneWidget);
        expect(find.text('제목을 고쳤어요'), findsOneWidget);

        // 스낵바 타이머를 남긴 채 끝내면 "A Timer is still pending"으로 깨진다.
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
      });
    });
  });
}
