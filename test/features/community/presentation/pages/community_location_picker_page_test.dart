import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_address_entity.dart';
import 'package:cops_and_robbers/features/community/presentation/pages/community_location_picker_page.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

import '../../community_fakes.dart';

/// 주소 조회만 응답하는 Repository — 이 화면이 쓰는 건 그거 하나다.
class _AddressRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs {
  _AddressRepository({this.address, this.error});

  final CommunityAddressEntity? address;
  final Object? error;

  double? lastLatitude;
  double? lastLongitude;

  @override
  Future<CommunityAddressEntity> getAddress({
    required double latitude,
    required double longitude,
  }) async {
    lastLatitude = latitude;
    lastLongitude = longitude;
    if (error != null) throw error!;
    return address!;
  }
}

/// 지도가 플랫폼 뷰라 탭을 흉내 낼 수 없다. 대신 [initialTarget]을 넘겨
/// "핀이 찍힌 직후" 상태에서 시작한다 — 검증 대상인 주소 조회·확정 규칙은 같다.
Widget _wrap(_AddressRepository repo) => ProviderScope(
  overrides: [communityRepositoryProvider.overrideWithValue(repo)],
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
      home: const CommunityLocationPickerPage(
        initialTarget: LatLng(37.5502, 127.0736),
      ),
    ),
  ),
);

/// 반환값을 검증하려면 push한 쪽이 있어야 한다 — pop 결과는 호출자만 받는다.
Widget _wrapPushedFrom(
  _AddressRepository repo, {
  required void Function(CommunityPickedLocation?) onPicked,
}) => ProviderScope(
  overrides: [communityRepositoryProvider.overrideWithValue(repo)],
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
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final picked = await Navigator.of(context)
                  .push<CommunityPickedLocation>(
                    MaterialPageRoute(
                      builder: (_) => const CommunityLocationPickerPage(
                        initialTarget: LatLng(37.5502, 127.0736),
                      ),
                    ),
                  );
              onPicked(picked);
            },
            child: const Text('열기'),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  group('CommunityLocationPickerPage', () {
    testWidgets('shows_lot_address_when_lookup_succeeds', (tester) async {
      final repo = _AddressRepository(
        address: const CommunityAddressEntity(
          region: '서울특별시 광진구 화양동',
          address: '서울특별시 광진구 화양동 1-20',
          countryCode: 'KR',
        ),
      );

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      // 번지까지 붙은 주소를 보여 준다 — 동 단위만으로는 "여기가 맞나"를 못 정한다.
      expect(find.text('서울특별시 광진구 화양동 1-20'), findsOneWidget);
      expect(repo.lastLatitude, 37.5502);
      expect(repo.lastLongitude, 127.0736);
    });

    testWidgets(
      'returns_picked_coordinates_region_and_address_when_confirmed',
      (tester) async {
        final repo = _AddressRepository(
          address: const CommunityAddressEntity(
            region: '서울특별시 광진구 화양동',
            address: '서울특별시 광진구 화양동 1-20',
            countryCode: 'KR',
          ),
        );
        CommunityPickedLocation? received;

        await tester.pumpWidget(
          _wrapPushedFrom(repo, onPicked: (value) => received = value),
        );
        await tester.tap(find.text('열기'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(CommunityLocationPickerPage.confirmKey));
        await tester.pumpAndSettle();

        // 작성 화면이 셋을 다 받는다. region은 지도 미리보기 라벨,
        // address(번지)는 상세주소 읽기 전용 칸에 그대로 꽂힌다.
        expect(received?.latitude, 37.5502);
        expect(received?.longitude, 127.0736);
        expect(received?.region, '서울특별시 광진구 화양동');
        expect(received?.address, '서울특별시 광진구 화양동 1-20');
      },
    );

    testWidgets('keeps_confirm_disabled_when_address_lookup_fails', (
      tester,
    ) async {
      // 주소가 없는 좌표는 서버가 글 작성도 400으로 거절한다. 확정을 여기서 막아
      // 작성 화면까지 갔다가 되돌아오는 왕복을 없앤다.
      final repo = _AddressRepository(
        error: const ServerException(
          message: '주소를 찾을 수 없습니다',
          messageKey: 'errorCommunityAddressLoadGeneric',
        ),
      );

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.text('주소를 찾을 수 없는 곳이에요. 다른 곳을 골라주세요'), findsOneWidget);

      await tester.tap(find.byKey(CommunityLocationPickerPage.confirmKey));
      await tester.pumpAndSettle();

      // 눌러도 아무 일이 없어야 한다 — 화면이 그대로 남아 있다.
      expect(find.byType(CommunityLocationPickerPage), findsOneWidget);
    });
  });
}
