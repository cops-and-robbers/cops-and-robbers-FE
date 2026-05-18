import 'dart:math' as math;
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/dialogs/app_popup.dart';
import '../../../../core/services/tutorial/tutorial_service.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/i18n/locale_provider.dart';
import '../../../../router/route_paths.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'language_settings_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bug/presentation/providers/bug_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../../../core/widgets/pages/text_submit_page.dart';
import '../../../credits/presentation/pages/credits_page.dart';
import 'agreement_settings_page.dart';

/// 설정 페이지
///
/// 카테고리별로 메뉴를 그룹화합니다:
/// - 계정: 닉네임 변경
/// - 앱 설정: 알림, 위치 권한 관리
/// - 이용 안내: 앱 버전, 버그 제보, 이용약관, 개인정보 처리방침
/// - 기타: 로그아웃, 회원 탈퇴
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  /// 히든 크레딧 페이지 진입을 위한 탭 카운터
  int _versionTapCount = 0;
  DateTime? _lastVersionTap;

  /// 게임 알림 토글 중복 실행 방지 플래그 (setState 없이 사용)
  bool _gamePushToggling = false;

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
      // 이스터에그 발견 — 페이드 + 블러 애니메이션으로 크레딧 페이지 진입
      Navigator.of(context).push(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const CreditsPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                // 블러: 10 → 0 (선명해짐)
                final blur = (1 - animation.value) * 10;
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Opacity(opacity: animation.value, child: child),
                );
              },
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamePushState = ref.watch(gamePushNotifierProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: Text(
          l10n.settings_settingsPage_L104,
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ══════════════════════════════════════════
            // 계정
            // ══════════════════════════════════════════
            _buildSectionHeader(l10n.settings_settingsPage_L115),
            _buildMenuItem(
              text: l10n.settings_settingsPage_L117,
              trailing: _buildForwardArrow(),
              onTap: _onNicknameChange,
            ),
            SizedBox(height: AppSpacing.vertical8),

            _buildSectionDivider(),

            // ══════════════════════════════════════════
            // 앱 설정
            // ══════════════════════════════════════════
            _buildSectionHeader(l10n.settings_settingsPage_L128),
            _buildSwitchMenuItem(
              text: l10n.settings_settingsPage_L130,
              subtitle: l10n.settings_settingsPage_L131,
              value: gamePushState.valueOrNull ?? false,
              onToggle: _onGamePushToggle,
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settings_settingsPage_L137,
              // "게임 중 알림" 부분만 더 큰 스타일 + 진한 색상으로 강조
              subtitleWidget: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: l10n.settings_settingsPage_L143,
                      style: AppTextStyles.tag12Semibold.copyWith(
                        color: AppColors.black800,
                      ),
                    ),
                    TextSpan(
                      text: l10n.settings_settingsPage_L149,
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

            _buildMenuItem(
              text: l10n.settings_settingsPage_L164,
              subtitle: l10n.settings_settingsPage_L165,
              onTap: () =>
                  AppSettings.openAppSettings(type: AppSettingsType.location),
            ),
            _buildItemDivider(),

            // 언어 설정 — 현재 선택값을 subtitle에 표시, 탭 시 BottomSheet
            _buildMenuItem(
              text: AppLocalizations.of(context).settingsLanguageLabel,
              subtitle: _currentLanguageDisplay(),
              trailing: _buildForwardArrow(),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LanguageSettingsPage(),
                  ),
                );
                // 페이지에서 돌아온 후 subtitle 갱신 (isFollowingSystem은 watch 불가)
                if (mounted) setState(() {});
              },
            ),
            SizedBox(height: AppSpacing.vertical4),

            _buildSectionDivider(),

            // ══════════════════════════════════════════
            // 이용 안내
            // ══════════════════════════════════════════
            _buildSectionHeader(l10n.settings_settingsPage_L176),
            _buildVersionItem(),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settings_settingsPage_L179,
              onTap: _onBugReport,
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settings_settingsPage_L182,
              onTap: () => context.push('/tutorial'),
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settings_settingsPage_L186,
              onTap: _onResetTutorial,
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settings_settingsPage_L189,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AgreementSettingsPage(),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.vertical4),
            _buildSectionDivider(),

            // ══════════════════════════════════════════
            // 기타
            // ══════════════════════════════════════════
            _buildSectionHeader(l10n.settings_settingsPage_L202),
            _buildMenuItem(
              text: l10n.settings_settingsPage_L204,
              textColor: AppColors.red,
              onTap: _onLogout,
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: l10n.settings_settingsPage_L210,
              textColor: AppColors.black600,
              onTap: _showDeleteAccountDialog,
            ),

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
  /// isFollowingSystem은 notifier 내부 상태라 watch 불가 — read로 일회성 조회
  String _currentLanguageDisplay() {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(appLocaleProvider);
    final isFollowingSystem = ref
        .read(appLocaleProvider.notifier)
        .isFollowingSystem;
    if (isFollowingSystem) return l10n.settingsLanguageOptionSystem;
    switch (locale.languageCode) {
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
      child: const Divider(color: AppColors.black100, height: 1),
    );
  }

  /// 카테고리 간 구분선 (h=4, 화면 전체 너비, black100)
  Widget _buildSectionDivider() {
    return Container(
      width: double.infinity,
      height: 4,
      color: AppColors.black100,
    );
  }

  /// 우측 화살표 아이콘 (icon_previous.svg 180도 회전, black300, 20px)
  Widget _buildForwardArrow() {
    return Transform.rotate(
      angle: math.pi,
      child: SvgPicture.asset(
        'assets/icons/icon_previous.svg',
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(
          AppColors.black300,
          BlendMode.srcIn,
        ),
      ),
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
              AppLocalizations.of(context).settings_settingsPage_L292,
              style: AppTextStyles.label_16.copyWith(color: AppColors.black),
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.data?.version ?? '';
                return Text(
                  'v$version',
                  style: AppTextStyles.paragraph14Semibold.copyWith(
                    color: AppColors.black300,
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
  Widget _buildMenuItem({
    required String text,
    required VoidCallback onTap,
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
                  activeTrackColor: AppColors.black,
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
      AppSnackbar.show(
        context,
        message: e is AppException
            ? e.message
            : AppLocalizations.of(context).dialogsettingsPageMessage,
        backgroundColor: AppColors.red,
      );
    } finally {
      _gamePushToggling = false;
    }
  }

  /// 닉네임 변경
  Future<void> _onNicknameChange() async {
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);

    await AppPopup.showRandomLoading(
      context: context,
      category: LoadingCategory.loadProfile,
    );

    try {
      final profile = await ref.read(userRepositoryProvider).getMyProfile();
      if (!mounted) return;
      final encodedNickname = Uri.encodeComponent(profile.nickname);
      router.push('${RoutePaths.nicknameSetup}?nickname=$encodedNickname');
    } on AuthException {
      return;
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: e.message,
        backgroundColor: AppColors.red,
      );
    } finally {
      // 로딩 팝업 종료 보장
      if (navigator.canPop()) navigator.pop();
    }
  }

  /// 버그 제보 입력 화면 진입
  void _onBugReport() {
    final l10n = AppLocalizations.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TextSubmitPage(
          title: l10n.dialogsettingsPageTitle,
          label: l10n.fieldsettingsPageLabel,
          hintText: l10n.fieldsettingsPageHint,
          submitText: l10n.settings_settingsPage_L498,
          maxLength: 1000,
          onSubmit: _submitBugReport,
        ),
      ),
    );
  }

  /// 버그 제보 API 호출 + 결과 처리
  ///
  /// 성공: loading + 입력 페이지 모두 닫고 설정 화면으로 복귀, 성공 스낵바 표시.
  /// 실패: loading만 닫고 입력 페이지는 유지(재시도 가능), 에러 스낵바 표시.
  /// AuthException은 AuthInterceptor가 강제 로그아웃을 자동 처리하므로 무시.
  Future<void> _submitBugReport(String content) async {
    final navigator = Navigator.of(context);

    await AppPopup.showRandomLoading(
      context: context,
      category: LoadingCategory.bugReport,
    );

    try {
      await ref.read(bugRepositoryProvider).reportBug(content: content);
      if (!mounted) return;
      if (navigator.canPop()) navigator.pop(); // loading 닫기
      if (navigator.canPop()) navigator.pop(); // TextSubmitPage 닫기
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).dialogsettingsPageMessage1b8e,
      );
    } on AuthException {
      // AuthInterceptor가 강제 로그아웃 + 로그인 화면 이동을 처리
      // 다이얼로그는 Navigator 스택에 남으므로 명시적으로 닫아준다
      if (navigator.canPop()) navigator.pop(); // loading 닫기
      return;
    } on AppException catch (e) {
      if (!mounted) return;
      if (navigator.canPop()) navigator.pop(); // loading만 닫고 입력 페이지는 유지
      AppSnackbar.show(
        context,
        message: e.message,
        backgroundColor: AppColors.red,
      );
    }
  }

  /// 튜토리얼 초기화 (코치마크 한정)
  ///
  /// SharedPreferences의 모든 코치마크 키를 삭제하고, 신호를 발행해
  /// 부모 위젯이 dispose되지 않은 화면도 즉시 재노출되게 한다.
  /// 마지막에 홈으로 이동해 첫 코치마크가 바로 떠 보이도록 한다.
  Future<void> _onResetTutorial() async {
    final l10n = AppLocalizations.of(context);
    final result = await AppDialog.confirm(
      context: context,
      title: l10n.dialogsettingsPageTitleD4a4,
      message: l10n.dialogsettingsPageMessageA4c9,
      confirmText: l10n.dialogsettingsPageConfirm,
    );
    if (result != true || !mounted) return;

    await TutorialService.resetAll();
    if (!mounted) return;

    ref.read(tutorialResetSignalProvider.notifier).state++;
    AppSnackbar.show(
      context,
      message: AppLocalizations.of(context).dialogsettingsPageMessageC8cb,
    );
    context.go(RoutePaths.home);
  }

  /// 로그아웃
  Future<void> _onLogout() async {
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final result = await AppDialog.confirm(
      context: context,
      title: l10n.dialogsettingsPageTitle9ab1,
      message: l10n.dialogsettingsPageMessageE675,
      confirmText: l10n.dialogsettingsPageConfirm9ab1,
      isDestructive: true,
    );
    if (result != true || !mounted) return;

    await AppPopup.showRandomLoading(
      // ignore: use_build_context_synchronously
      context: context,
      category: LoadingCategory.logout,
    );

    await ref.read(authNotifierProvider.notifier).signOut();
    if (!mounted) return;

    if (navigator.canPop()) navigator.pop();

    final authState = ref.read(authNotifierProvider);
    AppSnackbar.show(
      // ignore: use_build_context_synchronously
      context,
      message: authState.hasError
          ? AppLocalizations.of(context).settings_settingsPage_L590
          : AppLocalizations.of(context).settings_settingsPage_L590_1,
      backgroundColor: authState.hasError ? AppColors.red : AppColors.blue,
    );
  }

  /// 회원 탈퇴 확인 다이얼로그 표시
  void _showDeleteAccountDialog() {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);

    AppDialog.show(
      context: context,
      title: l10n.dialogsettingsPageTitle5e0d,
      message: l10n.settings_settingsPage_L603,
      customContent: AppTextField(
        controller: controller,
        hintText: l10n.fieldsettingsPageHint2960,
      ),
      cancelText: l10n.dialogsettingsPageCancel,
      confirmText: l10n.dialogsettingsPageConfirm9140,
      isDestructive: true,
      validator: () {
        // 검증 키워드는 한국어 입력만 허용 (localize 대상 아님)
        final text = controller.text.trim();
        return text == '탈퇴하기' || text.toLowerCase() == 'delete';
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
    final navigator = Navigator.of(context);

    await AppPopup.showRandomLoading(
      context: context,
      category: LoadingCategory.deleteAccount,
    );

    try {
      await ref.read(deleteAccountUseCaseProvider).execute();
      if (!mounted) return;

      await ref
          .read(authNotifierProvider.notifier)
          .cleanupAfterAccountDeletion();
      if (!mounted) return;

      context.go('${RoutePaths.login}?accountDeleted=true');
      ref.read(authNotifierProvider.notifier).forceLogout();
      return;
    } on AuthException {
      return;
    } on AppException catch (e) {
      if (navigator.canPop()) navigator.pop();
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: e.message,
        backgroundColor: AppColors.red,
      );
    }
  }
}
