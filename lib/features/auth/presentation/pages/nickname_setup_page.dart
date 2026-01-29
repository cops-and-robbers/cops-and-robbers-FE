import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/chips/action_chip.dart' as custom_chip;
import '../../../../core/widgets/inputs/app_text_field.dart';

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
/// 중복 확인 기능을 제공하며, 나중에 API 연동 예정입니다.
class NicknameSetupPage extends StatefulWidget {
  const NicknameSetupPage({super.key});

  @override
  State<NicknameSetupPage> createState() => _NicknameSetupPageState();
}

class _NicknameSetupPageState extends State<NicknameSetupPage> {
  // ============================================
  // State Variables
  // ============================================

  /// 닉네임 입력 컨트롤러
  late TextEditingController _nicknameController;

  /// 닉네임 검증 상태
  NicknameValidationState _validationState = NicknameValidationState.none;

  // ============================================
  // Lifecycle Methods
  // ============================================

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
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
  void _onCheckDuplicate() {
    final nickname = _nicknameController.text.trim();

    // 빈 닉네임 검증
    if (nickname.isEmpty) {
      setState(() {
        _validationState = NicknameValidationState.empty;
      });
      return;
    }

    debugPrint('중복 확인 - 입력값: $nickname');

    // TODO: API 연동 - 닉네임 중복 체크
    // 임시로 "test"는 중복으로 처리
    if (nickname == 'test') {
      setState(() {
        _validationState = NicknameValidationState.duplicate;
      });
    } else {
      setState(() {
        _validationState = NicknameValidationState.valid;
      });
    }
  }

  /// 확인 버튼 클릭 시 호출
  ///
  /// 버튼이 valid 상태에서만 활성화되므로,
  /// 이 메서드는 유효한 닉네임에 대해서만 호출됩니다.
  void _onConfirm() {
    final nickname = _nicknameController.text.trim();

    debugPrint('확인 버튼 클릭 - 닉네임: $nickname');
    // TODO: API 연동 - 닉네임 저장 및 다음 페이지 이동
  }

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
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
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        '닉네임을 설정해요',
                        style: AppTextStyles.heading_24.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: AppSpacing.vertical16),

                      // 설명
                      Text(
                        '서비스 내에서 계속 사용될 닉네임이에요\n1~10글자로 생성할 수 있어요',
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.black600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // 닉네임 입력칸 + 중복 확인 버튼
                _buildNicknameInputRow(),

                // 검증 피드백 메시지
                if (_validationState != NicknameValidationState.none)
                  _buildValidationFeedback(),

                const Spacer(),

                // 확인 버튼 (valid 상태에서만 활성화)
                AppButton(
                  text: '확인',
                  onPressed: _validationState == NicknameValidationState.valid
                      ? _onConfirm
                      : null,
                  showBorder: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 닉네임 입력칸과 중복 확인 버튼을 포함한 Stack 위젯
  Widget _buildNicknameInputRow() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        // TextField
        AppTextField(
          hintText: '포근포근백설기',
          controller: _nicknameController,
          maxLength: 10,
          onChanged: (value) {
            // 입력값이 변경되면 검증 상태 초기화
            if (_validationState != NicknameValidationState.none) {
              setState(() {
                _validationState = NicknameValidationState.none;
              });
            }
          },
        ),

        // 중복 확인 버튼 (TextField 오른쪽 내부에 위치)
        Positioned(
          right: AppSpacing.horizontal4,
          child: custom_chip.ActionChip(
            text: '중복 확인',
            height: AppSpacing.vertical40,
            onTap: _onCheckDuplicate,
          ),
        ),
      ],
    );
  }

  /// 검증 피드백 메시지 위젯
  Widget _buildValidationFeedback() {
    // 상태별 메시지, 색상, 아이콘 설정
    final String message;
    final Color color;
    final String iconPath;

    switch (_validationState) {
      case NicknameValidationState.empty:
        message = '1글자 미만의 닉네임은 사용할 수 없어요';
        color = AppColors.red;
        iconPath = 'assets/icons/icon_wrong mark.svg';
        break;
      case NicknameValidationState.duplicate:
        message = '중복된 닉네임이에요. 다른 닉네임을 입력하세요';
        color = AppColors.red;
        iconPath = 'assets/icons/icon_wrong mark.svg';
        break;
      case NicknameValidationState.valid:
        message = '사용 가능한 닉네임이에요';
        color = AppColors.deepGreen;
        iconPath = 'assets/icons/icon_check mark.svg';
        break;
      case NicknameValidationState.error:
        message = '오류가 발생했어요. 다시 시도해주세요';
        color = AppColors.red;
        iconPath = 'assets/icons/icon_wrong mark.svg';
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
