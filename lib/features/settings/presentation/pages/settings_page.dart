import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/url_launcher_util.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../router/route_paths.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';

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
  bool _notificationEnabled = true;

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
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final profile = await ref
                        .read(userRepositoryProvider)
                        .getMyProfile();
                    if (!mounted) return;
                    final encodedNickname = Uri.encodeComponent(
                      profile.nickname,
                    );
                    router.push(
                      '${RoutePaths.nicknameSetup}?nickname=$encodedNickname',
                    );
                  } catch (_) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다')),
                    );
                  }
                },
              ),

              const Divider(color: AppColors.black100, height: 1),

              // ── 알림 섹션 ──
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '알림',
                            style: AppTextStyles.label_16.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: AppSpacing.vertical8),
                          Text(
                            '게임 중 알림을 제외한 기타 알림의 설정이에요',
                            style: AppTextStyles.tag_12.copyWith(
                              color: AppColors.black600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _notificationEnabled,
                      onChanged: (value) {
                        setState(() => _notificationEnabled = value);
                        // TODO: 알림 설정 저장 로직
                      },
                      activeThumbColor: AppColors.white,
                      activeTrackColor: AppColors.black,
                    ),
                  ],
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
                onTap: () async =>
                    await launchExternalUrl(AppUrls.privacyPolicy),
              ),

              const Divider(color: AppColors.black100, height: 1),

              // ── 이용약관 ──
              _buildMenuItem(
                text: '이용약관',
                onTap: () async =>
                    await launchExternalUrl(AppUrls.termsOfService),
              ),

              const Divider(color: AppColors.black100, height: 1),

              // ── 로그아웃 ──
              _buildMenuItem(
                text: '로그아웃',
                textColor: AppColors.red,
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final result = await AppDialog.confirm(
                    context: context,
                    title: '로그아웃',
                    message: '정말 로그아웃 하시겠어요?',
                    confirmText: '로그아웃',
                    isDestructive: true,
                  );
                  if (result == true && mounted) {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (!mounted) return;
                    final authState = ref.read(authNotifierProvider);
                    messenger.clearSnackBars();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          authState.hasError ? '로그아웃에 실패했습니다' : '로그아웃되었습니다',
                          style: AppTextStyles.paragraph_14,
                        ),
                        backgroundColor: authState.hasError
                            ? AppColors.red
                            : AppColors.blue,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),

              const Divider(color: AppColors.black100, height: 1),

              // ── 회원 탈퇴 ──
              _buildMenuItem(
                text: '회원 탈퇴',
                textColor: AppColors.black600,
                onTap: () {
                  // TODO: 회원 탈퇴 로직
                },
              ),
            ],
          ),
        ),
      ),
    );
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
        padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical16),
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
