import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/spacing_and_radius.dart';
import 'core/widgets/buttons/app_button.dart';
import 'core/widgets/chips/action_chip.dart' as custom_chips;
import 'core/widgets/chips/info_radius_chip.dart';
import 'core/widgets/inputs/app_slider.dart';
import 'core/widgets/inputs/app_text_field.dart';
import 'core/widgets/buttons/zone_setting_button_example.dart';
import 'features/session/domain/entities/session_settings.dart';
import 'features/session/domain/entities/zone_info.dart';
import 'features/session/presentation/widgets/session_info_view.dart';

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

  // AppSlider 테스트용 상태
  double _maxPlayers = 50.0;
  double _policeWaitTime = 5.0;
  double _playgroundRadius = 400.0;
  double _roundTime = 30.0;

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

                SizedBox(height: AppSpacing.vertical32),

                // ============================================
                // AppSlider 테스트
                // ============================================
                _buildSectionTitle('AppSlider 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                // 기본 슬라이더 (검정 계열)
                AppSlider(
                  label: '라운드 제한 시간',
                  value: _maxPlayers,
                  min: 5,
                  max: 50,
                  unit: '명',
                  divisions: 45, // 1명 단위
                  onChanged: (value) {
                    setState(() => _maxPlayers = value);
                  },
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 파란색 슬라이더
                AppSlider(
                  label: '플레이그라운드 반경',
                  value: _playgroundRadius,
                  min: 100,
                  max: 1000,
                  unit: 'm',
                  divisions: 90, // 10m 단위
                  activeTrackColor: AppColors.blue800,
                  thumbColor: AppColors.blue,
                  inactiveTrackColor: AppColors.blue100,
                  onChanged: (value) {
                    setState(() => _playgroundRadius = value);
                  },
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 복합 텍스트 스타일 슬라이더 (NEW)
                AppSlider(
                  label: '경찰 시작 시간',
                  value: _policeWaitTime,
                  min: 1,
                  max: 10,
                  unit: '분',
                  divisions: 9, // 1분 단위
                  displayPrefix: '도둑 시작 후',
                  displaySuffix: '뒤',
                  onChanged: (value) {
                    setState(() => _policeWaitTime = value);
                  },
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 최소/최대 숨김 슬라이더 (초록색)
                AppSlider(
                  label: '라운드 시간',
                  value: _roundTime,
                  min: 10,
                  max: 60,
                  unit: '분',
                  showMinMax: false, // 최소/최대 숨김
                  activeTrackColor: AppColors.green800,
                  thumbColor: AppColors.green,
                  inactiveTrackColor: AppColors.green100,
                  onChanged: (value) {
                    setState(() => _roundTime = value);
                  },
                ),
                AppSlider(
                  label: '플레이그라운드 반경',
                  value: _playgroundRadius,
                  min: 100,
                  max: 1000,
                  unit: 'm',
                  divisions: 90, // 10m 단위
                  activeTrackColor: AppColors.blue800,
                  thumbColor: AppColors.blue,
                  inactiveTrackColor: AppColors.blue100,
                  showContainer: false,
                  onChanged: (value) {
                    setState(() => _playgroundRadius = value);
                  },
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // SessionInfoView 테스트
                // ============================================
                _buildSectionTitle('SessionInfoView 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                const SessionInfoView(
                  sessionCode: 'A1B2C3',
                  zones: [
                    ZoneInfo(id: '1', name: '플레이그라운드', radiusMeters: 400),
                    ZoneInfo(id: '2', name: '감옥', radiusMeters: 200),
                  ],
                  settings: SessionSettings(
                    maxPlayers: 50,
                    roundTimeMinutes: 30,
                    locationShareSeconds: 5,
                    policeStartDelayMinutes: 5,
                  ),
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // ZoneSettingButton 테스트
                // ============================================
                _buildSectionTitle('ZoneSettingButton 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                // 전용 테스트 페이지 이동 버튼
                AppButton(
                  text: '구역 설정 버튼 예시 페이지 열기',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ZoneSettingButtonExample(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.blue,
                  showBorder: false,
                  icon: Icon(
                    Icons.map_outlined,
                    size: 20.w,
                    color: AppColors.white,
                  ),
                  iconPosition: IconPosition.leading,
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // InfoRadiusChip & ActionChip 테스트
                // ============================================
                _buildSectionTitle('InfoRadiusChip & ActionChip 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                // 기본 InfoRadiusChip (파란색)
                const InfoRadiusChip(prefix: '반경', value: '400m'),
                SizedBox(height: AppSpacing.vertical12),

                // 커스텀 InfoRadiusChip (초록색, 더 넓음)
                InfoRadiusChip(
                  prefix: '거리',
                  value: '1.2km',
                  backgroundColor: AppColors.green,
                  width: 130.w,
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 기본 ActionChip (검정)
                custom_chips.ActionChip(
                  text: '중복 확인',
                  onTap: () {
                    _showSnackBar('중복확인 클릭!');
                  },
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 커스텀 ActionChip (파란색, 더 좁음)
                custom_chips.ActionChip(
                  text: '확인',
                  onTap: () {
                    _showSnackBar('확인 클릭!');
                  },
                  backgroundColor: AppColors.blue,
                  width: 80.w,
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 조합 예시 (Row로 배치)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const InfoRadiusChip(prefix: '플레이그라운드', value: '500m'),
                    SizedBox(width: AppSpacing.horizontal12),
                    custom_chips.ActionChip(
                      text: '설정',
                      onTap: () {
                        _showSnackBar('설정 클릭!');
                      },
                    ),
                  ],
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
    // 스낵바 비활성화
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(message),
    //     duration: const Duration(seconds: 2),
    //     backgroundColor: AppColors.green,
    //   ),
    // );
  }
}
