import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';

/// 모임 장소 지도 미리보기
///
/// 조작할 수 없는 정지 상태다 — 상세 화면은 세로 스크롤이라, 지도가 제스처를
/// 먹으면 지도 위에서 스크롤이 멈춘다. 탭하면 전체 화면 지도로 넘어가 거기서
/// 확대·이동한다.
///
/// Android는 lite mode(정적 이미지)를 쓴다. 목록에서 상세로 자주 드나드는
/// 화면이라 매번 지도 엔진을 띄우면 눈에 띄게 버벅인다. iOS는 lite mode가
/// 없어 일반 지도를 그리되 제스처만 막는다.
class CommunityMapPreview extends StatelessWidget {
  const CommunityMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.locationLabel,
    this.height = 180,
    this.onTap,
  });

  final double latitude;
  final double longitude;

  /// 전체 화면 지도의 제목. 없으면 지도만 띄운다.
  final String? locationLabel;

  final double height;

  /// 탭 동작 교체. 기본은 전체 화면 지도를 여는 것이고, 작성 화면처럼 탭이
  /// 다른 뜻(장소 재선택)인 곳이 이걸 넘긴다.
  final VoidCallback? onTap;

  static const _zoom = 15.0;

  /// 전체 화면 지도의 줌 한계. 미리보기 카드는 제스처를 다 꺼둬 해당 없다.
  /// 값은 장소 선택 화면과 같다 (`community_location_picker_page.dart`).
  static const _zoomLimit = MinMaxZoomPreference(12, 20);

  /// 미리보기 지도 — 테스트에서 탭 대상을 찾는다.
  static const Key previewKey = Key('community_map_preview');

  bool get _useLiteMode => !kIsWeb && Platform.isAndroid;

  @override
  Widget build(BuildContext context) {
    final target = LatLng(latitude, longitude);
    // 이 화면을 덮는 다음 화면의 전환. null이면 라우트 밖이라 덮일 일이 없다.
    final covering = ModalRoute.of(context)?.secondaryAnimation;

    return GestureDetector(
      key: previewKey,
      onTap:
          onTap ??
          () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  _CommunityMapFullscreen(target: target, title: locationLabel),
            ),
          ),
      child: SizedBox(
        height: height.h,
        width: double.infinity,
        child: covering == null
            ? _buildMap(target)
            : AnimatedBuilder(
                animation: covering,
                builder: (context, _) =>
                    covering.status == AnimationStatus.dismissed
                    ? _buildMap(target)
                    : const ColoredBox(color: AppColors.black100),
              ),
      ),
    );
  }

  /// 지도 본체.
  ///
  /// **다른 화면이 이 화면을 덮는 동안에는 트리에서 들어낸다.** 덮인 화면은
  /// `Overlay`가 레이아웃에서 빼는데, 플랫폼 뷰는 전역 포인터 라우트를 걸어 두고
  /// 터치가 올 때마다 자기 크기를 묻는다 — 레이아웃 없는 상태에서 화면 아무
  /// 데나 누르면 그 자리에서 앱이 죽는다. iOS `RenderDarwinPlatformView`,
  /// Android `RenderAndroidView`, 둘 다 같은 `hasSize` assert다.
  ///
  /// `isCurrent`가 아니라 `secondaryAnimation`을 보는 이유: 바텀시트·다이얼로그가
  /// 떠도 `isCurrent`는 false가 되지만 그때는 아래 화면이 그대로 레이아웃되므로
  /// 크래시 조건이 아니다. 거기서까지 들어내면 시트를 여닫을 때마다 지도가 새로
  /// 뜬다 (작성 화면의 날짜·인원 시트).
  ///
  /// 되돌아올 때 깜빡이지 않는 이유: 덮는 화면이 닫히기 시작하는 순간
  /// `dismissed`가 풀려, 전환이 끝나기 전에 지도가 다시 붙는다.
  Widget _buildMap(LatLng target) {
    // 지도가 포인터를 못 받게 막는다 — 위의 GestureDetector는 그대로 탭을 받는다.
    return AbsorbPointer(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: target, zoom: _zoom),
        liteModeEnabled: _useLiteMode,
        markers: {
          Marker(markerId: const MarkerId('meeting'), position: target),
        },
        // 미리보기에 필요 없는 컨트롤은 전부 끈다.
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        zoomGesturesEnabled: false,
        scrollGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
      ),
    );
  }
}

/// 전체 화면 지도 — 미리보기를 탭하면 열린다.
class _CommunityMapFullscreen extends StatelessWidget {
  const _CommunityMapFullscreen({required this.target, this.title});

  final LatLng target;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppTopBar(
        titleWidget: title == null
            ? null
            : Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading_20.copyWith(
                  color: AppColors.black,
                ),
              ),
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.vertical16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: target,
            zoom: CommunityMapPreview._zoom,
          ),
          minMaxZoomPreference: CommunityMapPreview._zoomLimit,
          markers: {
            Marker(markerId: const MarkerId('meeting'), position: target),
          },
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}
