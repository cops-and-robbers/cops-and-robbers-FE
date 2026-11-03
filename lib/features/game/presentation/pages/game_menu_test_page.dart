import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/map_styles.dart';
import '../../../../core/widgets/buttons/my_location_button.dart';
import '../../../../core/widgets/buttons/svg_icon_button.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/game_fab_menu.dart';
import '../widgets/game_timer_text.dart';
import 'ar_capture_page.dart';

/// 인게임 버튼 개편 시험 화면 (#655). main에 머지하기 전에 제거한다.
///
/// 게임 서버 없이 화면 구성만 보여 준다. 상단바 오른쪽 버튼으로 경찰과 도둑을 바꾼다. 지도는 세종대 일대 고정이고,
/// 포착과 나가기 외 버튼은 눌러도 동작하지 않는다.
class GameMenuTestPage extends StatefulWidget {
  const GameMenuTestPage({super.key});

  @override
  State<GameMenuTestPage> createState() => _GameMenuTestPageState();
}

class _GameMenuTestPageState extends State<GameMenuTestPage> {
  static const LatLng _center = LatLng(37.5509, 127.0752);

  final DateTime _startTime = DateTime.now();
  bool _isPolice = false;

  Circle _missionPoint(String id, double dLat, double dLng) => Circle(
    circleId: CircleId(id),
    center: LatLng(_center.latitude + dLat, _center.longitude + dLng),
    radius: 30,
    strokeWidth: 2,
    strokeColor: AppColors.blue,
    fillColor: AppColors.blue500Alpha20,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buttonBottom = 38.h + MediaQuery.paddingOf(context).bottom;
    final isDark = !_isPolice;
    final accent = isDark ? AppColors.green : AppColors.blue;
    final buttonColor = isDark ? AppColors.black : null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      appBar: AppTopBar(
        isDarkMode: isDark,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: SvgPicture.asset(
            AppIcons.gameOut,
            width: 24.w,
            height: 24.w,
            colorFilter: ColorFilter.mode(
              isDark ? AppColors.white : AppColors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
        titleWidget: GameTimerText(
          startTime: _startTime,
          totalDuration: const Duration(minutes: 30),
          locationRevealIntervalMinutes: 5,
          isDarkMode: isDark,
        ),
        actions: [
          // 시험 화면 전용: 경찰과 도둑 화면을 바꿔 본다.
          IconButton(
            onPressed: () => setState(() => _isPolice = !_isPolice),
            icon: Icon(
              Icons.swap_horiz,
              color: isDark ? AppColors.white : AppColors.black,
              size: 24.w,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _center,
                zoom: 16,
              ),
              style: isDark ? MapStyles.dark : null,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              circles: {
                Circle(
                  circleId: const CircleId('playground'),
                  center: _center,
                  radius: 500,
                  strokeWidth: 2,
                  strokeColor: accent,
                  fillColor: AppColors.blackAlpha0,
                ),
                _missionPoint('mission1', 0.0012, -0.0011),
                _missionPoint('mission2', -0.0003, 0.0012),
                _missionPoint('mission3', -0.0016, -0.0004),
              },
            ),
          ),
          Positioned(
            left: 20.w,
            bottom: buttonBottom,
            child: MyLocationButton(
              onPressed: () {},
              isFocused: true,
              focusedColor: accent,
              unfocusedColor: isDark ? AppColors.green500 : AppColors.blue500,
              backgroundColor: buttonColor,
              isDarkMode: isDark,
            ),
          ),
          Positioned(
            right: 20.w,
            bottom: buttonBottom,
            // 채팅은 언제 올지 몰라 메뉴에 넣지 않고 지도에 둔다.
            child: SvgIconButton(
              assetPath: AppIcons.comment,
              onPressed: () {},
              iconColor: accent,
              backgroundColor: buttonColor,
              isDarkMode: isDark,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: buttonBottom,
            child: Center(
              child: GameFabMenu(
                isDarkMode: isDark,
                // 왼쪽부터 좌표, 참가자, 체포. 모드 전용 항목은 해당 모드에서만 오른쪽 끝에 붙는다.
                items: [
                  GameFabMenuItem(
                    label: l10n.gameMenuGrid,
                    icon: AppIcons.grid,
                  ),
                  GameFabMenuItem(
                    label: l10n.gameMenuParticipants,
                    icon: AppIcons.person,
                  ),
                  // 경찰은 스캔해서 체포하고, 도둑은 자기 QR을 보여 준다.
                  GameFabMenuItem(
                    label: _isPolice ? l10n.gameMenuArrest : l10n.gameMenuMyQr,
                    icon: _isPolice ? AppIcons.qrScan : AppIcons.qrCode,
                  ),
                  // 미션은 도둑 전용이다.
                  if (!_isPolice)
                    GameFabMenuItem(
                      label: l10n.gameMenuCapture,
                      icon: AppIcons.camera,
                      highlighted: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ArCapturePage(),
                        ),
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
}
