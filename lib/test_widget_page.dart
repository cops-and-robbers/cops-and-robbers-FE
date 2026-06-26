import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/utils/share_util.dart';
import 'package:go_router/go_router.dart';

import 'router/route_paths.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/spacing_and_radius.dart';
import 'core/constants/text_styles.dart';
import 'core/widgets/buttons/app_button.dart';
import 'core/network/websocket/stomp_connection.dart';
import 'core/widgets/dialogs/app_dialog.dart';
import 'core/widgets/dialogs/dialog_spacing.dart';
import 'core/widgets/dialogs/app_popup.dart';
import 'core/widgets/dialogs/reconnect_modal.dart';
import 'core/widgets/dialogs/countdown_timer_content.dart';
import 'core/services/loading_message_service.dart';
import 'core/widgets/chips/action_chip.dart' as custom_chips;
import 'core/widgets/chips/info_radius_chip.dart';
import 'core/widgets/inputs/app_slider.dart';
import 'core/widgets/inputs/app_text_field.dart';
import 'core/widgets/buttons/zone_setting_button_example.dart';
import 'core/widgets/indicators/step_indicator.dart';
import 'core/widgets/loading/custom_progress_bar.dart';
import 'core/widgets/loading/loading_page.dart';
import 'features/auth/presentation/pages/agreement_page.dart';
import 'features/auth/presentation/pages/nickname_setup_page.dart';
import 'features/game/domain/entities/game_result_entity.dart';
import 'features/game/presentation/providers/game_result_provider.dart';
import 'features/game/presentation/widgets/event_arrest_success_dialog.dart';
import 'features/game/presentation/widgets/event_result_board.dart';
import 'features/game/presentation/widgets/game_over_result_dialog.dart';
import 'features/game/presentation/widgets/ping_selection_card.dart';
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

  // StepIndicator 테스트용 상태
  int _currentStep = 0;

  // CustomProgressBar 테스트용 상태
  double _progress = 0.0;

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
          centerTitle: true,
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
                    debugPrint('기본 버튼 클릭!');
                  },
                ),

                SizedBox(height: AppSpacing.vertical12),

                // 테두리 없는 버튼
                AppButton(
                  text: '테두리 없는 버튼 (초록)',
                  onPressed: () {
                    debugPrint('초록 버튼 클릭!');
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
                    debugPrint('설정 버튼 클릭!');
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
                    debugPrint('다음 버튼 클릭!');
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
                              style: AppTextStyles.tag_12.copyWith(
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
                        debugPrint('로그인 성공! (시뮬레이션)');
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
                  label: '경찰 출동 시간',
                  value: _policeWaitTime,
                  min: 1,
                  max: 10,
                  unit: '분',
                  divisions: 9, // 1분 단위
                  displayPrefix: '도둑 도망 후',
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
                // NicknameSetupPage 테스트
                // ============================================
                _buildSectionTitle('NicknameSetupPage 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                // 닉네임 설정 페이지 이동 버튼
                AppButton(
                  text: '닉네임 설정 페이지 열기',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NicknameSetupPage(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.black,
                  showBorder: false,
                  icon: Icon(
                    Icons.person_outline,
                    size: 20.w,
                    color: AppColors.black,
                  ),
                  iconPosition: IconPosition.leading,
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // AgreementPage 테스트
                // ============================================
                _buildSectionTitle('AgreementPage 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                // 약관 동의 페이지 이동 버튼
                AppButton(
                  text: '약관 동의 페이지 열기',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgreementPage(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.black,
                  showBorder: false,
                  icon: Icon(
                    Icons.gavel_outlined,
                    size: 20.w,
                    color: AppColors.black,
                  ),
                  iconPosition: IconPosition.leading,
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
                    locationShareMinutes: 5,
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
                    debugPrint('중복확인 클릭!');
                  },
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 커스텀 ActionChip (파란색, 더 좁음)
                custom_chips.ActionChip(
                  text: '확인',
                  onTap: () {
                    debugPrint('확인 클릭!');
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
                        debugPrint('설정 클릭!');
                      },
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // StepIndicator 테스트
                // ============================================
                _buildSectionTitle('StepIndicator 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                // 현재 단계 표시
                Text(
                  '현재 단계: ${_currentStep + 1} / 4',
                  style: AppTextStyles.paragraph_14_100.copyWith(
                    color: AppColors.black600,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 기본 StepIndicator (검정 계열)
                StepIndicator(
                  totalSteps: 4,
                  currentStep: _currentStep,
                  barHeight: 4.0,
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 초록색 StepIndicator
                StepIndicator(
                  totalSteps: 4,
                  currentStep: _currentStep,
                  barHeight: 4.0,
                  activeColor: AppColors.green,
                  inactiveColor: AppColors.green100,
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 크기 큰 StepIndicator
                StepIndicator(
                  totalSteps: 5,
                  currentStep: _currentStep % 5,
                  barHeight: 4.0,
                  spacing: 12.0,
                  activeColor: AppColors.blue,
                  inactiveColor: AppColors.blue100,
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 단계 변경 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppButton(
                      text: '이전',
                      onPressed: _currentStep > 0
                          ? () {
                              setState(() {
                                _currentStep = (_currentStep - 1) % 4;
                              });
                            }
                          : null,
                      width: 100.w,
                      height: 44.h,
                      backgroundColor: AppColors.black800,
                      showBorder: false,
                    ),
                    SizedBox(width: AppSpacing.horizontal16),
                    AppButton(
                      text: '다음',
                      onPressed: () {
                        setState(() {
                          _currentStep = (_currentStep + 1) % 4;
                        });
                      },
                      width: 100.w,
                      height: 44.h,
                      showBorder: false,
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // CustomProgressBar 테스트
                // ============================================
                _buildSectionTitle('CustomProgressBar 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                // 기본 ProgressBar (검정 계열)
                CustomProgressBar(progress: _progress),
                SizedBox(height: AppSpacing.vertical16),

                // 진행률 텍스트 포함
                CustomProgressBar(progress: _progress, showPercentage: true),
                SizedBox(height: AppSpacing.vertical16),

                // 초록색 ProgressBar (높이 큰)
                CustomProgressBar(
                  progress: _progress,
                  fillColor: AppColors.green,
                  backgroundColor: AppColors.green100,
                  height: 12.h,
                  showPercentage: true,
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 파란색 ProgressBar (커스텀 너비)
                CustomProgressBar(
                  progress: _progress,
                  fillColor: AppColors.blue,
                  backgroundColor: AppColors.blue100,
                  width: 300.w,
                  height: 6.h,
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 진행률 조절 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppButton(
                      text: '-25%',
                      onPressed: () {
                        setState(() {
                          _progress = (_progress - 0.25).clamp(0.0, 1.0);
                        });
                      },
                      width: 80.w,
                      height: 44.h,
                      backgroundColor: AppColors.red,
                      showBorder: false,
                    ),
                    SizedBox(width: AppSpacing.horizontal12),
                    AppButton(
                      text: '+25%',
                      onPressed: () {
                        setState(() {
                          _progress = (_progress + 0.25).clamp(0.0, 1.0);
                        });
                      },
                      width: 80.w,
                      height: 44.h,
                      backgroundColor: AppColors.green,
                      foregroundColor: AppColors.black,
                      showBorder: false,
                    ),
                    SizedBox(width: AppSpacing.horizontal12),
                    AppButton(
                      text: '초기화',
                      onPressed: () {
                        setState(() {
                          _progress = 0.0;
                        });
                      },
                      width: 80.w,
                      height: 44.h,
                      backgroundColor: AppColors.black800,
                      showBorder: false,
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // LoadingPage 테스트
                // ============================================
                _buildSectionTitle('LoadingPage 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                // 기본 로딩 페이지 (진행률 없음)
                AppButton(
                  text: '기본 로딩 페이지 (진행률 없음)',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const LoadingPage(message: '로그인 중...'),
                      ),
                    );
                  },
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 진행률 포함 로딩 페이지
                AppButton(
                  text: '진행률 포함 로딩 페이지',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoadingPage(
                          message: '방 입장 중...',
                          progress: 0.7,
                          showPercentage: true,
                        ),
                      ),
                    );
                  },
                  backgroundColor: AppColors.blue,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 서브 메시지 포함 로딩 페이지
                AppButton(
                  text: '서브 메시지 포함 로딩 페이지',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoadingPage(
                          message: '게임 준비 중...',
                          subtitle: '잠시만 기다려주세요',
                          progress: 0.5,
                        ),
                      ),
                    );
                  },
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.black,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 어두운 배경 로딩 페이지
                AppButton(
                  text: '어두운 배경 로딩 페이지',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoadingPage(
                          message: '로딩 중...',
                          backgroundColor: AppColors.black,
                          textColor: AppColors.white,
                          progress: 0.3,
                          showPercentage: true,
                        ),
                      ),
                    );
                  },
                  backgroundColor: AppColors.black800,
                  showBorder: false,
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // AppDialog 테스트
                // ============================================
                _buildSectionTitle('AppDialog 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                // 1버튼 (게임 규칙)
                AppButton(
                  text: '1버튼 다이얼로그 (게임 규칙)',
                  onPressed: () {
                    AppDialog.show(
                      context: context,
                      title: '게임 규칙',
                      spacing: DialogSpacing(toContent: AppSpacing.vertical12),
                      customContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1. 경찰은 모든 도둑을 잡아서 체포하면,\n'
                            '도둑은 제한 시간이 끝날 때까지 버티면 승리해요',
                            style: AppTextStyles.paragraph_14.copyWith(
                              color: AppColors.black600,
                            ),
                          ),
                          SizedBox(height: AppSpacing.vertical8),
                          Text(
                            '2. 도둑팀의 위치는 n분마다 경찰팀에게 공유돼요',
                            style: AppTextStyles.paragraph_14.copyWith(
                              color: AppColors.black600,
                            ),
                          ),
                          SizedBox(height: AppSpacing.vertical8),
                          Text(
                            '3. 지정된 게임 구역에서 벗어나면 안 돼요\n'
                            '→ 구역 안으로 돌아갈 때까지 위치가 드러나요',
                            style: AppTextStyles.paragraph_14.copyWith(
                              color: AppColors.black600,
                            ),
                          ),
                        ],
                      ),
                      confirmText: '확인했어요!',
                      confirmColor: AppColors.blue,
                    );
                  },
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 팝업 (게임 종료)
                AppButton(
                  text: '팝업 (게임 종료)',
                  onPressed: () {
                    AppPopup.show(
                      context: context,
                      autoCloseDuration: const Duration(seconds: 10),
                      barrierDismissible: false,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '게임 종료!',
                            style: AppTextStyles.heading_20.copyWith(
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.vertical12),
                          Text(
                            '게임 시작 지점으로 모여 주세요!',
                            style: AppTextStyles.paragraph_14_100.copyWith(
                              color: AppColors.black600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                  showBorder: false,
                  backgroundColor: AppColors.black800,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 2버튼 (취소 + 확인)
                AppButton(
                  text: '2버튼 다이얼로그 (취소+확인)',
                  onPressed: () {
                    AppDialog.show(
                      context: context,
                      title: '체포할까요?',
                      message: '이 플레이어를 체포합니다',
                      cancelText: '취소',
                      onConfirm: () {},
                    );
                  },
                  backgroundColor: AppColors.blue,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 위험 액션 (빨간 확인 버튼)
                AppButton(
                  text: '위험 액션 다이얼로그 (isDestructive)',
                  onPressed: () async {
                    final result = await AppDialog.confirm(
                      context: context,
                      title: '정말 탈퇴하시겠어요?',
                      message: '회원 정보가 전부 삭제되어 복구할 수 없어요',
                      confirmText: '탈퇴하기',
                      isDestructive: true,
                    );
                    if (result == true && mounted) {
                      debugPrint('삭제 확인!');
                    }
                  },
                  backgroundColor: AppColors.red,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 아바타 포함 (체포 로직 - 파란 확인 버튼)
                AppButton(
                  text: '아바타 다이얼로그 (체포 로직)',
                  onPressed: () {
                    AppDialog.show(
                      context: context,
                      title: '해당 플레이어를 체포하셨나요?',
                      showAvatar: true,
                      avatarWidget: ClipRRect(
                        borderRadius: AppRadius.large,
                        child: Image.asset(
                          'assets/app_icon.png',
                          width: 92.w,
                          height: 108.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      nickname: '닉네임',
                      cancelText: '아니요',
                      confirmText: '네',
                      confirmColor: AppColors.blue,
                    );
                  },
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.black,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 타이머 다이얼로그 (여유)
                AppButton(
                  text: '타이머 팝업 (여유) - 1분 자동닫힘',
                  onPressed: () {
                    AppPopup.show(
                      context: context,
                      autoCloseDuration: const Duration(minutes: 1),
                      barrierDismissible: false,
                      content: const CountdownTimerContent(
                        duration: Duration(minutes: 1),
                        subtitle: '도둑이 도망치는 중이에요!',
                      ),
                    );
                  },
                  backgroundColor: AppColors.black600,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 타이머 다이얼로그 (1분 미만)
                AppButton(
                  text: '타이머 팝업 (30초) - 빨간색',
                  onPressed: () {
                    AppPopup.show(
                      context: context,
                      autoCloseDuration: const Duration(seconds: 30),
                      barrierDismissible: false,
                      content: const CountdownTimerContent(
                        duration: Duration(seconds: 30),
                        subtitle: '도둑 잡을 준비 되셨나요?',
                      ),
                    );
                  },
                  backgroundColor: AppColors.red,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 초대코드 생성 다이얼로그
                AppButton(
                  text: '초대코드 생성 다이얼로그',
                  onPressed: () {
                    const sessionCode = 'A1B2C3';
                    final messenger = ScaffoldMessenger.of(context);
                    AppDialog.show(
                      context: context,
                      title: '초대코드를 생성했어요',
                      message: '친구에게 코드를 공유하고 게임에 참여해 보세요!',
                      cancelText: '닫기',
                      confirmText: '공유하기',
                      confirmColor: AppColors.blue,
                      onConfirm: () {
                        shareText(
                          '경찰과 도둑 게임에 참여하세요!\n참여코드: $sessionCode',
                          subject: '경찰과 도둑 초대코드',
                        );
                      },
                      customContent: GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(
                            const ClipboardData(text: sessionCode),
                          );
                          messenger.clearSnackBars();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                '코드가 복사되었습니다',
                                style: AppTextStyles.paragraph_14,
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.vertical20,
                            horizontal: AppSpacing.horizontal16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.black100),
                            borderRadius: AppRadius.medium,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sessionCode,
                                style: AppTextStyles.heading_20.copyWith(
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(width: AppSpacing.horizontal4),
                              SvgPicture.asset(
                                'assets/icons/icon_copy.svg',
                                width: 20.w,
                                height: 20.w,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.black300,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  backgroundColor: AppColors.blue,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 초대코드 다이얼로그 (다크 모드)
                AppButton(
                  text: '초대코드 다이얼로그 (다크 모드)',
                  onPressed: () {
                    const sessionCode = 'A1B2C3';
                    final messenger = ScaffoldMessenger.of(context);
                    AppDialog.show(
                      context: context,
                      isDarkMode: true,
                      backgroundColor: AppColors.black,
                      title: '초대코드를 생성했어요',
                      titleStyle: AppTextStyles.robberHeading.copyWith(
                        color: AppColors.white,
                      ),
                      message: '친구에게 코드를 공유하고 게임에 참여해 보세요!',
                      cancelText: '닫기',
                      confirmText: '공유하기',
                      onConfirm: () {
                        shareText(
                          '경찰과 도둑 게임에 참여하세요!\n참여코드: $sessionCode',
                          subject: '경찰과 도둑 초대코드',
                        );
                      },
                      customContent: GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(
                            const ClipboardData(text: sessionCode),
                          );
                          messenger.clearSnackBars();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                '코드가 복사되었습니다',
                                style: AppTextStyles.paragraph_14,
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.vertical20,
                            horizontal: AppSpacing.horizontal16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.black800),
                            borderRadius: AppRadius.medium,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sessionCode,
                                style: AppTextStyles.robberHeading.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              SizedBox(width: AppSpacing.horizontal4),
                              SvgPicture.asset(
                                'assets/icons/icon_copy.svg',
                                width: 20.w,
                                height: 20.w,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.black500,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  backgroundColor: AppColors.black800,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 랜덤 로딩 팝업 테스트
                AppButton(
                  text: '랜덤 로딩 팝업 (2초)',
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await AppPopup.showRandomLoading(
                      context: context,
                      category: LoadingCategory.joinRoom,
                    );
                    await Future.delayed(const Duration(seconds: 2));
                    if (navigator.canPop()) navigator.pop();
                  },
                  backgroundColor: AppColors.black600,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 커스텀 타이틀 스타일
                AppButton(
                  text: '커스텀 타이틀 스타일',
                  onPressed: () {
                    AppDialog.show(
                      context: context,
                      title: '커스텀 제목',
                      message: 'titleStyle로 제목 스타일을 변경할 수 있습니다',
                      titleStyle: AppTextStyles.heading_20.copyWith(
                        color: AppColors.blue,
                      ),
                      confirmColor: AppColors.blue,
                    );
                  },
                  backgroundColor: AppColors.blue800,
                  showBorder: false,
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // GameOverResultDialog 테스트
                // ============================================
                _buildSectionTitle('GameOverResultDialog 테스트'),
                SizedBox(height: AppSpacing.vertical8),
                Text(
                  '4조합 버튼 — mock AsyncValue.data로 다이얼로그 표시',
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.black400,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical16),

                AppButton(
                  text: '경찰 승리 (light)',
                  onPressed: () => _showMockGameOverDialog(
                    context: context,
                    isDarkMode: false,
                    myTeam: 'POLICE',
                    winnerTeam: 'POLICE',
                  ),
                  backgroundColor: AppColors.blue,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                AppButton(
                  text: '경찰 패배 (light)',
                  onPressed: () => _showMockGameOverDialog(
                    context: context,
                    isDarkMode: false,
                    myTeam: 'POLICE',
                    winnerTeam: 'ROBBER',
                  ),
                  backgroundColor: AppColors.red,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                AppButton(
                  text: '도둑 승리 (dark)',
                  onPressed: () => _showMockGameOverDialog(
                    context: context,
                    isDarkMode: true,
                    myTeam: 'ROBBER',
                    winnerTeam: 'ROBBER',
                  ),
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.black,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                AppButton(
                  text: '도둑 패배 (dark)',
                  onPressed: () => _showMockGameOverDialog(
                    context: context,
                    isDarkMode: true,
                    myTeam: 'ROBBER',
                    winnerTeam: 'POLICE',
                  ),
                  backgroundColor: AppColors.black800,
                  showBorder: false,
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // ReconnectModal 테스트
                // ============================================
                _buildSectionTitle('ReconnectModal 테스트'),
                SizedBox(height: AppSpacing.vertical8),
                Text(
                  '"재연결" 탭 → 2초 스피너 → 모달 자동 닫힘',
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.black400,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 경찰팀 (light 테마, 파란 버튼)
                AppButton(
                  text: '재연결 모달 — 경찰 (light)',
                  onPressed: () {
                    final notifier = ValueNotifier(
                      StompConnectionState.disconnected,
                    );
                    final nav = Navigator.of(context);
                    ReconnectModal.show(
                      context: context,
                      isDarkMode: false,
                      stateNotifier: notifier,
                      onReconnect: () {
                        // connecting 상태 → 2초 후 connected 처리 후 모달 닫기
                        notifier.value = StompConnectionState.connecting;
                        Future.delayed(const Duration(seconds: 2), () {
                          if (nav.canPop()) nav.pop();
                          notifier.dispose();
                        });
                      },
                    );
                  },
                  backgroundColor: AppColors.blue,
                  showBorder: false,
                ),
                SizedBox(height: AppSpacing.vertical12),

                // 도둑팀 (dark 테마, 초록 버튼)
                AppButton(
                  text: '재연결 모달 — 도둑 (dark)',
                  onPressed: () {
                    final notifier = ValueNotifier(
                      StompConnectionState.disconnected,
                    );
                    final nav = Navigator.of(context);
                    ReconnectModal.show(
                      context: context,
                      isDarkMode: true,
                      stateNotifier: notifier,
                      onReconnect: () {
                        notifier.value = StompConnectionState.connecting;
                        Future.delayed(const Duration(seconds: 2), () {
                          if (nav.canPop()) nav.pop();
                          notifier.dispose();
                        });
                      },
                    );
                  },
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.black,
                  showBorder: false,
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // 페이지 이동 테스트 (점검/강제 업데이트)
                // ============================================
                _buildSectionTitle('페이지 이동 테스트'),
                SizedBox(height: AppSpacing.vertical16),

                // 점검 페이지 이동
                AppButton(
                  text: '점검 페이지 (Maintenance)',
                  onPressed: () => context.go(RoutePaths.maintenance),
                  backgroundColor: AppColors.black800,
                  showBorder: false,
                ),

                SizedBox(height: AppSpacing.vertical12),

                // 강제 업데이트 페이지 이동
                AppButton(
                  text: '강제 업데이트 페이지 (Force Update)',
                  onPressed: () => context.go(RoutePaths.forceUpdate),
                  backgroundColor: AppColors.black800,
                  showBorder: false,
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // 맵 핑 (PingSelectionCard) 테스트
                // ============================================
                _buildSectionTitle('맵 핑 선택 카드 테스트'),
                SizedBox(height: AppSpacing.vertical8),
                Text(
                  '롱프레스 시 좌표 위에 뜨는 발견/의심 선택 카드. 셀을 탭하면 스낵바로 표시돼요.',
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.black400,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 경찰 (light) — 파란 카드
                Text(
                  '경찰 (light)',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.black600,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical8),
                Center(
                  child: PingSelectionCard(
                    isDarkMode: false,
                    onFound: () => _showPingSnack('발견 (경찰)'),
                    onSuspect: () => _showPingSnack('의심 (경찰)'),
                  ),
                ),
                SizedBox(height: AppSpacing.vertical24),

                // 도둑 (dark) — 검정 카드 (어두운 배경 위에서 확인)
                Text(
                  '도둑 (dark)',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.black600,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: AppSpacing.vertical24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black900,
                    borderRadius: AppRadius.medium,
                  ),
                  child: Center(
                    child: PingSelectionCard(
                      isDarkMode: true,
                      onFound: () => _showPingSnack('발견 (도둑)'),
                      onSuspect: () => _showPingSnack('의심 (도둑)'),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.vertical24),

                // 핑 마커 미리보기 (지도에 찍히는 핑은 종류 심볼 단독, 핀 꼬리 없음)
                Text(
                  '핑 마커 미리보기 (지도에는 종류 심볼만 — 핀 꼬리는 선택 카드 전용)',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.black600,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical12),
                Row(
                  children: [
                    // light 마커 2종 (흰 배경)
                    _buildPingMarkerPreview(type: 'found', isDark: false),
                    SizedBox(width: AppSpacing.horizontal24),
                    _buildPingMarkerPreview(type: 'suspect', isDark: false),
                    SizedBox(width: AppSpacing.horizontal24),
                    // dark 마커 2종 (어두운 배경)
                    Container(
                      padding: EdgeInsets.all(AppSpacing.horizontal12),
                      decoration: BoxDecoration(
                        color: AppColors.black900,
                        borderRadius: AppRadius.medium,
                      ),
                      child: Row(
                        children: [
                          _buildPingMarkerPreview(type: 'found', isDark: true),
                          SizedBox(width: AppSpacing.horizontal24),
                          _buildPingMarkerPreview(
                            type: 'suspect',
                            isDark: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.vertical64),

                // ============================================
                // 이벤트 모드 모달 테스트
                // ============================================
                _buildSectionTitle('이벤트 모드 모달 테스트'),
                SizedBox(height: AppSpacing.vertical8),
                Text(
                  '운영진 체포 성공(증거 공개) + 게임 종료 결과 보드. 경찰 화면 전용(라이트).',
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.black400,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical16),

                // 체포 성공 다이얼로그 — 증거 1~3
                for (var i = 1; i <= 3; i++) ...[
                  AppButton(
                    text: '체포 성공 다이얼로그 (증거 $i)',
                    onPressed: () => EventArrestSuccessDialog.show(
                      context: context,
                      evidenceIndex: i,
                      robberNickname: '운영진$i',
                    ),
                    backgroundColor: AppColors.blue,
                    showBorder: false,
                  ),
                  SizedBox(height: AppSpacing.vertical12),
                ],

                // 결과 보드 — 검거 0~3명
                for (var count = 0; count <= 3; count++) ...[
                  AppButton(
                    text: '결과 보드 (검거 $count명)',
                    onPressed: () => EventResultBoard.show(
                      context: context,
                      arrestCount: count,
                      onGoHome: () => Navigator.of(context).pop(),
                    ),
                    backgroundColor: AppColors.black800,
                    showBorder: false,
                  ),
                  SizedBox(height: AppSpacing.vertical12),
                ],

                SizedBox(height: AppSpacing.vertical64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 다이얼로그 시각 테스트용 헬퍼 — gameResultProvider를 mock AsyncValue.data로 override
  void _showMockGameOverDialog({
    required BuildContext context,
    required bool isDarkMode,
    required String myTeam,
    required String winnerTeam,
  }) {
    const mockGameResultId = 999;
    const mockEntity = GameResultEntity(
      winnerTeam: 'POLICE', // UI에서는 myTeam==winnerTeam 비교만 쓰므로 임의값 OK
      durationSeconds: 1845, // 30:45
      totalArrestCount: 12,
      remainingRobberCount: 2,
    );

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProviderScope(
        overrides: [
          gameResultProvider(
            mockGameResultId,
          ).overrideWith((_) async => mockEntity),
        ],
        child: GameOverResultDialog(
          isDarkMode: isDarkMode,
          myTeam: myTeam,
          winnerTeam: winnerTeam,
          gameResultId: mockGameResultId,
          onGoHome: () => Navigator.of(context).pop(),
          onRematch: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// 핑 선택 카드 셀 탭 → 어떤 셀을 눌렀는지 스낵바로 표시 (시각 테스트용)
  void _showPingSnack(String label) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('핑: $label', style: AppTextStyles.paragraph_14),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 핑 마커 미리보기 (지도에 찍히는 핑은 종류 심볼 단독 — 핀 꼬리 없음)
  Widget _buildPingMarkerPreview({required String type, required bool isDark}) {
    final theme = isDark ? 'darkmode' : 'lightmode';
    return SvgPicture.asset(
      'assets/icons/icon_ping_${type}_marker_$theme.svg',
      width: 24.w,
      height: 24.w,
    );
  }

  /// 섹션 제목 위젯
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subHeading_18.copyWith(color: AppColors.black),
    );
  }
}
