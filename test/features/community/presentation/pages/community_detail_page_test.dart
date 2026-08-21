import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_detail_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_fakes.dart';

const _postId = 7;

const _region = '서울특별시 광진구 화양동';
const _placeName = '어린이대공원 정문';

/// 화면에 보이는 라벨 — `region · placeName`.
const _label = '$_region · $_placeName';

/// 복사돼야 하는 값 — 번지까지 붙은 지번 주소.
const _lotAddress = '서울특별시 광진구 화양동 164-2';

CommunityPostEntity _post({String? address, String? region = _region}) =>
    CommunityPostEntity(
      id: _postId,
      writerId: 1,
      title: '같이 하실 분',
      content: '본문',
      meetingAt: DateTime(2026, 9, 10, 18),
      latitude: 37.5502,
      longitude: 127.0736,
      maxParticipants: 10,
      status: CommunityPostStatus.recruiting,
      createdAt: DateTime(2026, 8, 20),
      region: region,
      placeName: _placeName,
      address: address,
    );

/// 본문 조회만 응답하는 Repository — 이 화면이 실서버에서 받는 건 그거 하나다.
class _DetailRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs {
  _DetailRepository(this.post);

  final CommunityPostEntity post;

  @override
  Future<CommunityPostEntity> getPost(int postId) async => post;
}

Widget _wrap(_DetailRepository repo) => ProviderScope(
  overrides: [
    communityRepositoryProvider.overrideWithValue(repo),
    // 더보기 메뉴가 로그인 사용자 id를 watch 한다. 덮지 않으면 실제 AuthNotifier가
    // Firebase까지 끌고 들어와, 이 화면과 무관한 이유로 깨진다.
    currentUserIdProvider.overrideWithValue(1),
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
      home: const CommunityDetailPage(postId: _postId),
    ),
  ),
);

/// 복사 스낵바가 스스로 사라질 때까지 기다린다.
///
/// 3초 타이머를 남긴 채 테스트가 끝나면 "A Timer is still pending"으로 깨진다 —
/// 스낵바는 Overlay라 화면 dispose로는 정리되지 않는다.
Future<void> _letSnackbarExpire(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

/// 상세를 띄우고 [label]이 적힌 장소 행을 탭한다.
Future<void> _tapLocation(
  WidgetTester tester,
  _DetailRepository repo, {
  String label = _label,
}) async {
  await tester.pumpWidget(_wrap(repo));
  await tester.pumpAndSettle();

  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
  await _letSnackbarExpire(tester);
}

void main() {
  /// 클립보드는 플랫폼 채널이라 테스트에서 실물이 없다. 담긴 값을 보려면
  /// 채널을 가로채는 수밖에 없다.
  late List<String> copied;

  setUp(() {
    copied = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('CommunityDetailPage 장소 복사', () {
    testWidgets('copies_lot_address_not_the_displayed_label_when_tapped', (
      tester,
    ) async {
      final repo = _DetailRepository(_post(address: _lotAddress));

      await _tapLocation(tester, repo);

      // 화면에 보이는 건 동 단위 라벨, 담기는 건 번지까지 붙은 주소다.
      expect(find.text(_label), findsOneWidget);
      expect(copied, [_lotAddress]);
    });

    testWidgets('copies_region_only_when_server_omits_the_lot_address', (
      tester,
    ) async {
      // 백엔드가 아직 address를 안 싣는 동안의 동작. 장소명은 빼고 지역만 담는다 —
      // "화양동 · 어린이대공원 정문"을 지도 앱에 붙여넣으면 검색이 깨진다.
      final repo = _DetailRepository(_post());

      await _tapLocation(tester, repo);

      expect(copied, [_region]);
    });

    testWidgets('copies_place_name_when_reverse_geocoding_left_no_region', (
      tester,
    ) async {
      final repo = _DetailRepository(_post(region: null));

      await _tapLocation(tester, repo, label: _placeName);

      expect(copied, [_placeName]);
    });
  });
}
