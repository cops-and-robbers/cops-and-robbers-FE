import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
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
import 'legal_document_page.dart';

/// 설정 페이지
///
/// 닉네임 변경, 알림, 버그 제보, 개인정보 처리방침,
/// 로그아웃, 회원탈퇴 메뉴를 제공합니다.
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
        child: Padding(
          padding: AppPadding.horizontal24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 닉네임 변경 ──
              _buildMenuItem(
                text: '닉네임 변경',
                onTap: () async {
                  final router = GoRouter.of(context);
                  final navigator = Navigator.of(context);

                  await AppPopup.showRandomLoading(
                    context: context,
                    category: LoadingCategory.loadProfile,
                  );

                  try {
                    final profile = await ref
                        .read(userRepositoryProvider)
                        .getMyProfile();
                    if (!mounted) return;
                    // 로딩 팝업 닫기
                    if (navigator.canPop()) navigator.pop();
                    final encodedNickname = Uri.encodeComponent(
                      profile.nickname,
                    );
                    router.push(
                      '${RoutePaths.nicknameSetup}?nickname=$encodedNickname',
                    );
                  } on AuthException {
                    // 로딩 팝업 닫기 + 인터셉터에서 force logout 처리됨
                    if (navigator.canPop()) navigator.pop();
                    return;
                  } on AppException catch (e) {
                    // 로딩 팝업 닫기
                    if (navigator.canPop()) navigator.pop();
                    if (!mounted) return;
                    AppSnackbar.show(
                      // ignore: use_build_context_synchronously
                      context,
                      message: e.message,
                      backgroundColor: AppColors.red,
                    );
                  }
                },
              ),

              const Divider(color: AppColors.black100, height: 1),

              // ── 알림 설정 ──
              _buildMenuItem(
                text: '알림 설정',
                subtitle: '기기 설정에서 알림 권한을 변경할 수 있어요',
                onTap: () => AppSettings.openAppSettings(
                  type: AppSettingsType.notification,
                ),
              ),

              const Divider(color: AppColors.black100, height: 1),

              // ── 위치 권한 관리 ──
              _buildMenuItem(
                text: '위치 권한 관리',
                subtitle: '기기 설정에서 위치 권한을 변경할 수 있어요',
                onTap: () => AppSettings.openAppSettings(
                  type: AppSettingsType.location,
                ),
              ),

              const Divider(color: AppColors.black100, height: 1),

              // ── 버그 제보 ──
              _buildMenuItem(
                text: '버그 제보',
                onTap: () {
                  // TODO: 버그 제보 페이지 이동
                },
              ),

              const Divider(color: AppColors.black100, height: 1),

              // ── 개인정보 처리방침 ──
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

              const Divider(color: AppColors.black100, height: 1),

              // ── 이용약관 ──
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

              const Divider(color: AppColors.black100, height: 1),

              // ── 로그아웃 ──
              _buildMenuItem(
                text: '로그아웃',
                textColor: AppColors.red,
                onTap: () async {
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

                  // 로딩 팝업 닫기
                  if (navigator.canPop()) navigator.pop();

                  final authState = ref.read(authNotifierProvider);
                  AppSnackbar.show(
                    // ignore: use_build_context_synchronously
                    context,
                    message: authState.hasError ? '로그아웃에 실패했습니다' : '로그아웃되었습니다',
                    backgroundColor: authState.hasError
                        ? AppColors.red
                        : AppColors.blue,
                  );
                },
              ),

              const Divider(color: AppColors.black100, height: 1),

              // ── 회원 탈퇴 ──
              _buildMenuItem(
                text: '회원 탈퇴',
                textColor: AppColors.black600,
                onTap: () => _showDeleteAccountDialog(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 회원 탈퇴 확인 다이얼로그 표시
  ///
  /// "탈퇴하기" 또는 "delete" 입력 시에만 탈퇴 버튼이 동작합니다.
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
  ///
  /// 로딩 팝업으로 터치를 차단하고,
  /// 1. DELETE /api/user/me (백엔드 계정 삭제)
  /// 2. AuthNotifier.cleanupAfterAccountDeletion() (로컬 정리 + 리다이렉트)
  Future<void> _executeDeleteAccount() async {
    final navigator = Navigator.of(context);

    await AppPopup.showRandomLoading(
      context: context,
      category: LoadingCategory.deleteAccount,
    );

    try {
      // 1. 백엔드 계정 삭제
      await ref.read(deleteAccountUseCaseProvider).execute();
      if (!mounted) return;

      // 2. 로컬 정리 (Firebase signOut + 토큰 삭제)
      await ref
          .read(authNotifierProvider.notifier)
          .cleanupAfterAccountDeletion();
      if (!mounted) return;

      // 3. 로그인 화면으로 이동 (탈퇴 완료 메시지 전달) 후 state 초기화
      context.go('${RoutePaths.login}?accountDeleted=true');
      ref.read(authNotifierProvider.notifier).forceLogout();
      return;
    } on AuthException {
      // AuthInterceptor에서 강제 로그아웃 처리됨
      return;
    } on AppException catch (e) {
      // 로딩 팝업 닫기
      if (navigator.canPop()) navigator.pop();
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: e.message,
        backgroundColor: AppColors.red,
      );
    }
  }

  /// 설정 메뉴 아이템 빌더
  Widget _buildMenuItem({
    required String text,
    required VoidCallback onTap,
    Color? textColor,
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.vertical16,
          horizontal: AppSpacing.horizontal4,
        ),
        child: SizedBox(
          width: double.infinity,
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
      ),
    );
  }
}
