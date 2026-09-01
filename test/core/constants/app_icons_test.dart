import 'dart:io';

import 'package:cops_and_robbers/core/constants/app_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// `assets/icons/` 경로 리터럴을 찾는 패턴 — 가드와 상수 추출이 함께 쓴다.
final _iconLiteral = RegExp(r"assets/icons/");

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppIcons 조합 경로', () {
    // 조합 경로는 완성된 파일명이 소스에 없어 검색으로 검증할 수 없다.
    // 실제 번들 로드로 조합 규칙이 맞는지 확인한다.
    Future<void> expectBundledSvg(String path) async {
      final data = await rootBundle.loadString(path);
      expect(data, contains('<svg'), reason: '$path 가 번들에 없거나 SVG 형식이 아님');
    }

    for (final type in ['found', 'suspect']) {
      for (final isDark in [true, false]) {
        test('pingMarker_loads_when_type_${type}_dark_$isDark', () async {
          await expectBundledSvg(
            AppIcons.pingMarker(type: type, isDark: isDark),
          );
        });

        test('pingSelect_loads_when_type_${type}_dark_$isDark', () async {
          await expectBundledSvg(
            AppIcons.pingSelect(type: type, isDark: isDark),
          );
        });
      }
    }

    for (final isDark in [true, false]) {
      test('pingPin_loads_when_dark_$isDark', () async {
        await expectBundledSvg(AppIcons.pingPin(isDark: isDark));
      });

      test('role_loads_police_when_dark_$isDark', () async {
        await expectBundledSvg(AppIcons.role(isPolice: true, isDark: isDark));
      });

      test('role_loads_robber_when_dark_$isDark', () async {
        await expectBundledSvg(AppIcons.role(isPolice: false, isDark: isDark));
      });
    }
  });

  group('AppIcons 상수', () {
    test('every_declared_path_exists_on_disk', () {
      final source = File(
        'lib/core/constants/app_icons.dart',
      ).readAsStringSync();
      final paths = RegExp(
        r"'(assets/icons/[^'$]+\.svg)'",
      ).allMatches(source).map((m) => m.group(1)!).toSet();

      expect(paths, isNotEmpty, reason: 'app_icons.dart 에서 경로를 하나도 못 읽었다');
      final missing = paths.where((p) => !File(p).existsSync()).toList()
        ..sort();
      expect(missing, isEmpty, reason: '선언된 경로에 해당하는 파일이 없음');
    });
  });

  group('경로 리터럴 가드', () {
    test('no_icon_path_literal_outside_app_icons', () {
      const owner = 'lib/core/constants/app_icons.dart';
      final offenders = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path == owner) continue;

        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (_iconLiteral.hasMatch(lines[i])) {
            offenders.add('${entity.path}:${i + 1}');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            '아이콘 경로는 $owner 의 상수·함수만 쓴다. 리터럴이 남은 곳:\n'
            '${offenders.join('\n')}',
      );
    });
  });
}
