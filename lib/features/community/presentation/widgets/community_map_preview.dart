import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/previous_button.dart';

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

  /// 미리보기 지도 — 테스트에서 탭 대상을 찾는다.
  static const Key previewKey = Key('community_map_preview');

  bool get _useLiteMode => !kIsWeb && Platform.isAndroid;

  @override
  Widget build(BuildContext context) {
    final target = LatLng(latitude, longitude);

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
        // 지도가 포인터를 못 받게 막는다 — 위의 GestureDetector는 그대로 탭을 받는다.
        child: AbsorbPointer(
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
        ),
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
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => Navigator.of(context).pop()),
        centerTitle: true,
        title: title == null
            ? null
            : Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading_20.copyWith(
                  color: AppColors.black,
                ),
              ),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.vertical16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: target,
            zoom: CommunityMapPreview._zoom,
          ),
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
