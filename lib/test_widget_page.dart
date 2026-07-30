import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/spacing_and_radius.dart';
import 'core/constants/text_styles.dart';
import 'core/network/websocket/stomp_connection.dart';
import 'core/widgets/buttons/app_button.dart';
import 'core/widgets/dialogs/dialog_animation.dart';
import 'core/widgets/dialogs/reconnect_modal.dart';
import 'core/widgets/map/pin_zone_setting_widget.dart';
import 'features/auth/presentation/pages/agreement_page.dart';
import 'features/auth/presentation/pages/nickname_setup_page.dart';
import 'features/game/data/models/game_area_model.dart';
import 'features/game/domain/entities/area_shape.dart';
import 'features/game/domain/entities/game_result_entity.dart';
import 'features/game/presentation/providers/game_result_provider.dart';
import 'features/game/presentation/providers/player_game_record_provider.dart';
import 'features/game/presentation/widgets/game_over_result_dialog.dart';
import 'features/game/presentation/widgets/ping_selection_card.dart';
import 'features/session/presentation/pages/setup_playground_page.dart';
import 'features/session/presentation/pages/setup_prison_page.dart';
import 'features/session/presentation/widgets/area_type_toggle.dart';
import 'router/route_paths.dart';

/// 위젯 시각 테스트 페이지
///
/// 앱 흐름에서 재현하기 번거로운 feature 위젯·다이얼로그·페이지만 모아 확인한다.
/// (AppButton 등 기본 core 컴포넌트 데모는 정리 — 실제 화면에서 확인)
class TestWidgetPage extends StatefulWidget {
  const TestWidgetPage({super.key});

  @override
  State<TestWidgetPage> createState() => _TestWidgetPageState();
}

class _TestWidgetPageState extends State<TestWidgetPage> {
  // 폴리곤 구역(#456) 테스트용 상태
  GameAreaType _areaTypePreview = GameAreaType.circle;
  int _pinPreviewCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('위젯 테스트'),
        centerTitle: true,
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.all20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // 페이지 이동 테스트
              // ============================================
              _buildSectionTitle('페이지 이동 테스트'),
              SizedBox(height: AppSpacing.vertical16),

              AppButton(
                text: '닉네임 설정 페이지 열기',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NicknameSetupPage(),
                    ),
                  );
                },
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.black,
                showBorder: false,
              ),
              SizedBox(height: AppSpacing.vertical12),

              AppButton(
                text: '약관 동의 페이지 열기',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AgreementPage(),
                    ),
                  );
                },
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.black,
                showBorder: false,
              ),
              SizedBox(height: AppSpacing.vertical12),

              AppButton(
                text: '점검 페이지 (Maintenance)',
                onPressed: () => context.go(RoutePaths.maintenance),
                backgroundColor: AppColors.black800,
                showBorder: false,
              ),
              SizedBox(height: AppSpacing.vertical12),

              AppButton(
                text: '강제 업데이트 페이지 (Force Update)',
                onPressed: () => context.go(RoutePaths.forceUpdate),
                backgroundColor: AppColors.black800,
                showBorder: false,
              ),

              SizedBox(height: AppSpacing.vertical64),

              // ============================================
              // GameOverResultDialog 테스트
              // ============================================
              _buildSectionTitle('GameOverResultDialog 테스트'),
              SizedBox(height: AppSpacing.vertical8),
              Text(
                '4조합 버튼 — mock AsyncValue.data로 다이얼로그 표시',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.black400,
                ),
              ),
              SizedBox(height: AppSpacing.vertical16),

              AppButton(
                text: '경찰 승리 (light)',
                onPressed: () => _showMockGameOverDialog(
                  context: context,
                  isDarkMode: false,
                  myTeam: 'POLICE',
                  winnerTeam: 'POLICE',
                ),
                backgroundColor: AppColors.blue,
                showBorder: false,
              ),
              SizedBox(height: AppSpacing.vertical12),

              AppButton(
                text: '경찰 패배 (light)',
                onPressed: () => _showMockGameOverDialog(
                  context: context,
                  isDarkMode: false,
                  myTeam: 'POLICE',
                  winnerTeam: 'ROBBER',
                ),
                backgroundColor: AppColors.red,
                showBorder: false,
              ),
              SizedBox(height: AppSpacing.vertical12),

              AppButton(
                text: '도둑 승리 (dark)',
                onPressed: () => _showMockGameOverDialog(
                  context: context,
                  isDarkMode: true,
                  myTeam: 'ROBBER',
                  winnerTeam: 'ROBBER',
                ),
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.black,
                showBorder: false,
              ),
              SizedBox(height: AppSpacing.vertical12),

              AppButton(
                text: '도둑 패배 (dark)',
                onPressed: () => _showMockGameOverDialog(
                  context: context,
                  isDarkMode: true,
                  myTeam: 'ROBBER',
                  winnerTeam: 'POLICE',
                ),
                backgroundColor: AppColors.black800,
                showBorder: false,
              ),

              SizedBox(height: AppSpacing.vertical64),

              // ============================================
              // ReconnectModal 테스트
              // ============================================
              _buildSectionTitle('ReconnectModal 테스트'),
              SizedBox(height: AppSpacing.vertical8),
              Text(
                '"재연결" 탭 → 2초 스피너 → 모달 자동 닫힘',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.black400,
                ),
              ),
              SizedBox(height: AppSpacing.vertical16),

              // 경찰팀 (light 테마, 파란 버튼)
              AppButton(
                text: '재연결 모달 — 경찰 (light)',
                onPressed: () {
                  final notifier = ValueNotifier(
                    StompConnectionState.disconnected,
                  );
                  final nav = Navigator.of(context);
                  ReconnectModal.show(
                    context: context,
                    isDarkMode: false,
                    stateNotifier: notifier,
                    onReconnect: () {
                      // connecting 상태 → 2초 후 connected 처리 후 모달 닫기
                      notifier.value = StompConnectionState.connecting;
                      Future.delayed(const Duration(seconds: 2), () {
                        if (nav.canPop()) nav.pop();
                        notifier.dispose();
                      });
                    },
                  );
                },
                backgroundColor: AppColors.blue,
                showBorder: false,
              ),
              SizedBox(height: AppSpacing.vertical12),

              // 도둑팀 (dark 테마, 초록 버튼)
              AppButton(
                text: '재연결 모달 — 도둑 (dark)',
                onPressed: () {
                  final notifier = ValueNotifier(
                    StompConnectionState.disconnected,
                  );
                  final nav = Navigator.of(context);
                  ReconnectModal.show(
                    context: context,
                    isDarkMode: true,
                    stateNotifier: notifier,
                    onReconnect: () {
                      notifier.value = StompConnectionState.connecting;
                      Future.delayed(const Duration(seconds: 2), () {
                        if (nav.canPop()) nav.pop();
                        notifier.dispose();
                      });
                    },
                  );
                },
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.black,
                showBorder: false,
              ),

              SizedBox(height: AppSpacing.vertical64),

              // ============================================
              // 맵 핑 (PingSelectionCard) 테스트
              // ============================================
              _buildSectionTitle('맵 핑 선택 카드 테스트'),
              SizedBox(height: AppSpacing.vertical8),
              Text(
                '롱프레스 시 좌표 위에 뜨는 발견/의심 선택 카드. 셀을 탭하면 스낵바로 표시돼요.',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.black400,
                ),
              ),
              SizedBox(height: AppSpacing.vertical16),

              // 경찰 (light) — 파란 카드
              Text(
                '경찰 (light)',
                style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
              ),
              SizedBox(height: AppSpacing.vertical8),
              Center(
                child: PingSelectionCard(
                  isDarkMode: false,
                  onFound: () => _showPingSnack('발견 (경찰)'),
                  onSuspect: () => _showPingSnack('의심 (경찰)'),
                ),
              ),
              SizedBox(height: AppSpacing.vertical24),

              // 도둑 (dark) — 검정 카드 (어두운 배경 위에서 확인)
              Text(
                '도둑 (dark)',
                style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
              ),
              SizedBox(height: AppSpacing.vertical8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical24),
                decoration: BoxDecoration(
                  color: AppColors.black900,
                  borderRadius: AppRadius.medium,
                ),
                child: Center(
                  child: PingSelectionCard(
                    isDarkMode: true,
                    onFound: () => _showPingSnack('발견 (도둑)'),
                    onSuspect: () => _showPingSnack('의심 (도둑)'),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.vertical24),

              // 핑 마커 미리보기 (지도에 찍히는 핑은 종류 심볼 단독, 핀 꼬리 없음)
              Text(
                '핑 마커 미리보기 (지도에는 종류 심볼만 — 핀 꼬리는 선택 카드 전용)',
                style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
              ),
              SizedBox(height: AppSpacing.vertical12),
              Row(
                children: [
                  // light 마커 2종 (흰 배경)
                  _buildPingMarkerPreview(type: 'found', isDark: false),
                  SizedBox(width: AppSpacing.horizontal24),
                  _buildPingMarkerPreview(type: 'suspect', isDark: false),
                  SizedBox(width: AppSpacing.horizontal24),
                  // dark 마커 2종 (어두운 배경)
                  Container(
                    padding: EdgeInsets.all(AppSpacing.horizontal12),
                    decoration: BoxDecoration(
                      color: AppColors.black900,
                      borderRadius: AppRadius.medium,
                    ),
                    child: Row(
                      children: [
                        _buildPingMarkerPreview(type: 'found', isDark: true),
                        SizedBox(width: AppSpacing.horizontal24),
                        _buildPingMarkerPreview(type: 'suspect', isDark: true),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.vertical64),

              // ============================================
              // 폴리곤 구역 (#456) 테스트
              // ============================================
              _buildSectionTitle('폴리곤 구역 (#456) 테스트'),
              SizedBox(height: AppSpacing.vertical8),
              Text(
                'API 미연결 미리보기. 토글로 원형/핀 전환, 핀 위젯은 지도 탭으로 꼭짓점 추가·핀 탭으로 삭제.',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.black400,
                ),
              ),
              SizedBox(height: AppSpacing.vertical16),

              // 1) AreaTypeToggle (거리로/핀으로)
              Text(
                'AreaTypeToggle',
                style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
              ),
              SizedBox(height: AppSpacing.vertical8),
              Center(
                child: AreaTypeToggle(
                  selected: _areaTypePreview,
                  onChanged: (type) {
                    setState(() => _areaTypePreview = type);
                  },
                ),
              ),
              SizedBox(height: AppSpacing.vertical8),
              Center(
                child: Text(
                  '선택: ${_areaTypePreview == GameAreaType.circle ? '거리로 설정(원형)' : '핀으로 설정(폴리곤)'}',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.black400,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.vertical24),

              // 2) PinZoneSettingWidget 인라인 (플레이그라운드 blue)
              Text(
                'PinZoneSettingWidget (지도 탭 = 핀 추가 / 핀 탭 = 삭제)',
                style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
              ),
              SizedBox(height: AppSpacing.vertical8),
              ClipRRect(
                borderRadius: AppRadius.medium,
                child: PinZoneSettingWidget(
                  initialPoints: const [],
                  pinColor: AppColors.blue,
                  fillColor: AppColors.blue500Alpha20,
                  strokeColor: AppColors.blue800,
                  locationButtonColor: AppColors.blue,
                  mapHeight: 320.h,
                  onPointsChanged: (points) {
                    setState(() => _pinPreviewCount = points.length);
                  },
                ),
              ),
              SizedBox(height: AppSpacing.vertical8),
              Text(
                '현재 꼭짓점: $_pinPreviewCount개 (3~10개, 3개 이상부터 면적 칩 표시)',
                style: AppTextStyles.tag_12.copyWith(color: AppColors.black400),
              ),
              SizedBox(height: AppSpacing.vertical24),

              // 3) 실제 설정 페이지 열기 (로컬 draft만, 백엔드 미연결)
              AppButton(
                text: '플레이그라운드 설정 열기 (핀 모드, 폴리곤 시드)',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SetupPlaygroundPage(
                        editInitialShape: AreaShape.polygon(
                          points: [
                            for (final point in _mockPlaygroundPolygon)
                              GeoPoint(
                                latitude: point.latitude,
                                longitude: point.longitude,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                backgroundColor: AppColors.blue,
                showBorder: false,
                icon: Icon(
                  Icons.map_outlined,
                  size: 20.w,
                  color: AppColors.white,
                ),
                iconPosition: IconPosition.leading,
              ),
              SizedBox(height: AppSpacing.vertical12),

              AppButton(
                text: '플레이그라운드 설정 열기 (원형 모드)',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SetupPlaygroundPage(
                        editInitialShape: AreaShape.circle(
                          center: GeoPoint(
                            latitude: 37.5665,
                            longitude: 126.9780,
                          ),
                          radiusInMeters: 400,
                        ),
                      ),
                    ),
                  );
                },
                backgroundColor: AppColors.blue800,
                showBorder: false,
              ),
              SizedBox(height: AppSpacing.vertical12),

              AppButton(
                text: '감옥 설정 열기 (핀 모드, 참조 폴리곤 + 포함 검증)',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SetupPrisonPage(
                        editArgs: PrisonEditArgs(
                          playground: AreaShape.polygon(
                            points: [
                              for (final point in _mockPlaygroundPolygon)
                                GeoPoint(
                                  latitude: point.latitude,
                                  longitude: point.longitude,
                                ),
                            ],
                          ),
                          initialJail: AreaShape.polygon(
                            points: [
                              for (final point in _mockJailPolygon)
                                GeoPoint(
                                  latitude: point.latitude,
                                  longitude: point.longitude,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                backgroundColor: AppColors.red,
                showBorder: false,
                icon: Icon(
                  Icons.map_outlined,
                  size: 20.w,
                  color: AppColors.white,
                ),
                iconPosition: IconPosition.leading,
              ),

              SizedBox(height: AppSpacing.vertical64),
            ],
          ),
        ),
      ),
    );
  }

  /// 다이얼로그 시각 테스트용 헬퍼 — gameResult + playerGameRecord를 mock override
  void _showMockGameOverDialog({
    required BuildContext context,
    required bool isDarkMode,
    required String myTeam,
    required String winnerTeam,
  }) {
    const mockGameResultId = 999;
    const mockEntity = GameResultEntity(
      winnerTeam: 'POLICE', // UI에서는 myTeam==winnerTeam 비교만 쓰므로 임의값 OK
      durationSeconds: 1845, // 30:45
      totalArrestCount: 12,
      remainingRobberCount: 2,
    );
    final isRobber = myTeam == 'ROBBER';
    final mockRecord = PlayerGameRecord(
      route: _exampleMyRecordRoute,
      distanceMeters: 2543,
      myArrestCount: isRobber ? 0 : 3,
      myEscapeCount: isRobber ? 2 : 0,
      arrestLocations: isRobber ? const [] : _exampleArrestLocations,
      caughtLocations: isRobber ? _exampleCaughtLocations : const [],
      endedAt: DateTime.now(),
    );

    // GameOverResultDialog.show()와 동일한 배리어/pop 설정 — Provider override가
    // 필요해 showDialog를 직접 쓰지만 표시 디자인은 실제와 같게 유지한다.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: DialogAnimation.barrierColor,
      builder: (_) => PopScope(
        canPop: false,
        child: ProviderScope(
          overrides: [
            gameResultProvider(
              mockGameResultId,
            ).overrideWith((_) async => mockEntity),
            playerGameRecordNotifierProvider.overrideWith(
              () => _MockPlayerGameRecord(mockRecord),
            ),
          ],
          child: GameOverResultDialog(
            isDarkMode: isDarkMode,
            myTeam: myTeam,
            winnerTeam: winnerTeam,
            gameResultId: mockGameResultId,
            onGoHome: () => Navigator.of(context).pop(),
            onRematch: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  /// 핑 선택 카드 셀 탭 → 어떤 셀을 눌렀는지 스낵바로 표시 (시각 테스트용)
  void _showPingSnack(String label) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('핑: $label', style: AppTextStyles.paragraph_14),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 핑 마커 미리보기 (지도에 찍히는 핑은 종류 심볼 단독 — 핀 꼬리 없음)
  Widget _buildPingMarkerPreview({required String type, required bool isDark}) {
    final theme = isDark ? 'darkmode' : 'lightmode';
    return SvgPicture.asset(
      'assets/icons/icon_ping_${type}_marker_$theme.svg',
      width: 24.w,
      height: 24.w,
    );
  }

  /// 섹션 제목 위젯
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subHeading_18.copyWith(color: AppColors.black),
    );
  }
}

/// 내 기록 다이얼로그 미리보기용 예시 경로 (서울 시청 인근 가상 러닝 루프).
///
/// 상승 → 우상단 → 상단 좌측 횡단 → 좌측 하강 → 하단 복귀로 사방향 이동을 보여준다.
const List<LatLngModel> _exampleMyRecordRoute = [
  // 하단 시작 (남쪽)
  LatLngModel(latitude: 37.5651, longitude: 126.9779),
  LatLngModel(latitude: 37.5656, longitude: 126.9777),
  LatLngModel(latitude: 37.5661, longitude: 126.9776),
  // 북동으로 상승
  LatLngModel(latitude: 37.5666, longitude: 126.9780),
  LatLngModel(latitude: 37.5670, longitude: 126.9786),
  LatLngModel(latitude: 37.5673, longitude: 126.9793),
  // 우상단 꼭짓점
  LatLngModel(latitude: 37.5677, longitude: 126.9799),
  LatLngModel(latitude: 37.5682, longitude: 126.9802),
  // 좌측으로 꺾어 상단 횡단
  LatLngModel(latitude: 37.5686, longitude: 126.9799),
  LatLngModel(latitude: 37.5688, longitude: 126.9792),
  LatLngModel(latitude: 37.5689, longitude: 126.9785),
  LatLngModel(latitude: 37.5687, longitude: 126.9778),
  // 좌측 하강
  LatLngModel(latitude: 37.5683, longitude: 126.9773),
  LatLngModel(latitude: 37.5678, longitude: 126.9769),
  LatLngModel(latitude: 37.5672, longitude: 126.9767),
  // 하단으로 복귀 (살짝 동쪽)
  LatLngModel(latitude: 37.5666, longitude: 126.9768),
  LatLngModel(latitude: 37.5660, longitude: 126.9771),
  LatLngModel(latitude: 37.5655, longitude: 126.9775),
];

/// 경찰 미리보기용 — 내가 도둑을 잡은 지점(경로 위 점들).
const List<LatLngModel> _exampleArrestLocations = [
  LatLngModel(latitude: 37.5673, longitude: 126.9793),
  LatLngModel(latitude: 37.5688, longitude: 126.9792),
  LatLngModel(latitude: 37.5672, longitude: 126.9767),
];

/// 도둑 미리보기용 — 내가 잡힌 지점(경로 위 점들).
const List<LatLngModel> _exampleCaughtLocations = [
  LatLngModel(latitude: 37.5670, longitude: 126.9786),
  LatLngModel(latitude: 37.5666, longitude: 126.9768),
  LatLngModel(latitude: 37.5660, longitude: 126.9771),
];

/// 폴리곤 구역 미리보기용 — 플레이그라운드 사각형 (서울 시청 인근).
const List<LatLng> _mockPlaygroundPolygon = [
  LatLng(37.5680, 126.9760),
  LatLng(37.5680, 126.9800),
  LatLng(37.5650, 126.9800),
  LatLng(37.5650, 126.9760),
];

/// 폴리곤 구역 미리보기용 — 플레이그라운드 안쪽의 감옥 삼각형.
const List<LatLng> _mockJailPolygon = [
  LatLng(37.5668, 126.9775),
  LatLng(37.5668, 126.9785),
  LatLng(37.5660, 126.9780),
];

/// 미리보기용 mock 내 기록 Notifier — 고정 데이터를 반환.
class _MockPlayerGameRecord extends PlayerGameRecordNotifier {
  _MockPlayerGameRecord(this._data);

  final PlayerGameRecord _data;

  @override
  PlayerGameRecord build() => _data;
}
