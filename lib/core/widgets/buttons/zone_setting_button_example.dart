import 'package:flutter/material.dart';

import '../../constants/spacing_and_radius.dart';
import 'zone_setting_button.dart';

/// 구역 설정 버튼 사용 예시 페이지
///
/// 이 파일은 개발 및 테스트 용도로만 사용됩니다.
class ZoneSettingButtonExample extends StatelessWidget {
  const ZoneSettingButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zone Setting Button Example'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.horizontal20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // 플레이그라운드 (반경 미설정)
            // ============================================
            const Text(
              '플레이그라운드 (반경 미설정)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.vertical8),
            ZoneSettingButton(
              zoneType: ZoneType.playground,
              title: '플레이그라운드',
              onPressed: () {
                debugPrint('플레이그라운드 설정 페이지로 이동');
              },
            ),

            SizedBox(height: AppSpacing.vertical20),

            // ============================================
            // 플레이그라운드 (반경 설정됨)
            // ============================================
            const Text(
              '플레이그라운드 (반경 400m)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.vertical8),
            ZoneSettingButton(
              zoneType: ZoneType.playground,
              title: '플레이그라운드',
              radiusMeters: 400,
              onPressed: () {
                debugPrint('플레이그라운드 설정 페이지로 이동 (반경: 400m)');
              },
            ),

            SizedBox(height: AppSpacing.vertical20),

            // ============================================
            // 감옥 (반경 미설정)
            // ============================================
            const Text(
              '감옥 (반경 미설정)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.vertical8),
            ZoneSettingButton(
              zoneType: ZoneType.prison,
              title: '감옥',
              onPressed: () {
                debugPrint('감옥 설정 페이지로 이동');
              },
            ),

            SizedBox(height: AppSpacing.vertical20),

            // ============================================
            // 감옥 (반경 설정됨)
            // ============================================
            const Text(
              '감옥 (반경 200m)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.vertical8),
            ZoneSettingButton(
              zoneType: ZoneType.prison,
              title: '감옥',
              radiusMeters: 200,
              onPressed: () {
                debugPrint('감옥 설정 페이지로 이동 (반경: 200m)');
              },
            ),
          ],
        ),
      ),
    );
  }
}
