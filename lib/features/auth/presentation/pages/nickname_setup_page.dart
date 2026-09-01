import 'dart:async';

import 'package:cops_and_robbers/core/i18n/error_message_mapper.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/chips/action_chip.dart' as custom_chip;
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/services/analytics/analytics_service.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../../../../router/route_paths.dart';

/// 닉네임 검증 상태
enum NicknameValidationState {
  /// 초기 상태 (검증 전)
  none,

  /// 빈 닉네임
  empty,

  /// 중복된 닉네임
  duplicate,

  /// 사용 가능한 닉네임
  valid,

  /// 서버 오류 등
  error,
}

/// 첫 로그인 시 닉네임 설정 페이지
///
/// 사용자가 서비스에서 사용할 닉네임(1~10글자)을 설정합니다.
/// 백엔드에서 자동 생성된 닉네임이 초기값으로 표시되며, 수정 가능합니다.
/// 중복 확인 후 닉네임을 변경합니다.
class NicknameSetupPage extends ConsumerStatefulWidget {
  /// 백엔드에서 자동 생성된 닉네임 (로그인 응답의 nickname 필드)
  final String initialNickname;

  const NicknameSetupPage({super.key, this.initialNickname = ''});

  @override
  ConsumerState<NicknameSetupPage> createState() => _NicknameSetupPageState();
}

class _NicknameSetupPageState extends ConsumerState<NicknameSetupPage> {
  // ============================================
  // State Variables
  // ============================================

  /// 닉네임 입력 컨트롤러
  late TextEditingController _nicknameController;

  /// 닉네임 검증 상태
  NicknameValidationState _validationState = NicknameValidationState.none;

  /// API 호출 중 로딩 상태
  bool _isLoading = false;

  /// 닉네임이 서버 생성 값에서 변경되었는지 여부
  ///
  /// 서버가 생성한 랜덤 닉네임은 이미 유니크하므로,
  /// 변경하지 않으면 중복확인 없이 바로 확인 가능합니다.
  bool get _isNicknameChanged =>
      _nicknameController.text.trim() != widget.initialNickname;

  // ============================================
  // Lifecycle Methods
  // ============================================

  @override
  void initState() {
    super.initState();
    // 백엔드에서 받은 닉네임을 초기값으로 설정 (수정 가능)
    _nicknameController = TextEditingController(text: widget.initialNickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  // ============================================
  // Event Handlers
  // ============================================

  /// 중복 확인 버튼 클릭 시 호출
  Future<void> _onCheckDuplicate() async {
    if (_isLoading) return;

    final nickname = _nicknameController.text.trim();

    // 빈 닉네임 검증
    if (nickname.isEmpty) {
      setState(() {
        _validationState = NicknameValidationState.empty;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isAvailable = await ref
          .read(userRepositoryProvider)
          .checkNickname(nickname);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _validationState = isAvailable
            ? NicknameValidationState.valid
            : NicknameValidationState.duplicate;
      });
    } on AppException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _validationState = NicknameValidationState.error;
      });

      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
        backgroundColor: AppColors.red,
      );
    }
  }

  /// 닉네임 설정/변경 완료 후 네비게이션
  ///
  /// - 설정에서 진입 (push): canPop == true → pop으로 설정 페이지로 복귀
  /// - 첫 로그인 (redirect): canPop == false → go로 홈 이동
  void _navigateAfterComplete() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.home);
    }
  }

  /// 확인 버튼 클릭 시 호출
  ///
  /// - 닉네임 미변경: 서버 닉네임 그대로 사용 → API 호출 없이 홈 이동
  /// - 닉네임 변경: 중복확인 통과 후 → updateNickname API 호출
  Future<void> _onConfirm() async {
    if (_isLoading) return;

    // 닉네임을 변경하지 않았으면 API 호출 없이 바로 이동
    // ⚠️ 네비게이션을 먼저 수행 후 상태 갱신
    // (상태 변경 → refreshListenable → GoRouter가 push된 라우트를 잃는 문제 방지)
    if (!_isNicknameChanged) {
      _navigateAfterComplete();
      unawaited(
        ref
            .read(authNotifierProvider.notifier)
            .updateNicknameCompleted(widget.initialNickname),
      );
      return;
    }

    final nickname = _nicknameController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(userRepositoryProvider).updateNickname(nickname);

      if (!mounted) return;

      // 닉네임 변경 퍼널 이벤트
      unawaited(ref.read(analyticsServiceProvider).logNicknameChange());

      // 성공 피드백: 네비게이션 전에 띄우면 루트 Overlay에 등록되어
      // pop/go 이후 복귀한 화면에서도 그대로 표시됨
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).messageNicknameSaved,
        iconPath: AppIcons.checkMark,
      );

      // ⚠️ 네비게이션을 먼저 수행 후 상태 갱신
      // (상태 변경 → refreshListenable → GoRouter가 push된 라우트를 잃는 문제 방지)
      _navigateAfterComplete();
      unawaited(
        ref
            .read(authNotifierProvider.notifier)
            .updateNicknameCompleted(nickname),
      );
    } on AppException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
        backgroundColor: AppColors.red,
      );
    }
  }

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        // 빈 공간 클릭 시 키보드 닫기
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: AppPadding.all20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50.h),

                // 제목, 설명, 입력칸 영역 (좌우 패딩 4)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontal4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        l10n.nicknameSetupTitle,
                        style: AppTextStyles.heading_24.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: AppSpacing.vertical16),

                      // 설명
                      Text(
                        l10n.nicknameSetupSubtitle,
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.black600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.vertical28),

                // 닉네임 입력칸 + 중복 확인 버튼
                _buildNicknameInputRow(l10n),

                // 검증 피드백 메시지
                if (_validationState != NicknameValidationState.none)
                  _buildValidationFeedback(l10n),

                const Spacer(),

                // 확인 버튼
                // - 닉네임 미변경: 바로 활성화 (서버 닉네임은 이미 유니크)
                // - 닉네임 변경: 중복확인 통과 후 활성화
                AppButton(
                  text: l10n.buttonConfirm,
                  onPressed:
                      !_isLoading &&
                          _nicknameController.text.trim().isNotEmpty &&
                          (!_isNicknameChanged ||
                              _validationState == NicknameValidationState.valid)
                      ? _onConfirm
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 닉네임 입력칸과 중복 확인 버튼을 포함한 Stack 위젯
  Widget _buildNicknameInputRow(AppLocalizations l10n) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        // TextField
        AppTextField(
          hintText: widget.initialNickname.isNotEmpty
              ? widget.initialNickname
              : l10n.fieldNicknameHint,
          controller: _nicknameController,
          maxLength: 20,
          textColor: _isNicknameChanged ? null : AppColors.black600,
          // NOTE: inputFormatters 제거 — 천지인/나랏글 등 일부 한국어 IME가
          // 자모 조합 중 임시 문자를 사용해 필터링되면 입력 자체가 깨지는 문제 방지.
          // 특수문자 검증은 백엔드(닉네임 중복확인/업데이트 API)에서 수행.
          onChanged: (value) {
            // 입력값이 변경되면 검증 상태 초기화 + 버튼 상태 갱신
            setState(() {
              _validationState = NicknameValidationState.none;
            });
          },
        ),

        // 중복 확인 버튼 (TextField 오른쪽 내부에 위치)
        Positioned(
          right: AppSpacing.horizontal4,
          child: _isLoading
              ? Padding(
                  padding: EdgeInsets.only(right: AppSpacing.horizontal8),
                  child: SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : custom_chip.ActionChip(
                  text: l10n.buttonCheckNicknameDuplicate,
                  height: AppSpacing.vertical40,
                  onTap: _isNicknameChanged ? _onCheckDuplicate : null,
                ),
        ),
      ],
    );
  }

  /// 검증 피드백 메시지 위젯
  Widget _buildValidationFeedback(AppLocalizations l10n) {
    // 상태별 메시지, 색상, 아이콘 설정
    final String message;
    final Color color;
    final String iconPath;

    switch (_validationState) {
      case NicknameValidationState.empty:
        message = l10n.errorNicknameTooShort;
        color = AppColors.red;
        iconPath = AppIcons.wrongMark;
        break;
      case NicknameValidationState.duplicate:
        message = l10n.errorNicknameDuplicated;
        color = AppColors.red;
        iconPath = AppIcons.wrongMark;
        break;
      case NicknameValidationState.valid:
        message = l10n.nicknameAvailable;
        color = AppColors.deepGreen;
        iconPath = AppIcons.checkMark;
        break;
      case NicknameValidationState.error:
        message = l10n.errorTemporaryRetry;
        color = AppColors.red;
        iconPath = AppIcons.wrongMark;
        break;
      case NicknameValidationState.none:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.vertical8,
        left: AppSpacing.horizontal8,
      ),
      child: Row(
        children: [
          // 아이콘
          SvgPicture.asset(
            iconPath,
            width: 20.w,
            height: 20.h,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          SizedBox(width: AppSpacing.horizontal8),
          // 메시지
          Text(message, style: AppTextStyles.tag_12.copyWith(color: color)),
        ],
      ),
    );
  }
}
