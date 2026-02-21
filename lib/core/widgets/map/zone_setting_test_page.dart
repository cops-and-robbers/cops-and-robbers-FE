import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import 'zone_setting_widget.dart';

/// 구역 설정 위젯 테스트 페이지
/// Zone setting widget test page
///
/// **테스트 항목**:
/// - Circle 렌더링
/// - 마커 드래그 동작
/// - 슬라이더 반경 조절
/// - 색상 커스터마이징
class ZoneSettingTestPage extends StatefulWidget {
  const ZoneSettingTestPage({super.key});

  @override
  State<ZoneSettingTestPage> createState() => _ZoneSettingTestPageState();
}

class _ZoneSettingTestPageState extends State<ZoneSettingTestPage> {
  LatLng? _selectedCenter;
  double _selectedRadius = 500.0;

  // ZoneSettingWidget의 GlobalKey (resetToCurrentLocation 호출용)
  final GlobalKey<State<ZoneSettingWidget>> _zoneSettingKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('구역 설정 테스트 (Circle)'),
        centerTitle: true,
        actions: [
          // 내 위치로 돌아가기 버튼
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _resetToMyLocation,
            tooltip: '내 위치로 이동',
          ),
        ],
      ),
      body: Column(
        children: [
          // 구역 설정 위젯 (고정)
          ZoneSettingWidget(
            key: _zoneSettingKey,
            initialRadius: 500,
            minRadius: 100,
            maxRadius: 1000,
            onZoneChanged: (center, radius) {
              setState(() {
                _selectedCenter = center;
                _selectedRadius = radius;
              });
              debugPrint('🎮 원형 업데이트: ($center, ${radius}m)');
            },
            // 색상 기본값 (blue 계열)
          ),

          SizedBox(height: AppSpacing.vertical16),

          // 스크롤 가능한 정보 영역
          Expanded(
            child: SingleChildScrollView(
              padding: AppPadding.horizontal16,
              child: Column(
                children: [
                  // 현재 선택된 값 표시
                  Container(
                    padding: AppPadding.all16,
                    decoration: BoxDecoration(
                      color: AppColors.blue100,
                      borderRadius: AppRadius.medium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // 예시이므로 fontsize 이렇게 설정함
                          '현재 설정',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.vertical8),
                        if (_selectedCenter != null) ...[
                          Text(
                            '중심: ${_selectedCenter!.latitude.toStringAsFixed(4)}, ${_selectedCenter!.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                        Text(
                          '반경: ${_selectedRadius.toInt()}m',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.vertical16),

                  // API 요청 미리보기
                  Container(
                    padding: AppPadding.all16,
                    decoration: BoxDecoration(
                      color: AppColors.black100,
                      borderRadius: AppRadius.medium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'API 요청 (미리보기)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.vertical8),
                        if (_selectedCenter != null)
                          Text(
                            '''{
  "playgroundType": "CIRCLE",
  "playgroundCenter": {
    "latitude": ${_selectedCenter!.latitude},
    "longitude": ${_selectedCenter!.longitude}
  },
  "playgroundRadiusInMeters": ${_selectedRadius.toInt()}
}''',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          )
                        else
                          const Text(
                            '위젯 초기화 중...',
                            style: TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 내 위치로 돌아가기
  /// Reset zone center to my location
  Future<void> _resetToMyLocation() async {
    final state = _zoneSettingKey.currentState;
    if (state == null) {
      debugPrint('⚠️ ZoneSettingWidget state를 찾을 수 없습니다');
      return;
    }

    // ZoneSettingWidget의 resetToCurrentLocation 메서드 호출
    final zoneState = state as dynamic;
    await zoneState.resetToCurrentLocation();

    debugPrint('✅ 내 위치로 이동 완료');
  }
}
