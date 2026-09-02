import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/legal_doc.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/dividers/solid_divider.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/loading/app_loading.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/i18n/locale_provider.dart';
import '../../../../router/route_paths.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../user/presentation/providers/profile_icon_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../widgets/sns_channel_row.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';

/// 마이페이지
///
/// 바텀 네비게이션 마이페이지 탭의 루트 화면.
/// 카테고리별로 메뉴를 그룹화합니다:
/// - 계정: 닉네임 변경
/// - 앱 설정: 알림, 위치 권한 관리
/// - 이용 안내: 앱 버전, 버그 제보, 이용약관, 개인정보 처리방침
/// - 기타: 로그아웃, 회원 탈퇴
class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  /// 히든 크레딧 페이지 진입을 위한 탭 카운터
  int _versionTapCount = 0;
  DateTime? _lastVersionTap;

  /// 게임 알림 토글 중복 실행 방지 플래그 (setState 없이 사용)
  bool _gamePushToggling = false;

  /// 커뮤니티 알림 토글 중복 실행 방지 플래그 (게임 알림과 같은 이유)
  bool _communityPushToggling = false;

  /// 앱 버전 5탭 → 크레딧 페이지 진입
  void _onVersionTap() {
    final now = DateTime.now();
    // 마지막 탭으로부터 2초 초과 시 카운터 리셋
    if (_lastVersionTap != null &&
        now.difference(_lastVersionTap!).inSeconds > 2) {
      _versionTapCount = 0;
    }
    _lastVersionTap = now;
    _versionTapCount++;

    if (_versionTapCount >= 5) {
      _versionTapCount = 0;
      // 이스터에그 발견. 전환 연출은 라우터의 buildBlurFade 가 맡는다.
      context.push(RoutePaths.credits);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamePushState = ref.watch(gamePushNotifierProvider);
    final communityPushState = ref.watch(communityPushNotifierProvider);
    final selectedIconId = ref.watch(profileIconProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppTopBar(title: l10n.pageSettingsTitle),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ══════════════════════════════════════════
            // 프로필 아이콘
            // ══════════════════════════════════════════
            _buildSectionHeader(l10n.mypageProfileIconLabel),
            _buildProfileIconPicker(selectedIconId),
            SizedBox(height: AppSpacing.vertical8),

            _buildSectionDivider(),

            // ══════════════════════════════════════════
            // 계정
            // ══════════════════════════════════════════
            _buildSectionHeader(l10n.settingsSectionAccount),
            _buildMenuItem(
              text: l10n.settingsAccountChangeNickname,
              leadingAsset: AppIcons.nickname,
              trailing: _buildForwardArrow(),
              onTap: _onNicknameChange,
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settingsAccountMyScraps,
              // 모집글 카드의 스크랩 아이콘과 같은 에셋·같은 원본 색(노랑).
              // 세로 20 — 24 슬롯 안에서 다른 아이콘과 눈높이를 맞춘 값이다.
              // 가로는 SvgPicture 기본 contain이 원본 비율(12:14)대로 잡는다.
              leadingAsset: AppIcons.saveOn,
              leadingAssetSize: 20,
              trailing: _buildForwardArrow(),
              onTap: () => context.push(RoutePaths.myScraps),
            ),
            SizedBox(height: AppSpacing.vertical8),

            _buildSectionDivider(),

            // ══════════════════════════════════════════
            // 앱 설정
            // ══════════════════════════════════════════
            _buildSectionHeader(l10n.settingsSectionAppPreferences),
            _buildSwitchMenuItem(
              text: l10n.settingsAppGameNotification,
              subtitle: l10n.settingsAppGameNotificationDescription,
              leadingAsset: AppIcons.gameNotification,
              value: gamePushState.valueOrNull ?? false,
              onToggle: _onGamePushToggle,
            ),
            _buildItemDivider(),
            _buildSwitchMenuItem(
              text: l10n.settingsAppCommunityNotification,
              subtitle: l10n.settingsAppCommunityNotificationDescription,
              // 커뮤니티 알림함 진입 아이콘과 같은 종 — "커뮤니티 알림"이 한 정체로 읽힌다.
              // ponytail: 시안이 다른 아이콘을 주면 이 한 줄만 바꾼다.
              leadingAsset: AppIcons.noti,
              value: communityPushState.valueOrNull ?? false,
              onToggle: _onCommunityPushToggle,
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settingsAppGeneralNotification,
              leadingAsset: AppIcons.notification,
              // "게임 중 알림" 부분만 더 큰 스타일 + 진한 색상으로 강조
              subtitleWidget: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: l10n.settingsAppGeneralNotificationHighlight,
                      style: AppTextStyles.tag12Semibold.copyWith(
                        color: AppColors.black800,
                      ),
                    ),
                    TextSpan(
                      text: l10n.settingsAppGeneralNotificationDetail,
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.black600,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () => AppSettings.openAppSettings(
                type: AppSettingsType.notification,
              ),
            ),
            _buildItemDivider(),

            // 언어 설정. subtitle 은 _currentLanguageDisplay() 가 appLocaleProvider 를
            // watch 하므로 값을 바꾸면 자동으로 갱신된다.
            _buildMenuItem(
              text: l10n.settingsLanguageLabel,
              subtitle: _currentLanguageDisplay(),
              leadingAsset: AppIcons.language,
              onTap: () => context.push(RoutePaths.languageSettings),
            ),
            _buildItemDivider(),

            _buildMenuItem(
              text: l10n.settingsAppLocationPermission,
              subtitle: l10n.settingsAppLocationPermissionDescription,
              leadingAsset: AppIcons.locationPin,
              onTap: () =>
                  AppSettings.openAppSettings(type: AppSettingsType.location),
            ),
            SizedBox(height: AppSpacing.vertical4),

            _buildSectionDivider(),

            // ══════════════════════════════════════════
            // 이용 안내
            // ══════════════════════════════════════════
            _buildSectionHeader(l10n.settingsSectionGuide),
            _buildVersionItem(),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settingsGuideAppIntro,
              onTap: () => context.push(RoutePaths.onboarding),
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settingsGuideBugReport,
              onTap: () => context.push(RoutePaths.bugReport),
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settingsGuideOpenSourceLicenses,
              onTap: () =>
                  context.push(RoutePaths.legalDocumentOf(LegalDoc.licenses)),
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settingsGuideAgreements,
              onTap: () => context.push(RoutePaths.agreementSettings),
            ),
            SizedBox(height: AppSpacing.vertical4),
            _buildSectionDivider(),

            // ══════════════════════════════════════════
            // 기타
            // ══════════════════════════════════════════
            _buildSectionHeader(l10n.settingsSectionEtc),
            _buildMenuItem(
              text: l10n.buttonLogout,
              textColor: AppColors.red,
              onTap: _onLogout,
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settingsEtcDeleteAccount,
              textColor: AppColors.black600,
              onTap: _showDeleteAccountDialog,
            ),
            SizedBox(height: AppSpacing.vertical8),

            // ══════════════════════════════════════════
            // 공식 SNS 채널
            // ══════════════════════════════════════════
            _buildSectionDivider(),
            const SnsChannelRow(),

            SizedBox(height: AppSpacing.vertical64),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // i18n 헬퍼
  // ═══════════════════════════════════════════════════════════════════════════

  /// 설정 메뉴 subtitle용 현재 언어 표시 문자열
  ///
  /// "시스템 따름" / "한국어" / "English" / "日本語" 중 하나 반환
  String _currentLanguageDisplay() {
    final l10n = AppLocalizations.of(context);
    final localeState = ref.watch(appLocaleProvider);
    if (localeState.isFollowingSystem) return l10n.settingsLanguageOptionSystem;
    switch (localeState.locale.languageCode) {
      case 'en':
        return l10n.settingsLanguageOptionEnglish;
      case 'ja':
        return l10n.settingsLanguageOptionJapanese;
      case 'ko':
      default:
        return l10n.settingsLanguageOptionKorean;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 섹션 공통 위젯
  // ═══════════════════════════════════════════════════════════════════════════

  /// 카테고리 헤더 (계정, 앱 설정, 이용 안내, 기타)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.horizontal24,
        right: AppSpacing.horizontal24,
        top: AppSpacing.vertical24,
        bottom: AppSpacing.vertical4,
      ),
      child: Text(
        title,
        style: AppTextStyles.paragraph14Semibold.copyWith(
          color: AppColors.black600,
        ),
      ),
    );
  }

  /// 항목 간 구분선 (h=1, 좌우 20px)
  Widget _buildItemDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal20),
      child: const SolidDivider(),
    );
  }

  /// 카테고리 간 구분선 (h=4, 화면 전체 너비, black100)
  Widget _buildSectionDivider() {
    return Container(
      width: double.infinity,
      height: AppSpacing.vertical4,
      color: AppColors.black100,
    );
  }

  /// 프로필 아이콘 선택 섹션
  ///
  /// 선택지가 [kProfileIconIds] 2개뿐이라 다이얼로그 없이 인라인으로 노출한다.
  /// 선택 즉시 홈 프로필 카드에도 반영된다(같은 provider를 watch).
  Widget _buildProfileIconPicker(int selectedId) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.horizontal24,
        right: AppSpacing.horizontal24,
        top: AppSpacing.vertical8,
      ),
      child: Row(
        children: [
          for (final id in kProfileIconIds)
            Padding(
              padding: EdgeInsets.only(
                right: id == kProfileIconIds.last ? 0 : AppSpacing.horizontal12,
              ),
              child: GestureDetector(
                onTap: () => unawaited(_onProfileIconSelect(id)),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.horizontal4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: id == selectedId
                          ? AppColors.blueVer2Basic
                          : AppColors.transparent,
                      width: 2.w,
                    ),
                  ),
                  child: SvgPicture.asset(
                    profileIconAsset(id),
                    width: 48.w,
                    height: 48.w,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 우측 화살표 아이콘 (icon_previous.svg 180도 회전, black300, 20px)
  Widget _buildForwardArrow() {
    // 예전에는 icon_previous 를 180도 돌려 썼다. 전용 에셋이 생겨 그대로 쓴다.
    return SvgPicture.asset(
      AppIcons.next,
      width: 20,
      height: 20,
      colorFilter: const ColorFilter.mode(AppColors.black300, BlendMode.srcIn),
    );
  }

  /// 앱 버전 항목 (좌: "앱 버전", 우: "v1.x.x")
  /// 5회 연속 탭 시 히든 크레딧 페이지로 이동
  Widget _buildVersionItem() {
    return GestureDetector(
      onTap: _onVersionTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.vertical16,
          horizontal: AppSpacing.horizontal24,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).settingsAppVersionLabel,
              style: AppTextStyles.label_16.copyWith(color: AppColors.black),
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.data?.version ?? '';
                return Text(
                  'v$version',
                  style: AppTextStyles.paragraph14Semibold.copyWith(
                    color: AppColors.black600,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 메뉴 아이템
  // ═══════════════════════════════════════════════════════════════════════════

  /// 설정 메뉴 아이템 빌더
  ///
  /// 일부 텍스트에 강조가 필요한 경우 [subtitleWidget]을 사용하면 [subtitle] 대신 표시된다.
  /// 설정 메뉴 한 줄.
  ///
  /// 행 높이는 내용에서 나온다. 상하 여백 16이 모든 경우에 같고 안쪽 높이만 달라진다.
  ///   텍스트만        16 + 16 + 16 = 48
  ///   아이콘 + 주      16 + 24 + 16 = 56
  ///   아이콘 + 주 + 보조  16 + (16+8+12) + 16 = 68
  /// 아이콘(24)이 주+보조 묶음(36)보다 작아 마지막 경우의 높이는 텍스트가 정한다.
  ///
  /// [leadingAsset] 과 [subtitle] 은 서로 독립이다. 닉네임 변경은 아이콘만 있고
  /// 보조 텍스트가 없어서, 둘을 묶어 위젯을 나누면 오히려 중복이 생긴다.
  Widget _buildMenuItem({
    required String text,
    required VoidCallback onTap,
    String? leadingAsset,
    double? leadingAssetSize,
    Color? textColor,
    String? subtitle,
    Widget? subtitleWidget,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.vertical16,
          horizontal: AppSpacing.horizontal24,
        ),
        child: Row(
          children: [
            if (leadingAsset != null) ...[
              // 받은 아이콘이 다색이라 colorFilter 를 걸지 않는다.
              // 스크랩처럼 원본이 24보다 작은 아이콘은 [leadingAssetSize]로 원본
              // 크기를 준다 — 24로 늘리면 옆 24 아이콘들보다 굵고 커 보인다.
              // 자리는 24로 고정해 어느 행이든 글자 시작점이 같게 둔다.
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: Center(
                  child: SvgPicture.asset(
                    leadingAsset,
                    width: (leadingAssetSize ?? 24).w,
                    height: (leadingAssetSize ?? 24).w,
                  ),
                ),
              ),
              SizedBox(width: 18.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.label_16.copyWith(
                      color: textColor ?? AppColors.black,
                    ),
                  ),
                  if (subtitleWidget != null) ...[
                    SizedBox(height: AppSpacing.vertical8),
                    subtitleWidget,
                  ] else if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.vertical8),
                    Text(
                      subtitle,
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.black600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  /// 스위치 토글이 포함된 설정 메뉴 아이템 빌더
  Widget _buildSwitchMenuItem({
    required String text,
    String? subtitle,
    String? leadingAsset,
    required bool value,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.horizontal24,
          right: AppSpacing.horizontal20,
          top: AppSpacing.vertical16,
          bottom: AppSpacing.vertical16,
        ),
        child: Row(
          children: [
            if (leadingAsset != null) ...[
              SvgPicture.asset(leadingAsset, width: 24.w, height: 24.w),
              SizedBox(width: 18.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.label_16.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.vertical8),
                    Text(
                      subtitle,
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.black600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AbsorbPointer(
              child: Theme(
                data: Theme.of(context).copyWith(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Switch(
                  value: value,
                  onChanged: (_) {},
                  activeThumbColor: AppColors.white,
                  // 켜짐은 v3 강조색. 바텀 네비 활성 아이콘·선택된 프로필
                  // 아이콘 테두리와 같은 값이라 "켜짐/선택됨"이 앱 전체에서
                  // 한 색으로 읽힌다. 꺼짐은 중립 회색 그대로 둔다.
                  activeTrackColor: AppColors.blueVer2Basic,
                  inactiveThumbColor: AppColors.white,
                  inactiveTrackColor: AppColors.black200,
                  trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 액션 핸들러
  // ═══════════════════════════════════════════════════════════════════════════

  /// 게임 알림 토글
  ///
  /// _gamePushToggling 플래그로 중복 탭과 스위치 onChanged 동시 발화를 차단.
  /// 실패 시 AppException.message를 그대로 노출해 네트워크/서버/검증 사유를 구분.
  Future<void> _onGamePushToggle() async {
    if (_gamePushToggling) return;
    _gamePushToggling = true;
    try {
      await ref.read(gamePushNotifierProvider.notifier).toggle();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      AppSnackbar.show(
        context,
        message: e is AppException
            ? l10n.errorByException(e)
            : l10n.errorGameNotificationToggleFailed,
        backgroundColor: AppColors.red,
      );
    } finally {
      _gamePushToggling = false;
    }
  }

  /// 커뮤니티 알림 토글 — 게임 알림과 같은 꼴.
  ///
  /// 낙관적 갱신이라 스위치는 즉시 바뀌고, 실패하면 provider가 되돌린다.
  /// 여기서는 왜 안 바뀌었는지만 알린다.
  Future<void> _onCommunityPushToggle() async {
    if (_communityPushToggling) return;
    _communityPushToggling = true;
    try {
      await ref.read(communityPushNotifierProvider.notifier).toggle();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      AppSnackbar.show(
        context,
        message: e is AppException
            ? l10n.errorByException(e)
            : l10n.errorCommunityPushUpdateUnexpected,
        backgroundColor: AppColors.red,
      );
    } finally {
      _communityPushToggling = false;
    }
  }

  /// 프로필 아이콘 선택
  ///
  /// 화면은 즉시 바뀌고 저장은 뒤따른다. 저장이 실패하면 provider가 이전 값으로
  /// 되돌리므로, 여기서는 왜 안 바뀌었는지만 알려주면 된다.
  Future<void> _onProfileIconSelect(int id) async {
    try {
      await ref.read(profileIconProvider.notifier).select(id);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      AppSnackbar.show(
        context,
        message: e is AppException
            ? l10n.errorByException(e)
            : l10n.errorProfileIconUpdateFailed,
        backgroundColor: AppColors.red,
      );
    }
  }

  /// 닉네임 변경
  Future<void> _onNicknameChange() async {
    final router = GoRouter.of(context);

    final loading = AppLoading.show(context, LoadingCategory.loadProfile);

    try {
      final profile = await ref.read(userRepositoryProvider).getMyProfile();
      await loading.close();
      if (!mounted) return;
      final encodedNickname = Uri.encodeComponent(profile.nickname);
      router.push('${RoutePaths.nicknameSetup}?nickname=$encodedNickname');
    } on AuthException {
      await loading.close();
      return;
    } on AppException catch (e) {
      await loading.close();
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
        backgroundColor: AppColors.red,
      );
    } finally {
      // 안전망: 위에서 처리하지 못한 예외 타입으로 인해 close()가 호출되지
      // 않는 경로를 막는다. close()는 멱등이므로 정상 경로에는 영향 없음.
      await loading.close();
    }
  }

  /// 버그 제보 입력 화면 진입
  /// 로그아웃
  Future<void> _onLogout() async {
    final l10n = AppLocalizations.of(context);
    final result = await AppDialog.confirm(
      context: context,
      title: l10n.dialogLogoutTitle,
      message: l10n.dialogLogoutMessage,
      confirmText: l10n.buttonLogout,
      isDestructive: true,
    );
    if (result != true || !mounted) return;

    // ignore: use_build_context_synchronously
    final loading = AppLoading.show(context, LoadingCategory.logout);

    try {
      await ref.read(authNotifierProvider.notifier).signOut();
    } finally {
      await loading.close();
    }
    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);
    AppSnackbar.show(
      // ignore: use_build_context_synchronously
      context,
      message: authState.hasError
          ? AppLocalizations.of(context).snackbarLogoutFailed
          : AppLocalizations.of(context).snackbarLogoutSuccess,
      backgroundColor: authState.hasError ? AppColors.red : AppColors.blue,
    );
  }

  /// 회원 탈퇴 확인 다이얼로그 표시
  void _showDeleteAccountDialog() {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);

    AppDialog.show(
      context: context,
      title: l10n.dialogDeleteAccountTitle,
      message: l10n.dialogDeleteAccountMessage,
      customContent: AppTextField(
        controller: controller,
        hintText: l10n.fieldDeleteAccountHint,
      ),
      cancelText: l10n.buttonCancel,
      confirmText: l10n.buttonDeleteAccount,
      isDestructive: true,
      validator: () {
        // 검증 키워드는 모든 로케일에서 'delete'로 통일 (글로벌 공통 영문)
        // 로케일별 번역어를 허용하지 않는 이유:
        // 1) hint와 정책 일치 — 각 로케일 hint도 'delete'만 안내
        // 2) 한 단어 영문이라 입력 비용·오타 위험 모두 낮음
        return controller.text.trim().toLowerCase() == 'delete';
      },
      onConfirm: () => _executeDeleteAccount(),
    ).whenComplete(() {
      Future.delayed(
        DialogAnimation.duration + const Duration(milliseconds: 50),
        controller.dispose,
      );
    });
  }

  /// 회원 탈퇴 실행
  Future<void> _executeDeleteAccount() async {
    final loading = AppLoading.show(context, LoadingCategory.deleteAccount);

    try {
      await ref.read(deleteAccountUseCaseProvider).execute();
      if (!mounted) {
        await loading.close();
        return;
      }

      await ref
          .read(authNotifierProvider.notifier)
          .cleanupAfterAccountDeletion();

      // 로그인 화면 위에 로딩이 남지 않도록 이동 전에 닫는다
      await loading.close();
      if (!mounted) return;

      context.go('${RoutePaths.login}?accountDeleted=true');
      ref.read(authNotifierProvider.notifier).forceLogout();
      return;
    } on AuthException {
      await loading.close();
      return;
    } on AppException catch (e) {
      await loading.close();
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
        backgroundColor: AppColors.red,
      );
    } finally {
      // 안전망: 위에서 처리하지 못한 예외 타입으로 인해 close()가 호출되지
      // 않는 경로를 막는다. close()는 멱등이므로 정상 경로에는 영향 없음.
      await loading.close();
    }
  }
}
