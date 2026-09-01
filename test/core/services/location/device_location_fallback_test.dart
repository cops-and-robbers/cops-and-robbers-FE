import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:cops_and_robbers/core/services/location/device_location_service.dart';

/// 폴백 좌표가 다시 흩어지지 않게 지키는 가드.
///
/// #525에서 이 좌표가 5개 파일에 복붙돼 있었고 "현재 위치를 못 얻으면 어떻게
/// 할지"도 호출부마다 따로 정하고 있었다. 권한 문제가 "그냥 좀 이상한 위치"로만
/// 보인 이유다.
void main() {
  test('fallback_is_declared_once_in_the_service', () {
    expect(
      DeviceLocationService.fallbackLocation,
      const LatLng(37.5480, 127.0810),
    );
  });

  test('no_other_source_file_hardcodes_the_fallback_coordinate', () {
    const owner = 'lib/core/services/location/device_location_service.dart';
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path == owner) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('37.5480')) {
          offenders.add('${entity.path}:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          '폴백 좌표는 $owner 의 fallbackLocation 만 쓴다. 복붙이 남은 곳:\n'
          '${offenders.join('\n')}',
    );
  });
}
