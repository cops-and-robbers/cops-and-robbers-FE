import 'dart:math' as math;

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/dialogs/app_popup.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../../../core/widgets/pages/text_submit_page.dart';
import 'legal_document_page.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: Text(
          '설정',
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
            _buildSectionHeader('계정'),
            _buildMenuItem(
              text: '닉네임 변경',
              trailing: _buildForwardArrow(),
              onTap: _onNicknameChange,
            ),
            SizedBox(height: AppSpacing.vertical8),

            _buildSectionDivider(),

            // ══════════════════════════════════════════
            // 앱 설정
            // ══════════════════════════════════════════
            _buildSectionHeader('앱 설정'),
            _buildMenuItem(
              text: '알림',
              subtitle: '게임 중 알림을 제외한 기타 알림의 설정이에요',
              onTap: () => AppSettings.openAppSettings(
                type: AppSettingsType.notification,
              ),
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: '위치 권한 관리',
              subtitle: '기기 설정에서 위치 권한을 변경할 수 있어요',
              onTap: () =>
                  AppSettings.openAppSettings(type: AppSettingsType.location),
            ),
            SizedBox(height: AppSpacing.vertical4),

            _buildSectionDivider(),

            // ══════════════════════════════════════════
            // 이용 안내
            // ══════════════════════════════════════════
            _buildSectionHeader('이용 안내'),
            _buildVersionItem(),
            _buildItemDivider(),
            _buildMenuItem(text: '버그 제보', onTap: _onBugReport),
            _buildItemDivider(),
            _buildMenuItem(
              text: '이용약관',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LegalDocumentPage(
                    title: '이용약관',
                    assetPath: 'assets/legal/terms_of_service.json',
                    externalUrl: AppUrls.termsOfService,
                  ),
                ),
              ),
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: '개인정보 처리방침',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LegalDocumentPage(
                    title: '개인정보 처리방침',
                    assetPath: 'assets/legal/privacy_policy.json',
                    externalUrl: AppUrls.privacyPolicy,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.vertical4),
            _buildSectionDivider(),

            // ══════════════════════════════════════════
            // 기타
            // ══════════════════════════════════════════
            _buildSectionHeader('기타'),
            _buildMenuItem(
              text: '로그아웃',
              textColor: AppColors.red,
              onTap: _onLogout,
            ),
            _buildItemDivider(),
            _buildMenuItem(
              text: '회원 탈퇴',
              textColor: AppColors.black600,
              onTap: _showDeleteAccountDialog,
            ),

            SizedBox(height: AppSpacing.vertical32),
          ],
        ),
      ),
    );
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
  Widget _buildVersionItem() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.vertical16,
        horizontal: AppSpacing.horizontal24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '앱 버전',
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
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 메뉴 아이템
  // ═══════════════════════════════════════════════════════════════════════════

  /// 설정 메뉴 아이템 빌더
  Widget _buildMenuItem({
    required String text,
    required VoidCallback onTap,
    Color? textColor,
    String? subtitle,
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
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 액션 핸들러
  // ═══════════════════════════════════════════════════════════════════════════

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
      if (navigator.canPop()) navigator.pop();
      final encodedNickname = Uri.encodeComponent(profile.nickname);
      router.push('${RoutePaths.nicknameSetup}?nickname=$encodedNickname');
    } on AuthException {
      if (navigator.canPop()) navigator.pop();
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

  /// 버그 제보
  void _onBugReport() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TextSubmitPage(
          title: '버그 제보',
          label: '버그 내용',
          hintText: '어떤 문제가 발생했나요?\n발생 상황을 자세히 적어주세요(시간, 기기 정보 포함)',
          submitText: '제보하기',
          onSubmit: (text) {
            // TODO: 버그 제보 API 연동 (백엔드 API 미구현 상태)
            Navigator.of(context).pop();
            AppSnackbar.show(context, message: '버그 제보가 접수되었어요');
          },
        ),
      ),
    );
  }

  /// 로그아웃
  Future<void> _onLogout() async {
    final navigator = Navigator.of(context);
    final result = await AppDialog.confirm(
      context: context,
      title: '로그아웃',
      message: '정말 로그아웃 하시겠어요?',
      confirmText: '로그아웃',
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
      message: authState.hasError ? '로그아웃에 실패했습니다' : '로그아웃되었습니다',
      backgroundColor: authState.hasError ? AppColors.red : AppColors.blue,
    );
  }

  /// 회원 탈퇴 확인 다이얼로그 표시
  void _showDeleteAccountDialog() {
    final controller = TextEditingController();

    AppDialog.show(
      context: context,
      title: '회원 탈퇴',
      message:
          '탈퇴하면 모든 데이터가 삭제되며\n되돌릴 수 없습니다.\n\n계속하려면 "탈퇴하기" 또는 "delete"를 입력하세요.',
      customContent: AppTextField(
        controller: controller,
        hintText: '탈퇴하기 또는 delete',
      ),
      cancelText: '취소',
      confirmText: '탈퇴',
      isDestructive: true,
      validator: () {
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
