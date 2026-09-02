import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_fakes.dart';

/// 국가 조회만 응답한다 — 이 provider가 쓰는 건 그거 하나다.
class _CountryRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs {
  _CountryRepository({this.countryCode, this.error});

  final String? countryCode;
  final Object? error;

  int callCount = 0;
  double? lastLatitude;
  double? lastLongitude;

  @override
  Future<String?> getCountryCode({
    required double latitude,
    required double longitude,
  }) async {
    callCount++;
    lastLatitude = latitude;
    lastLongitude = longitude;
    if (error != null) throw error!;
    return countryCode;
  }
}

ProviderContainer _containerWith(
  CommunityRepository repo, {
  DeviceCoordinates? position,
  String deviceCountryCode = 'KR',
}) {
  final container = ProviderContainer(
    overrides: [
      communityRepositoryProvider.overrideWithValue(repo),
      // GPS·권한·기기 로케일은 전부 시스템 경계다.
      currentPositionResolverProvider.overrideWithValue(() async => position),
      deviceCountryCodeProvider.overrideWithValue(deviceCountryCode),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('communityCountryCodeProvider', () {
    test('returns_server_country_code_when_position_available', () async {
      final repo = _CountryRepository(countryCode: 'JP');
      final container = _containerWith(
        repo,
        position: (latitude: 35.6895, longitude: 139.6917),
      );

      final code = await container.read(communityCountryCodeProvider.future);

      // 로케일이 KR이어도 실제 위치의 국가가 이긴다 — 일본에 있는 한국 기기가
      // 한국 목록을 보면 안 된다.
      expect(code, 'JP');
      expect(repo.lastLatitude, 35.6895);
      expect(repo.lastLongitude, 139.6917);
    });

    test('falls_back_to_device_locale_when_location_unavailable', () async {
      // 위치 권한이 없으면 좌표가 없다. 목록 한 번 보자고 권한 팝업을 띄우지
      // 않으므로 이 경로가 기본값에 가깝다.
      final repo = _CountryRepository(countryCode: 'JP');
      final container = _containerWith(
        repo,
        position: null,
        deviceCountryCode: 'US',
      );

      expect(await container.read(communityCountryCodeProvider.future), 'US');
      // 좌표가 없으면 서버를 부를 이유가 없다.
      expect(repo.callCount, 0);
    });

    test('falls_back_to_device_locale_when_lookup_fails', () async {
      // 벤더 장애(500)·국가를 못 정하는 좌표(400) 모두 여기로 온다. 국가 하나
      // 못 알아냈다고 목록 전체가 에러 화면이 되면 안 된다.
      final repo = _CountryRepository(
        error: const ServerException(message: '주소 조회 실패'),
      );
      final container = _containerWith(
        repo,
        position: (latitude: 35.6895, longitude: 139.6917),
        deviceCountryCode: 'US',
      );

      expect(await container.read(communityCountryCodeProvider.future), 'US');
    });

    test(
      'falls_back_to_device_locale_when_server_omits_country_code',
      () async {
        // 스키마에 required가 없어 null이 올 수 있다 (LSN-0009).
        final repo = _CountryRepository(countryCode: null);
        final container = _containerWith(
          repo,
          position: (latitude: 35.6895, longitude: 139.6917),
          deviceCountryCode: 'US',
        );

        expect(await container.read(communityCountryCodeProvider.future), 'US');
      },
    );

    test('resolves_once_when_read_repeatedly', () async {
      // 페이지를 넘길 때마다 GPS를 다시 켜고 벤더를 다시 부르면 안 된다 —
      // 화면 진입당 1회가 계약이다 (DEC-0021, Geoapify 일 3,000건 한도).
      final repo = _CountryRepository(countryCode: 'JP');
      final container = _containerWith(
        repo,
        position: (latitude: 35.6895, longitude: 139.6917),
      );

      await container.read(communityCountryCodeProvider.future);
      await container.read(communityCountryCodeProvider.future);
      await container.read(communityCountryCodeProvider.future);

      expect(repo.callCount, 1);
    });
  });
}
