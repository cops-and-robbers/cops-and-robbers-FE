import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/community_address_entity.dart';
import '../providers/community_provider.dart';

/// 작성 화면이 돌려받는 모임 장소.
///
/// [region]은 화면에 보여 줄 값일 뿐이다 — 서버는 글을 저장할 때 좌표로 다시
/// 역지오코딩하므로 전송하지 않는다.
typedef CommunityPickedLocation = ({
  double latitude,
  double longitude,
  String? region,
});

/// 모임 장소 선택 화면
///
/// 지도를 탭한 지점으로 핀이 옮겨가고, 그때마다 좌표 주소를 조회해 하단에
/// 보여 준다. 주소를 확인시키는 이유는 좌표만으로는 사용자가 "여기가 맞나"를
/// 판단할 수 없기 때문이다.
///
/// 주소를 못 찾는 좌표(바다·산속 등)는 서버가 글 작성도 거부하므로, 여기서
/// 미리 막아 작성 화면까지 갔다가 400을 맞는 왕복을 없앤다.
class CommunityLocationPickerPage extends ConsumerStatefulWidget {
  const CommunityLocationPickerPage({super.key, this.initialTarget});

  /// 수정·재선택 시 이전에 고른 좌표. 없으면 현재 위치에서 시작한다.
  final LatLng? initialTarget;

  /// 지도 — 테스트에서 탭 대상을 찾는다.
  static const Key mapKey = Key('community_location_picker_map');

  /// 하단 확인 버튼.
  static const Key confirmKey = Key('community_location_picker_confirm');

  @override
  ConsumerState<CommunityLocationPickerPage> createState() =>
      _CommunityLocationPickerPageState();
}

class _CommunityLocationPickerPageState
    extends ConsumerState<CommunityLocationPickerPage> {
  /// 위치 권한이 없을 때 처음 보여 줄 좌표 — 구역 설정 위젯들과 같은 값을 쓴다.
  static const LatLng _fallbackTarget = LatLng(37.5480, 127.0810);

  static const double _zoom = 16;

  /// 줌 한계 — 상한 20은 다른 지도들과 같은 값이고, 하한 12는 인게임 지도
  /// (`google_map_view.dart:46`) 기본값을 그대로 쓴다. 구역이 없는 지도라
  /// 반경으로 계산할 게 없고, 동네를 못 알아볼 만큼 축소되면 어디를 찍는지
  /// 알 수 없어 핀을 정확히 놓을 수 없다.
  static const _zoomLimit = MinMaxZoomPreference(12, 20);

  LatLng? _target;

  /// 현재 핀의 주소. null이면 아직 첫 조회 전이다.
  /// 로딩·성공·실패를 한 필드로 들고 있어야 하단 카드가 세 상태를 한 곳에서 그린다.
  AsyncValue<CommunityAddressEntity>? _address;

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _startFromInitialTarget();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// 시작 좌표를 정하고 곧바로 주소를 한 번 조회한다.
  ///
  /// 조회를 미루면 처음 열었을 때 핀은 찍혀 있는데 확인 버튼은 죽어 있어
  /// "왜 안 눌리지"가 된다.
  Future<void> _startFromInitialTarget() async {
    final initial = widget.initialTarget ?? await _currentOrFallback();
    if (!mounted) return;
    setState(() => _target = initial);
    await _lookUp(initial);
  }

  /// 권한이 **이미 있을 때만** 현재 위치를 쓴다 — 장소를 고르러 들어온 화면에서
  /// 권한 팝업부터 띄우지 않는다.
  ///
  /// 목록이 쓰는 판별기를 그대로 재사용한다. 그쪽이 이미 "권한 있으면 좌표,
  /// 없으면 국가 코드"라서, 좌표가 비면 여기서도 권한이 없는 것이다.
  Future<LatLng> _currentOrFallback() async {
    final query = await ref.read(countryQueryResolverProvider)();
    final latitude = query.latitude;
    final longitude = query.longitude;
    if (latitude == null || longitude == null) return _fallbackTarget;
    return LatLng(latitude, longitude);
  }

  Future<void> _lookUp(LatLng target) async {
    setState(() => _address = const AsyncValue.loading());

    try {
      final address = await ref
          .read(communityRepositoryProvider)
          .getAddress(latitude: target.latitude, longitude: target.longitude);
      // 빠르게 여러 번 탭하면 응답이 순서를 바꿔 도착할 수 있다. 마지막으로 찍은
      // 핀의 결과가 아니면 버린다 — 아니면 핀과 주소가 어긋난 채로 확정된다.
      if (!mounted || target != _target) return;
      setState(() => _address = AsyncValue.data(address));
    } catch (error, stackTrace) {
      if (!mounted || target != _target) return;
      setState(() => _address = AsyncValue.error(error, stackTrace));
    }
  }

  void _onMapTapped(LatLng target) {
    setState(() => _target = target);
    _lookUp(target);
  }

  void _confirm() {
    final target = _target;
    final region = _address?.valueOrNull?.region;
    if (target == null) return;

    Navigator.of(context).pop<CommunityPickedLocation>((
      latitude: target.latitude,
      longitude: target.longitude,
      region: region,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final target = _target;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: PreviousButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(
          l10n.communityLocationPickerTitle,
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
      ),
      body: target == null
          // 현재 위치를 묻는 동안. 지도를 좌표 없이 띄우면 엉뚱한 곳에서
          // 시작했다가 카메라가 튀어 어지럽다.
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  key: CommunityLocationPickerPage.mapKey,
                  initialCameraPosition: CameraPosition(
                    target: target,
                    zoom: _zoom,
                  ),
                  minMaxZoomPreference: _zoomLimit,
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: _onMapTapped,
                  markers: {
                    Marker(
                      markerId: const MarkerId('picked'),
                      position: target,
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildAddressCard(l10n),
                ),
              ],
            ),
    );
  }

  /// 하단 확인 카드 — 조회 중 / 주소 있음 / 주소 없음 세 상태를 그린다.
  Widget _buildAddressCard(AppLocalizations l10n) {
    final address = _address;

    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(AppSpacing.horizontal16),
        padding: AppPadding.all16,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.ver2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              // 상태가 바뀌어도 카드 높이가 흔들리지 않게 한 줄 높이를 고정한다.
              height: 44.h,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildAddressText(l10n, address),
              ),
            ),
            SizedBox(height: AppSpacing.vertical12),
            AppButton(
              key: CommunityLocationPickerPage.confirmKey,
              text: l10n.communityLocationPickerConfirm,
              // 주소를 못 찾은 좌표는 서버가 글 작성도 거부한다 — 여기서 막는다.
              onPressed: address?.hasValue ?? false ? _confirm : null,
              width: double.infinity,
              backgroundColor: AppColors.logo,
              showBorder: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressText(
    AppLocalizations l10n,
    AsyncValue<CommunityAddressEntity>? address,
  ) {
    if (address == null || address.isLoading) {
      return Text(
        l10n.communityLocationPickerLoading,
        style: AppTextStyles.label_16.copyWith(color: AppColors.black300),
      );
    }

    if (address.hasError) {
      return Text(
        l10n.communityLocationPickerNotFound,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.label_16.copyWith(color: AppColors.red900),
      );
    }

    // region·address가 둘 다 비는 경우는 서버가 200을 주면서 값을 안 채운 때다.
    // 확인 버튼은 살아 있어도 되지만(좌표는 유효하다) 표시할 글자는 없다.
    final value = address.requireValue;
    final label = value.address ?? value.region;

    return Text(
      label ?? l10n.communityLocationPickerHint,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.label_16.copyWith(color: AppColors.black),
    );
  }
}
