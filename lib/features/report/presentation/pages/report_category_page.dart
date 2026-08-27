import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/pages/text_submit_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/constants/report_categories.dart';

/// 신고 접수 결과 — 사용자가 그냥 나갔으면 화면이 null을 돌려준다.
class ReportOutcome {
  const ReportOutcome(this.error);

  /// null이면 접수 완료.
  final Object? error;
}

/// 신고 유형 선택 화면
///
/// 유형을 고르고 아래 "신고하기"를 누르면 [submit]으로 접수한 뒤 결과를 돌려준다.
/// 기타는 사유가 필수라 누르는 즉시 작성 화면을 이 화면 위에 얹는다 — 작성 화면에서
/// 뒤로 가면 유형 목록으로 돌아온다.
///
/// 결과 안내(스낵바)는 호출부가 한다. 이 화면은 그때 이미 닫혀 있다.
///
/// 시트가 아니라 화면인 이유: 유형이 일곱이라 시트로 올리면 화면 대부분을 덮고,
/// 아래 제출 버튼이 홈 인디케이터와 겹친다. 여기서는 버튼이 확인 역할을 겸한다.
class ReportCategoryPage extends StatefulWidget {
  const ReportCategoryPage({
    super.key,
    required this.submit,
    this.isDarkMode = false,
  });

  /// 고른 유형으로 접수한다. 기타면 [etcReason]에 사용자가 쓴 사유가 담긴다.
  final Future<void> Function(ReportCategory category, String? etcReason)
  submit;

  /// 인게임 채팅은 도둑 테마(어두운 화면) 위에서 열린다.
  final bool isDarkMode;

  static Future<ReportOutcome?> push(
    BuildContext context, {
    required Future<void> Function(ReportCategory category, String? etcReason)
    submit,
    bool isDarkMode = false,
  }) {
    // 루트 네비게이터로 띄운다 — 브랜치 네비게이터에 올리면 바텀 네비게이션이
    // 그대로 남아 신고 화면 아래에 탭이 보인다.
    return Navigator.of(context, rootNavigator: true).push<ReportOutcome>(
      MaterialPageRoute(
        builder: (_) =>
            ReportCategoryPage(submit: submit, isDarkMode: isDarkMode),
      ),
    );
  }

  @override
  State<ReportCategoryPage> createState() => _ReportCategoryPageState();
}

/// 기타 사유 길이 상한 — 서버 검증값(`etcReason.maxLength`)과 같아야 한다.
const int _etcReasonMaxLength = 300;

class _ReportCategoryPageState extends State<ReportCategoryPage> {
  ReportCategory? _selected;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black900 : AppColors.white,
      appBar: AppTopBar(
        title: l10n.buttonReport,
        isDarkMode: isDark,
        leading: Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: PreviousButton(
            onPressed: () => Navigator.of(context).pop(),
            color: isDark ? AppColors.white : null,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.horizontal20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.vertical20),
              // 라벨만 좌우로 4 더 들어간다 — 카드가 화면 패딩에 딱 붙기 때문에
              // 라벨을 같은 x에 두면 카드 테두리에 붙어 보인다.
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal4,
                ),
                child: Text(
                  l10n.reportCategoryLabel,
                  style: AppTextStyles.label_16.copyWith(
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.vertical18),
              Expanded(child: SingleChildScrollView(child: _buildCard(l10n))),
              AppButton(
                text: l10n.buttonReport,
                // 유형을 고르기 전에는 보낼 것이 없다.
                onPressed: _selected == null || _submitting ? null : _submit,
                width: double.infinity,
                backgroundColor: AppColors.red,
                foregroundColor: AppColors.white,
                borderRadius: AppRadius.xlarge,
                showBorder: false,
                textStyle: isDark
                    ? AppTextStyles.robberLabel
                    : AppTextStyles.label_16,
              ),
              SizedBox(height: AppSpacing.vertical16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(AppLocalizations l10n) {
    final categories = ReportCategory.values;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xl20,
        border: Border.all(color: _lineColor),
      ),
      // 마지막 항목의 배경이 둥근 모서리 밖으로 새지 않게 잘라 낸다.
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < categories.length; i++) ...[
            if (i > 0) Divider(height: 1.h, thickness: 1.h, color: _lineColor),
            _buildOption(
              l10n,
              categories[i],
              isFirst: i == 0,
              isLast: i == categories.length - 1,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOption(
    AppLocalizations l10n,
    ReportCategory category, {
    required bool isFirst,
    required bool isLast,
  }) {
    final isSelected = category == _selected;
    final label = category.localizedLabel(l10n);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      onTap: () => _select(category),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(category),
        child: Padding(
          // 항목마다 20. 카드의 맨 위·맨 아래만 4를 더 준다 — 둥근 모서리 안쪽에
          // 글자가 붙어 보이지 않게 하는 여백이다.
          padding: EdgeInsets.only(
            left: AppSpacing.horizontal20,
            right: AppSpacing.horizontal20,
            top: AppSpacing.vertical20 + (isFirst ? AppSpacing.vertical4 : 0.0),
            bottom:
                AppSpacing.vertical20 + (isLast ? AppSpacing.vertical4 : 0.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.label16Medium.copyWith(
                    color: widget.isDarkMode
                        ? AppColors.white
                        : AppColors.black,
                  ),
                ),
              ),
              if (isSelected)
                // 색이 SVG에 박혀 있어 colorFilter를 주지 않는다.
                SvgPicture.asset(
                  'assets/icons/icon_check.svg',
                  width: 14.w,
                  height: 14.w,
                  // 밝은 화면에서는 에셋에 박힌 색을 그대로 쓴다. 어두운 화면에서는
                  // 그 색이 배경에 묻혀 보이지 않아 흰색으로 덧칠한다.
                  colorFilter: widget.isDarkMode
                      ? const ColorFilter.mode(AppColors.white, BlendMode.srcIn)
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 카드 테두리와 항목 구분선 색.
  Color get _lineColor =>
      widget.isDarkMode ? AppColors.black800 : AppColors.black100;

  void _select(ReportCategory category) {
    if (_submitting) return;
    VibrationService.instance().buttonTap();

    // 기타는 사유를 반드시 써야 접수된다 — 고른 뒤 아래 버튼을 또 누르게 하면
    // 작성 화면까지 탭이 두 번 든다. 누르는 즉시 작성 화면을 얹는다.
    if (category == ReportCategory.other) {
      setState(() => _selected = category);
      unawaited(_openReasonWriter());
      return;
    }

    setState(() => _selected = category);
  }

  /// 기타 사유 작성 화면을 이 화면 위에 얹는다.
  ///
  /// 이 화면을 스택에 남기는 이유: 작성하다 뒤로 가면 유형 목록으로 돌아와야
  /// 한다. 접수에 성공하면 작성 화면과 이 화면을 함께 닫는다.
  Future<void> _openReasonWriter() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => TextSubmitPage(
          title: l10n.buttonReport,
          label: l10n.fieldReportContentLabel,
          hintText: l10n.fieldReportReasonHint,
          submitText: l10n.buttonReport,
          isDestructive: true,
          isDarkMode: widget.isDarkMode,
          // 서버 검증값과 같은 값이다(api-docs `etcReason.maxLength`). 앱에서
          // 안 막으면 다 쓰고 신고를 누른 뒤에야 400으로 되돌아온다.
          maxLength: _etcReasonMaxLength,
          onSubmit: (text) => _runSubmit(ReportCategory.other, text),
        ),
      ),
    );

    // 작성 화면을 그냥 닫고 돌아온 경우 — 고른 표시를 지워 처음 상태로 되돌린다.
    if (mounted && !_submitting) setState(() => _selected = null);
  }

  void _submit() {
    VibrationService.instance().buttonTap();
    unawaited(_runSubmit(_selected!, null));
  }

  /// 접수하고 이 화면(기타면 작성 화면까지)을 닫는다. 결과 안내는 호출부가 한다.
  Future<void> _runSubmit(ReportCategory category, String? etcReason) async {
    if (_submitting) return;
    setState(() => _submitting = true);

    Object? failure;
    try {
      await widget.submit(category, etcReason);
    } catch (e) {
      failure = e;
    }
    if (!mounted) return;

    final navigator = Navigator.of(context);
    // 기타는 작성 화면이 이 화면 위에 얹혀 있다 — 그것부터 닫는다.
    if (category == ReportCategory.other) navigator.pop();
    navigator.pop(ReportOutcome(failure));
  }
}
