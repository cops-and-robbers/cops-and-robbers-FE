import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/spacing_and_radius.dart';
import 'core/widgets/buttons/app_button.dart';
import 'core/widgets/inputs/app_text_field.dart';

/// 공용 컴포넌트 테스트 페이지
///
/// AppButton, AppTextField 등 core widgets를 테스트하는 페이지
class TestWidgetPage extends StatefulWidget {
  const TestWidgetPage({super.key});

  @override
  State<TestWidgetPage> createState() => _TestWidgetPageState();
}

class _TestWidgetPageState extends State<TestWidgetPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  bool _emailHasError = false;
  String _emailErrorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 빈 공간 클릭 시 키보드 닫기
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text('공용 컴포넌트 테스트'),
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppPadding.all20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // AppButton 테스트
                // ============================================
                _buildSectionTitle('AppButton 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                // 기본 버튼
                AppButton(
                  text: '기본 버튼 (검정)',
                  onPressed: () {
                    _showSnackBar('기본 버튼 클릭!');
                  },
                ),

                SizedBox(height: AppSpacing.vertical12),

                // 테두리 없는 버튼
                AppButton(
                  text: '테두리 없는 버튼 (초록)',
                  onPressed: () {
                    _showSnackBar('초록 버튼 클릭!');
                  },
                  showBorder: false,
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.black,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 아이콘 포함 버튼 (leading)
                AppButton(
                  text: '설정',
                  onPressed: () {
                    _showSnackBar('설정 버튼 클릭!');
                  },
                  showBorder: false,
                  icon: Icon(
                    Icons.settings,
                    size: 20.w,
                    color: AppColors.white,
                  ),
                  iconPosition: IconPosition.leading,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 아이콘 포함 버튼 (trailing)
                AppButton(
                  showBorder: false,
                  text: '다음',
                  onPressed: () {
                    _showSnackBar('다음 버튼 클릭!');
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 20.w,
                    color: AppColors.white,
                  ),
                  iconPosition: IconPosition.trailing,
                  backgroundColor: AppColors.blue,
                  borderColor: AppColors.blue800,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 로딩 중 버튼
                AppButton(
                  text: '로딩 중...',
                  onPressed: () {},
                  isLoading: _isLoading,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 비활성화 버튼
                AppButton(
                  text: '비활성화 버튼',
                  onPressed: null, // null이면 비활성화
                ),

                SizedBox(height: AppSpacing.vertical32),

                // ============================================
                // AppTextField 테스트
                // ============================================
                _buildSectionTitle('AppTextField 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                // 기본 TextField
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      hintText: '이메일을 입력하세요',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      hasError: _emailHasError,
                      onChanged: (value) {
                        // 간단한 이메일 유효성 검사
                        setState(() {
                          if (value.isEmpty) {
                            _emailHasError = false;
                            _emailErrorMessage = '';
                          } else if (!value.contains('@')) {
                            _emailHasError = true;
                            _emailErrorMessage = '올바른 이메일 형식이 아닙니다';
                          } else {
                            _emailHasError = false;
                            _emailErrorMessage = '';
                          }
                        });
                      },
                    ),
                    if (_emailHasError)
                      Padding(
                        padding: EdgeInsets.only(
                          left: AppSpacing.horizontal20,
                          top: AppSpacing.vertical4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16.w,
                              color: AppColors.red,
                            ),
                            SizedBox(width: AppSpacing.horizontal4),
                            Text(
                              _emailErrorMessage,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 비밀번호 TextField
                AppTextField(
                  hintText: '비밀번호를 입력하세요',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 테두리 없는 TextField (검색)
                AppTextField(
                  hintText: '검색어를 입력하세요',
                  showBorder: false,
                  backgroundColor: AppColors.black100,
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.black600,
                    size: 20.w,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 여러 줄 TextField (메모)
                AppTextField(
                  hintText: '메모를 입력하세요',
                  controller: _memoController,
                  maxLines: 5,
                  height: 120.h,
                  textInputAction: TextInputAction.newline,
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 커스텀 색상 TextField
                AppTextField(
                  hintText: '닉네임을 입력하세요',
                  backgroundColor: AppColors.green100,
                  borderColor: AppColors.green,
                  focusedBorderColor: AppColors.green800,
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 비활성화 TextField
                AppTextField(hintText: '비활성화 상태', enabled: false),

                SizedBox(height: AppSpacing.vertical32),

                // ============================================
                // 조합 예시 (로그인 폼)
                // ============================================
                _buildSectionTitle('조합 예시 - 로그인 폼'),
                SizedBox(height: AppSpacing.vertical16),

                AppTextField(
                  hintText: '이메일',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.black600,
                    size: 20.w,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical12),

                AppTextField(
                  hintText: '비밀번호',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: AppColors.black600,
                    size: 20.w,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical24),

                AppButton(
                  text: '로그인',
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });

                    // 2초 후 로딩 해제 (시뮬레이션)
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                        _showSnackBar('로그인 성공! (시뮬레이션)');
                      }
                    });
                  },
                  isLoading: _isLoading,
                ),

                SizedBox(height: AppSpacing.vertical64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 섹션 제목 위젯
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }

  /// 스낵바 표시
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.green,
      ),
    );
  }
}
