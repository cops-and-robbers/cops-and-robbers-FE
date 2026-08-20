import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/community_provider.dart';
import '../widgets/community_date_sheet.dart';
import '../widgets/community_headcount_sheet.dart';
import '../widgets/community_map_preview.dart';
import 'community_location_picker_page.dart';

/// 모집글 작성 화면
///
/// 커뮤니티 목록의 플로팅 "모집글 작성" 버튼에서 진입한다. 다섯 항목(제목·설명·
/// 날짜·만나는 곳·좌표)이 모두 차야 우측 상단 완료가 살아난다 — 백엔드
/// `CommunityPostCreateRequest`가 전부 required라 하나라도 비면 서버가 거부한다.
///
/// 장소가 둘로 나뉘는 이유(DEC-0015): 좌표로는 건물명을 신뢰할 수준으로 얻을 수
/// 없어, 지도에서 **좌표**를 찍고 "만나는 곳"은 작성자가 **직접 입력**한다.
/// 서버는 좌표를 역지오코딩해 동 단위 지역을 따로 저장한다.
class CommunityCreatePage extends ConsumerStatefulWidget {
  const CommunityCreatePage({super.key});

  /// 좌표 선택 카드 — 테스트에서 탭 대상을 찾는다.
  static const Key mapCardKey = Key('community_create_map_card');

  @override
  ConsumerState<CommunityCreatePage> createState() =>
      _CommunityCreatePageState();
}

class _CommunityCreatePageState extends ConsumerState<CommunityCreatePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();

  /// 날짜는 직접 입력하지 않지만, 다른 카드와 같은 서체·여백을 공짜로 쓰려고
  /// 읽기 전용 `AppTextField`로 그린다. 그래서 컨트롤러가 필요하다.
  final _dateController = TextEditingController();

  // 제목에서 엔터를 치면 설명으로 넘어간다. 설명은 여러 줄 입력이라 엔터를
  // 줄바꿈에 쓰므로 체인이 여기서 끊기고, 날짜는 시트로만 고른다.
  final _contentFocus = FocusNode();

  DateTime? _meetingAt;
  int _headcount = _defaultHeadcount;

  /// 지도에서 고른 모임 좌표. 안 고르면 완료가 살아나지 않는다.
  CommunityPickedLocation? _picked;

  /// 등록 요청이 날아가 있는 동안. 완료를 두 번 눌러 글이 두 개 생기는 걸 막는다.
  bool _submitting = false;

  /// 시안 기본값. 백엔드 허용 범위(2~50) 안에 있다.
  static const int _defaultHeadcount = 10;

  /// 카드 높이 — 모두 내부 패딩 16(`AppPadding.all16`) 기준으로 잡았다.
  /// 한 줄짜리 최소 높이는 16 + 16(label16Medium 한 줄) + 16 = 48이다.
  static double get _fieldHeight => 48.h;
  static double get _contentHeight => 150.h;
  static double get _locationHeight => 54.h;
  static double get _mapHeight => 120.h;
  static double get _stepperSize => 36.w;

  @override
  void initState() {
    super.initState();
    // 완료 버튼 활성 여부가 세 입력 모두에 걸려 있어 글자 수가 아니라
    // "비었나/찼나"가 바뀌는 순간만 다시 그린다.
    for (final controller in [
      _titleController,
      _contentController,
      _locationController,
    ]) {
      controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _titleController,
      _contentController,
      _locationController,
    ]) {
      controller.removeListener(_onTextChanged);
      controller.dispose();
    }
    _dateController.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  bool _lastCanSubmit = false;

  void _onTextChanged() {
    final canSubmit = _canSubmit;
    if (canSubmit == _lastCanSubmit) return;
    setState(() => _lastCanSubmit = canSubmit);
  }

  bool get _canSubmit =>
      _titleController.text.trim().isNotEmpty &&
      _contentController.text.trim().isNotEmpty &&
      _locationController.text.trim().isNotEmpty &&
      _meetingAt != null &&
      _picked != null &&
      !_submitting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      // AppBar만 흰색이고 그 아래 본문은 목록과 같은 연하늘 배경.
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: l10n.buttonCancel,
          icon: SvgPicture.asset(
            'assets/icons/icon_delete.svg',
            width: 24.w,
            height: 24.h,
          ),
        ),
        title: Text(
          l10n.communityCreatePost,
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
        actions: [_buildDoneAction(l10n)],
      ),
      body: SafeArea(
        // 키보드가 올라오면 아래 항목이 가려지므로 본문 전체가 스크롤한다.
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontal16,
            vertical: AppSpacing.vertical20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(l10n.communityCreateLabelTitle),
              _buildTitleField(l10n),
              _buildSectionGap(),
              _buildLabel(l10n.communityCreateLabelContent),
              _buildContentField(l10n),
              _buildSectionGap(),
              _buildLabel(l10n.communityCreateLabelDate),
              _buildDateField(l10n),
              _buildSectionGap(),
              _buildLabel(l10n.communityCreateLabelLocation),
              _buildLocationField(l10n),
              SizedBox(height: AppSpacing.vertical12),
              _buildMapCard(l10n),
              _buildSectionGap(),
              _buildLabel(l10n.communityCreateLabelHeadcount),
              _buildHeadcountRow(l10n),
            ],
          ),
        ),
      ),
    );
  }

  /// 완료 — 네 항목이 다 차기 전에는 눌러도 반응하지 않는다.
  Widget _buildDoneAction(AppLocalizations l10n) {
    final enabled = _canSubmit;

    return Semantics(
      button: true,
      enabled: enabled,
      label: l10n.buttonDone,
      excludeSemantics: true,
      onTap: enabled ? _submit : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? _submit : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal16),
          child: Center(
            child: Text(
              l10n.buttonDone,
              style: AppTextStyles.label_16.copyWith(
                color: enabled ? AppColors.logo : AppColors.black200,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.vertical10),
      child: Text(
        text,
        style: AppTextStyles.paragraph14Semibold.copyWith(
          color: AppColors.black600,
        ),
      ),
    );
  }

  Widget _buildSectionGap() => SizedBox(height: AppSpacing.vertical20);

  /// 입력 카드 그림자.
  ///
  /// `AppTextField`는 그림자를 파라미터로 받지 않으므로 밖에서 씌운다. 필드와
  /// 같은 반경을 줘야 그림자가 모양을 따라간다 (community_page.dart:433과 같은 방식).
  Widget _wrapWithShadow(Widget field) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.ver2,
      ),
      child: field,
    );
  }

  Widget _buildTitleField(AppLocalizations l10n) {
    return _wrapWithShadow(
      AppTextField(
        controller: _titleController,
        hintText: l10n.communityCreateHintTitle,
        // 백엔드 title 제약과 같은 값. 잘라내는 게 아니라 입력을 막는다.
        maxLength: 100,
        width: double.infinity,
        height: _fieldHeight,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _contentFocus.requestFocus(),
        borderRadius: AppRadius.large,
        showBorder: false,
        hintColor: AppColors.black200,
      ),
    );
  }

  Widget _buildContentField(AppLocalizations l10n) {
    return _wrapWithShadow(
      SizedBox(
        height: _contentHeight,
        child: AppTextField(
          controller: _contentController,
          focusNode: _contentFocus,
          hintText: l10n.communityCreateHintContent,
          width: double.infinity,
          // 여러 줄 입력에서 엔터는 줄바꿈이다 — 규칙·준비물을 줄로 나눠 적는
          // 칸이라 여기서 포커스를 넘기면 그걸 못 쓴다.
          maxLines: 100,
          textAlignVertical: TextAlignVertical.top,
          borderRadius: AppRadius.large,
          showBorder: false,
          hintColor: AppColors.black200,
        ),
      ),
    );
  }

  /// 날짜 — 직접 입력하지 않고 시트로만 고른다.
  ///
  /// `readOnly`만으로는 탭이 TextField에 먹혀 키보드가 뜨므로 `AbsorbPointer`로
  /// 입력을 통째로 막고, 탭은 바깥 `GestureDetector`가 받는다.
  Widget _buildDateField(AppLocalizations l10n) {
    final value = _meetingAt;
    // 포맷은 요일 라벨을 ARB에서 꺼내므로 로케일이 바뀌면 결과도 달라진다.
    // 값을 고르는 시점이 아니라 그리는 시점에 채워야 언어 변경이 반영된다.
    _dateController.text = value == null ? '' : _formatMeetingAt(l10n, value);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openDateSheet,
      child: _wrapWithShadow(
        AbsorbPointer(
          child: AppTextField(
            controller: _dateController,
            hintText: l10n.communityCreateHintDate,
            readOnly: true,
            width: double.infinity,
            height: _fieldHeight,
            borderRadius: AppRadius.large,
            showBorder: false,
            hintColor: AppColors.black200,
            prefixIcon: _buildPrefixIcon('assets/icons/icon_date.svg'),
            prefixIconConstraints: const BoxConstraints(),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField(AppLocalizations l10n) {
    return _wrapWithShadow(
      AppTextField(
        controller: _locationController,
        hintText: l10n.communityCreateHintLocation,
        width: double.infinity,
        height: _locationHeight,
        textInputAction: TextInputAction.done,
        borderRadius: AppRadius.large,
        showBorder: false,
        hintColor: AppColors.black200,
        prefixIcon: _buildPrefixIcon('assets/icons/icon_pin.svg'),
        prefixIconConstraints: const BoxConstraints(),
      ),
    );
  }

  /// prefixIcon은 Material 기본 제약(최소 48×48)이 걸려 있어 그대로 두면 작은
  /// 아이콘이 과하게 벌어진다. 제약을 풀고 좌우 여백을 직접 준다.
  Widget _buildPrefixIcon(String assetPath) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.horizontal16,
        right: AppSpacing.horizontal8,
      ),
      child: SvgPicture.asset(assetPath, width: 20.w, height: 20.h),
    );
  }

  /// 좌표 선택 카드 — 탭하면 지도 화면이 열리고, 고르면 미리보기로 바뀐다.
  ///
  /// 좌표를 고르기 전에는 지도를 안 띄운다. 아무 데나 가리키는 지도는 사용자가
  /// "이미 골라졌나" 하고 오해하게 만든다.
  Widget _buildMapCard(AppLocalizations l10n) {
    final picked = _picked;

    if (picked == null) {
      return GestureDetector(
        key: CommunityCreatePage.mapCardKey,
        behavior: HitTestBehavior.opaque,
        onTap: _openLocationPicker,
        child: Container(
          width: double.infinity,
          height: _mapHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.ver2,
          ),
          child: Text(
            l10n.communityCreateHintPickLocation,
            style: AppTextStyles.label_16.copyWith(color: AppColors.black200),
          ),
        ),
      );
    }

    // 미리보기가 자체 탭 제스처를 갖고 있어 밖에서 감싸면 먹히지 않는다 —
    // 탭 동작 자체를 "전체 화면 지도" 대신 "장소 재선택"으로 갈아 끼운다.
    return ClipRRect(
      key: CommunityCreatePage.mapCardKey,
      borderRadius: AppRadius.large,
      child: CommunityMapPreview(
        latitude: picked.latitude,
        longitude: picked.longitude,
        locationLabel: picked.region,
        height: _mapHeight,
        onTap: _openLocationPicker,
      ),
    );
  }

  /// 지도 화면을 열고 고른 좌표를 받아 온다. 취소하면 기존 선택을 유지한다.
  Future<void> _openLocationPicker() async {
    final picked = await Navigator.of(context).push<CommunityPickedLocation>(
      MaterialPageRoute(
        builder: (_) => CommunityLocationPickerPage(
          initialTarget: _picked == null
              ? null
              : LatLng(_picked!.latitude, _picked!.longitude),
        ),
      ),
    );
    if (!mounted || picked == null) return;

    setState(() => _picked = picked);
  }

  Widget _buildHeadcountRow(AppLocalizations l10n) {
    return Row(
      children: [
        _buildStepperButton(
          glyph: '-',
          semanticsLabel: l10n.communityHeadcountDecrease,
          onTap: _headcount > CommunityHeadcountSheet.min
              ? () => _changeHeadcount(-1)
              : null,
        ),
        SizedBox(width: AppSpacing.horizontal12),
        // 숫자를 탭하면 휠 시트로 한 번에 고른다 — 10명을 40명으로 바꾸려고
        // +를 서른 번 누르게 두지 않는다.
        // 숫자 폭이 바뀌어도 −/+ 가 밀리지 않도록 최대값(50) 글자폭만큼 자리를
        // 미리 잡아 둔다. 접미사가 로케일마다 다르므로(명 / 人 / 없음) px 고정 대신
        // 같은 스타일의 최대 라벨을 투명하게 깔아 폭을 재게 한다.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openHeadcountSheet,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Visibility(
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Text(
                  l10n.communityHeadcountValue(CommunityHeadcountSheet.max),
                  style: _headcountTextStyle,
                ),
              ),
              Text(
                l10n.communityHeadcountValue(_headcount),
                style: _headcountTextStyle,
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.horizontal12),
        _buildStepperButton(
          glyph: '+',
          semanticsLabel: l10n.communityHeadcountIncrease,
          onTap: _headcount < CommunityHeadcountSheet.max
              ? () => _changeHeadcount(1)
              : null,
        ),
      ],
    );
  }

  /// 인원 숫자 스타일. 폭 자리잡이 텍스트와 반드시 같아야 해서 한 곳에 둔다.
  /// tabularFigures — 기본 숫자 글립은 폭이 제각각이라 자리수가 그대로여도
  /// 숫자가 좌우로 흔들린다.
  TextStyle get _headcountTextStyle => AppTextStyles.label16Medium.copyWith(
    color: AppColors.black,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// [onTap]이 null이면 한계에 닿은 상태 — 글리프를 흐린 색으로 바꾼다.
  Widget _buildStepperButton({
    required String glyph,
    required String semanticsLabel,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: _stepperSize,
          height: _stepperSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.ver2,
          ),
          child: Text(
            glyph,
            style: AppTextStyles.label16Medium.copyWith(
              color: enabled ? AppColors.black : AppColors.black300,
            ),
          ),
        ),
      ),
    );
  }

  void _changeHeadcount(int delta) {
    VibrationService.instance().buttonTap();
    setState(
      () => _headcount = (_headcount + delta).clamp(
        CommunityHeadcountSheet.min,
        CommunityHeadcountSheet.max,
      ),
    );
  }

  Future<void> _openHeadcountSheet() async {
    VibrationService.instance().buttonTap();
    final picked = await CommunityHeadcountSheet.show(
      context,
      selected: _headcount,
    );
    if (picked == null || !mounted) return;
    setState(() => _headcount = picked);
  }

  Future<void> _openDateSheet() async {
    VibrationService.instance().buttonTap();
    // 시트가 키보드 뒤로 가려지지 않도록 먼저 내린다.
    FocusScope.of(context).unfocus();
    final picked = await CommunityDateSheet.show(context, initial: _meetingAt);
    if (picked == null || !mounted) return;
    setState(() {
      _meetingAt = picked;
      _lastCanSubmit = _canSubmit;
    });
  }

  /// `26.08.29 (목) 14:30`
  ///
  /// `DateFormat`에 로케일을 넘기려면 `initializeDateFormatting`이 필요한데 이 앱은
  /// 그걸 호출하지 않는다. 카드와 같은 방식으로 요일을 ARB에서 꺼내 조립한다
  /// (`community_post_card.dart:196`).
  String _formatMeetingAt(AppLocalizations l10n, DateTime dt) {
    final weekdays = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    String pad(int value) => value.toString().padLeft(2, '0');

    return l10n.communityCreateDateValue(
      pad(dt.year % 100),
      pad(dt.month),
      pad(dt.day),
      weekdays[dt.weekday - 1],
      '${pad(dt.hour)}:${pad(dt.minute)}',
    );
  }

  /// 등록 API 연결 지점. 지금은 화면만 있어 안내로 끝낸다.
  Future<void> _submit() async {
    final picked = _picked;
    final meetingAt = _meetingAt;
    if (picked == null || meetingAt == null || _submitting) return;

    VibrationService.instance().buttonTap();
    setState(() => _submitting = true);

    try {
      final created = await ref
          .read(communityRepositoryProvider)
          .createPost(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            meetingAt: meetingAt,
            latitude: picked.latitude,
            longitude: picked.longitude,
            placeName: _locationController.text.trim(),
            maxParticipants: _headcount,
          );
      if (!mounted) return;

      // 목록을 무효화해 방금 쓴 글이 맨 위에 보이게 한다. 화면을 먼저 닫으면
      // 뒤에 남은 목록이 낡은 채로 보인다.
      ref.invalidate(communityFeedNotifierProvider);
      Navigator.of(context).pop(created);
    } on AppException catch (e) {
      if (!mounted) return;
      // 과거 모임 시각·주소 없는 좌표 등 서버가 거절한 이유를 그대로 보여 준다.
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
      );
      setState(() => _submitting = false);
    }
  }
}
